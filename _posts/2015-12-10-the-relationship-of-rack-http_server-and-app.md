---
layout: post
title: "The relationship of rack, http_server and app"
date: 2015-12-10
category: tech
tags: [ruby, thin, rack]
comments: true
author: flowerwrong
avatar: 'https://avatars2.githubusercontent.com/u/5362640?v=3&s=460'
---

本文描述了[rack](https://github.com/rack/rack)中间件, `http_server` [thin](https://github.com/macournoyer/thin) 和我们开发的逻辑应用之间的关系。首先介绍一下整体框架，描述了一个请求到相应的具体过程。

![]()

首先服务器`thin`启动监听`tcp`套接字(此处忽略其他协议)，并依据配置决定是多线程还是多进程模型(本文不关心，以多进程为例)；当一个请求到达的时候，`thin`首先初始化`Request` 和 `Response`对象，
接收到数据后就进行`http`协议的解析并初始化`env`对象，此对象非常重要，他是一个`hash`，包含了所有的http头部解析和http数据，然后把该`hash`传递给我们的应用，应用处理后返回`[status, headers, body]`的形式。
`thin`做收尾处理，最后发送到客户端。那我们的`rack middleware`在哪里呢？简单来说，如果我们的app使用了一个叫做`ToUpper`的`middleware`，那么其实在`thin`里面初始化的app实例变量就是`ToUpper`，同时`ToUpper`
有一个`app`的实例变量，值为我们应用。并且，`middleware`是按照反向顺序使用的。

```ruby
app = Rack::Builder.new do
  use ToCap
  use ToUpper
  run App
end

Rack::Handler::Thin.run app
```

那么会按照`ToUpper`, `ToCap`, `App`的执行顺序, 最后交由`thin`返回处理结果给客户端。


###### 基础`rack` based应用

```ruby
# demo.rb
require 'rack'

class App
  def self.call(_env)
    [ 200, {'Content-Type' => 'text/plain'}, ['hello, yang!'] ]
  end
end

class ToUpper
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    uppered_body = body.map(&:upcase)
    [status, headers, uppered_body]
  end
end

class AddTail
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    caped_body = [body[0] + ' I am add by AddTail middleware']
    [status, headers, caped_body]
  end
end

app = Rack::Builder.new do
  use AddTail
  use ToUpper
  run App
end

Rack::Handler::Thin.run app
```

该应用包括了两个`middleware`和一个简单的应用。

```bash
ruby demo.rb
curl -i 'http://127.0.0.1:8080'


HTTP/1.1 200 OK
Content-Type: text/plain
Connection: close
Server: thin

HELLO, YANG! I am add by AddTail middleware
```

我们的讲解将从这里开始。

下面请先下载[rack](https://github.com/rack/rack)和[thin](https://github.com/macournoyer/thin)的源代码。`thin`是基于[eventmachine](https://github.com/eventmachine/eventmachine)的，
eventmachine是一个事件驱动和高并发的库，使用[reactor 模型](http://en.wikipedia.org/wiki/Reactor_pattern)。但本文不涉及，他负责启动`tcp`服务器
        EventMachine.start_server(@host, @port, Connection, &method(:initialize_connection))
并且可以开启多线程模式(默认不启动)。

```ruby
# thin-1.6.4/lib/thin/backends/base.rb # line47
def initialize
  @connections                    = {}
  @timeout                        = Server::DEFAULT_TIMEOUT
  @persistent_connection_count    = 0
  @maximum_connections            = Server::DEFAULT_MAXIMUM_CONNECTIONS
  @maximum_persistent_connections = Server::DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS
  @no_epoll                       = false
  @ssl                            = nil
  @threaded                       = nil
  @started_reactor                = false
end
```

#### app 实例

```ruby
app = Rack::Builder.new do
  use AddTail
  use ToUpper
  run App
end
```

该实例会返回一个`Rack::Builder`的实例 `#<Rack::Builder:0x000000020e4ac8 @warmup=nil, @run=App, @map=nil, @use=[#<Proc:0x000000020d7df0@/home/yy/.rvm/gems/ruby-2.2.3/gems/rack-1.6.4/lib/rack/builder.rb:86>, #<Proc:0x000000020d77b0@/home/yy/.rvm/gems/ruby-2.2.3/gems/rack-1.6.4/lib/rack/builder.rb:86>]>`
可以看出里面比较重要的是`@run`(应用名称) 和 `@use`(middleware数组) 两个实例变量.

#### 待续


#### Reference

* [ruby-c-extension-book](https://github.com/wusuopu/ruby-c-extension-book)
* [eventmachine wiki](https://github.com/eventmachine/eventmachine/wiki)
* [sinatra](https://github.com/bmizerany/sinatra)
* [thin](https://github.com/macournoyer/thin)
* [rack](https://github.com/rack/rack)
