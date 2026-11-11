package com.myblog.service;

import com.myblog.model.Message;
import com.myblog.model.MessageRequest;
import com.myblog.repository.MessageRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Lab05 · MyBlog 的"大脑"。
 *
 * 两件事：
 *   1. 做业务决定（校验内容不能为空、把 Request 翻译成 Message）
 *   2. 把存储交给 Repository 边界
 *
 * 它不懂 HTTP（这里没有任何 @RequestBody 之类的注解），
 * 也不懂数据住在哪（List？MySQL？它不关心）。
 *
 * @Service 的意义：让容器在启动时把它创建出来，并把构造器要的
 * MessageRepository 递进来 —— 这叫作"依赖在启动时接线"。
 * 一旦这根系错了（比如忘了给实现类加 @Repository），
 * 应用会在启动阶段直接失败，而不是等到第一次请求才出问题。
 */
@Service
public class MessageService {

    private final MessageRepository messageRepository;

    // 构造器注入 + final：依赖在创建时一次性接好，之后不许改
    public MessageService(MessageRepository messageRepository) {
        this.messageRepository = messageRepository;
    }

    /** 收下访客的申请表，产出一条真正的留言。 */
    public Message create(MessageRequest request) {
        if (request.content == null || request.content.isBlank()) {
            throw new IllegalArgumentException("content must not be empty");
        }
        Message message = new Message();
        message.setContent(request.content);
        // id 和 createdAt 由仓库授予，不由访客决定
        return messageRepository.save(message);
    }

    public List<Message> list() {
        return messageRepository.findAll();
    }

    /** 诚实的返回类型：这条留言可能存在，也可能不存在。 */
    public Optional<Message> findById(Long id) {
        return messageRepository.findById(id);
    }
}
