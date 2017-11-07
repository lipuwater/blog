---
title: "android ble log"
date: 2017-11-07
category: tech
tags: [android, ble, log]
author: flowerwrong
---

## 环境搭建

```bash
# install android-platform-tools
brew cask install android-platform-tools

# hci log 配置文件
cat /etc/bluetooth/bt_stack.conf
```

## 修改 `/etc/bluetooth/bt_stack.conf` 文件配置，开启hci log

```bash
cd ~/Downloads
adb pull /etc/bluetooth/bt_stack.conf
vim bt_stack.conf
```

配置文件注意事项

```
# Enable BtSnoop logging function
# valid value : true, false
BtSnoopLogOutput=false // 开启关闭日志

# BtSnoop log output file
BtSnoopFileName=/sdcard/btsnoop_hci.log // 日志保存路径

# 日志级别等等
```

写入配置文件

```bash
# 避免 remote Read-only file system
adb root
adb remount
adb push bt_stack.conf /etc/bluetooth/
```

正常使用蓝牙

```
adb pull /sdcard/btsnoop_hci.log
```

## 日志分析

open with wireshark
