package com.myblog;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 启动类所在的包就是"根包"。
 *
 * @SpringBootApplication 里的 @ComponentScan 默认只扫描
 * "本类所在包及其子包" —— 所以它必须待在 com.myblog，
 * 才能扫到 com.myblog.controller / service / repository / mapper 等所有层。
 */
@SpringBootApplication
public class MyblogApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyblogApplication.class, args);
    }
}
