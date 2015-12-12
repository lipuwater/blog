---
layout: post
title: "curl for api"
date: 2015-12-10
category: tech
tags: [ruby, curl]
comments: true
author: flowerwrong
avatar: 'https://avatars2.githubusercontent.com/u/5362640?v=3&s=460'
---

## Options

* `-i`: 显示响应头信息
* `-X Method`: 使用某http方法，例如`-X POST`, `-X PUT` [GET POST DELETE PUT HEAD PATCH...]
* `-H "key:value"`: 添加请求头信息
* `-d "key=value&key2=value2"`: 添加http payload
* `-v`: `--verbose` 显示执行过程中的详细信息


## Linux 重定向输出

```bash
fd > file # 表示将输出从文件描述符`fd`重定向到文件，如果存在，内容会覆盖
fd >> file # 表示将输出从文件描述符`fd`重定向到一个文件中，如果存在，则追加内容
```

## Linux 管道

通过管道将 `stdout` 导入到 `stdin`

```bash
command1 | command2 paramater1 | command3 parameter1 - parameter2 | command4
```

使用重定向主要是为了进行`json`字符串的格式化

```bash
curl -X GET -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" "http://127.0.0.1/articles.json" | python -m json.tool
```

## Demo

```bash
curl -X GET -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" "http://127.0.0.1/articles?page=1&per_page=10" | python -m json.tool
curl -X POST -d "title:'new title'&body='new body'" -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" "http://127.0.0.1/articles" | python -m json.tool
curl -X GET -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" "http://127.0.0.1/articles/1" | python -m json.tool
curl -X PUT -d "title:'updated title'" -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" "http://127.0.0.1/articles/1" | python -m json.tool
curl -X PATCH -d "title:'updated title'" -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" "http://127.0.0.1/articles/1" | python -m json.tool
curl -i -v -X DELETE -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" "http://127.0.0.1/articles/1"
```
