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
# install build tools
sudo apt-get install build-essential
sudo apt-get install g++ autoconf automake cmake git curl zlib1g zlib1g.dev

# install ffmpeg
sudo apt-get install ffmpeg

# install ssl for nginx
sudo apt-get install libssl-dev

# install pcre for nginx
sudo apt-get install libpcre3 libpcre3-dev

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

worker_processes 4; # cpu核数

events {
    worker_connections  1024;
}

rtmp {
    server {
      	listen 1935;
      	chunk_size 4000;
      	application live {
    	      live on;

      	    record all;
      	    record_path /usr/local/nginx/html/videos; # 目录权限777
      	    record_max_size 10000M; # 最大文件为10G，超过大小就会自动才分为多个文件
            record_suffix -%Y-%m-%d-%T.flv; # flv文件名
      	    record_unique on;

            hls on;
            hls_path /usr/local/nginx/html/hls; # 目录权限777

            # 转为426*240
            exec ffmpeg -i rtmp://localhost/$app/$name -s 426*240 -c:a libfdk_aac -b:a 128k -c:v libx264 -b:v 700k -f flv rtmp://localhost/sd/$name;
	      }

        application sd {
            live on;

            hls on;
            hls_path /usr/local/nginx/html/hls-sd; # 目录权限777
        }
    }
}


http {
    server {
        listen      80;

	      location /hls {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /usr/local/nginx/html;
            add_header Cache-Control no-cache;
        }

        location /hls-sd {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /usr/local/nginx/html;
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
