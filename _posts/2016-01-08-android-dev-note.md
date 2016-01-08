---
title: "Andriod Dev Note"
date: 2016-01-08
category: tech
tags: [android, note]
author: nekocode
---

- [Android gradle tasks](http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Android-tasks)
- [gradle plugin user guide chinese](https://avatarqing.gitbooks.io/gradlepluginuserguidechineseverision/content/introduction/README.html)
- [Fragment 的一些讲解](http://blog.csdn.net/lmj623565791/article/details/42628537)
- http://blog.mohitkanwal.com/blog/2015/03/07/styling-material-toolbar-in-android/
- android 3.0 版本后 `AsyncTask` 改为默认串行执行：http://droidyue.com/blog/2014/11/08/bad-smell-of-asynctask-in-android/
- android 注意内存泄露问题：http://droidyue.com/blog/2015/04/12/avoid-memory-leaks-on-context-in-android/
- [androiddevtools](http://www.androiddevtools.cn/)
- [react native](http://blog.csdn.net/zhe13/article/details/48439967?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)

```java
//TODO 放缩处理、显示操作层
eyeAdjustView.setVisibility(View.VISIBLE);
btnViewAdjust.setTag(true);

Matrix matrix = new Matrix();
float minY = Math.min(eyesInfo.p[0].y, eyesInfo.p[5].y);
float maxY = Math.max(eyesInfo.p[0].y, eyesInfo.p[5].y);
float w = eyesInfo.p[5].x - eyesInfo.p[0].x;
float minX = eyesInfo.p[0].x - w * 0.25f;
float maxX = eyesInfo.p[0].x + w * 1.25f;

//rect 范围空间不能为 0
if(minY == maxY) maxY++;
if(minX == maxX) maxX++;

RectF mTempSrc = new RectF(minX, minY, maxX, maxY);
RectF mTempDst = new RectF(0, 0, imageView.getWidth(), imageView.getHeight());
matrix.setRectToRect(mTempSrc, mTempDst, Matrix.ScaleToFit.CENTER);
imageView.setImageMatrix(matrix);
imageView.invalidate();

eyeAdjustView.setFeatures(matrix, eyesInfo, imageView);
```

- 设置 ITALIC 需要将字体的 Typeface 设置为 MONOSPACE 
- 需要 context 的地方（非 UI）尽量使用 ApplicationContext ，而不是传 Activity:Context，因为有可能会导致 activity 无法被回收（内存泄露）
- **ViewPager 不应该使用 getScrollX() 获取当前滑动的 X 坐标**，因为在 ViewPager 所在 Fragment 进行 Resume/Recreate 的时候（例如屏幕旋转），无论 currentItem 为多少，scrollX 都会被置零，所以应该通过 **OnPageChangeListener** 来计算出真实的 scrollX：
```
// ...
@Override
public void onPageScrolled(int position, float positionOffset,
        int positionOffsetPixels) {
    scrollX = position * mViewpager.getWidth() + positionOffsetPixels;
    invalidate();

    Log.e("TAG", String.format("onPageScrolled: %d, %f, %d", position, positionOffset, positionOffsetPixels));
        
    if (mViewPagerOnPageChangeListener != null) {
        mViewPagerOnPageChangeListener.onPageScrolled(position, positionOffset,
                positionOffsetPixels);
    }
}
// ...
```


## Java

- [Grails：约定优于配置](http://www.infoq.com/cn/articles/case-study-grails-partii/)   
举个简单的例子。在 Django 1.3 之后引入了「Class-based view」，有「ListView」和「DetailView」。Django 的「ListView.as_view(model=Publisher,)」不需要指定去 render 哪个template，而是自动去使用了「/path/to/project/books/templates/books/publisher_list.html」这个模板。这即是 **convention over configuration** 的一个典型示范。优先使用默认的约定，而不是非要明确的指定要 render 的 template。


- kotlin：**`限制优于约定`**   
nullable 和 notnullable、var 和 val 等。语法上限制比口头约定更不易造成潜在 bug。


- Java 线程锁：http://blog.csdn.net/ghsau/article/details/7461369/
- [Java 内部类会隐式持有外部类实例的引用](http://droidyue.com/blog/2014/10/02/the-private-modifier-in-java/)

####泛型
- Java 实现泛型的方法是 **类型擦除**。使用这种实现最主要的原因是为了向前兼容，这种实现方式有很多缺陷。与 C# 中的泛型相比，Java 的泛型可以算是 **"伪泛型"** 了。在 C# 中，不论是在程序源码中、在编译后的中间语言，还是在运行期泛型都是真实存在的。**Java则不同，Java的泛型只在源代码存在** ，只供编辑器检查使用，编译后的字节码文件已擦除了泛型类型，同时在必要的地方插入了强制转型的代码。   

```java
//泛型代码：
public static void main(String[] args) {  
    List<String> stringList = new ArrayList<String>();  
    stringList.add("oliver");  
    System.out.println(stringList.get(0));  
}  

//将上面的代码的字节码反编译后：
public static void main(String args[])  
{  
    List stringList = new ArrayList();  
    stringList.add("oliver");  
    System.out.println((String)stringList.get(0));  
}
```


## Kotlin


### 入门
- [Kotlin 在线编译器](http://try.kotlinlang.org/#/Examples)
- [Getting started with Android and Kotlin](http://kotlinlang.org/docs/tutorials/kotlin-android.html)
- [Working with Kotlin in Android Studio](http://blog.jetbrains.com/kotlin/2013/08/working-with-kotlin-in-android-studio/)
- [Kotlin 中文博客教程](http://my.oschina.net/yuanhonglong/blog?catalog=3333352)
- https://docs.google.com/document/d/1ReS3ep-hjxWA8kZi0YqDbEhCqTt29hG8P44aA9W0DM8/preview?hl=en&forcehl=1&sle=true

### Note

```kotlin
val a: Int = 10000
print(a === a) // Prints 'true'
val boxedA: Int? = a
val anotherBoxedA: Int? = a
print(boxedA === anotherBoxedA) // !!!Prints 'false'!!!

// ====

val a: Int = 10000
print(a == a) // Prints 'true'
val boxedA: Int? = a
val anotherBoxedA: Int? = a
print(boxedA == anotherBoxedA) // Prints 'true'

// ====

val a: Int = 10000
val boxedA: Int = a
val anotherBoxedA: Int = a
print(boxedA === anotherBoxedA) // Prints 'true'
```

- [kotlin_android_base_framework](https://github.com/nekocode/kotlin_android_base_framework)
- [github.com/JetBrains/anko](https://github.com/JetBrains/anko)
- [kotlinAndroidLib (android studio plugin)](https://github.com/vladlichonos/kotlinAndroidLib)


```kotlin
public var heightScale: Float = 0.8f
    set(value) {
        $heightScale = value
        this.requestLayout()
    }
// backing filed syntax is deprecated, user 'field' instead
public var heightScale: Float = 0.8f
    set(value) {
        field = value
        this.requestLayout()
    }
```