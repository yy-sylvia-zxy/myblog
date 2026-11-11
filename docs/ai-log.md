# ai-log · 破坏性实验与 Bug 记录

记录规则：只写真实发生过的现象（谁改的、改成什么、屏幕上出现了什么、为什么）。
"理论上会……"不算记录。

---

## Lab02 · 三个破坏实验

### 记录 1：返回 String 与返回对象的差别

- 改动：`/hello` 仍返回 `String`，`/profile` 返回 `BlogProfile` 对象。
- 现象（实测响应头）：
  - `GET /hello` → `200 | Content-Type: text/plain; charset=UTF-8` → `Hello, I am Sylvia. I Exist.`
  - `GET /profile` → `200 | Content-Type: application/json` → `{"name":...,"owner":...,"message":...}`
- 结论：`@RestController` 把返回值写进响应体，但**写什么格式取决于返回类型**。
  String 走 `StringHttpMessageConverter`（纯文本）；对象走 `Jackson`（JSON）。
  想让浏览器/前端"读懂结构"，返回的就必须是对象，而不是拼好的字符串。

### 记录 2：@Controller 与 @RestController 的差别

- 改动：把 `HelloController` 上的 `@RestController` 换成 `@Controller`。
- 现象（预期与原理）：方法返回值不再被写进响应体，而是被当成"视图名"，
  Spring 会去找模板（`profile`、`hello`），找不到就报
  `Circular view path` / `404` —— 屏幕上不再出现 JSON。
- 原因：`@RestController = @Controller + @ResponseBody`。
  少了 `@ResponseBody`，`return 对象` 就不再等于"把对象序列化进响应体"。
- 结论：写 REST 接口，注解写错一个字母，行为就从"返回数据"变成"找页面"。

### 记录 3：改字段名导致 JSON key 改变

- 改动：把 `BlogProfile` 的 `owner` 字段改名为 `author`（不改变量类型、不改值）。
- 现象（预期与原理）：`/profile` 返回的 JSON 里 key 从 `"owner"` 变成 `"author"`，
  值一个字没变，但前端的 `data.owner` 立刻取不到东西（`undefined`）。
- 原因：Jackson 序列化时**用字段名（或 getter 名）当 key**，
  Java 里改个名字，接口契约就变了 —— 这就是为什么后面 Week08 要把
  "门口的话"统一成 `{code,message,data}` 骨架：让前端只需要信一次形状。
- 结论：字段名不是"内部实现"，对 REST 接口来说它就是公开 API。

---

## Lab04 · 三个 Bug

### Bug 1：POST 时缺 `Content-Type: application/json`

- 现象：请求体明明是 `{"content":"..."}`，服务端却回 `415 Unsupported Media Type`。
- 原因：`@RequestBody` 需要一个能把"字节流"翻译成对象的转换器，
  Spring 靠 `Content-Type` 决定用哪个（这里是 Jackson 的 JSON 转换器）。
  没这个头，它不知道这堆字节是什么格式，只能拒绝。
- 修法：请求头补上 `Content-Type: application/json`。

### Bug 2：JSON 键名不匹配 —— 真正的现象是 500，不是 200

- 现象（2026-11-11 实测，MySQL 版）：发 `{"text":"hello"}`
  → `500 Internal Server Error`，响应体是 Spring 默认错误骨架
  `{"timestamp","status":500,"error":"Internal Server Error","path":"/messages"}`。
- 原因：Jackson 不认识 `text` 这个键，**静默忽略**，`MessageRequest.content` 保持 `null`；
  HTTP 层面语法没错，请求确实被受理，但 `null` 一路走到 `INSERT`，
  撞上 `content VARCHAR(1000) NOT NULL` 约束 → 抛异常 → 500。
- 修正一处旧记录：Week04 内存版时代记的是"返回 200、content 为 null"，
  因为内存 List 什么都能装。接上 MySQL 后，同类错误被数据库约束拦下，
  **存储层的约束把"业务沉默"变成了"显式失败"**。
- 结论：`200` 只代表"请求被受理"，不代表"业务成立"；判据要看响应体里的数据，
  以及是否真的落库。校验要写在 Service 里，别指望状态码替你说活。

### Bug 3：GET 打 POST 端点 405 / 错路径 404

- 现象：
  - `GET /messages` 正常；用 `GET` 去访问只声明了 `@PostMapping` 的路径 → `405 Method Not Allowed`。
  - 路径拼错（例如 `/message` 少个 s）→ `404 Not Found`。
- 原因：Spring 先按路径匹配到处理方法，再比对 HTTP 方法；
  路径对、方法不对 → 405；路径根本不存在 → 404。
- 结论：405 和 404 是两种不同的事实，别混着说"打不开"。

---

## Lab05 · 删除 @Service 的破坏实验

- 改动：注释掉 `MessageService` 上的 `@Service`。
- 现象（预期与原理）：启动阶段直接失败，报
  `Parameter 0 of constructor in com.myblog.controller.MessageController required a bean of type 'com.myblog.service.MessageService' that could not be found.`
- 原因：`MessageController` 构造器要求一个 `MessageService`，
  而没有 `@Service` 就没有这个 Bean，依赖**在启动时**接线，接不上就启动失败。
- 恢复：加回 `@Service`，启动正常。
- 结论：依赖注入的错误在"启动时"暴露，比在"第一次请求时"暴露幸运得多。

---

## Lab04 · 重启失忆（实测）

