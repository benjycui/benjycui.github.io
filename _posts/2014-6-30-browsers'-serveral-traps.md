---
layout: article
title: 浏览器的几个坑
category: browser
---

在最近的一个项目中，又被浏览器大爷们狠狠的修理了一顿，所以又得把它们的怪脾气给记下来，以免再惹几位大爷生气。

[测试代码](/upload/code/browsers'-serveral-traps.zip)

### input[disabled]的事件监听与冒泡

当input标签设置了disabled属性之后，它所有的Event Listener都不会被触发，不过在除了Firefox之外的其它浏览器中，冒泡依然正常。如下面代码，点击input[disabled]后，"Hello form CLICK!"不会弹出，而“Hello from DELEGATE!”会照常弹出，不过在Firefox中就两句都不会弹出。

{% highlight javascript %}
$(document).ready(function () {
  'use strict';

  $('input').click(function () {
    alert('Hello form CLICK!');
  });

  $('#trap1').delegate('input', 'click', function () {
    alert('Hello from DELEGATE!');
  });
});
{% endhighlight%}

这是不同浏览器的默认行为，使用zepto(v1.1.3)注册的事件也是如此，但是如果是用jQuery(v1.11.1)就会发现所有的浏览器中，两句话都不会弹出，应该是jQuery统一了不同浏览器的行为。

### P.S.
有人会问了，不是几个坑么，怎么只有一个？那是因为另外几个坑不知道为什么就无法重现了，看来是外星人和我开了一个玩笑。囧~
