package com.myblog.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.myblog.model.Article;
import org.apache.ibatis.annotations.Mapper;

/** Lab08 · 文章传声筒：一行 SQL 不写，增删改查全由 BaseMapper 兜底。 */
@Mapper
public interface ArticleMapper extends BaseMapper<Article> {
}
