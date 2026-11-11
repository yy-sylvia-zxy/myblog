package com.myblog.model;

/**
 * Lab03 · 身份（Identity）
 *
 * 和 Lab02 的 BlogProfile 相比，这里不是"多加两个字段"，
 * 而是把"这个博客是谁的"说清楚：五个字段各自回答一个问题。
 *
 *   blogName      我叫什么
 *   owner         我属于谁
 *   introduction  我是个什么样的人
 *   interests     我在乎什么
 *   vision        我要去哪里
 *
 * 验收方式很朴素：把这段 JSON 单独发给一位同学，只读 JSON、
 * 不看我的人，能不能判断出这是谁的博客。能，身份就立住了。
 */
public class PersonalProfile {

    public String blogName;
    public String owner;
    public String introduction;
    public String interests;
    public String vision;

    public PersonalProfile() {
    }

    public PersonalProfile(String blogName, String owner, String introduction,
                           String interests, String vision) {
        this.blogName = blogName;
        this.owner = owner;
        this.introduction = introduction;
        this.interests = interests;
        this.vision = vision;
    }
}
