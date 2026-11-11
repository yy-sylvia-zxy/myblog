package com.myblog.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.myblog.mapper.ArticleMapper;
import com.myblog.model.Article;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.NoSuchElementException;
import java.util.Optional;

/**
 * Lab08 · 文章业务员（Mapper 直达，与 MessageService 同一门派）。
 *
 * 职责：业务决策（校验、条件拼装、找不到怎么办）。
 * 不写 SQL，不碰 HTTP。
 * 找不到时抛 NoSuchElementException —— 翻译成 404 是"门口"的事，
 * 这是 Week07"Service 不撒谎、Controller 决定表达"的延续。
 */
@Service
public class ArticleService {

    private final ArticleMapper articleMapper;

    public ArticleService(ArticleMapper articleMapper) {
        this.articleMapper = articleMapper;
    }

    /** 发布（POST /articles）：主键由 MySQL 自增回填。 */
    public Article create(Article article) {
        if (article.getTitle() == null || article.getTitle().isBlank()) {
            throw new IllegalArgumentException("title 不能为空");
        }
        if (article.getContent() == null || article.getContent().isBlank()) {
            throw new IllegalArgumentException("content 不能为空");
        }
        if (article.getCreatedAt() == null) {
            article.setCreatedAt(LocalDateTime.now());
        }
        articleMapper.insert(article);
        return article;
    }

    /** 读单篇：查不到就抛 NoSuchElementException（交给 advice 变 404）。 */
    public Article getById(Long id) {
        return Optional.ofNullable(articleMapper.selectById(id))
                .orElseThrow(() -> new NoSuchElementException("article not found"));
    }

    /**
     * 修订（PUT /articles/{id}）—— 八周以来第一个 update 动词。
     * 只覆盖传进来的字段（null = 这次不改），其余保持原样。
     */
    public Article update(Long id, Article patch) {
        Article existing = getById(id);          // 复用"找不到就抛"的逻辑
        if (patch.getTitle() != null) {
            existing.setTitle(patch.getTitle());
        }
        if (patch.getContent() != null) {
            existing.setContent(patch.getContent());
        }
        articleMapper.updateById(existing);
        return existing;
    }

    /** 撤回（DELETE /articles/{id}）：删不到（0 行）也视为找不到。 */
    public void delete(Long id) {
        int rows = articleMapper.deleteById(id);
        if (rows == 0) {
            throw new NoSuchElementException("article not found");
        }
    }

    /**
     * 发现列表（GET /articles?keyword=&page=&size=）。
     * Week07 的"发现肌肉"原样平移：keyword 命中标题或正文其一；
     * 过滤、切片、计数全在 MySQL（拦截器切成 COUNT + LIMIT 两条 SQL）。
     */
    public Page<Article> search(String keyword, long page, long size) {
        LambdaQueryWrapper<Article> qw = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            qw.like(Article::getTitle, keyword)
              .or()
              .like(Article::getContent, keyword);
        }
        qw.orderByDesc(Article::getCreatedAt);
        return articleMapper.selectPage(new Page<>(page, size), qw);
    }
}
