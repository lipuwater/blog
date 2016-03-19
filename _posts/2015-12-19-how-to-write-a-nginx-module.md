---
title: "How to write a nginx module?"
date: 2015-12-19
category: tech
tags: [nginx, c]
author: flowerwrong
---

## 待续

## Nginx 多进程模型

![](/assets/posts/nginx-worker-process.PNG)
图片来自 `http://tengine.taobao.org/book/chapter_02.html`

一般来说，worker数量和cpu核数一致。

## Nginx 重启的工作方式

```bash
ps -aux | grep nginx
sudo kill -HUP nginx_pid # HUP: hang up信号
```

![](/assets/posts/nginx-master-reload.png)

Nginx 接收到 `HUP` 信号后，master进程重新加载配置文件，然后根据配置文件启动一定个数的worker进程，新的进程正常接收并处理新的请求，
与此同时，master进程会给老的worker进程发送信号，老的worker进程接收到信号后就不再接收新的请求，继续处理完已接收的请求后光荣退出。


## 系统描述符大小限制

`ulimit -n`

## 易错理解

* 对于http1.1协议来说，如果响应头中的`Transfer-encoding`为`chunked`传输，则`表示body是流式输出`，`body会被分成多个块`，每块的开始会标识出当前块的长度，此时，body不需要通过长度来指定

## Reference

* [nginx模块开发篇](http://tengine.taobao.org/book/module_development.html)
* [openresty: a full-fledged web application server by bundling the standard Nginx core, lots of high quality 3rd-party Nginx modules, as well as most of their external dependencies](http://openresty.org/)
* [taobao tengine](http://tengine.taobao.org/documentation_cn.html)
