---
title: "Simple RTMP and HLS Live"
date: 2015-12-09
category: tech
tags: [c++, rtmp, hls, srs, live]
author: flowerwrong
---

Use [srs](https://github.com/ossrs/srs) by [winlinvip](https://github.com/winlinvip) to set up simple a live stream server.


## srs

SRS is industrial-strength live streaming cluster, for the best conceptual integrity and the simplest implementation.

## features

* rtmp
* hls
* dvr to flv
* http api and callback
* use ffmpeg to transcode 1080p to 480p...

## Install

```bash
git clone https://github.com/ossrs/srs.git
cd srs/trunk
./configure --disable-all --with-ssl --with-hls --with-nginx --with-ffmpeg --with-transcode --with-dvr --with-http-api --with-http-callback --with-http-server

make

./objs/srs -c conf/srs.conf
```

## srs.conf

```nginx
listen              1935;
max_connections     1000;
srs_log_tank        file;
srs_log_file        ./objs/srs.log;

stats {
    network         0;
    disk            sda sdb xvda xvdb;
}

#############################################################################################
# HTTP sections
#############################################################################################

http_api {
    enabled         on;
    listen          1985;
    crossdomain     on;
}

http_server {
    enabled         on;
    listen          8080;
    dir             ./objs/nginx/html;
}


vhost __defaultVhost__ {
    security {
        enabled         on;
        # deny            publish     all;
        allow           publish     192.168.10.196;
        allow           publish     127.0.0.1;
        allow           play        all;
    }

    dvr {
        enabled         on;
        dvr_plan        session;
        dvr_path        ./objs/nginx/html/[app]/[stream].[timestamp].flv;
        dvr_duration    30;
        dvr_wait_keyframe       on;
        time_jitter             full;
    }

    transcode {
        enabled     on;
        # ffmpeg      ./objs/ffmpeg/bin/ffmpeg;
        ffmpeg      /usr/bin/ffmpeg; # use your own ffmpeg, run `which ffmpeg`, @see https://github.com/ossrs/srs/issues/550
        engine sd {
            enabled         on;
            vfilter {
            }
            vcodec          libx264;
            vbitrate        400;
            vfps            25;
            vwidth          426;
            vheight         240;
            vthreads        12;
            vprofile        main;
            vpreset         medium;
            vparams {
            }
            acodec          libfdk_aac;
            abitrate        70;
            asample_rate    44100;
            achannels       2;
            aparams {
            }
            output          rtmp://127.0.0.1:[port]/[app]?vhost=[vhost]/[stream]_[engine];
        }
    }

    hls {
        enabled         on;
        hls_fragment    10;
        hls_td_ratio    1.5;
        hls_aof_ratio   2.0;
        hls_window      60;
        hls_on_error    continue;
        hls_storage     disk;
        hls_path        ./objs/nginx/html;
        hls_m3u8_file   [app]/[stream].m3u8;
        hls_ts_file     [app]/[stream]-[seq].ts;
        hls_ts_floor    off;
        hls_mount       [vhost]/[app]/[stream].m3u8;
        hls_acodec      aac;
        hls_vcodec      h264;
        hls_cleanup     on;
        hls_dispose     0;
        hls_nb_notify   64;
        hls_wait_keyframe       on;
    }

    http_hooks {
        enabled         on;
        on_connect      http://127.0.0.1:8085/api/v1/clients http://localhost:8085/api/v1/clients;
        on_close        http://127.0.0.1:8085/api/v1/clients http://localhost:8085/api/v1/clients;
        on_publish      http://127.0.0.1:8085/api/v1/streams http://localhost:8085/api/v1/streams;
        on_unpublish    http://127.0.0.1:8085/api/v1/streams http://localhost:8085/api/v1/streams;
        on_play         http://127.0.0.1:8085/api/v1/sessions http://localhost:8085/api/v1/sessions;
        on_stop         http://127.0.0.1:8085/api/v1/sessions http://localhost:8085/api/v1/sessions;
        on_dvr          http://127.0.0.1:8085/api/v1/dvrs http://localhost:8085/api/v1/dvrs;
        on_hls          http://127.0.0.1:8085/api/v1/hls http://localhost:8085/api/v1/hls;
        on_hls_notify   http://127.0.0.1:8085/api/v1/hls/[app]/[stream][ts_url];
    }
}
```

Now you can visit `127.0.0.1` to see the demo page for live.

## How to push flow to server?

* You can use android software [broadcaster](http://help.aodianyun.com/aodianyun_doc/60).
* Also you can use adobe's [flash media live encoder](http://www.adobe.com/cn/products/flash-media-encoder.html) on windows.
* Also you can open source [OBS](https://obsproject.com/) on Mac, Linux or Windows.

## Reference

* [srs server](https://github.com/ossrs/srs)
* [srs wiki](https://github.com/ossrs/srs/wiki/v2_CN_Home)
* [srs callback](https://github.com/FlowerWrong/srs_callback)
