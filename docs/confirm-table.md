Web 程序设计（AI Native） · MyBlog 项目

前八次实战 / Lab 核心任务确认表

学生姓名：____________　　学号：____________　　班级：____________

· 判定规则　每周三项全部通过，记为该周达标。

· 证据标准　每一项都要留下可复查的东西——截图、请求与响应、SQL 结果、commit 记录。口头“能跑”不算证据；HTTP 200 也不等于能力成立。

| 周次 / 能力 | 核心完成任务与验收证据 | 确认 |
| --- | --- | --- |
| Lab 01<br>Week 01<br>Existence<br>存在<br>日期 ________ | ① 项目能独立启动：控制台出现 Tomcat started on port(s): 8080 与 Started MyBlogApplication；此时访问根路径得到 404（服务活着、尚无路由）。<br>证据：控制台两行截图 | □ |
|  | ② GET /hello 返回带本人姓名的文本；DevTools 中该请求为 200 OK，Response 就是自己写的那句话。<br>证据：浏览器截图 + Network 截图 | □ |
|  | ③ GET /me 返回一段自我介绍，并能口述完整链路：URL → 浏览器 → 8080 → @GetMapping → return → 浏览器。<br>证据：截图 + 口述或书面说明 | □ |
| Lab 02<br>Week 02<br>Structured Voice<br>结构化表达<br>日期 ________ | ① 新建 BlogProfile，GET /profile 返回 ≥3 个字段的 JSON（name / owner / message）；DevTools 中 Content-Type 为 application/json。<br>证据：JSON 截图 + 响应头截图 | □ |
|  | ② /me 由 String 升级为 JSON 对象，且仍在 Week01 的同一工程内（未新建项目）。<br>证据：改前/改后对照 | □ |
|  | ③ 完成三个破坏实验并各留一条记录：返回 String 与返回对象的差别、@Controller 与 @RestController 的差别、改字段名导致 JSON key 改变。<br>证据：ai-log.md 三条记录 | □ |
| Lab 03<br>Week 03<br>Identity<br>身份<br>日期 ________ | ① 新建 PersonalProfile，GET /profile 返回 ≥5 个有真实含义的字段（blogName / owner / introduction / interests / vision）。<br>证据：JSON 截图 | □ |
|  | ② /me 与新身份保持一致（未推倒重建）；任选一位同学做 Recognition Test，只读 JSON 能判断这是谁的博客。<br>证据：测试记录 + 改动的字段 | □ |
|  | ③ 完成一次有意义的提交并推送到 GitHub：commit 信息可辨识，能在仓库历史里指出这条 Week03 记录。<br>证据：仓库链接 + commit | □ |
| 实战 04<br>Week 04<br>Listening<br>倾听<br>日期 ________ | ① POST /messages 配合 @RequestBody 接收 JSON，响应中原样带回刚发送的内容（请求头含 Content-Type: application/json）。<br>证据：HTTP 客户端请求 + 响应 | □ |
|  | ② 连发 ≥2 条不同内容，GET /messages 全部列出；GET /messages/{id}（或 ?keyword=）能取回指定一条。<br>证据：列表与单条截图 | □ |
|  | ③ 重启应用后 GET /messages 变空，并能解释“列表活在 JVM 堆内存、随进程消失”；三个 Bug（缺 Content-Type / 键名不匹配但返回 200 / GET 打 POST 端点得到 405、错路径得到 404）均有记录。<br>证据：重启前后对照 + 三条 bug 记录 | □ |
| 实战 05<br>Week 05<br>Structure<br>结构<br>日期 ________ | ① 抽出 MessageService 与 MessageRepository 接口 + InMemoryMessageRepository 实现；Controller 只剩“收请求 → 调 Service → 还响应”，类中不再持有 List。<br>证据：重构后目录结构 + 代码 | □ |
|  | ② 用与重构前完全相同的一组请求（POST / 列表 / 单条）逐条比对，响应完全一致；重构前的基线响应已留存。<br>证据：改前改后两组响应 | □ |
|  | ③ 删掉 @Service 后应用启动失败（required a bean of type 'MessageService'），恢复后能解释“依赖在启动时接线”；并能画出一次请求经过三层的路径图。<br>证据：报错截图 + 层图 | □ |
| 实战 06<br>Week 06<br>Memory<br>记忆<br>日期 ________ | ① 建成 myblog 库与 message 表（utf8mb4），数据源配置可用，Message 实体 + MessageMapper 就位；POST /messages 写入数据库，id 由自增回填。<br>证据：建表语句 + POST 响应含 id | □ |
|  | ② GET 读的是数据库：绕过 API 直接在 MySQL 里 INSERT 一行，GET /messages 能看到它。<br>证据：SQL 与响应截图 | □ |
|  | ③ 重启存活：POST 一条独特内容 → 彻底停止 → 重新启动 → GET，id 与 content 与重启前完全一致；代码中不存在 List 与 MySQL 双写。<br>证据：重启前后两次响应 | □ |
| 实战 07<br>Week 07<br>Discovery<br>发现<br>日期 ________ | ① 配置 MybatisPlusConfig 分页拦截器并生效：控制台可见 COUNT 与带 LIMIT 的两条 SQL；缺它时 selectPage 会静默返回全量。<br>证据：SQL 日志 | □ |
|  | ② keyword 命中与诚实落空：命中项 total 正确且每条都含关键词；不存在的词返回 items: []、total: 0，不报错。<br>证据：两组请求响应 | □ |
|  | ③ 分页与叠加：page/size 切片正确、total 为匹配总数；keyword + page=2 时过滤条件不丢失；POST 与 GET /{id} 行为未变。<br>证据：8 项测试矩阵 | □ |
| 实战 08<br>Week 08<br>Article & Contract<br>资源与契约<br>日期 ________ | ① Article 表 + 实体 + Mapper + Service + Controller 打通全生命周期：POST 发布（返回自增 id）、GET 单篇、PUT 修订后可回读、DELETE 后同 id 返回 404。<br>证据：五组请求响应 | □ |
|  | ② 统一契约：成功与失败都是 {code, message, data} 骨架；Service 抛 NoSuchElementException，由 @RestControllerAdvice 翻译成 404 JSON，不再吐 HTML 错误页。<br>证据：成功体与失败体对照 | □ |
|  | ③ 连续性：GET /messages?keyword=…&page=1&size=5 的 total 与 /profile 响应，与开工前记录逐字一致（两张“照片”相同）。<br>证据：开工前 / 收工后对照 | □ |

汇总与签字

达标周数：________ / 8　　　待补做项：________ 项

教师签字：____________________　　　日期：________________
