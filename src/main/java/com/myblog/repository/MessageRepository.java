package com.myblog.repository;

import com.myblog.model.Message;

import java.util.List;
import java.util.Optional;

/**
 * Lab05 · 存储的边界（接口）。
 *
 * Service 只认识这个接口："有个地方能存、能全查、能按 id 查"。
 * 它不知道、也不需要知道背后是内存里的 ArrayList（本周）
 * 还是 MySQL 的一张表（Week06）。
 * 这就是"接口隔离变化"：换实现，Service 一行不用改。
 */
public interface MessageRepository {

    /** 存一条；id 由实现负责分配。 */
    Message save(Message message);

    /** 全部留言，按插入顺序。 */
    List<Message> findAll();

    /** 按 id 找一条；找不到返回空盒子，而不是 null。 */
    Optional<Message> findById(Long id);
}
