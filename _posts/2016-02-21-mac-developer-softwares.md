---
title: "Mac developer softwares"
date: 2016-02-21
category: tech
tags: [mac, softwares]
author: flowerwrong
---

首先安装`xcode`，建议直接上app store上下载，速度有点慢，耐心等待。
然后安装`command line tools`，运行 `xcode-select --install` 安装即可。

# 免费软件

## [homebrew](http://brew.sh/): Mac 下超好用的包管理工具

### 基本用法

```zsh
brew -h
brew search mysql
brew install mysql
```

## [homebrew cask](http://caskroom.io/): homebrew 扩展

### 安装

`brew tap caskroom/cask`

### 基本用法

```zsh
brew search google-chrome
brew cask install google-chrome
```

## [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh): 帮助你管理zsh软件的利器
## iTerm2 + tmux: mac terminal 增强
## dash: 查看 api 文档的工具, install via app store
## [atom editor](http://atom.io/)
## [mate 2](https://macromates.com/): rails default editor
## wireshark: 抓包软件

```zsh
brew install wireshark --with-qt
sudo wireshark
```

## [janus(vim)](https://github.com/carlhuda/janus)
## google-chrome: install via brew
## sourcetree: install via brew
## shadowsocks-libev: install via brew
## 图片预览: preview不好用，使用finder替代，点选图片，然后空格键；如果不在乎几十块钱，买xee
## [cheatsheet](https://www.mediaatelier.com/CheatSheet/): know your short custs.

`hold command key for a later`

## [spectacle](https://github.com/eczarny/spectacle): Spectacle allows you to organize your windows without using a mouse. (with Hammerspoon you can del it)

```zsh
alt + command + f => fullscreen
alt + command + > => left side
...
```

## [Hammerspoon](http://www.hammerspoon.org/): I selected, config window manager, hot keys and others in lua.

## tiling window manager(with Hammerspoon you can del theme)

### [Amethyst](https://github.com/ianyh/Amethyst): easy to use
### [kwm](https://github.com/koekeishiya/kwm): configable and nice syntax

```zsh
kwmc help

kwmc space -t bsp # 自动分屏效果
kwmc space -t monocle # 每个窗口都全屏
kwmc space -t float # 不回自动分屏
```

### [more1](http://apple.stackexchange.com/questions/9659/what-window-management-options-exist-for-os-x)
### [more2](https://news.ycombinator.com/item?id=10771186)
### [more3](https://news.ycombinator.com/item?id=8768022)

## [sequel-pro](http://www.sequelpro.com/): mysql gui db management
## [redisdesktop](http://redisdesktop.com/): Cross-platform open source Redis DB management tool
## [OBS](https://obsproject.com/): Free, open source software for live streaming and recording
## [eclipse-cpp](http://www.eclipse.org/downloads/packages/eclipse-ide-cc-developers/mars2): eclipse for c/c++ developer
## [go2shell](http://zipzapmac.com/go2shell)

### config

`open -a Go2Shell --args config`

## [glances](https://github.com/nicolargo/glances): 流量统计工具
## [macdown](http://macdown.uranusjr.com/): MacDown is an open source Markdown editor for OSX
## [sketch](https://www.sketchapp.com/)

### [sketch-toolbox](http://sketchtoolbox.com/)

## [iconjar](http://geticonjar.com/): Organize, search and use icons the easy way.

# 开发环境


## api doc

* dash for mac: need money
* [zeal](https://github.com/zealdocs/zeal) for windows and linux: open source
* [devdocs](https://github.com/Thibaut/devdocs) for all

## nodejs

`brew install nodejs`

## ruby

1. install [rvm](http://rvm.io/)
2. `rvm install ruby-2.3.0`
3. `rvm use ruby-2.3.0 --default`

## java

`brew cask install java`

## database

```zsh
brew install mysql
brew install redis
```

## 开机启动

```zsh
# redis
ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist

# mysql
ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

## Terminal 技巧

* ctrl + a:移动光标的开头
* ctrl + e:移动光标的末尾
* shift + esc + b:向前按单词移动光标
* shift + esc + f:向后按单词移动光标
* 光标移动速度: 系统偏好设置->键盘->按键重复快，按键前延迟慢
* 目录跳转 `autojump` oh-my-zsh plugin. Usage: `j -h`

## 桌面技巧

* tiling window manager with hammerspoon plugin [hs.tiling](https://github.com/dsanson/hs.tiling)
* 可以添加桌面，快捷键是 ctrl + 上方向键 或者 F3，然后点击 + 号
* ctrl + 左右方向键 切换桌面

# 待续
