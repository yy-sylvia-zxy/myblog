package com.myblog.repository;

import com.myblog.model.Message;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Lab05 · 内存版实现（Lab06 起停用）。
 *
 * 数据住在这个 JVM 进程的堆里，所以：
 *   进程活着 → 留言在
 *   进程重启 → 留言全部消失（这是 Week05 留下的"签名缺陷"）
 *
 * Lab06 起改用 DbMessageRepository，这里的 @Repository 被注释掉：
 * 一个接口只能有一个实现被登记，否则 Spring 不知道递哪个给你
 * （NoUniqueBeanDefinitionException）。类保留着，作为 Week05 的历史证据。
 */
// @Repository   ← Week06 起停用：避免与 DbMessageRepository 冲突
public class InMemoryMessageRepository implements MessageRepository {

    // final 锁住的是"引用"不是"内容"：可以往里 add，但不能把 messages 指向另一个 List
    private final List<Message> messages = new ArrayList<>();

    private long nextId = 1;

    @Override
    public Message save(Message message) {
        message.setId(nextId++);
        message.setCreatedAt(LocalDateTime.now());
        messages.add(message);
        return message;
    }

    @Override
    public List<Message> findAll() {
        return messages;
    }

    @Override
    public Optional<Message> findById(Long id) {
        return messages.stream()
                .filter(m -> m.getId().equals(id))
                .findFirst();
    }
}
