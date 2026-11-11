package com.myblog.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.myblog.model.Message;
import org.apache.ibatis.annotations.Mapper;

/**
 * Lab06 · 留言的"传声筒"。
 *
 * 这里一行 SQL 都不写：BaseMapper 已经准备好了 insert / selectById /
 * selectList / deleteById 等一整套方法，泛型 Message 告诉它操作哪张表
 * （表名来自 Message 上的 @TableName）。
 *
 * @Mapper 让 MyBatis 在启动时为这个接口生成实现类（动态代理），
 * 之后就能像普通 Bean 一样被注入。
 */
@Mapper
public interface MessageMapper extends BaseMapper<Message> {
}
