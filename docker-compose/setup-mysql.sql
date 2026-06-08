-- Run on the REMOTE MySQL host as root:  sudo mysql < setup-mysql.sql
-- Creates shared DB + user GPUStack connects to. Other projects use their own DBs
-- on the same MySQL server — resources shared, data isolated per DB.

CREATE DATABASE IF NOT EXISTS gpustack CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- '%' = allow connections from any host (the GPUStack container's IP).
-- Tighten to your docker subnet for production, e.g. 'gpustack'@'172.17.%'.
CREATE USER IF NOT EXISTS 'gpustack'@'%' IDENTIFIED BY 'gpustack_pass';
GRANT ALL PRIVILEGES ON gpustack.* TO 'gpustack'@'%';

FLUSH PRIVILEGES;

-- REMINDER: remote MySQL must listen on the LAN, not just 127.0.0.1.
-- Edit /etc/mysql/mysql.conf.d/mysqld.cnf -> bind-address = 0.0.0.0
-- then: sudo systemctl restart mysql
