---
layout: article
title: 初探ES6 -- Promise与Generator
category: js
---

在ES5都还没有完全普及的时候，ES6标准就基本确定了，并且浏览器也已经部分实现了其中的特性。而在我一个多月的开发过程中，用得比较多的两个特性就是Promise与Generator。所以本文会试着去总结一下我对Promise与Generator的理解，以及在使用过程中碰到的一些困惑。

所有例子的代码都可以在node@0.11.13的harmony模式中正常运行。

### Promise
其实Promise并不是什么新的东西，早在ES6出现之前就已经有不少的库，如jQuery，实现了Promise的功能。不过有一点要注意的是，jQuery Promise遵循的是[Promise/A](http://wiki.commonjs.org/wiki/Promises/A)规范，而ES6 Promise遵循的是[Promise/A+](http://promisesaplus.com/)规范， 两者在使用的时候会有一些[不同](http://promisesaplus.com/differences-from-promises-a)。

对于Promise，按我的理解，能抽象为：

1. 定义一个任务，如打开一个文件。
2. 监听任务的执行结果。
3. 如果执行成功/失败，调用对应的callback。

代码大概如下（[ES6 Promise的语法](http://es6.ruanyifeng.com/#docs/promise)）：

{% highlight javascript %}
// ES6 Promise
new Promise(function (resolve, reject) {
  // 定义一个任务，如打开一个文件。
  if (test) {
    // 执行成功
    resolve(fileData);
  } else {
    // 执行失败
    reject(err);
  }
})
  // 监听任务的执行结果
  .then(function (data) {
    // 处理成功的情况。
  }, function (err) {
    // 处理失败的情况。
  });
{% endhighlight%}

这个执行流与Callbacks似乎没什么不同（事实上jQuery Promise就是基于jQuery Callbacks实现的）：

{% highlight javascript %}
// Callbacks
// 定义一个任务，如打开一个文件。
fs.readFile('/etc/passwd', function (err, data) {
  if (!err) {
    // 处理成功的情况。
  } else {
    // 处理失败的情况。
  }
});
{% endhighlight%}

那么使用Promise有什么优势呢？最常见的说法就是解决Callbacks hell的问题。

#### 解决Callbacks hell
在介绍Promise怎么解决Callbacks hell之前，很有必要统一一下对Callbacks hell的定义。而对于Callbacks hell，主流理解是这样：

{% highlight javascript %}
// 每一步都需要使用上一步返回的数据
doStep1(function (data) {
  // Blabla一大堆操作
  doStep2(function (data) {
    // Blabla一大堆操作
    doStep3(function (data) {
      // Blabla一大堆操作
      // 继续……
    });
  });
});
{% endhighlight%}

也就是Callbacks hell === Pyramid of doom。但是Callbacks hell并不是多重嵌套，而是[Inversion of Control](http://blog.getify.com/promises-part-2/)，就是你失去了对自己代码的控制权。栗子：

{% highlight javascript %}
// 引入的第三方代码
function doSomething (callback) {
  // Blabla一大堆操作
  callback();
  // Blabla一大堆操作
  callback();
  // Blabla一大堆操作
  callback();
}

// 我自己的代码
doSomething(function () {
  console.log("Display only once!");
});
{% endhighlight%}

我传入了一个函数给第三方的代码，并且预期这个函数只会执行一次，不过事实上却是执行了三次 -- 毕竟没有那个规定callback只能执行一次，如map、reduce的callback就是执行多次的。

使用Callbacks的时候，我们必须了解别人的代码会如何调用传入的callback，但当项目中引入了大量的第三方模块时，这样就显得很不现实。而Promise规范规定：

1. 初始状态为pending。
2. 如果执行成功，状态从pending变为resolved，调用success callback。
3. 如果执行失败，状态从pending变为rejected，调用fail callback。
4. 当状态变为resolved/rejected后，状态将无法再发生改变。

所以使用Promise时，callback会且只会被执行一次，并且只会执行success/fail其中一个callback。因此避免了Callbacks hell的问题。

#### Promise是Yieldable的
使用Promise的第二个优势就是它能与Generator协作，把回调风格的异步代码变成顺序风格的异步代码，如[co](https://github.com/visionmedia/co)就是基于Generator与Promise（严格来说是Yieldables）提供了这个功能。明显，在进一步介绍这个优势之前，我们必须先去了解一下Generator。

#### 插曲：一个小坑
或者不算是坑吧，但我就是踩了下去。ES6 Promise中，resolve与reject只会把第一个参数传给callback，如下：

{% highlight javascript %}
new Promise(function (resolve, reject) {
  resolve(1, 2);
}).then(function (a, b) {
  console.log(a, b); // 输出：1 undefined
});

new Promise(function (resolve, reject) {
  reject(1, 2);
}).then(function () {}, function (a, b) {
  console.log(a, b); // 输出：1 undefined
});
{% endhighlight%}

### Generator
偷懒了，其实全称是Generator Function（[语法参考](http://es6.ruanyifeng.com/#docs/generator)）。Generator提供了两个普通函数没有的功能：

1. 暂停当前函数的执行。
2. 通过it.next()从Generator中返回/传入值。

又是栗子：
{% highlight javascript %}
// 与普通函数相比，Generator函数名前多了一个“*”号，并且内部能使用yield expression。
function *example () {
  console.log("Print after calling it.next().");

  var x = yield 1; // 暂停当前函数的执行，并把1传到函数外。
  console.log(x); // 输出：2
}

// 调用Generator后返回的是一个Iterator，而不是执行其中的代码，直到调用it.next()。
var it = example();

// 这行输出可以证明example中的代码没有立刻执行。
console.log("Print before calling it.next().");

// 第一次调用it.next()，开始执行example中的代码，输出：Print after calling it.next().
console.log(it.next().value); // 输出：1

// 执行其它操作，注意这个时候example中的代码并没有完全执行完，因为yield把它中断了。
console.log("Hello world!");

it.next(2); // 把 2 传入。
{% endhighlight%}

为了方便理解，可以把"yield blabla;"类比为nodejs的异步IO调用，可以对比下图与下下图。

nodejs异步IO：

![nodejs异步IO](/upload/images/async-io-of-nodejs.png)

Generator的执行流：

![Generator的执行流](/upload/images/yield-in-generator-function.png)

#### 两个例外
1. 第一次it.next()传入的值会被扔掉，而非作为yield的返回值，如下：
{% highlight javascript %}
function *example () {
  var x = yield "Something";
  console.log(x); // 输出2而不是1。
}

var it = example();
it.next(1);
it.next(2);
{% endhighlight%}

2. 最后一次调用it.next()时value的值是return后面的值，而非yield后面的值（因为已经没有yield expression了），如下：
{% highlight javascript %}
function *example () {
  yield "Something";
  return "Hello world!"; // 如果没有return，则等价于return undefined。
}

var it = example();
console.log(it.next().value); // 输出：Something
console.log(it.next().value); // 输出：Hello world!
{% endhighlight%}

### Promise与Generator的协作
当发现Promise与Generator可以如此协作的时候，我的第一感觉就是**惊艳** -- 没甚文化，只能想到这个词了。

赶着去吃饭，所以例子就直接用co了，可以先把以下的模式当成一种特殊的语法：

{% highlight javascript %}
co(function *() {
  // 在这个块中，yield promise的返回值为resolve/reject的参数。
})();
{% endhighlight%}

例子：

{% highlight javascript %}
var co = require("co");
var fs = require("fs");

function readFile () {
  return new Promise(function (resolve, reject) {
    fs.readFile('/etc/passwd', function (err, data) {
      if (!err) {
        resolve(data);
      } else {
        reject(err);
      }
    });
  });
}

co(function *() {
  var file = yield readFile();
  console.log(file); // 后输出
})();

console.log("Hello world!"); // 先输出

// 如果你是直接把代码复制进node cli后执行，请把上面这个空行也复制过去，
// 以保证node能够一次性的接收整个例子的代码，不然输出的顺序不符合预期。
{% endhighlight%}

从上面的例子可以看到，co使用Generator与Yieldables（Promise）把回调风格的代码变成了顺序执行的风格，但是背后依然是异步执行，所以“Hello world!”会在file之前输出。

### 总结
读者自己总结一下就好，我吃饭去了。囧~
