---
layout: article
title: 自调用函数及其应用
tags: Javascript
---

js函数一个有趣的技巧，就是在定义完一个函数后，立刻对其进行调用。也就是所谓的自调用函数。

自调用函数的一种最常见的声明方式如下：

{% highlight javascript %}
(function() {
	// N多的代码
})();
{% endhighlight%}

把一个匿名函数放进一对括号里，并且在这对括号后面使用另外一对括号调用该函数，因此函数在刚声明完毕的时候就会立刻运行。

那么，自调用函数在实际的开发中有什么应用呢？


## 1. 命名空间

虽然js原生是不支持命名空间的，但是通过自调用函数是可以轻易的模拟出来。如jQuery中可以看到的应用：

{% highlight javascript %}
(function( window, undefined ) {
	// N多的代码
	window.jQuery = window.$ = jQuery;
})( window );
{% endhighlight%}

在之前的代码把N多的方法添加到局部变量jQuery上后，再通过window.jQuery和window.$把那些方法暴露到外面。这样在匿名函数外就可以且只可以通过jQuery或$访问那些已被暴露的方法，同时又不用担心其他的局部变量会污染全局。


## 2. 捕获局部变量

举个栗子，先运行一下下面的代码：

{% highlight javascript %}
var i;

for (i = 0; i < 10; i++) {
	setTimeout(function () {
		console.log(i);	
	}, 1000);
}
{% endhighlight%}

然后你会发现10个输出都是10，为什么呢？因为setTimeout所调用的函数只是得到了对变量i的引用，而在setTimeout调用该函数前，变量i已经被修改为10了。

再运行一下下面的代码：

{% highlight javascript %}
var i;

for (i = 0; i < 10; i++) {
	(function (i) {
		setTimeout(function () {
			console.log(i);	
		}, 1000);
	})(i);
}
{% endhighlight%}

这次的输出就是0-9了，因为每循环一次，setTimeout外面的自调用函数就把for循环的变量i的值捕获且赋值给了一个新的局部变量i。所以在setTimeout调用它内部的匿名函数的时候，自然就能输出不同的值了。

## 3. 创建私有变量

js原生是木有“类”这个概念的，更不用说对私有变量的支持了。但是js的灵活使我们能够轻易的模拟出私有变量。这里举的栗子是为对象字面量添加私有变量。先看另外一种私有变量的声明方法，约定的下划线(_var)：

{% highlight javascript %}
var CONST = {
	_PI: 3.14,
	_E: 2.71,
	get: function (name) {
		return this['_' + name];
	}
};
{% endhighlight%}

这种约定并不会使_PI或_E变成真正的私有变量，所以在外部还是能够直接读写CONST._PI和CONST._E的。如果队伍里都是听话的乖孩子的话，这样写完全ok且更加简洁。但是“神队友”无处不在，所以有时我们就要使用强制的方法防止别人访问私有变量了。

{% highlight javascript %}
var CONST = (function () {
	var pri = {
		PI: 3.14,
		E: 2.71,
	}

	return {
		get: function (name) {
			return pri[name];
		}
	};
})();
{% endhighlight%}

在自调用函数内声明了私有变量，然后返回一个对象，因为该对象在声明的时候与私有变量是在同一自调用函数的内部，所以该对象能够访问这些私有变量。在这种情况下，外部就只能通过返回的对象的方法去操作私有变量。


P.S. 自调用函数是语句，所以后面不要忘了加上“;”。
