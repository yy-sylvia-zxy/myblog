# evidence-destructive · 两次破坏性实验的原始记录

对象：`MybatisPlusConfig`（分页拦截器）、`ApiExceptionAdvice`（统一异常处理）。
方法：注释掉关键行 → 重启 → 发请求 → 还原 → 重启 → 再发请求。
原始日志：`docs/evidence-destructive.log`、`run-*.log`（Mapper SQL 输出）。

---

## 实验 A：注释掉 `PaginationInnerInterceptor`

请求：`GET /messages?page=2&size=1`（期望只有 1 条、total = 3）

```text
status=200 | Content-Type=application/json
{"items":[ {"id":3,...}, {"id":2,...}, {"id":1,...} ],"total":0,"page":2,"size":1}
```

- 一次请求回来了 **3 条**（整张表），`size=1` 完全没有生效
- `total` 是 **0** —— 拦截器没做事，Page 对象里的 total 根本没被填
- 状态码仍然是 **200**

同一次请求在数据库里发出的 SQL（只有一条，没有 LIMIT、没有 COUNT）：

```text
Preparing: SELECT id,content,created_at FROM message ORDER BY created_at DESC
```

## 实验 B/E：还原拦截器后

```text
status=200
{"items":[{"id":2,"content":"第二条留言——这次写进 MySQL，不是内存",...}],"total":3,"page":2,"size":1}
```

SQL 变成两条，`LIMIT ?,?` 出现了：

```text
Preparing: SELECT COUNT(*) AS total FROM message
Preparing: SELECT id,content,created_at FROM message ORDER BY created_at DESC LIMIT ?,?
```

**结论**：分页不是"看起来少了几条"，而是数据库里真的多了一句 `LIMIT`。
看不见 `LIMIT` 的分页，就是假的。

---

## 实验 C：注释掉 `@RestControllerAdvice`

请求：`GET /articles/999`（期望 404 + `{code,message,data}`）

```text
status=500 | Content-Type=application/json
{
  "timestamp": "2026-11-11T04:57:26.580Z",
  "status": 500,
  "error": "Internal Server Error",
  "path": "/articles/999"
}
```

同一实例日志里的异常原文：

```text
ERROR ... Servlet.service() for servlet [dispatcherServlet] threw exception
    [Request processing failed: java.util.NoSuchElementException: article not found]
java.util.NoSuchElementException: article not found
```

三点值得记：

1. "文章不存在"本来是 **404**（客户端要找的东西没有），
   但因为没人接话，变成了 **500**（服务器自己出错了）。同一件事，两种含义。
2. 骨架换了：`timestamp/status/error/path`（Spring 默认错误体），
   不是我们的 `code/message/data` —— 前端要多写一套解析。
3. 断言的"HTML 错误页"并没有出现，Spring Boot 4 默认给的是 **JSON**。
   所以课程里说的"吐 HTML 堆栈"要看具体版本与 Accept 头，不能当定理背。

## 实验 D/E：还原 advice 后

```text
404 |
{
  "code": 404,
  "data": null,
  "message": "article not found"
}
```

---

## 这次踩到的坑（值得记住）

**还原文件后行为没有变**：第一次跑完 A/B，发现"还原后"的响应和"破坏时"一模一样
（`total` 还是 0）。原因不是代码没改回来，而是：

- 用 `Copy-Item` 还原 `.bak` 时，**目标文件沿用了备份的时间戳**（比已编译的
  `target/classes` 里那个 class 还旧）；
- Maven 是"按时间戳判断要不要重编译"的，看到源文件没变新，就**跳过了编译**；
- 于是"还原后"的请求，其实还在跑**旧 class**。

修法：还原后把文件时间戳推到当前（或 `mvn clean compile`），强制重新编译。
第二次验证才拿到真正的"还原后"行为。

教训：破坏实验最怕的不是改坏，而是**改回来了却没生效**——
那就成了一份假的实验记录。判断依据永远是"行为指纹"（`total`、`LIMIT`、404 骨架），
而不是"我把文件改回去了"这个动作本身。
