---
title: "Bubble Sort in Ruby and Erlang"
date: 2015-12-11
category: tech
tags: [ruby, bubble_sort, erlang]
author: flowerwrong
---

#### 定义

1. 比较相邻的元素。如果第一个比第二个大，就交换他们两个。
2. 对每一对相邻元素作同样的工作，从开始第一对到结尾的最后一对。在这一点，最后的元素应该会是最大的数。
3. 针对所有的元素重复以上的步骤，除了最后一个。
4. 持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较

#### 平均时间复杂度O(n2)

* 初始化为正序: O(n)
* 初始化为反序: O(n2)

#### 实现

```ruby
def bubble_sort(array)
  return array if array.size < 2
  (array.size - 2).downto(0) do |i|
    (0 .. i).each do |j|
      array[j], array[j + 1] = array[j + 1], array[j] if array[j] >= array[j + 1]
    end
  end
  return array
end
```

```erlang
-module(sort).

-export([bubble_sort/1]).

bubble_sort(L)->
  bubble_sort(L, length(L)).

bubble_sort(L, 0)->
  L;
bubble_sort(L, N)->
  bubble_sort(do_bubble_sort(L), N - 1).

do_bubble_sort([A])->
  [A];
do_bubble_sort([A, B | R])->
  case A < B of
    true -> [A | do_bubble_sort([B | R])];
    false -> [B | do_bubble_sort([A | R])]
  end.
```
