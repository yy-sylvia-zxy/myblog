package com.myblog.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.myblog.mapper.MessageMapper;
import com.myblog.model.Message;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Lab07 · 留言业务员（方案 A：直接依赖 MessageMapper）。
 *
 * Week05 的 Repository 接口在 Week06 完成了"从内存搬到 MySQL"的使命；
 * 本周按课程给的方案 A，Service 直接与 Mapper 对话：
 * 过滤条件、切片、计数全部交给 MySQL 与分页拦截器。
 *
 * 它依然不懂 HTTP，也依然是我们唯一做"业务决定"的地方。
 */
@Service
public class MessageService {

    private final MessageMapper messageMapper;   // 唯一的依赖

    public MessageService(MessageMapper messageMapper) {
        this.messageMapper = messageMapper;
    }

    /** 创建留言（POST /messages），id 由 MySQL 自增并回填。 */
    public Message create(Message message) {
        if (message.getContent() == null || message.getContent().isBlank()) {
            throw new IllegalArgumentException("content 不能为空");
        }
        if (message.getCreatedAt() == null) {
            message.setCreatedAt(LocalDateTime.now());
        }
        messageMapper.insert(message);
        return message;
    }

    /** 查询单条；查不到返回空盒子，由 Controller 决定怎么说。 */
    public Optional<Message> getById(Long id) {
        return Optional.ofNullable(messageMapper.selectById(id));
    }

    /**
     * 搜索 + 分页（GET /messages?keyword=&page=&size=）。
     *
     * 条件按需累积：keyword 有值 → 追加 LIKE；
     * 始终按创建时间倒序（新的在前）。
     * 注意这里不"先查全部再在 Java 里筛" —— 那是 Week04 的做法；
     * 现在过滤、切片、计数都发生在 MySQL 里。
     */
    public Page<Message> search(String keyword, long page, long size) {
        LambdaQueryWrapper<Message> qw = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            qw.like(Message::getContent, keyword);
        }
        qw.orderByDesc(Message::getCreatedAt);
        return messageMapper.selectPage(new Page<>(page, size), qw);
    }
}
