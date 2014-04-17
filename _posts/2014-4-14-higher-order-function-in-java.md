---
layout: article
title: 在Java中模拟高阶函数
category: java
---

我从大二开始接触Lisp，到现在差不多一年半了。期间断断续续的学习了Common Lisp、Emacs Lisp、和Clojure。惭愧的是，到现在，都还没用Lisp做过一个像样的项目。不过，就如Eric S. Raymond所说：“Lisp很值得学习。你掌握它以后，会感受到它带来的极大启发。这会大大提高你的编程水平，使你成为一名更好的程序员，即使你在实际工作中很少用到Lisp。”

虽然我还没掌握Lisp，不过它已经极大的改变了我对编程的看法。现在，回头看看以前学习过的Java、CSS之类，居然还真的发现了一些有趣的东西。例如本文的主题：在Java中模拟高阶函数。

什么是高阶函数？以下是维基百科的解释：

> 在数学和计算机科学中，高阶函数是至少满足下列一个条件的函数：

> * 接受一个或多个函数作为输入
> * 输出一个函数

同时高阶函数也是函数式编程语言的基础之一，能极大的提高语言的表现力。

那么，在不支持高阶函数的Java中（至少在Java7以前是如此），我们能怎样模拟呢？灵感来自Javascript和Scala：

* 在Javascript中，一个函数就是一个对像，所以一个函数自身也可以拥有field和method
* 在Scala中，当你试图去调用一个对像，如：object()时，编译器会把它改为对对像apply方法的调用，即：object.apply()

所以我创建了这么一个抽像类，把Java中的函数也变成了一个对像，就像Javascript一样：

{% highlight java %}
public abstract class Function {
        public abstract Object apply (Object[] args);

        public Object call (Object... args) {
                return apply(args);
        }
}
{% endhighlight%}

所以现在我们可以这样创建、调用函数咯：

{% highlight java %}
Function greet = new Function() {
    public Object apply (Object[] args) {
        String name = (String)args[0];
        System.out.println("Hello, " + name +"!");
        return null;
    }
};

greet.call("world"); // "Hello, world!"
{% endhighlight%}

无可否认，模拟出来的语法比原生的要累赘，大量的类型转换也会让不少Java程序员不齿吧。但是拥有高阶函数的Java，将会比原来的版本要更加的灵活。

举栗子前先买个萌，在Javascript中经常使用的立即函数/自调用函数，现在Java也可以了:)

{% highlight java %}
(new Function() {
        public Object apply (Object[] args) {
            System.out.println("Immediate function!");
            return null;
        }
}).call();
{% endhighlight%}

### 免责声明
以下代码只是为了作为示例而写，虽然都能运行，但是没有经过严格测试，也不是按照最佳实践来写。不过，就如《编程珠玑》中的一个例子：

> 我很惊讶：在足够的时间内，只有大约10%的专业程序员可以把这个小程序（二分查找）写对。但写不对这个小程序的还不止这些人：高德纳在《计算机程序设计的艺术 第3卷排序和查找》第6.2.1节的"历史与参考文献"部分指出，虽然早在1946年就有人将二分查找的方法公诸于世，但直到1962年才有人写出没有bug的二分查找程序。

所以发现错误后不要喷我XD，不过你们能提供反馈的话，我将很乐意改进。

[示例代码下载](/upload/code/higher-order-function-in-java.zip)

### 几个栗子...
接下来我会用上面的技巧把一些在函数式编程语言中常用的函数引入到Java中，同时向你们展示高阶函数的灵活性。

首先是map、reduce。注意这里要展示的并不是Google提出的MapReduce架构，不过事实上那个架构的主要思想，“Map”和“Reduce”就是从函数式编程语言借来的。

#### map(fn, collection)

> 映射collection里的每一个值, 通过一个转换函数(fn)产生一个新的集合。

