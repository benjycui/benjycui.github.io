---
layout: article
title: 打酱油的identity与noop
category: programming
---

在编程中，一个函数，往往是一个功能的抽象，也就是说一个函数应该完成一些具体的任务，如strlen用来计算字符串的长度，printf把字符串输出到终端。但有那么两个函数，本身并没有实现什么功能，却依然有不少的使用场景，它们就是identity(恒等)与noop(no operation的缩写)。

刚接触这两个函数的时候，实在想不通这样的函数有什么用，所以感觉他们就是打酱油的。直到最近，才开始有点理解这两个函数。

### identity函数

identity只做一件事，就是直接把传入的参数返回，源码如下：

{% highlight javascript %}
var identity = function (anything) {
  return anything;
};
{% endhighlight%}

很难想像这么一个简单的函数能有什么应用，好吧，应用场景不多，但还是有的。

#### 1. 数组浅拷贝/类数组转为数组

主流的方法应该是使用slice函数：

{% highlight javascript %}
var generated = [].slice.call(original);
{% endhighlight%}

而用identity后就会如下：

{% highlight javascript %}
var generated = [].map.call(original, identity);
{% endhighlight%}

个人觉得还是用slice比较简单，不过[underscore.js](https://github.com/jashkenas/underscore/blob/master/underscore.js)的_.toArray使用的是后一种方式。

#### 2. 稀疏数组转为密集数组

在v8中，稀疏数组会自动转为哈希表的形式存储，这样的好处是节省内存，不过访问速度会有所降低。而underscore.js提供了一个把稀疏数组转为密集数组的_.compact：

{% highlight javascript %}
_.compact = function(array) {
  return _.filter(array, _.identity); // _.filter的功能类似于[].filter.call
};
{% endhighlight%}

#### 3. es5-sham.js中的应用

es5-shim能够为老旧浏览器模拟ES5的特性，而[es5-sham.js](https://github.com/es-shims/es5-shim/blob/master/es5-sham.js)是其中的一个文件。es5-sham.js中有以下代码：

{% highlight javascript %}
if (!Object.seal) {
  Object.seal = function seal(object) {
    return object;
  };
}
{% endhighlight%}

Object.seal是ES5提供的新函数，具体的作用可以看一下[John Resig的文章](http://ejohn.org/blog/ecmascript-5-objects-and-properties/)。这里只要知道Object.seal为传入的对象增添了一些特性然后返回，并且这些特性是用旧版js无法模拟的就行。

既然是无法模拟的，那么这个shim脚本在设计时就有以下两种选择：

1. 不为Object.seal做任何的模拟，但是这样用户在使用Object.seal时就必须先做对象检测。

2. 就像es5-sham.js中这样，实现一个identity函数，虽然没有原生Object.seal应有的功能，但省去了做对象检测的麻烦。

### noop函数

好吧，identity只做一件事，而noop干脆什么都不做了，它会忽略所有的输入，不做任何事情。

{% highlight javascript %}
var noop = function () {};
{% endhighlight%}

不过这样的函数依然有使用的价值，如在Koa中。

稍微看一下源码，就会发现Koa的Middleware中都会有`yield *next;`这行代码，这行代码保证了Koa所有的Middleware都会调用下一个(next)Middleware：

`Middleware-1 -> Middleware-2 -> N个Middleware -> Last Middleware`

但是怎么知道后面是否还有Middleware可以调用呢？让每个Middleware的开发者都去做判断不大现实，所以Koa保证了最后的Middleware一定noop，代码如下：

{% highlight javascript %}
function compose(middleware){
  return function *(next){
    if (!next) next = noop();

    var i = middleware.length;

    while (i--) {
      next = middleware[i].call(this, next);
    }

    yield *next;
  }
}
{% endhighlight%}

因为noop不会做任何的事情，保证了Middleware的调用会在这里结束。

### 总结

学了几年的编程，做了一些项目后，发现已经无法再像以前那样只顾着实现功能了，更多的是要关注一些与功能无关的点。如es5-sham.js中，把代码写成这样：

{% highlight javascript %}
Object.seal = function seal(object) {
  return object;
};
{% endhighlight%}

与这样：

{% highlight javascript %}
Object.seal = function (object) {
  return object;
};
{% endhighlight%}

两者在功能上是一样的，但是如果有出错的话，命名函数(前者)明显比匿名函数(后者)更容易定位错误。
