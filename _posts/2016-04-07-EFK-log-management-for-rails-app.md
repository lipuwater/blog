---
title: "EFK log management system"
date: 2016-04-07
category: tech
tags: [EFK log elasticsearch kibana fluentd]
author: flowerwrong
---

# EFK log management system

## What's EFK?

EFK are a collection of open source tools for log management system.
There are 3 softwares in it.

* [elasticsearch](https://www.elastic.co/products/elasticsearch): Search & Analyze Data in Real Time
* [fluentd](http://www.fluentd.org/): A data collector for unified logging layer
* [kibana](https://www.elastic.co/products/kibana): Explore & Visualize Your Data

## EFK VS ELK

I do not know.

## Rails demo

You can see a rails demo in [Collecting and Analyzing Ruby on Rails Logs](http://www.fluentd.org/datasources/rails).

## Install EFK for mac

```bash
wget https://download.elastic.co/kibana/kibana/kibana-4.5.0-darwin-x64.tar.gz
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.1/elasticsearch-2.3.1.tar.gz

tar -zxvf kibana-4.5.0-darwin-x64.tar.gz
tar -zxvf elasticsearch-2.3.1.tar.gz

gem install fluentd --no-ri --no-rdoc
```

## Usage

1. start elasticsearch
2. start kibana
3. start fluentd
4. start rails app

## Auth

If you want to auth elasticsearch and kibana, you can use [shield](https://www.elastic.co/products/shield).

```bash
cd path_to_elasticsearch
# install shield
./bin/plugin install license
./bin/plugin install shield

# start elasticsearch
./bin/elasticsearch

# add user to admin group
./bin/shield/esusers useradd es_admin -r admin
# test it
curl -u es_admin -XGET 'http://localhost:9200/'

# shield for kibana
# add user to kibana4_server group
./bin/shield/esusers useradd kibana4-server -r kibana4_server

# config path_to_kibana/config/kibana.yml
elasticsearch.username: kibana4-server
elasticsearch.password: your_pass_word

# Also you can add more user just for different privileges, shield is powerful.
```

## Some config file

#### Gemfile

```ruby
gem 'fluentd'
gem 'act-fluent-logger-rails'
gem 'lograge'
# fluentd plugins
gem 'fluent-plugin-elasticsearch'
gem 'fluent-plugin-parser'
```

#### fluent.conf

```
<source>
  type forward
  port 24224
</source>
<match neeqdc>
  type parser
  key_name messages
  format json
  tag rails
</match>
<match rails>
  type elasticsearch
  # user yang
  # password yang123
  # host localhost
  # port 9200
  logstash_format true
</match>
```


#### production.rb

```ruby
# log
config.log_level = :info
config.logger = ActFluentLoggerRails::Logger.new
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new
config.lograge.custom_options = lambda do |event|
  unwanted_keys = %w(format action controller)
  params = event.payload[:params].reject { |key, _| unwanted_keys.include? key }

  opts = {
    ip: event.payload[:ip],
    app: 'neeqdc',
    params: params,
    user_agent: event.payload[:user_agent],
    env: Rails.env,
    log_time: Time.now
  }

  # Thx https://gist.github.com/bf4/5911868
  if event.payload[:exception]
    quoted_stacktrace = %Q('#{Array(event.payload[:stacktrace]).to_json}')
    opts[:stacktrace] = quoted_stacktrace
  end
  opts
end
```

#### application_controller.rb

```ruby
# for lograge
def append_info_to_payload(payload)
  super
  payload[:ip] = request.headers['HTTP_X_REAL_IP'] || request.remote_ip
  payload[:params] = request.params
  payload[:user_agent] = request.env['HTTP_USER_AGENT'] || request.user_agent
end
```

#### There is a bug in [act-fluent-logger-rails](https://github.com/actindi/act-fluent-logger-rails) gem, so I add a monkey patch.

```ruby
# config/initializers/logger_monkey_patch.rb
# https://github.com/actindi/act-fluent-logger-rails/blob/master/lib/act-fluent-logger-rails/logger.rb

# -*- coding: utf-8 -*-
require 'json'

module ActFluentLoggerRails
  class FluentLogger

    def add_message(severity, message)
      @severity = severity if @severity < severity

      message =
        case message
        when ::String
          message
        when ::Exception
          message
        else
          message.inspect
        end

      begin
        JSON.parse message
        if message.encoding == Encoding::UTF_8
          @messages << message
        else
          @messages << message.dup.force_encoding(Encoding::UTF_8)
        end
      rescue => e
        unless @messages.blank?
          message_json_hash = JSON.parse @messages[0]
          message_json_hash[:stacktrace] = message
          @messages[0] = message_json_hash.to_json
        end
      end

      flush if @flush_immediately
    end

  end
end
```
