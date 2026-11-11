package com.myblog.repository;

import com.myblog.mapper.MessageMapper;
import com.myblog.model.Message;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Lab06 · 数据库版仓库。
 *
 * 它实现的是 Week05 就定好的那个 MessageRepository 接口 —— 
 * 接口没变、签名没变，只是"住的地方"从 JVM 堆换成了 MySQL 的表。
 * Service 和 Controller 因此一行都不用改，这叫"替换实现，不动依赖"。
 */
@Repository
public class DbMessageRepository implements MessageRepository {

    private final MessageMapper messageMapper;

    public DbMessageRepository(MessageMapper messageMapper) {
        this.messageMapper = messageMapper;
    }

    @Override
    public Message save(Message message) {
        messageMapper.insert(message);
        // 主键由 MySQL 自增生成，insert 之后被回填到 message.id
        return message;
    }

    @Override
    public List<Message> findAll() {
        // null = 不带任何过滤条件，等价于 selectList 全表
        return messageMapper.selectList(null);
    }

    @Override
    public Optional<Message> findById(Long id) {
        return Optional.ofNullable(messageMapper.selectById(id));
    }
}
