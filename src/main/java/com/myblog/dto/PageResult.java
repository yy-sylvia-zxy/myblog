package com.myblog.dto;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

/**
 * Lab07 · 分页结果载荷。
 *
 * MyBatis-Plus 的 Page 对象里字段很多（orders、optimizeCountSql……），
 * 直接扔给前端是"把内部结构当接口"。这里只留四格：
 *   items  当前页的数据
 *   total  符合条件的总条数（不是本页条数）
 *   page   当前第几页
 *   size   每页多少条
 *
 * 用 record：不可变、自动带构造器与 getter，正好适合"只读的响应"。
 */
public record PageResult<T>(List<T> items, long total, long page, long size) {

    public static <T> PageResult<T> of(Page<T> p) {
        return new PageResult<>(p.getRecords(), p.getTotal(),
                                p.getCurrent(), p.getSize());
    }
}
