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

### Bug 2：JSON 键名不匹配，却仍然返回 200

- 现象：发 `{"text":"hello"}`，接口返回 `200`，但 `content` 是 `null`
  （后续 Week07 起会因为 `content` 为空被业务规则拦下）。
- 原因：Jackson 找不到 `text` 对应的字段，于是**静默忽略**，
  `MessageRequest.content` 保持 `null`。HTTP 协议层面没有任何错，所以是 200。
- 结论：`200` 只代表"服务器受理了"，不代表"业务成立"。这就是为什么
  Service 里要有 `content 不能为空` 的校验 —— 校验是业务在说话，状态码不会说话。

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

## Lab06–Lab08 · 待补（数据库配置完成后逐条补记录）

> 备注：这一段的实验要在数据源接通之后才有意义（POST 写库、直插验证、重启存活、
> 分页拦截器的 COUNT+LIMIT、Article 全生命周期、advice 的 404）。
> 每一条实际跑完都会把"请求 / 响应 / SQL 日志"原文贴进 `docs/evidence.md`。
