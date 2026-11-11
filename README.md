# MyBlog

Web 程序设计（AI Native）课程项目 · 八周累进式实战

- 姓名：赵熙语（Sylvia）
- 学号：25281E127
- 技术栈：Java 17 · Spring Boot 4.1.1 · Maven · MyBatis-Plus 3.5.17 · MySQL 8.0

## 这个项目在做什么

MyBlog 不是八个互不相干的小练习，而是一个从 Week01 一路"长大"的数字自我：

| 周次 | 能力 | 这一周学到的东西 | 关键路由 |
| --- | --- | --- | --- |
| Lab01 | Existence 存在 | 项目能启动、能响应，URL → Controller → return 的链路 | `GET /hello` |
| Lab02 | Structured Voice 结构化表达 | 从"说一句话"到"说一个对象"，Jackson 把对象变 JSON | `GET /profile`、`GET /me` |
| Lab03 | Identity 身份 | 五个字段说清"这是谁的博客" | `GET /profile` |
| Lab04 | Listening 倾听 | `POST` + `@RequestBody`，访客的话被收下并编号 | `POST/GET /messages` |
| Lab05 | Structure 结构 | 抽出 Service / Repository，Controller 只做接待 | 同上（行为不变） |
| Lab06 | Memory 记忆 | 数据搬进 MySQL，重启不再失忆 | 同上（数据存活） |
| Lab07 | Discovery 发现 | 关键词 + 分页，过滤切片计数交给数据库 | `GET /messages?keyword=&page=&size=` |
| Lab08 | Article & Contract 资源与契约 | 第二个资源走完发布/读取/修订/撤回；响应统一成 `{code,message,data}` | `/articles` |

## 目录结构（分层）

```
src/main/java/com/myblog/
├── MyblogApplication.java        启动类（根包 = com.myblog，决定组件扫描范围）
├── config/MybatisPlusConfig.java 分页拦截器
├── controller/                   前台：只收参数、喊 Service、还响应
│   ├── HelloController.java      /hello、/me、/profile
│   ├── MessageController.java    /messages
│   ├── ArticleController.java    /articles
│   └── ApiExceptionAdvice.java   统一把"找不到"翻译成 404 JSON
├── service/                      大脑：业务规则（校验、条件拼装、找不到怎么办）
│   ├── MessageService.java
│   └── ArticleService.java
├── repository/                   Lab05 的存储边界（Lab06 起由数据库实现接替）
│   ├── MessageRepository.java
│   ├── InMemoryMessageRepository.java   内存版（已停用，留作 Week05 证据）
│   └── DbMessageRepository.java         MySQL 版
├── mapper/                       传声筒：extends BaseMapper，一行 SQL 都不写
│   ├── MessageMapper.java
│   └── ArticleMapper.java
├── model/                        实体与 DTO
└── dto/                          Result（统一契约）、PageResult（分页载荷）
```

一次请求经过的路径：

```
浏览器 → Tomcat:8080 → Controller（前台）
                              ↓ 调用
                       Service（业务规则）
                              ↓ 调用
                       Mapper / Repository（存储）
                              ↓
                          MySQL 表
```

## 运行方式

1. 建库建表：`mysql -u root -p < db/schema.sql`
2. 配数据源：`src/main/resources/application.properties` 填写 `spring.datasource.password`
3. 启动：`mvn spring-boot:run`（或在 IDEA 里直接运行 `MyblogApplication`）
4. 访问：<http://localhost:8080/hello>

## 接口一览

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/hello` | 纯文本问候（Lab01） |
| GET | `/me` | 我的 JSON 身份 |
| GET | `/profile` | 博客五字段名片 |
| POST | `/messages` | 提交留言 `{"content":"..."}`，返回 201 与自增 id |
| GET | `/messages?keyword=&page=&size=` | 列表 / 搜索 / 分页，返回 `{items,total,page,size}` |
| GET | `/messages/{id}` | 单条留言，找不到 404 |
| POST | `/articles` | 发布文章 `{"title":"...","content":"..."}` |
| GET | `/articles?keyword=&page=&size=` | 文章列表（外层 `Result`，内层分页） |
| GET | `/articles/{id}` | 读单篇 |
| PUT | `/articles/{id}` | 修订文章 |
| DELETE | `/articles/{id}` | 撤回文章，删除后再读返回 404 JSON |

## 学习记录

- `docs/ai-log.md` —— 破坏性实验与 Bug 记录（我改坏了什么、现象是什么、为什么）
- `docs/reflection.md` —— 每周反思（我自己写的部分用「我」开头，AI 辅助的部分另有标注）
