---
title: "How to navigate source code in ruby?"
date: 2015-12-13
category: tech
tags: [ruby, source_code]
author: flowerwrong
---

ruby是一门动态语言，各种元编程技术层出不穷，所以要找一个向java或者其他静态语言那样的`ide`可谓难如登天，
目前发现的最好用的是[jetbrains](https://www.jetbrains.com/)公司出品的[rubymine](https://www.jetbrains.com/ruby/)。
但效果也不是那么理想。而且`rubymine`价格不菲。对于喜欢轻量级`ide`的程序员来说，无疑各种不爽。

在ruby里面其实有自带的方法可以用来查找源代码。

## `source_location`

```ruby
# rails_app/config/initializers/src.rb
def edit(file, line)
  `atom -n #{file}:#{line}` # 指定行号打开文件
  # `subl #{file}:#{line}`
  # `mate #{file} -l #{line}`
end

def src(object, method)
  if object.respond_to?(method)
    meth = object.method(method)
  elsif object.is_a?(Class)
    meth = object.instance_method(method)
  end
  location = meth.source_location
  if location
    Thread.new { edit(*location) } # 新线程打开，主进程无需等待
  end
  location
rescue NameError => ex
  p ex
  nil
end
```

## Usage

```bash
rails c

src(Article, find)
```


## Reference

* [how-to-find-where-a-method-is-defined-at-runtime](http://stackoverflow.com/questions/175655/how-to-find-where-a-method-is-defined-at-runtime)
* [view-source-ruby-methods](https://pragmaticstudio.com/blog/2013/2/13/view-source-ruby-methods)
* [jimweirich/source_for.rb](https://gist.github.com/jimweirich/4950443)
