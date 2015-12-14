---
title: "The relationship of rack, http_server and app"
date: 2015-12-10
category: tech
tags: [ruby, thin, rack]
author: flowerwrong
---

本文描述了[rack](https://github.com/rack/rack)中间件, `http_server` [thin](https://github.com/macournoyer/thin) 和我们开发的逻辑应用之间的关系。首先介绍一下整体框架，描述了一个请求到相应的具体过程。

![]()

首先服务器`thin`启动并监听`tcp`套接字(此处忽略其他协议)，并依据配置决定是是否使用多线程(本文不关心，以多进程为例)；当一个请求到达的时候，`thin`首先初始化`Request` 和 `Response`对象，
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


###### `rack` based应用

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

在rack里面，目前用到的最重要的两个类是`Rack::Handler::Thin`和`Rack::Builder`，其中前者是必须符合`Rack`规范，以`thin`为例

```ruby
# https://github.com/macournoyer/thin
require "thin"
require "thin/server"
require "thin/logging"
require "thin/backends/tcp_server"
require "rack/content_length"
require "rack/chunked"

module Rack
  module Handler
    class Thin
      def self.run(app, options={})
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || 8080
        args = [host, port, app, options]
        # Thin versions below 0.8.0 do not support additional options
        args.pop if ::Thin::VERSION::MAJOR < 1 && ::Thin::VERSION::MINOR < 8
        server = ::Thin::Server.new(*args)
        yield server if block_given?
        server.start
      end

      def self.valid_options
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        {
          "Host=HOST" => "Hostname to listen on (default: #{default_host})",
          "Port=PORT" => "Port to listen on (default: 8080)",
        }
      end
    end
  end
end
```

其中`run(app, options = {})`类方法是必不可少的，`Rack`只是内置了几个handler，我们也可以使用`打开类技术`自行编写，通常传递`app`，`host`，`port`等参数。例如`puma`的：

```ruby
# https://github.com/puma/puma/blob/master/lib/rack/handler/puma.rb
require 'rack/handler'
require 'puma'

module Rack
  module Handler
    module Puma
      DEFAULT_OPTIONS = {
        :Host => '0.0.0.0',
        :Port => 8080,
        :Threads => '0:16',
        :Verbose => false
      }

      def self.run(app, options = {})
        options  = DEFAULT_OPTIONS.merge(options)

        if options[:Verbose]
          app = Rack::CommonLogger.new(app, STDOUT)
        end

        if options[:environment]
          ENV['RACK_ENV'] = options[:environment].to_s
        end

        server   = ::Puma::Server.new(app)
        min, max = options[:Threads].split(':', 2)

        puts "Puma #{::Puma::Const::PUMA_VERSION} starting..."
        puts "* Min threads: #{min}, max threads: #{max}"
        puts "* Environment: #{ENV['RACK_ENV']}"
        puts "* Listening on tcp://#{options[:Host]}:#{options[:Port]}"

        server.add_tcp_listener options[:Host], options[:Port]
        server.min_threads = min
        server.max_threads = max
        yield server if block_given?

        begin
          server.run.join
        rescue Interrupt
          puts "* Gracefully stopping, waiting for requests to finish"
          server.stop(true)
          puts "* Goodbye!"
        end

      end

      def self.valid_options
        {
          "Host=HOST"       => "Hostname to listen on (default: localhost)",
          "Port=PORT"       => "Port to listen on (default: 8080)",
          "Threads=MIN:MAX" => "min:max threads to use (default 0:16)",
          "Verbose"         => "Don't report each request (default: false)"
        }
      end
    end

    register :puma, Puma
  end
end
```

#### `thin`开启监听

当调用`Rack::Handler::Thin.run app`后，`rack`就会执行`Rack::Handler::Thin.run`方法，接着创建server实例`server = ::Thin::Server.new(*args)`，同时创建`@app`实例，然后启动。
在`Thin::Server`类中，我们可以查看他的初始化代码

```ruby
# https://github.com/macournoyer/thin/blob/master/lib/thin/server.rb#L100
def initialize(*args, &block)
  host, port, options = DEFAULT_HOST, DEFAULT_PORT, {}

  # Guess each parameter by its type so they can be
  # received in any order.
  args.each do |arg|
    case arg
    when Fixnum, /^\d+$/ then port    = arg.to_i
    when String          then host    = arg
    when Hash            then options = arg
    else
      @app = arg if arg.respond_to?(:call)
    end
  end

  # Set tag if needed
  self.tag = options[:tag]

  # Try to intelligently select which backend to use.
  @backend = select_backend(host, port, options) # 此处决定服务器套接字类型(通常为tcp套接字)

  load_cgi_multipart_eof_fix

  @backend.server = self

  # Set defaults
  @backend.maximum_connections            = DEFAULT_MAXIMUM_CONNECTIONS
  @backend.maximum_persistent_connections = DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS
  @backend.timeout                        = options[:timeout] || DEFAULT_TIMEOUT

  # Allow using Rack builder as a block
  @app = Rack::Builder.new(&block).to_app if block

  # If in debug mode, wrap in logger adapter
  @app = Rack::CommonLogger.new(@app) if Logging.debug?

  @setup_signals = options[:signals] != false
end

def select_backend(host, port, options)
  case
  when options.has_key?(:backend)
    raise ArgumentError, ":backend must be a class" unless options[:backend].is_a?(Class)
    options[:backend].new(host, port, options)
  when options.has_key?(:swiftiply)
    Backends::SwiftiplyClient.new(host, port, options)
  when host.include?('/')
    Backends::UnixServer.new(host)
  else
    Backends::TcpServer.new(host, port) # tcp套接字
  end
end
```

通过`select_backend`来决定服务器套接字类型，我们关注的是`Backends::TcpServer.new(host, port)`，查看`Backends::TcpServer`和`Backends::Base`的代码可以发现`thin`直接使用了`eventmachine`来启动tcp服务器。
并且默认是单线程的，也可以开启多线程，但注意线程安全问题。启动服务器的时候，`eventmachine`有自己的规则。`EventMachine.start_server(@host, @port, Connection, &method(:initialize_connection))`可以看出，
`thin`使用了自己的`Connection`处理请求

```ruby
# https://github.com/macournoyer/thin/blob/master/lib/thin/connection.rb#L30
module Thin
  # Connection between the server and client.
  # This class is instanciated by EventMachine on each new connection
  # that is opened.
  class Connection < EventMachine::Connection # 祖先链 [Thin::Connection, Thin::Logging, EventMachine::Connection, Object, Kernel, BasicObject]
    def post_init; end # 具体代码省略
    def receive_data(data); end
    def unbing; end
  end
end
```

#### 请求到达

当我们的请求到达的时候，比如`curl -i 'http://127.0.0.1:8080'`，依据`eventmachine`的规则： `post_init`，`receive_data(data)`，`unbind`等会先后执行。

```ruby
def post_init
  @request  = Request.new
  @response = Response.new
end
```
在`post_init`中，thin初始化了两个对象，分别是请求和响应。当接收数据时执行`receive_data`

```ruby
def receive_data(data)
      @idle = false
      trace data
      process if @request.parse(data)
    rescue InvalidRequest => e
      log_error("Invalid request", e)
      post_process Response::BAD_REQUEST
end
```

这里首先执行`@request.parse(data)`来解析http协议，主要是http头部，下面细说，然后执行`process`方法

```ruby
def process
  if threaded? # 多线程模式
    @request.threaded = true
    EventMachine.defer(method(:pre_process), method(:post_process)) # callback模式
  else
    @request.threaded = false
    post_process(pre_process) # 单线程，先执行pre_process，再执行`post_process(res)`
  end
end
```

以单线程为例，这里先执行`pre_process`，然后`post_process(res)`，`post_process(res)`只是做一些后续处理，并发送数据到客户端。重要的是`pre_process`

```ruby
def pre_process
  # Add client info to the request env
  @request.remote_address = remote_address

  # Connection may be closed unless the App#call response was a [-1, ...]
  # It should be noted that connection objects will linger until this
  # callback is no longer referenced, so be tidy!
  @request.async_callback = method(:post_process)

  if @backend.ssl?
    @request.env["rack.url_scheme"] = "https"

    if cert = get_peer_cert
      @request.env['rack.peer_cert'] = cert
    end
  end

  # When we're under a non-async framework like rails, we can still spawn
  # off async responses using the callback info, so there's little point
  # in removing this.
  response = AsyncResponse
  catch(:async) do
    # Process the request calling the Rack adapter
    # @request.env包含了http协议解析过后的所有信息
    # Rack::Builder#call(env) 也就是 @app.call(env)方法会调用`to_app`方法
    response = @app.call(@request.env) # 注意此处的app实例，就是我们之前初始化那个 <Rack::Builder:0x00000001059f28 @warmup=nil, @run=App, @map=nil, @use=[#<Proc:0x00000001059000@/home/yy/.rvm/gems/ruby-2.2.3/gems/rack-1.6.4/lib/rack/builder.rb:86>, #<Proc:0x000000010588a8@/home/yy/.rvm/gems/ruby-2.2.3/gems/rack-1.6.4/lib/rack/builder.rb:86>]>
  end
  response
rescue Exception => e
  unexpected_error(e)
  # Pass through error response
  can_persist? && @request.persistent? ? Response::PERSISTENT_ERROR : Response::ERROR
end
```

这里重要的是`@app.call(@request.env)`中的`call`方法，他会调用`to_app`这个重要方法

```ruby
# rack-1.6.4/lib/rack/builder
def to_app
  app = @map ? generate_map(@run, @map) : @run
  fail "missing run or map statement" unless app
  app = @use.reverse.inject(app) { |a,e| e[a] } # 反续执行
  @warmup.call(app) if @warmup
  p app # #<AddTail:0x00000001701bf0 @app=#<ToUpper:0x00000001701c18 @app=App>>
  p @run # App
  p @use # [#<Proc:0x00000000c62f78@/home/yy/.rvm/gems/ruby-2.2.3/gems/rack-1.6.4/lib/rack/builder.rb:86>, #<Proc:0x00000000c62d48@/home/yy/.rvm/gems/ruby-2.2.3/gems/rack-1.6.4/lib/rack/builder.rb:86>]
  app
end

def call(env)
  to_app.call(env)
end
```

通过上面打印的三个变量，可以知道`middleware`和`app`直接形成了一个很深的调用栈.由此可以知道，上面的简单应用的执行顺序是`App` -> `ToUpper` -> `AddTail`.最后`AddTail`执行完毕后就交由`thin`返回给客户端，这是`post_process`做的事情。


#### http协议解析

`thin`使用的是c语言来解析http协议，http协议的解析主要是http头部。其中尤为重要的就是`Content-Length`，具体可以参考[rfc-2616](https://tools.ietf.org/html/rfc2616#page-119).
扩展结构如下

```bash
├── ext
│   └── thin_parser
│       ├── common.rl
│       ├── extconf.rb
│       ├── ext_help.h
│       ├── parser.c
│       ├── parser.h
│       ├── parser.rl
│       └── thin.c
```

其中`.rl`文件是[ragel-Ragel State Machine Compiler](http://www.colm.net/open-source/ragel/)使用的，目的是生成c代码，类似flex和bison的作用。
如果去查看thin的`Request`对象，你会发现它并没有在里面标记http头部的值，这里使用了和c语言共享数据的方法，利用的是c语言的值-结果参数特性。c语言共享数据可以参考[ruby-c-extension-book: chapter5](https://github.com/wusuopu/ruby-c-extension-book/tree/master/zh/chapter05#结构体封装)

#### env对象

env对象是在rack app 和 rack middleware直接无缝传递的关键, 是一个 `[status, headers, body]` 的数组。


#### 待续


#### Reference

* [ruby-c-extension-book](https://github.com/wusuopu/ruby-c-extension-book)
* [eventmachine wiki](https://github.com/eventmachine/eventmachine/wiki)
* [sinatra](https://github.com/bmizerany/sinatra)
* [thin](https://github.com/macournoyer/thin)
* [rack](https://github.com/rack/rack)
* [ragel-Ragel State Machine Compiler](http://www.colm.net/open-source/ragel/)
