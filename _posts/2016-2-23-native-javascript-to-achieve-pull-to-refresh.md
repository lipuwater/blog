---
title: "native javascript to achieve pull to refresh"
date: 2016-2-23
category: tech
tags: [frontend, javascript]
author: zhou
---

不依赖jQuery插件，使用原生javascript实现下拉刷新效果


####参考
移动端touch事件 http://levi.yii.so/archives/3546
页面尺寸，定位 http://blog.csdn.net/fswan/article/details/17238933
demo https://github.com/zhn4/lotuszhn.github.io/tree/gh-pages/spa

####思路
+ 向下滑动时判断页面是否贴近顶部,不是的话不触发下拉刷新效果
+ 在贴近顶部的情况下触发下拉刷新效果
+ 预设的loading元素滑动到一定的距离情况下停止滑动,触发刷新
+ 预设的loading元素滑动距离不足以触发刷新效果的话会回滚并隐藏

####代码
```javascript
window.onload = function() {
	/*
	下拉刷新
	设置move_event对象，包含属性start，move
	touchstart生成move_event.start，记录起始y坐标
	touchmove生成move_event.move，记录移动y坐标
	* 判断doucment.body.scrollTop的距离,标示页面没滚动，可以触发位移的判断
	* move_event.start - move_event.move，判断移动距离，随移动距离增加gif的margin-top距离
	* gif的margin-top距离超过90px就固定在90px
	touchend判断gif移动距离，如果小于90触犯回弹效果并消失，否则触发刷新效果
	*/
	move_event = {};
	document.body.addEventListener('touchstart', function(event) {
		move_event.start = event.touches[0].pageY
	})
	document.body.addEventListener('touchmove', function(event) {
		move_event.move = event.touches[0].pageY
		if(document.body.scrollTop == 0) {
			console.log('可触发上拉刷新')
			if((move_event.move - move_event.start) > 10) {
				var refresh = document.getElementById('refresh')
				refresh.style.display = 'block'
				refresh.style.marginTop = (move_event.move - move_event.start) + 'px'
				if(refresh.style.marginTop.match(/\d+/g)[0] > 90) {
					refresh.style.marginTop = '90px'
				}
			}
		}
	})
	document.getElementById('box').addEventListener('touchend', function(event) {
		var refresh = document.getElementById('refresh')
		if(document.body.scrollTop > 0) {
			if(refresh.style.marginTop) {
				console.log('has')
			}else {
				console.log('has not')
			}
		}else {
			console.log('触发这个')
			if(refresh.style.marginTop.match(/\d+/g)[0] < 90) {
				var time = setInterval(function() {
					refresh.style.marginTop = refresh.style.marginTop.match(/\d+/g)[0] - 2 + 'px'
					if(refresh.style.marginTop.match(/\d+/g)[0] <= 0) {
						clearInterval(time)
					}
					if(refresh.style.marginTop < '0px') {
						refresh.style.display = 'none'
					}
				}, 10)
			}else {
				console.log('触发1.8秒刷新')
				setTimeout(function() {
					window.location.reload(false)
				}, 1800)
			}
		}
	})
}

```
