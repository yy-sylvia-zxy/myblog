package com.myblog.controller;

import com.myblog.model.MeResponse;
import com.myblog.model.PersonalProfile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * MyBlog 的前台。
 *
 * @RestController = @Controller + @ResponseBody
 *   方法返回值不再被当成"模板名"去找页面，而是直接被写进响应体。
 *   所以返回 String 得到纯文本，返回对象得到 JSON（由 Jackson 转换）。
 */
@RestController
public class HelloController {

    /** Lab01 保留：返回纯文本，验证服务活着。 */
    @GetMapping("/hello")
    public String hello() {
        return "Hello, I am Sylvia. I Exist.";
    }

    /**
     * Lab02：/me 从 String 升级成 JSON 对象。
     * 对照：以前 return 一段字符串 -> Content-Type: text/plain；
     *       现在 return 一个对象   -> Content-Type: application/json。
     */
    @GetMapping("/me")
    public MeResponse me() {
        return new MeResponse(
                "赵熙语（Sylvia）",
                "25281E127",
                "计算机科学与技术",
                "This is the beginning of my blog."
        );
    }

    /**
     * Lab02：新身份接口，返回 ≥3 个字段的 JSON（BlogProfile）。
     * Lab03：升级为 PersonalProfile，五个字段各自回答"我是谁"的一问。
     * 路由没变、项目没变 —— 身份是在原工程里长出来的，不是推倒重建。
     */
    @GetMapping("/profile")
    public PersonalProfile profile() {
        return new PersonalProfile(
                "Sylvia 的数字角落",
                "赵熙语 Sylvia（25281E127）",
                "广东金融学院计算机科学与技术专业学生，正在学习 Web 程序设计，习惯把学到的东西写成代码再讲一遍。",
                "Java、Spring Boot、数据结构与算法、摄影、英语",
                "把 MyBlog 做成一个能与访客对话的数字自我：它记得我说过的话，也能被修订。"
        );
    }
}
