package com.myblog.controller;

import com.myblog.model.Message;
import com.myblog.model.MessageRequest;
import com.myblog.service.MessageService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;

/**
 * Lab05 · 前台只剩三件事：收请求 → 喊 Service → 还响应。
 *
 * 这个类里已经看不到 List、nextId、LocalDateTime —— 
 * 存储和业务都被搬走了，Controller 不再"又当爹又当妈"。
 */
@RestController
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    /** POST /messages —— POST 是必须的：浏览器地址栏只能发 GET。 */
    @PostMapping("/messages")
    public Message create(@RequestBody MessageRequest request) {
        return messageService.create(request);
    }

    /** GET /messages，keyword 可选：required = false 是它存在的前提。 */
    @GetMapping("/messages")
    public List<Message> list(@RequestParam(name = "keyword", required = false) String keyword) {
        List<Message> all = messageService.list();

        if (keyword == null) {
            return all;
        }

        List<Message> result = new ArrayList<>();
        for (Message m : all) {
            if (m.getContent() != null && m.getContent().contains(keyword)) {
                result.add(m);
            }
        }
        return result;
    }

    /** GET /messages/{id}：找到是 200，找不到是 404，不撒谎。 */
    @GetMapping("/messages/{id}")
    public Message getOne(@PathVariable Long id) {
        return messageService.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "message not found: id=" + id));
    }
}
