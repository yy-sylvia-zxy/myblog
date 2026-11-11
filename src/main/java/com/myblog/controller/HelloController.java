package com.myblog.controller;

import com.myblog.model.BlogProfile;
import com.myblog.model.MeResponse;
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

    /** Lab02：新身份接口，返回 ≥3 个字段的 JSON。 */
    @GetMapping("/profile")
    public BlogProfile profile() {
        return new BlogProfile(
                "Sylvia's Blog",
                "赵熙语",
                "欢迎来到我的数字角落：这里记录一个计算机学生的代码、思考与成长。"
        );
    }
}
