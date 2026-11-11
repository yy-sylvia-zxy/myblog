package com.myblog.controller;

import com.myblog.dto.Result;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.NoSuchElementException;

/**
 * Lab08 · 门口的统一"道歉话术"。
 *
 * Service 遇到"文章不存在"时不懂 HTTP，它只会诚实地喊一声
 *   throw new NoSuchElementException("article not found");
 * 这一嗓子如果没人接，Spring 会吐一坨 HTML 错误页 + 500 + 堆栈，
 * 客人只想听一句体面的"没找到"，却收到了火灾现场的告示。
 *
 * @RestControllerAdvice 就是专职接话的人：把 NoSuchElementException
 * 翻译成 404 + Result 骨架的 JSON，成功和失败共用同一个 {code,message,data}。
 */
@RestControllerAdvice
public class ApiExceptionAdvice {

    @ExceptionHandler(NoSuchElementException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Result<Void> notFound(NoSuchElementException ex) {
        return Result.fail(404, ex.getMessage() == null ? "not found" : ex.getMessage());
    }
}
