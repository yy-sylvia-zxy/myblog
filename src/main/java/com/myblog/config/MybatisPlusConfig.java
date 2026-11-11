package com.myblog.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Lab07 · 分页拦截器。
 *
 * 没有它的时候，selectPage(new Page<>(1,5), qw) 不会报错，
 * 而是"安静地"把全表数据都给你 —— 一个最危险的错误：不报错的错误。
 *
 * 有了它，一次 selectPage 会被改写成两条 SQL：
 *   SELECT COUNT(*) ...            先数总数
 *   SELECT ... LIMIT ?, ?          再切片取当前页
 * 控制台日志里这两条一起出现，就是拦截器真的生效了。
 */
@Configuration
public class MybatisPlusConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
