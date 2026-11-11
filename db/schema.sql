-- MyBlog 数据库初始化脚本（Lab06 / Lab08）
-- 用法：mysql -u root -p < db/schema.sql
-- 或直接复制到 Navicat 的查询窗口执行。

-- 1) 建库：utf8mb4 才能正确存中文和 emoji
CREATE DATABASE IF NOT EXISTS myblog
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE myblog;

-- 2) Lab06：留言表
CREATE TABLE IF NOT EXISTS message (
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    content    VARCHAR(1000) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3) Lab08：文章表
CREATE TABLE IF NOT EXISTS article (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    title      VARCHAR(200) NOT NULL,
    content    TEXT         NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 验证
SHOW TABLES;
DESCRIBE message;
DESCRIBE article;
