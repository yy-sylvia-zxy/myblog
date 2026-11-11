# MyBlog 前八次实战 · 核心任务确认结果

> 依据《MyBlog_前八次实战核心任务确认表》逐条核对。
> 判定规则：每周三项全部通过记为该周达标。
> 核对时间：2026-11-11；工程：`myblog`（IDEA，Spring Boot 4.1.1 + MyBatis-Plus 3.5.17 + MySQL 8.0）。
> 原始响应与命令输出：`docs/confirm-evidence.log`、`docs/confirm-evidence2.log`、`docs/evidence-raw.log`、`docs/evidence-destructive.log`。

## 汇总

| 项目 | 结果 |
| --- | --- |
| 达标周数 | **7 / 8** |
| 已通过验收点 | **23 / 24** |
| 待补做项 | **1 项**：Lab03 ② Recognition Test（需找一位同学，只读 JSON 判断是谁的博客） |
| 附带说明 | 多项证据目前是"命令行请求 + 响应原文"，老师要的"浏览器 / DevTools 截图"需在本机补拍（接口本身已验证） |

---

## Lab 01 · 存在（Existence）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | 独立启动 + 根路径 404 | **达标** | 启动日志 `Started MyblogApplication in 2.636 seconds`；`GET /` → **HTTP 404** `{"timestamp","status":404,"error":"Not Found","path":"/"}`（服务活着、尚无路由） |
| ② | `GET /hello` 带本人姓名文本 | **达标** | `HTTP 200 | Content-Type: text/plain; charset=UTF-8`，响应体 `Hello, I am Sylvia. I Exist.` |
| ③ | `GET /me` 自我介绍 + 能口述链路 | **达标** | `HTTP 200 | application/json`，`{"name":"赵熙语（Sylvia）","studentId":"25281E127","major":"计算机科学与技术","message":"..."}`；链路口述见本文末"一次请求走过的路" |

## Lab 02 · 结构化表达（Structured Voice）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | `BlogProfile` + `GET /profile` ≥3 字段 JSON | **达标** | `BlogProfile` 三字段 `name/owner/message`（public 字段，示例"字段名即 JSON key"）；`/profile` 现由 Lab03 的 `PersonalProfile` 承接，返回 5 字段；`Content-Type: application/json` |
| ② | `/me` 由 String 升级为对象，仍在同一工程 | **达标** | commit `8bac5e7`（lab02）；改前 `text/plain`、改后 `application/json`，同一 `HelloController` 内并存 `/hello` 与 `/me` 两个返回类型 |
| ③ | 三个破坏实验各一条记录 | **达标（本次全部实测）** | ① String vs 对象：`/hello` → `text/plain`，`/profile` → `application/json` ② `@RestController` 改 `@Controller`：`GET /hello` → **404 + Spring 默认错误骨架**（返回值被当成视图名去找页面，找不到）③ `PersonalProfile.owner` 改名 `author`：`/profile` 的 key 立刻从 `owner` 变 `author`，值不变 |

## Lab 03 · 身份（Identity）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | `PersonalProfile` 五字段 | **达标** | `blogName / owner / introduction / interests / vision` 全部有真实内容，`owner` 为"赵熙语 Sylvia（25281E127）" |
| ② | `/me` 与新身份一致 + Recognition Test | **部分达标 → 待补做** | `/me` 与 `/profile` 同时给出姓名与学号，未推倒重建（同一 Controller、同一工程）；**Recognition Test 需一位同学只读 JSON 判断"这是谁的博客"，只能由你完成** |
| ③ | 有意义提交 + 推送 GitHub | **达标** | commit `ad85f3e` `lab03: 身份 - 新增 PersonalProfile 五字段…`；仓库 <https://github.com/yy-sylvia-zxy/myblog> |

