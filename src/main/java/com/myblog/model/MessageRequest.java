package com.myblog.model;

/**
 * Lab04 · 访客提交的"申请表"。
 *
 * 只有 content 一个字段：访客能说的只有内容。
 * 形状（Request）和实体（Message）分开，是 DTO 的意义：
 * 不让外面的人决定 id 和 createdAt。
 */
public class MessageRequest {

    public String content;
}
