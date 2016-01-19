---
title: "Vim primer for Rubist"
date: 2016-01-19
category: tech
tags: [vim, ruby, rails]
author: Ruchee
---

## 引子

`Vim` 是一个古老而又强大的编辑器，虽说现在各种现代化的编辑器和 `IDE` 层出不穷，但 `Vim` 历久弥新，魅力依旧

本文为想入门 `Vim` 的 `Ruby` 程序员提供指导，但具体修行还得看个人

`Vim` 本质上只是个工具，自己多用、勤用总归都是能掌握的，不要被网上传言的入门门槛吓倒

---

## 安装

- `Windows`：访问 `http://www.vim.org/download.php#pc` 下载适合自己系统的版本，双击按步骤安装即可
- `Mac OSX`：`brew install macvim ctags`
- `Ubuntu`：`sudo apt-get install vim-gtk exuberant-ctags`
- `其他Linux发行版`：使用 `yum` 或从源码进行安装

---

## 装好了，该怎么学呢？

先掌握几个基本的按键，知道怎么进入、退出和移动

- `i`：进入插入模式，开始输入内容（`Vim` 是一个多模式的编辑器，默认看到的是 `Normal` 模式，输入 `i` 进入 `Insert` 模式，此外还有个 `Visual` 模式。文件的编辑工作基本都在 `Insert` 模式下完成）
- `a`：同样是进入插入模式，但是在当前光标后面开始插入（`i` 在光标之前，`a` 在光标之后，`I` 在光标所在行的最开始，`A` 在光标所在行的最末尾）
- `<ESC>`：这是指按键盘的 `ESC` 键，这会回到 `Normal` 模式
- `:q`：这个需要在 `Normal` 模式下键入，用来退出 `Vim`
- `:q!`：后面加个感叹号代表强制退出，不管文件有没有保存
- `:wq!`：关闭所有缓冲区，并强制退出（`Vim` 每开一个文件编辑窗口就对应一个缓冲区）

`Vim` 里面的移动主要是指在 `Normal` 模式下怎么移动光标

- `h`：向左移动一格
- `j`：向下移动一格
- `k`：向上移动一格
- `l`：向右移动一格

`H J K L` 这四个按键是 `Vim` 里面使用最频繁的按键，虽说小键盘上的方向键也一样可以使用，但要想实现快速编码，必须熟悉并只使用 `H J K L`

知道怎么进入、退出和移动了？`Vim` 准备了一个极佳的交互式教程在等着你，名字叫做 `vimtutor`

`Windows` 用户在装完 `Vim` 后应该可以看到一个 `vimtutor` 的快捷键，双击即可；而 `Mac OSX` 和 `Linux` 用户可以在命令行键入 `vimtutor` 来打开这个教程

`vimtutor` 曾助无数 `Vim` 爱好者进入 `Vim` 的殿堂，请务必多练习几次，尽可能地熟悉里面介绍的全部按键和技巧

---

## 进阶

很多人在了解 `Vim` 的基本用法以后，还是完全不知道这货该怎么用在实际工作中，要啥没啥，感觉啥也干不了

有这种感觉是对的，因为 `Vim` 安装完后的初始状态就是一个白板，一切都需要自己去配置，配置好了才能助自己高效工作

对初学者来说，我的建议是先 `copy` 一个别人配置好的环境，用会再说，熟悉后再逐个配置项去看别人为什么这么配，并逐步修改为更适合自己的配置

这是我的配置，可以按说明安装和使用：[https://github.com/ruchee/vimrc](https://github.com/ruchee/vimrc)

国外还有个很出名的配置也推荐一试：[https://github.com/spf13/spf13-vim](https://github.com/spf13/spf13-vim)

---

## Ruby程序员怎么使用Vim

我的两件武器

- `snipMate`：语法补全
- `ctags`：单词补全 + 方法定义跳转

通用 `tags` 文件生成命令：`ctags -R --languages=ruby Ruby项目所在路径`

下面的 `Ruby` 脚本用来生成所有安装的 `gem` 的 `tags` 文件，如果安装了一个 `gem` 的多个版本，使用其版本号更高的

```ruby
#!/usr/bin/env ruby

@dirs = {}
Dir.entries(__dir__ + '/gems').each do |dir|
  unless ['.', '..'].include?(dir)
    dir.match(/^(.*?)-(\d+\.\d+\.\d+)$/) do |match|
      name = match[1]
      version = match[2]

      if @dirs[name]
        if Gem::Version.new(version) > Gem::Version.new(@dirs[name])
          @dirs[name] = version
        end
      else
        @dirs[name] = version
      end
    end
  end
end

@cmd = 'ctags -R --languages=ruby'
@dirs.each do |name, version|
  @cmd += " ./gems/#{name}-#{version}"
end

system @cmd
```

下面是我 `MacBook` 上的 `tags` 设置信息，以供参考（`set tags` 语句是需要写在 `Vim` 配置文件里面的，比如 `Mac OSX` 中就是 `~/.vimrc` 文件）

```vim
set tags+=~/code/company/liveneeq2/tags
set tags+=/usr/local/lib/ruby/tags
set tags+=/usr/local/lib/ruby/gems/2.3.0/tags
```

---

## 题外话

其实现在我并不怎么推荐新人学 `Vim`，因为一旦上了这个船再想下船就难了，而现代化的 `IDE` 对工程项目更为友好，学习和迁移成本也更低

---
