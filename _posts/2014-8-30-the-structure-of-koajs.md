---
layout: article
title: 初探Koa架构
category: js
---

在最近的一个项目中，nodejs端使用了[Koa](http://koajs.com/)，然后因为自己一向有看源码的习惯，所以把Koa的源码也稍微分析了一下，并整理了各部份之间的关系，以下是对这次学习的梳理。

### 简介
官方给Koa的定义是 *next generation web framework for node.js* ，而能充分体现 **next generation** 的莫过于Koa对ES6 Generator Function的**极致**使用。首先Koa强依赖于[co](https://github.com/visionmedia/co) -- 一个基于Generator Function与Yieldables以允许用户编写顺序风格异步代码的库（囧~好拗口，语言能力差呐……），同时它的所有的Middleware本质上都是一个Generator Function，最后，Koa Middleware之间的调用是通过Generator Function内部才能使用的Yield Expression。所以要理解Koa就必须先了解Generator Function，对于不知道什么是Generator Function的同学，建议先阅读[《Generator 函数》](http://es6.ruanyifeng.com/#docs/generator)和[《初探ES6 -- Promise与Generator》](http://benjycui.com/js/2014/08/23/first-glance-at-promise-and-generator-of-es6.html)。

### 结构分析
Koa由以下四个模块组成 -- 当然，也使用了一些外部模块如co，[koa-compose](https://github.com/koajs/compose)。

{% highlight shell %}
/lib
├── application.js
├── context.js
├── request.js
└── response.js
{% endhighlight%}

下面是Koa的官方例子：

{% highlight javascript %}
var koa = require('koa'); // 1. koa = application.exports
var app = koa();

// logger

app.use(function *(next){ // 2. 第一个Middleware
  var start = new Date;
  yield next;
  var ms = new Date - start;
  console.log('%s %s - %s', this.method, this.url, ms);
});

// response

app.use(function *(){ // 第二个Middleware，第几个use就是第几个Middleware
  this.body = 'Hello World'; // 3. this = new context.exports()
});

app.listen(3000);
{% endhighlight%}

1. 当程序执行到`var koa = require('koa');`时，返回的对象`koa`就是application.js的`exports`。

2. 每个Middleware的本质就是一个Generator Function，并且第几个use就是第几个Middleware，因为在Koa内部是使用数组存储Middleware的，所以有着严格的顺序。

3. 每当koajs接收到一个请求，就会新建一个`context.exports`的实例，并传给第一个Middleware -- 然后会依次传给后面的Middleware，其实这个实例就是我们在Middleware内使用的`this`所指向的对象。下面代码来自application.js：

{% highlight javascript %}
app.callback = function(){
  // 省略一些代码。。。
  return function(req, res){
    res.statusCode = 404; // 注：所有请求的状态码一开始都是404，
                          // 直到后面的Middleware根据响应的情况修改状态码。
    var ctx = self.createContext(req, res); // 每收到一个请求就生成一个新的context。
    onFinished(res, ctx.onerror);
    fn.call(ctx, ctx.onerror); // 传给第一个Middleware。
  }
};
{% endhighlight%}

在官方示例中没有使用到的两个对象分别是`this.request`和`this.response`，这两个对象分别是`request.exports`和`response.exports`的实例，所以context是包含了request与response对象。与[connect](https://github.com/senchalabs/connect)的一个不同在于，Koa并没有修改http模块传过来的`req`与`res`对象，而是分别在request.js与response.js两个模块内对其进行一层包装。

最后，用一张图片总结：

![Koajs处理并响应浏览器请求](/upload/images/how-the-koa-process-request.png)
