package com.myblog.repository;

import com.myblog.model.Message;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Lab05 · 内存版实现。
 *
 * 数据住在这个 JVM 进程的堆里，所以：
 *   进程活着 → 留言在
 *   进程重启 → 留言全部消失（这是本周的"签名缺陷"，Week06 换成 MySQL 后消失）
 *
 * @Repository 让 Spring 启动时把这个类实例化，并登记为 MessageRepository 的实现，
 * 之后谁在构造器里要一个 MessageRepository，它就把这个对象递过去（依赖注入）。
 */
@Repository
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
