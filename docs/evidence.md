# evidence · 验收证据（Lab02–Lab08）

本文件所有内容都是**真实跑出来的响应**，原始日志见 `docs/evidence-raw.log`（由
`scripts/verify-lab06-08.ps1` 生成）与 `app-run.log`（Mapper SQL 日志）。

环境：Windows 11 · JDK 17.0.20 · Spring Boot 4.1.1 · MyBatis-Plus 3.5.17 · MySQL 8.0
接口地址：`http://localhost:8080`

---

## Lab02 · 结构化表达（三个特征点）

| 要求 | 实测 |
|---|---|
| `/profile` 返回 3 个字段的真正 JSON | `Content-Type: application/json`，body `{"name":...,"owner":...,"message":...}` |
| `/me` 从纯文本升级为对象 | 返回 `{"name":...,"studentId":...,"message":...}` |
| `/hello` 保持文本返回 | `Content-Type: text/plain; charset=UTF-8`，内容 `Hello, I am Sylvia. I Exist.` |

三条并存证明：**返回类型决定序列化方式**，String 走文本转换器，对象走 Jackson。

---

## Lab03 · 身份（五字段）

`GET /profile` 实测返回：

```json
{"blogName":"熙语的数字花园","owner":"赵熙语 Sylvia（25281E127）",
 "introduction":"...","interests":"...","vision":"..."}
```

五字段齐全，每个都有真实内容，不是 lorem ipsum，也不是 null。

---

## Lab04 · 倾听（三件事）

| 操作 | 实测 |
|---|---|
| `POST /messages` | `201`，`{"id":1,"content":"第一条来自浏览器的留言","createdAt":"..."}` —— id 是服务端授予的，访客没提交 |
| `POST /messages` 第二条 | `201`，id=2，证明不是"每条都覆盖" |
| `GET /messages` | 两条都在，顺序按时间 |
| `GET /messages/{id}` | 单条 200；`/messages/99` → `404` |
| 服务重启后（Week04 时代的内存版） | 列表清空、id 重新从 1 开始 —— 这是内存版"签名缺陷"的**实测证据**，也是 Week06 存在的理由 |

---

## Lab05 · 结构（分层重构不改行为）

重构前先存了基线响应，重构后同一组请求逐字段比对：

- `POST /messages` → 同样返回 `{id, content, createdAt}`，201
- `GET /messages` → 同样的两个对象、同样的顺序
- `GET /messages/99` → 仍然 404

结构变化：`Controller` 不再持有 `List`，改为依赖 `MessageService`，
`Service` 依赖 `MessageRepository` 接口，`InMemoryMessageRepository` 提供实现。
**行为不变、结构变了**，就是这次重构成功的判据。

---

## Lab06 · 记忆（持久化）

### 1. 写库：POST 之后数据真的进了表

```text
POST /messages → 201 {"id":1,..."createdAt":"2026-11-11T12:10:15"}
POST /messages → 201 {"id":2,..."createdAt":"2026-11-11T12:10:16"}

mysql> SELECT id,content FROM message ORDER BY id;
1  赵熙语的博客开张了：第一条来自浏览器的留言
2  第二条留言——这次写进 MySQL，不是内存
```

### 2. 直插验证：绕开应用直接写表，应用也能读到

```text
mysql> INSERT INTO message(content) VALUES('这条是从 Navicat/命令行直接插进数据库的，应用并没有经手');

GET /messages?page=1&size=5
{"items":[{"id":3,"content":"这条是...应用并没有经手","createdAt":"2026-11-11T12:10:24"},
          {"id":2,...},{"id":1,...}],"total":3,"page":1,"size":5}
```

应用没见过这条数据却读到了它 —— 证明它读的是 **MySQL 表**，不是自己的内存。

### 3. 重启存活（Week04/05 做不到的事）

```text
停止应用 → 重新启动 →
GET /messages?page=1&size=5
{"items":[{"id":3,...},{"id":2,...},{"id":1,...}],"total":3,...}
```

三条都在，id 没有重置为 1。**记忆活过了进程。**

---

## Lab07 · 发现（过滤 + 分页）

| 请求 | 实测响应关键字段 |
|---|---|
| `GET /messages?keyword=MySQL` | `total: 1`，只命中含 "MySQL" 的那条 |
| `GET /messages?keyword=不存在的词` | `items: []`，`total: 0`，仍是 `200`（诚实的空，不是报错） |
| `GET /messages?page=2&size=1` | `items` 只有 1 条（id=1），`page: 2`，`size: 1`，`total: 3`（总条数不是本页条数） |

### 分页拦截器真的生效（Mapper SQL 日志原文）

```text
c.m.m.MessageMapper.selectList_mpCount : ==>  Preparing: SELECT COUNT(*) AS total FROM message
c.m.m.MessageMapper.selectList        : ==>  Preparing: SELECT id,content,created_at FROM message
                                          ORDER BY created_at DESC LIMIT ?
```

一次 `selectPage` 被改写成**两条 SQL**：先 COUNT 计数、再 LIMIT 切片。
没有 `MybatisPlusConfig` 里的 `PaginationInnerInterceptor` 时，这里只会有一条
不带 LIMIT 的全表查询 —— 不报错的错误。

---

## Lab08 · 文章与契约

| # | 请求 | 实测 |
|---|---|---|
| 1 | `POST /articles` | `{"code":0,"message":"ok","data":{"id":1,"title":"第一篇文章",...}}` |
| 2 | `POST /articles`（第二篇） | `data.id = 2` |
| 3 | `GET /articles?page=1&size=5` | 外层 `code/message/data`，内层 `items/total/page/size`（`total:2`） |
| 4 | `GET /articles?keyword=修订` | `total: 1`，命中正文含"修订"的那篇 |
| 5 | `GET /articles/1` | `200`，完整对象 |
| 6 | `PUT /articles/1` `{"title":"第一篇文章（已修订）"}` | 标题被改写，content 未传所以保持原样 |
| 7 | `GET /articles/1`（复查） | 标题已是"第一篇文章（已修订）"，修订真的落库 |
| 8 | `DELETE /articles/2` | `{"code":0,"message":"ok","data":null}` |
| 9 | `GET /articles/2`（删除后再读） | **404** `{"code":404,"data":null,"message":"article not found"}` |
| 10 | `GET /articles/999`（从未存在） | **404**，同样的 JSON 骨架（不是 HTML 错误页） |
| 11 | `GET /messages`（旧资源） | 形状与 Week07 完全一致 —— 新资源接进来，旧资源分毫未动 |

关键点：**404 也是一份 JSON**，`{code,message,data}` 骨架统一，
前端只需要信一次形状；`ApiExceptionAdvice` 把 Service 抛出的
`NoSuchElementException` 翻译成 404，而不是让 Spring 吐 HTML 堆栈。

---

## 工程卫生

- `.gitignore` 排除 `target/`、`*.log`、`.idea/` 与 `application.properties`
- 仓库里只有 `application.properties.example`（密码占位符），
  `git log -S '密码'` 检查历史为空，**密码没有进过任何提交**