## 实战 04 · 倾听（Listening）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | `POST /messages` + `@RequestBody` 原样带回 | **达标** | `POST /messages` → **201**，响应 `{"id":6,"content":"确认表取证：这一条来自 11 月 11 日自检","createdAt":"..."}`，content 与请求体逐字相同 |
| ② | 连发 ≥2 条 + 列表 + 单条 | **达标** | `GET /messages?page=1&size=5` 列出多条（id 1–6）；`GET /messages/1` → `{"id":1,"content":"赵熙语的博客开张了…"}`` |
| ③ | 重启后列表变空 + 三个 Bug 记录 | **达标（历史证据 + 本次复演）** | 重启变空发生在 Week04 内存版（见 `docs/evidence.md` 对照表；内存版代码在 commit `850d6ba`，可用 `git worktree` 在 8081 现场重演）。三个 Bug 本次全部实测：缺 `Content-Type` → **415**；键名 `text` 写错 → **500**（NOT NULL 约束拦下，`ai-log.md` 已修正旧记录）；`PUT /messages` → **405**、`/message` → **404** |

## 实战 05 · 结构（Structure）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | Service + Repository + 实现；Controller 不持 List | **达标** | `service/MessageService`、`repository/MessageRepository` 接口、`repository/InMemoryMessageRepository`；`MessageController` 只有"收请求 → 调 Service → 还响应" |
| ② | 重构前后同一组请求响应一致 + 基线留存 | **达标** | `docs/evidence.md` 的 Lab05 对照表：同一组 POST / 列表 / 单条，改前改后状态码与字段逐项相同 |
| ③ | 删 `@Service` 启动失败 + 能解释依赖接线 | **达标（本次实测）** | 注释掉 `@Service` 后：`APPLICATION FAILED TO START`，`Parameter 0 of constructor in com.myblog.controller.MessageController required a bean of type 'com.myblog.service.MessageService' that could not be found.`；还原后 `GET /messages` → 200 |

## 实战 06 · 记忆（Memory）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | myblog 库 + message 表（utf8mb4）+ Mapper + id 自增回填 | **达标** | `db/schema.sql` 建库建表；`POST /messages` → 201 且 `id` 由数据库自增回填（id 1…6 连续） |
| ② | 读的是数据库：绕过 API 直插一行 | **达标** | 命令行 `INSERT INTO message(content) VALUES('这条是从命令行直接插进数据库的…')` 后，`GET /messages` 读到 `id=3` 这条，应用并未经手 |
| ③ | 重启存活 + 无 List/MySQL 双写 | **达标** | 杀进程重启后 3 条仍在、id 未重置；`MessageService` 只依赖 `MessageMapper`，全项目无内存列表写入路径（`InMemoryMessageRepository` 的 `@Repository` 已注释，不参与装配） |

## 实战 07 · 发现（Discovery）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | 分页拦截器生效：COUNT + LIMIT；缺它静默全量 | **达标** | 有拦截器：`SELECT COUNT(*) AS total FROM message` + `… ORDER BY created_at DESC LIMIT ?,?`；注释掉 `PaginationInnerInterceptor` 后：`page=2&size=1` 仍 **200**，但返回全部 3 条、`total: 0`，SQL 只剩一条不带 COUNT/LIMIT 的 SELECT |
| ② | keyword 命中与诚实落空 | **达标** | `?keyword=MySQL` → `total:2`，两条都含 "MySQL"；`?keyword=zzzznotexist` → `{"items":[],"total":0}`，**200 不报错** |
| ③ | 分页与叠加 + 旧行为不变（8 项矩阵） | **达标（本次 8 项全跑）** | M1 `page=1&size=5` 200；M2 `page=2&size=2` → 2 条、`total:5`；M3 `keyword=MySQL` → `total:2`；**M4 `keyword=MySQL&page=2&size=1` → 1 条、`total:2`（过滤条件未丢）**；M5 空词 → `items:[]`；M6 `size=1000` 不崩；M7 `GET /messages/1` 200；M8 `POST` 201 |

## 实战 08 · 资源与契约（Article & Contract）

| # | 验收点 | 结论 | 证据 |
| --- | --- | --- | --- |
| ① | 文章全生命周期五组请求 | **达标（本次重跑）** | `POST /articles` → `{"code":0,"data":{"id":4,...}}`；`GET /articles/4` 200；`PUT` 改标题 → 200；回读得到修订后标题；`DELETE` 200；再读 → **404** |
| ② | 统一契约 + `@RestControllerAdvice` 翻译 404 | **达标** | 失败体统一为 `{"code":404,"data":null,"message":"article not found"}`，不是 Spring 默认骨架；注释掉 advice 的对照见 `docs/evidence-destructive.md` |
| ③ | 连续性：新旧接口"两张照片"一致 | **达标（本次实拍）** | 先记 `GET /messages?keyword=MySQL&page=1&size=5` 与 `GET /profile`，再跑完文章 CRUD，再读：两份响应**逐字相同**（`messages 逐字一致 = True`、`profile 逐字一致 = True`）。快照文件 `docs/snapshot-after.json` |

---

## 需要你本人补的一件事

**Lab03 ② 的 Recognition Test**：找一位同学，只给他看下面这段 JSON，不许看页面、不许看仓库：

```json
{"blogName":"Sylvia 的数字角落","owner":"赵熙语 Sylvia（25281E127）","introduction":"…","interests":"Java、Spring Boot、数据结构与算法、摄影、英语","vision":"…"}
```

让他说出"这是谁的博客"。**判断对**即为通过；留一条记录：日期 + 同学姓名（或化名）+ 他的判断 + 你改了哪几个字段（`owner` 里补学号、`interests` 里加摄影与英语）。这一项我替你做不了——它验证的是"信息足够让人认出你"，不是程序行为。

## 截图补拍清单（3 分钟）

接口结果都已实测，但确认表要"截图"形态：

1. IDEA 控制台两行：`Tomcat started on port(s): 8080` 与 `Started MyblogApplication`
2. 浏览器打开 `/hello`、`/me`、`/profile`，各截一张（F12 → Network 里再看 `Content-Type` 与状态码）
3. MySQL 命令行 `SELECT * FROM message;` 截一张

## 一次请求走过的路（Lab01 ③ 口述用）

`浏览器输入 http://localhost:8080/hello`
→ DNS 解析到 127.0.0.1、TCP 连 8080（Tomcat 在听）
→ Tomcat 把请求交给 Spring 的 `DispatcherServlet`
→ 它按"路径 + 方法"在映射表里找到 `HelloController.hello()`（由 `@GetMapping("/hello")` 登记的）
→ 反射调用该方法，拿到返回的 `String`
→ `@RestController` 让 `StringHttpMessageConverter` 把它直接写进响应体，`Content-Type: text/plain`
→ 浏览器收到 200 与那句话并渲染出来。

三层结构版（Lab05 之后）在中间多两步：Controller → Service（业务决定）→ Repository/Mapper（存取）。
