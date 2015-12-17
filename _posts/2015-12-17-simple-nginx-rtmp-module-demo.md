---
title: "Simple Nginx Rtmp Demo"
date: 2015-12-16
category: tech
tags: [nginx, rtmp]
author: flowerwrong
---

前面有写过一篇使用[srs](https://github.com/ossrs/srs)搭建直播服务器的文章，[地址](http://blog.liveneeq.com/tech/2015/12/09/simple-rtmp-and-hls-live.html)，srs大而且全，
但架不住`nginx-rtmp-module`小而简介，本文主要描述`nginx-rtmp-module`搭配nginx搭建直播服务器的过程。

## Install

```bash
mkdir live-demo && cd live-demo
wget http://nginx.org/download/nginx-1.9.9.tar.gz
tar -zxvf nginx-1.9.9.tar.gz

git clone https://github.com/arut/nginx-rtmp-module.git

cd nginx-1.9.9
./configure --add-module=../nginx-rtmp-module --with-debug
make
sudo make install

cd /usr/local/nginx
```

## Config


```
# nginx.conf

# user root;
worker_processes  1;


events {
    worker_connections  1024;
}


rtmp {
    server {
      	listen 1935; # rtmp协议服务端口
      	chunk_size 4000;

      	application live {
      	    live on;

      	    record all;
      	    record_path /usr/local/nginx/html/videos; # 保存flv文件到该文件夹, 注意文件夹权限改为777
      	    # record_max_size 100M;
      	    record_unique on;

            hls on;
            hls_path /tmp/hls; # hls分片保存文件夹，会自动清理, 注意文件夹权限改为777
  	    }
    }
}


http {
    server {
        listen 80; # http协议服务端口

	      server_name localhost _ 192.168.10.160; # 修改为你的ip

	      location /stat {
            rtmp_stat all;

            rtmp_stat_stylesheet stat.xsl;
        }

	      location /stat.xsl {
            root /usr/local/nginx/html/stat.xsl;
        }

	      location /hls {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /tmp; # 注意配合hls_path
            add_header Cache-Control no-cache;
        }
    }
}
```

## Usage

```bash
sudo sbin/nginx
```

## How to push flow to server?

* You can use android software [broadcaster](http://help.aodianyun.com/aodianyun_doc/60).
* Also you can use adobe's [flash media live encoder](http://www.adobe.com/cn/products/flash-media-encoder.html).

## Reference

* [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module)
* [nginx](http://nginx.org)
* [ffmpeg](http://ffmpeg.org)
