---
layout: article
title: setInterval的不足，及解决方案
---

js的初学者可能会认为，setInterval/setTimeout会在预设的时间点上准时执行预设的函数。可事实上setInterval/setTimeout并不真的会在设定的时间到了后就立刻执行函数，它只是在设定的时间后, 把任务添加到js的待处理队列里。同时因为js是单线程的，所以只有当前没任务正在执行时, 新加入的任务才会立刻被执行。但是如果当前有任务在执行，那么新加入的任务就必须等待, 如果前面出现了死循环，那么后面的任务就不可能被执行了。

同时，因为setInterval是定时的往队列里加入任务，所以如果前面有任务耽搁了太多的时间，队列里就会有大量的任务阻塞着，最终产生恶性循环。为了解决这个问题，网上的大多都是建议使用setTimeout，然后递归，如：

{% highlight javascript %}
var test = function () {
    // do something
    setTimeout(test, interval);
}
setTimeout(test, interval);
{% endhighlight%}

这个方案比较简单，但是违反了Don't repeat yourself原则，同样的代码反复出现。所以我写了下面两个函数，模仿了setInterval和clearInterval的功能，但使用的是setTimeout。

{% highlight javascript %}
var setTimer = function(fn, interval) {
  var recurse, ref;
  ref = {};
  ref["continue"] = true;
  (recurse = function() {
    if (ref["continue"]) {
      ref.timeout = setTimeout((function() {
        fn();
        recurse();
      }), interval);
    }
  })();
  return ref;
}

clearTimer = function(ref) {
  ref["continue"] = false;
  clearTimeout(ref.timeout);
}
{% endhighlight%}

调用方式和setInterval一样：

{% highlight javascript %}
var timer = setTimer(fn, interval);
clearTimer(timer);
{% endhighlight%}

上面的setTimer函数功能及使用方式与setInterval相似，但是因为是使用setTimeout递归实现的，所以不会像setInterval那样造成任务堆叠。

如果不需要使用到clearTimer，例如banner轮播那些动画就不需要终止，那就可以使用一个简化版：

{% highlight javascript %}
setRepeater = function(fn, interval) {
  setTimeout((function() {
    fn();
    $.setRepeater(fn, interval);
  }), interval);
}

 setRepeater(fn, interval);
{% endhighlight%}