{% highlight java %}
Function map = new Function() {
    public Object apply (Object[] args) {
        Function fn = (Function)args[0];
        List coll = (List)args[1];
        Iterator itr = coll.iterator();

        List result = new ArrayList();

        while (itr.hasNext()) {
            result.add(fn.call(itr.next()));
        }
        return result;
    }
};
{% endhighlight%}

在原来的Java中，如果我们要把一个集合中所有的小写字母转成大写字母（或者其它更加复杂的映射工作），就要自己去迭代整个集合，并把处理后的结果add到新的集合里。而在支持高阶函数的Java里，你只需要把映射函数及集合传进map，你要可以得到你想要的集合咯。这也是函数式编程关注What to do而非How to do的一个体现。栗子：

{% highlight java %}
// ['a', 'b', 'c'] -> ['A', 'B', 'C']
List uppercase = (List)map.call(new Function() {
        public Object apply (Object[] args) {
                return Character.toUpperCase((Character)args[0]);
        }
}, lowercase);
{% endhighlight%}

#### reduce(fn, collection) or reduce(fn, collection, init)

> 将一个collection里的所有值归结到一个单独的数值。init是归结的初始值，如果不传入，就会把collection的第一个值赋给init。每一步都由fn返回。fn会传入2个参数：init，value。

{% highlight java %}
Function reduce = new Function() {
        public Object apply (Object[] args) {
                Function fn = (Function)args[0];
                List coll = (List)args[1];
                Iterator itr = coll.iterator();

                Object init = args.length == 3? args[2]: itr.next();
                while (itr.hasNext()) {
                        init = fn.call(init, itr.next());
                }

                return init;
        }
};
{% endhighlight%}

现在我们可以用下面的方式去求和咯：

{% highlight java %}
Function add = new Function() {
        public Object apply (Object[] args) {
                return (Integer)args[0] + (Integer)args[1];
        }
};

// coll = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
int sum1 = (Integer)reduce.call(add, coll);
System.out.println(sum1); // 55

int sum2 = (Integer)reduce.call(add, coll, 11);
System.out.println(sum2); // 66
{% endhighlight%}

#### not(fn)

> 传入一个谓词函数，返回一个新的谓词函数，并且新的谓词函数的判断总是与原来的相反。

{% highlight java %}
Function not = new Function() {
        public Object apply (Object[] args) {
                final Function fn = (Function)args[0];

                return new Function() {
                        public Object apply (Object[] args) {
                                return !(Boolean)fn.apply(args);
                        }
                };
        }
};
{% endhighlight%}

现在我们可以基于原有的函数构造新的函数咯。我不会告诉你下面这个例子是从《Javascript权威指南》里抄过来的，只是用Java把它重写了：

{% highlight java %}
// 判断一个数字是否为偶数
Function isEven = new Function() {
        public Object apply (Object[] args) {
                return (Boolean)((Integer)args[0] % 2 == 0);
        }
};

System.out.println(isEven.call(2)); // true
System.out.println(isEven.call(3)); // false

// 一个数字如果不是偶数，那它就一定是奇数
Function isOdd = (Function)not.call(isEven);

System.out.println(isOdd.call(2)); // false
System.out.println(isOdd.call(3)); // true
{% endhighlight%}

#### curry化

> 在计算机科学中，柯里化（英语：Currying），又译为卡瑞化或加里化，是把接受多个参数的函数变换成接受一个单一参数（最初函数的第一个参数）的函数，并且返回接受余下的参数而且返回结果的新函数的技术。这个技术由 Christopher Strachey 以逻辑学家哈斯凯尔·加里命名的，尽管它是 Moses Schönfinkel 和 戈特洛布·弗雷格 发明的。 -- 维基百科

简单的说就是减少已有函数所需参数的方法。