- 操作：先 POST 两条留言（id 1、2），`GET /messages` 能看到两条；
  停止应用、重新启动后再 `GET /messages`。
- 现象：列表变成空的；再 POST 一条，id 又从 **1** 开始。
- 原因：Week04/05 的留言住在 `InMemoryMessageRepository` 的 `ArrayList` 里，
  也就是 JVM 的**堆内存**；进程结束，堆就没了。JVM 一重启，内存就是一张白纸。
- 结论：这正是 Week06 要把数据搬进 MySQL 的理由 —— 需要"活过进程"的记忆。

---

## Lab06 · 三个 Bug

### Bug 4：改了代码，屏幕上还是旧行为（8080 被旧进程占着）

- 现象：重新 `spring-boot:run` 之后，轮询 `/hello` 第一次就返回 200，
  但 `/messages` 的行为和上一版一模一样，新加的 Mapper 完全没有出现。
- 原因：上一周的实例还活着并占着 8080 端口；新进程要么绑定失败、
  要么根本没抢到端口。我看到的 200 是**旧进程**的回答。
- 教训：`200` 只证明"有人在这个端口上服务"，不证明"我这次的改动生效了"。
  验证改动要看**版本特征**（新字段、新字段名、新日志），而不是看状态码；
  动手前先确认端口上没有遗留进程。

### Bug 5：`mysql -e "source 中文路径/schema.sql"` 打不开文件

- 现象：`ERROR at line 1: Failed to open file '...\schema.sql', error: 2`。
- 原因：路径里有中文目录 + 反斜杠，mysql 客户端把它当成了自己的相对路径解析。
- 修法：干脆不 source，直接用 `mysql -e "CREATE TABLE ..."` 把 DDL 写进去。
- 教训：踩到"工具读不到我的文件"时，先怀疑路径写法，不要怀疑表结构写错。

### Bug 6：异常面前，Spring 默认给出的是 500 和另一套骨架

- 实测（注释掉 `ApiExceptionAdvice` 后）：`GET /articles/999` 返回
  `500`，body 是 `{"timestamp":...,"status":500,"error":"Internal Server Error","path":"/articles/999"}`，
  控制台里是 `java.util.NoSuchElementException: article not found` 的完整堆栈。
- 原因：`NoSuchElementException` 没有对应的 `@ExceptionHandler`，
  Spring Boot 走了默认错误处理，于是"东西不存在"被当成"服务器坏了"，
  骨架也从 `code/message/data` 变成 `timestamp/status/error/path`。
- 修法：`ApiExceptionAdvice` 用 `@RestControllerAdvice` 接住它，
  `@ResponseStatus(404)` + `Result.fail(404, ...)`；还原后同一请求变成
  `404 + {"code":404,"data":null,"message":"article not found"}`。
- 结论：**"错误也是接口契约的一部分"** —— 成功和失败必须长同一个样子。
  （顺带纠正一个常见说法：Boot 默认错误体在这里是 JSON 不是 HTML，
  具体形态取决于版本与 `Accept` 头，不能当定理背。）

---

## Lab07 · 一个"不报错的错误"

- 实测（注释掉 `MybatisPlusConfig` 里的 `PaginationInnerInterceptor`）：
  请求 `GET /messages?page=2&size=1`，返回 **200**，
  `items` 却是**全部 3 条**，`size=1` 完全没生效，`total` 是 **0**。
- 同一请求在数据库层只发出了一条 SQL，**没有 COUNT、没有 LIMIT**：
  `SELECT id,content,created_at FROM message ORDER BY created_at DESC`
- 还原拦截器后同一请求：`items` 只有 1 条（id=2），`total: 3`，
  SQL 变成 `SELECT COUNT(*) AS total FROM message` + `... LIMIT ?,?` 两条。
- 结论：最危险的 bug 是不报错的 bug。判断分页真假，要去日志里
  **亲眼看见 LIMIT**，不能只看返回条数"看起来变少了"。

---

## Lab07 的坑中坑：改回来了，却没生效

- 现象：第一次做破坏实验时，"还原拦截器后"的响应仍然和破坏时一模一样（`total: 0`）。
- 原因：用 `Copy-Item` 把 `.bak` 还原回去时，目标文件**沿用了备份的旧时间戳**；
  Maven 按时间戳判断是否需要重编译，认定源文件没变新 → **跳过编译** →
  跑的还是旧 class。
- 修法：还原后把文件时间戳推到当前（或 `mvn clean compile`），强制重编译，
  第二次验证才拿到真实的"还原后"行为。
- 结论：破坏实验最怕的不是改坏，而是**改回来了却没生效** —— 那就成了一假的记录。
  判断依据永远是行为指纹（`total`、`LIMIT`、404 骨架），而不是"我把文件改回去了"这个动作。


---

## Lab08 · 实测（含一次真实修错）

- 现象：验收脚本在"删除后再读"这条用例上抛出
  `Method invocation failed because [HttpResponseMessage] does not contain a method named 'GetResponseStream'`。
- 原因：PowerShell 7 的 `Invoke-WebRequest` 抛出的异常里，响应体不在
  `Response.GetResponseStream()`，而在 `$_.ErrorDetails.Message`。
- 修法：脚本的错误分支改成读 `ErrorDetails.Message`，
  再跑一次，404 用例的输出就是干净的 JSON 骨架。
- 结论：连"抓证据的脚本"本身也会写错 —— 所以要能区分
  "服务端返回错了" 和 "我没有正确读到服务端的返回"。

