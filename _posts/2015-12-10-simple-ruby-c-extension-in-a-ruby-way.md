---
title: "Simple Ruby C Extension in a Ruby Way"
date: 2015-12-10
category: tech
tags: [ruby, c-extension, c]
author: flowerwrong
---

[上一篇文章](http://blog.liveneeq.com/tech/2015/12/08/simple-ruby-ffi-demo.html)写了使用`ruby-ffi` gem来编写c扩展的方法，这种方法比较简单。这篇文章将介绍[官方的方法](https://github.com/ruby/ruby/blob/trunk/doc/extension.rdoc)来编写一个简单的c扩展。
本文延续上文，写一个简单的求和扩展。[源码](https://github.com/FlowerWrong/ffi-demos/tree/master/ruby-ext/ext/demo)地址.

#### Main c api

```c
VALUE rb_define_class(const char *name, VALUE super) // 创建ruby的class
VALUE rb_define_module(const char *name) // 创建ruby的moudle

VALUE rb_define_class_under(VALUE outer, const char *name, VALUE super) // 创建子类, 可以是class的, 也可以是module的
VALUE rb_define_module_under(VALUE outer, const char *name) // 创建子module

void rb_define_method(VALUE klass, const char *name, VALUE (*func)(), int argc) // 创建方法
void rb_define_singleton_method(VALUE object, const char *name, VALUE (*func)(), int argc) // 创建单例方法

void rb_define_module_function(VALUE module, const char *name, VALUE (*func)(), int argc) // 定义module方法

void rb_define_global_function(const char *name, VALUE (*func)(), int argc) // 定义kernel module的方法

void rb_define_const(VALUE klass, const char *name, VALUE val) // 定义常量
void rb_define_global_const(const char *name, VALUE val) // 定义全局常量
```

#### 代码骨架

```bash
└── ruby-ext
    └── ext
        └── demo
            ├── demo.c
            ├── extconf.rb
            └── README.md
```

#### 代码解析

###### demo.c

demo.c包括了c语言的求和函数 `int sum(int a, int b)`, 包裹函数 `VALUE demo_sum(VALUE self, VALUE aa, VALUE bb)` 以及ruby扩展的初始化函数 `void Init_Demo()`.

```c
#include "ruby.h" // 使用ruby c api

int sum(int a, int b); // c语言的求和函数

VALUE demo_sum(VALUE self, VALUE aa, VALUE bb); // 求和函数的包裹函数

int sum(int a, int b) {
  return a + b;
}

VALUE demo_sum(VALUE self, VALUE aa, VALUE bb) {
  int res = sum(FIX2INT(aa), FIX2INT(bb));
  return INT2FIX(res);
}

void Init_Demo() { // 扩展初始化函数, 在模块首次加载时执行, 所有c扩展都要定义一个名为Init_extname的函数
  VALUE module;
  module = rb_define_module("Demo"); // 创建模块
  rb_define_method(module, "demo_sum", demo_sum, 2); // 创建模块方法
}
```

上面的代码类似ruby中的:

```ruby
module Demo
  def demo_sum(a, b)
    a + b
  end
end
```

###### extconf.rb

```ruby
require 'mkmf'


extension_name = 'Demo' # 模块名
create_makefile(extension_name) # 创建Makefile
```

#### 安装使用

###### Install

```bash
ruby extconf.rb
make
sudo make install
```

###### Usage in irb

```irb
require 'Demo'
include Demo
demo_sum(1, 4) # => 5
```

#### Reference

* [The ruby c api](https://silverhammermba.github.io/emberb/c/)
* [How to make extension libraries for Ruby](https://github.com/ruby/ruby/blob/trunk/doc/extension.rdoc)
* [write-ruby-extension-with-c](https://www.gitbook.com/book/wusuopu/write-ruby-extension-with-c/details)
