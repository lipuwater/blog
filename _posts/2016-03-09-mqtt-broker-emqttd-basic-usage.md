---
title: "mqtt broker emqttd basic usage"
date: 2016-03-09
category: tech
tags: [mqtt, server]
author: flowerwrong
---

[Emqttd](http://emqtt.io/) is a clusterable, massively scalable, and extensible MQTT V3.1.1 broker written in Erlang/OTP.

## Install

1. download at http://emqtt.io/downloads
2. unzip it

## Usage

```bash
# Start console
./bin/emqttd console

# Start as daemon
./bin/emqttd start

# Check status
./bin/emqttd_ctl status

# Stop
./bin/emqttd stop
```

## Config

* [auth with username and pass, disable anonymous](https://github.com/emqtt/emqttd/wiki/Authentication#authentication-with-username-password)
* [/etc/init.d/emqttd](http://docs.emqtt.com/en/latest/install.html#etc-init-d-emqttd)

## Admin

```bash
sudo service emqttd status | start | stop | restart
```

## Dashboard

go to http://localhost:18083

## Test client

```ruby
# pub.rb
require 'rubygems'
require 'mqtt'

user_name = 'demo'
pass = 'demo'
host = '127.0.0.1'
$mqtt_host = "mqtt://#{user_name}:#{pass}@#{host}"

MQTT::Client.connect($mqtt_host, will_qos: 2, will_retain: false) do |client|
  p client.will_qos
  p client.will_retain
  p "sent msg The time is: #{Time.now} to topic demo"
  client.publish('demo', "The time is: #{Time.now}", false, 1)  # qos 1
end


# sub.rb
require 'rubygems'
require 'mqtt'

user_name = 'demo'
pass = 'demo'
host = '127.0.0.1'
$mqtt_host = "mqtt://#{user_name}:#{pass}@#{host}"

MQTT::Client.connect($mqtt_host, will_qos: 2, will_retain: false, clean_session: false, client_id: '1') do |client|
  client.get('demo') do |topic, message|
    puts "#{topic}: #{message}"
  end
end
```