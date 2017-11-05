---
title: "get start with ruby rake"
date: 2016-03-03
category: tech
tags: [ruby, http, proxy]
author: jun
---

## 代理服务器的一些基本作用
> 隐藏访问ip, 访问一些被墙或者拉黑访问端的网站,访问加速等

## 代理的流程：
> client --------> proxy server ------------> target server -----------> proxy server ----------> client

## ruby 简单的 http 代理服务服务器

主要是http协议的的解析

```ruby
require 'socket'
require 'logging'
require 'uri'

# 设置日志
$log = Logging.logger(STDERR)
$log.level = :warn

class HttpProxy
  def initialize(s, p)
    # 等待并获取客户端链接
    Socket.tcp_server_loop(s, p) do |connection|
      Thread.new deal_connection(connection)
    end
  end

  def deal_connection(connection)
    begin
      headers = {}
      headers_string = []
      while line = connection.readline
        break if line ==  "\r\n"
        headers_string << line
        line = line.split(' ', 2)
        # 将协议头部保存为一个hash
        if line[0][line[0].size - 1] == ':'  # 去除‘:’号
          headers[line[0].chop] = line[1]
        else
          headers[line[0]] = line[1]
        end
      end

      uri = URI.parse headers.first()[1].split(' ')[0]

      httpClient = TCPSocket.new(uri.host, (uri.port || 80))

      # 写入http 头部
      headers_string.each do |line|
        httpClient.write line
      end
      httpClient.write("Connection: close\r\n\r\n") # 关闭TCP

      # 写入 http body
      data = connection.read(headers['Content-Length'].to_i)  # Read
      httpClient.write data if data.length > 0

      # 返回数据给原始访问的客户端
      content_length = 0
      while line = httpClient.readline
        connection.write line
        if line.include? 'Content-Length:'
          content_length = line.split(' ')[1].strip
        end
        if line == "\r\n"
          break
        end
      end
      connection.write httpClient.read content_length.to_i if content_length.to_i > 0

      # 关闭链接
      httpClient.close
      connection.close
    rescue => e
      connection.close if connection
      $log.warn 'connection error.........................'
      $log.warn e.message
    end
  end
end

HttpProxy.new('0.0.0.0', 8088)
```

### 运行：
ruby xxxx.rb

