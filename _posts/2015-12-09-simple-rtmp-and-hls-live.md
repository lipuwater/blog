---
title: "Simple RTMP and HLS Live"
date: 2015-12-09
category: tech
tags: [c++, rtmp, hls, srs, live]
author: flowerwrong
---

Use [srs](https://github.com/ossrs/srs) by [winlinvip](https://github.com/winlinvip) to set up simple a live stream server.


#### srs

SRS is industrial-strength live streaming cluster, for the best conceptual integrity and the simplest implementation.

#### Install

```bash
git clone https://github.com/ossrs/srs.git
cd srs/trunk
./configure && make
./objs/srs -c conf/srs.conf
```

Now you can visit `127.0.0.1` to see the demo page for live.

#### How to push flow to server?

* You can use android software [broadcaster](http://help.aodianyun.com/aodianyun_doc/60).
* Also you can use adobe's [flash media live encoder](http://www.adobe.com/cn/products/flash-media-encoder.html).

#### Reference

* [srs server](https://github.com/ossrs/srs)
* [srs wiki](https://github.com/ossrs/srs/wiki/v2_CN_Home)
