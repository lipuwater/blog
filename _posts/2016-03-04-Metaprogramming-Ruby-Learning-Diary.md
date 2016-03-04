---
title: "Metaprogramming Ruby Learning Diary"
date: 2016-03-04
category: tech
tags: [ruby]
author: linyunjiang
---

# (1)instance_eval vs class_eval

先简单说下实例方法和类方法的区别,
实例方法即需要先定义一个实例,才能调用方法,例如:

```ruby
class A
  def fun
    puts 'A'
  end
end
a = A.new
a.fun
#=> A
```

类方法则可以直接

```ruby
class B
  def self.fun
    puts 'B'
  end
end
B.fun
#=> B
```

回到instance_eval和class_eval,正如字面上看到的,instance_eval的receiver必须为实例instance,
class_eval的receiver必须为class
1.instance_eval:

例1:

```ruby
class C
end
c = C.new
c.instance_eval do
  def c_inst
    puts 'c_inst'
  end
end

调用c.c_inst
#=> c_inst
c.single_methods
#=> [:c_inst]
```

另外类class本身也是Class类的一个实例,

例二:

```ruby
class C
end
C.instance_eval do
  def c_inst
    puts 'c_inst'
  end
end
调用C.c_inst
#=> c_inst
C.single_methods
#=> [:c_inst]
```

2.class_eval:
例三:

```ruby
class D
end
D.class_eval do
  def d_cla
    puts 'd_class_eval'
  end
end
调用D.d_cla
#=> NoMethodError: undefined method `d_cla' for D:Class

d = D.new
d.d_cla
#=> d_class_eval
d.singleton_methods
#=> []
```
由例一例二例三,再结合实例方法和类方法的区别,我们可以知道
instance_eval可以用来定义单态函数singleton_methods,class_eval可以用来定义实例函数instance_methods

### 待续



