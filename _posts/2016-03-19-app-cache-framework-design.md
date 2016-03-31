---
title: "APP缓存框架设计思路"
date: 2016-03-19
category: tech
tags: [缓存, 框架]
author: alafighting
---

无论大型或小型应用，灵活的缓存可以说不仅大大减轻了服务器的压力，而且因为更快速的用户体验而方便了用户。

下面将介绍如何设计一个适合APP的缓存框架：
>- [什么是缓存（Cache）](#what-is-cache)
>- [什么是三级缓存](#what-is-three-level-cache)
>- [缓存置换算法](#page-replacement-algorithm)
>- [缓存命中率](#cache-hit-rate)
>- [提高适用性](#improve-applicability)
>- [缓存解决方案](#solution)

### <div id='what-is-cache'>什么是缓存（Cache）</div>

- 凡是位于速度相差较大的两种硬件之间，用于协调两者数据传输速度差异的结构，均可称之为**`缓存`**（**`Cache`**）。

- 因为内存相对于硬盘读写速度更快，内存可以作为硬盘的缓存；
  同样的，硬盘读写速度远高于网络数据的读写速度，也可以将硬盘作为网络数据的缓存。

- 在内存和硬盘之间，硬盘与网络之间，都存在某种意义上的Cache。

- 表现上，缓存载体与被缓存载体总是相对的，缓存设备成本高于被缓存设备，缓存设备速度高于被缓存设备，缓存设备容量远远小于被缓存设备。

### <div id='what-is-three-level-cache'>什么是三级缓存</div>

- 在网络请求的HTTP协议中，有一套缓存策略，以减少昂贵的网络请求次数，称为`Internet临时文件`或`网络内容缓存`；

- 因为网络不一定总是可用的，或是对实时性要求不高的数据，每次从网络读取数据并非必要的，此时，可以在HTTP协议之外，在磁盘为他再做一层缓存，提高非必要情况下的数据加载速度，暂且就叫他`磁盘缓存`；

- 目前主流的DDR3内存的速度可以达到10GB/S，而硬盘相对的慢了很多数量级别，将硬盘数据加载到内存，为硬盘做一层缓存是很有必要的，这里就叫他`内存缓存`吧。
    
### <div id='page-replacement-algorithm'>缓存置换算法</div>
> 因为缓存成本高于持久容量，所以缓存容量远远小于持久容量，所以当有新的文件要被置换入缓存时，必须根据一定的原则来取代掉适当的文件。此原则即所谓`高速缓存文件置换机制`。

常见的缓存文件置换算法有：

- **`先进先出算法（FIFO）`**：最先进入的内容作为替换对象
- **`最近最少使用算法（LFU）`**：最近最少使用的内容作为替换对象
- **`最久未使用算法（LRU）`**：最久没有访问的内容作为替换对象
- **`非最近使用算法（NMRU）`**：在最近没有使用的内容中随机选择一个作为替换对象
- 其他，包括**变种算法**和**组合算法**

### <div id='cache-hit-rate'>缓存命中率</div>
> 如果没有命中缓存，就需要从原始地址获取，这个步骤叫做“`回源`”
> 回源的代价是高昂的，只有尽可能减少回源才能更好的发挥缓存的作用，但受限于缓存设备的成本，不能仅仅增加缓存容量，只能在成本和回源率之间寻求一个平衡点

### <div id='improve-applicability'>提高适用性</div>
在不同的场景，对缓存的需求也不一样。

- 对于不经常更新的数据，需要适当放宽缓存命中条件；而频繁更新的数据，则要求更严格的命中条件
- 除了常规的提高数据读取速度，也可以借助缓存，优化UI交互，提升用户体验
- 因为缓存设备的成本高昂，结合不同的使用场景，限定缓存容量是很有必要的

以上种种，对于不同场景下的缓存，使用方式也是完全不一样的。
为了更好的适应各种场景，就需要提高缓存的适用性。

### <div id='solution'>缓存解决方案</div>
现在整理一下，如何设计一套能解决上述缓存问题的框架。

*`该缓存框架需要满足以下需求`*：

- `简单易用`：约定大于配置
- `可配置性`：丰富的配置项，能够满足各种复杂场景
- `多级缓存`：为不同的硬件设备，提供不同的缓存级别，充分发挥硬件的特性
- `高命中率`：缓存不可能百分百命中，通过提高算法可以增加命中率，因使用场景不同，使用不同算法以更好适应
- `自动清理`：缓存因过期或容量问题，需要随时清理冗余数据
- `线程管理`：多线程处理，线程间回调处理

*`涉及的技术环节`*：

- `缓存策略`：仅缓存、仅网络、优先缓存、优先网络、先缓存后网络
- `缓存依据`：策略、有效期、容积
- `缓存层级`：Internet临时缓存、磁盘缓存、内存缓存
- `缓存算法`：FIFO、LFU、LRU、NMRU


### *感谢*
- [BlackSwift](http://www.jianshu.com/users/b99b0edd4e77)
- [Wikipedia](https://zh.wikipedia.org/wiki/)
