package com.myblog.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.myblog.dto.PageResult;
import com.myblog.dto.Result;
import com.myblog.model.Article;
import com.myblog.service.ArticleService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Lab08 · 文章前台：收参数 → 喊 Service → 套 Result 送客。
 *
 * 一行 SQL 不出现（Week05 立的规矩），一处裸对象不返回（Week08 的新规矩）。
 */
@RestController
@RequestMapping("/articles")
public class ArticleController {

    private final ArticleService articleService;

    public ArticleController(ArticleService articleService) {
        this.articleService = articleService;
    }

    /** 发布：POST /articles  body {"title":"...","content":"..."} */
    @PostMapping
    public Result<Article> create(@RequestBody Article article) {
        return Result.ok(articleService.create(article));
    }

    /**
     * 发现：GET /articles?keyword=&page=&size=
     * 双层载荷：外层 Result（契约骨架），内层 PageResult（四格分页）。
     */
    @GetMapping
    public Result<PageResult<Article>> list(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") long page,
            @RequestParam(defaultValue = "5") long size) {
        Page<Article> result = articleService.search(keyword, page, size);
        return Result.ok(PageResult.of(result));
    }

    /** 读单篇：GET /articles/{id}（找不到由 advice 统一变 404 JSON）。 */
    @GetMapping("/{id}")
    public Result<Article> getOne(@PathVariable Long id) {
        return Result.ok(articleService.getById(id));
    }

    /** 修订：PUT /articles/{id} —— 第一个 update 动词。 */
    @PutMapping("/{id}")
    public Result<Article> update(@PathVariable Long id, @RequestBody Article patch) {
        return Result.ok(articleService.update(id, patch));
    }

    /** 撤回：DELETE /articles/{id}，成功返回 code=0、data=null。 */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        articleService.delete(id);
        return Result.ok(null);
    }
}
