package com.myblog.model;

/**
 * Lab02 · 结构化表达（Structured Voice）
 *
 * Week01 我们用 String 说话，一句话就是一整段文本；
 * Week02 换成对象说话：一个对象 = 一组有名字的字段，
 * Jackson 会把它序列化成 JSON {"name":...,"owner":...,"message":...}。
 *
 * 这里故意用 public 字段：最直白地看到"字段名就是 JSON 的 key"。
 */
public class BlogProfile {

    public String name;      // 博客的名字
    public String owner;     // 博客的主人
    public String message;   // 想对访客说的话

    public BlogProfile() {
    }

    public BlogProfile(String name, String owner, String message) {
        this.name = name;
        this.owner = owner;
        this.message = message;
    }
}
