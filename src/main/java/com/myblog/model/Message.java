package com.myblog.model;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;

/**
 * Lab04 · 一条真正住在 MyBlog 里的留言。
 *
 * 注意它比访客提交的内容多了两样东西：
 *   id        身份（第几条留言）
 *   createdAt 出生时间
 * 这两样访客永远不提交，由系统授予 —— 访客只负责"说什么"。
 *
 * Lab06 · 同一个类多了三行注解，就从"内存里的对象"变成"数据库里的行"：
 *   @TableName("message")  这个类对应 message 表
 *   @TableId(IdType.AUTO)  主键交给 MySQL 自增，insert 之后回填到 id
 *   字段 createdAt ↔ 列 created_at（驼峰↔下划线由 MyBatis-Plus 自动转换）
 */
@TableName("message")
public class Message {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String content;

    private LocalDateTime createdAt;

    public Message() {
    }

    public Message(Long id, String content, LocalDateTime createdAt) {
        this.id = id;
        this.content = content;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
