package com.myblog.model;

/**
 * /me 的 JSON 形态。
 *
 * Lab02 要求：/me 由 String 升级为 JSON 对象，但仍在 Week01 的同一个工程里。
 * 也就是说——路由没变、工程没变，变的是"说话的形状"。
 */
public class MeResponse {

    public String name;
    public String studentId;
    public String major;
    public String message;

    public MeResponse() {
    }

    public MeResponse(String name, String studentId, String major, String message) {
        this.name = name;
        this.studentId = studentId;
        this.major = major;
        this.message = message;
    }
}
