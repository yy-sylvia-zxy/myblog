package com.myblog.dto;

/**
 * Lab08 · 统一响应契约：code / message / data 三格，永远同一个骨架。
 *
 * 为什么需要它？
 *   Week07 之前：成功返回裸对象，失败是 404 文本或 HTML 错误页，
 *   前端每接一个接口都要猜一次形状。
 *   现在：成功和失败长一个样，脸（Week09 的 Vue）只需要信一次。
 *
 * 刻意只留三个字段 —— 过度花哨的 Result 框架是本周点名的陷阱。
 */
public class Result<T> {
    public int code;        // 0 = 成功；404 = 没找到
    public String message;
    public T data;

    public static <T> Result<T> ok(T data) {
        Result<T> r = new Result<>();
        r.code = 0;
        r.message = "ok";
        r.data = data;
        return r;
    }

    public static <T> Result<T> fail(int code, String message) {
        Result<T> r = new Result<>();
        r.code = code;
        r.message = message;
        r.data = null;
        return r;
    }
}
