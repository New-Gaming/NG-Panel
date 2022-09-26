
<p align="center">
  <img alt="logo" src="https://raw.githubusercontent.com/New-Gaming/NG-Panel/main/route/static/logo.png" height="140" />
  <h3 align="center">NG-Panel</h3>
  <p align="center">NG定制Linux运维面板</p>
</p>

### 简介

NewGaming定制的开源Linux运维面板，便于安装环境和搭建网站

- [常用命令说明](/cmd.md)

![CentOS](https://img.shields.io/badge/LINUX-CentOS-blue?style=for-the-badge&logo=CentOS)
![Ubuntu](https://img.shields.io/badge/LINUX-Ubuntu-blue?style=for-the-badge&logo=Ubuntu)
![Debian](https://img.shields.io/badge/LINUX-Debian-blue?style=for-the-badge&logo=Debian)
![Fedora](https://img.shields.io/badge/LINUX-Fedora-blue?style=for-the-badge&logo=Fedora)


* SSH终端工具
* 面板收藏功能
* 网站子目录绑定
* 网站备份功能
* 插件方式管理

### 主要插件介绍

* OpenResty - 轻量级，占有内存少，并发能力强。
* PHP[52-81] - PHP是世界上最好的编程语言。
* MySQL - 一种关系数据库管理系统。
* MariaDB - 是MySQL的一个重要分支。
* MongoDB - 一种非关系NOSQL数据库管理系统。
* phpMyAdmin - 著名Web端MySQL管理工具。
* Memcached - 一个高性能的分布式内存对象缓存系统。
* Redis - 一个高性能的KV数据库。
* PureFtpd - 一款专注于程序健壮和软件安全的免费FTP服务器软件。
* Gogs - 一款极易搭建的自助Git服务。
* Rsyncd - 通用同步服务。


# Note

```
phpMyAdmin[4.4.15]支持MySQL[5.5-5.7]
phpMyAdmin[5.2.0]支持MySQL[8.0]

PHP[53-72]支持phpMyAdmin[4.4.15]
PHP[72-81]支持phpMyAdmin[5.2.0]
```


### 安装地址

- 初始安装

```
curl -fsSL  https://raw.githubusercontent.com/New-Gaming/NG-Panel/main/scripts/install.sh | bash
```

- 直接更新

```
curl -fsSL  https://raw.githubusercontent.com/New-Gaming/NG-Panel/main/scripts/update.sh | bash
```


### DEV使用

- 初始安装

```
curl -fsSL  https://raw.githubusercontent.com/New-Gaming/NG-Panel/dev/scripts/install_dev.sh | bash
```

- 直接更新

```
curl -fsSL  https://raw.githubusercontent.com/New-Gaming/NG-Panel/dev/scripts/update_dev.sh | bash
```