{% highlight java %}
Function curry = new Function() {
        public Object apply (Object[] args) {
                final Function fn = (Function)args[0];
                final Object[] argument = args;

                return new Function() {
                        public Object apply (Object[] args) {
                                Object[] a = new Object[argument.length + args.length - 1];
                                System.arraycopy(argument, 1, a, 0, argument.length - 1);
                                System.arraycopy(args, 0, a, argument.length - 1, args.length);
                                return fn.apply(a);
                        }
                };
        }
};
Function inc = (Function)curry.call(add, 1);
System.out.println(inc.call(5)); // 6
{% endhighlight%}

#### memoize(fn)

> 传入一个函数，然后返回一个功能相同，但是有记忆功能，即不会进行重复计算的函数。

{% highlight java %}
Function memoize = new Function() {
        public Object apply (Object[] args) {
                final Function fn = (Function)args[0];
                final HashMap<String, Object> cache = new HashMap<String, Object>();

                return new Function() {
                        public Object apply (Object[] args) {
                                String key = "";
                                for (Object o: args) {
                                        key += o.hashCode();
                                }

                                Object result = cache.get(key);
                                if (result == null) {
                                    result = fn.apply(args);
                                    cache.put(key, result);
                                }

                                return result;
                         }
                };
        }
};
{% endhighlight%}

如果一个函数要进行大量的计算，并且只要传入的参数一样，那么返回值就一定会一样。这种情况下我们会怎样优化呢？缓存？是的，我们可以把计算过的结果缓存起来。然后不好意思，我很懒，我既不想改函数的实现，也不想自己去维护缓存。这时，我的救世主从天而降--memoize。现在，我可以用一行代码完成这个工作咯。

{% highlight java %}
// 假设有一个非常耗时的计算
Function verySlowComputation = new Function() {
        public Object apply (Object[] args) {
                System.out.println("Why do you call me?" + (Integer)args[0]);
                return args[0];
        }
};

// 每次调用都会重复计算，消耗大量的计算资源
verySlowComputation.call(1); // Why do you call me?1
verySlowComputation.call(1); // Why do you call me?1

// 只要一次函数调用，就可以让一个函数具有缓存功能
Function memVerySlowComputation = (Function)memoize.call(verySlowComputation);

memVerySlowComputation.call(1); // Why do you call me?1
memVerySlowComputation.call(1); // 没有输出，因为之前的结果已经缓存，所以不再重复计算
memVerySlowComputation.call(2); // Why do you call me?2
{% endhighlight%}

看到这里，可能有人会说：经过memoize处理的函数，不会重复执行，那么，如果一个函数需要有副作用，如修改数据库怎么办？不执行就不会修改呐。我只能很无奈的说：你应该重构一下代码了！去看一下《重构：改善既有代码的设计》，里面介绍了一个重构手法：Separate Query from Modifier

> 如果某个函数只是向你提供一个值，没有任何看得到的副作用，那么这是个很有价值的东西。你可以任意调用这个函数，也可以把调用动作搬到函数的其他地方。简而言之，需要操心的事情少多了。

> 如果你遇到一个"既有返回值又有副作用"的函数，就应该试着将查询动作从修改动作中分割出来。 -- 《重构：改善既有代码的设计》

### 最后，再澄清两个误会

* 使用了高阶函数后，代码量好像更多了。两个原因：
  1. 示例过于简单，所以高阶函数的优势还不够明显。
  2. 用于模拟高阶函数的代码占了相当的篇幅，如果在原生支持高阶函数的语言内，如Python、Lisp，就能省去这一部份代码了。

* 这东西有什么用。要我说啊，真的没什么用。就像[BicaVm](https://github.com/nurv/BicaVM)一样，居然有人用Javascript去写JVM，这有什么用，性能也太差了吧！不过如果你还记得文章开头所说的：Lisp已经极大的改变了我对编程的看法。而这就是我要和你分享的想法：编程能力不是由你所用的语言决定的，而是你的思维。然后顺带宣传一下我热爱的函数式编程而已。
