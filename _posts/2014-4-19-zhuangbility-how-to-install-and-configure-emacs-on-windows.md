---
layout: article
title: 逼格提升之在Windows安装、配置Emacs
categories: [zhuangbility, emacs]
---

就世俗的观点而言，装逼是一个贬义词。但是如果看过《哈姆雷特》的话，应该还记得：“假如你没有美德的话，那就假装你有美德。”可见，装逼是追求美德的一个过程，只要*方法恰当*。同理，装逼也是追求牛逼的一个过程。

### 为什么选择Emacs
作为一名高逼格的程序员，应该用什么编辑器/IDE呢？有那么两句话：

> * 世界上的程序员分三种，一种使用Emacs，一种使用Vim，剩余的是其它。
> * Emacs是神的编辑器，而Vim是编辑器之神。

看来IDE不是一个好的选择。Vim虽然好用，但是*拜神的人*和*神一样的人*还是有一段距离，至少听起来是。所以，Emacs就是最好的选择了 :) 。

### 居然是Windows
装逼是需要成本的，屌丝如我，娶不起Mac这个白富美，泡不动Linux这个冰美人。更不用说，每个页面仔的背后都有一个坑爹的IE大爷。所以，我做了一个非常艰难的决定……

### 安装Emacs
官网下载请戳[尔康的鼻孔](http://www.gnu.org/software/emacs/#Obtaining)，解压到你放教育片的目录即可。不过如果你够逗逼的话，也可以试试某60的软件管家 -- 不要问我为什么这么清楚我不爱听 -_-|| 。

### 配置Emacs
Emacs的特点在于高度的可定制性，不过对于新手而言，不建议自己写配置 -- 说白了就是与其到处复制粘贴，还不如直接用大牛的。体会一下这首诗：

> 关注大师的言行，<br />
跟随大师的举动，<br />
和大师一并修行，<br />
领会大师的意境，<br />
成为真正的大师。<br />

在下载配置之前，有一个常见问题要解决。Emacs一开始并不是为Windows写的，只是后来移植过来，而从*nix系统移植过来的软件，大多会使用到home目录。而Windows是木有home目录的，所以每个软件都会把某个目录当成home，它们默认的home目录往往是不同的，而且你要找到它们的home目录也需要一定的时间。其中一个解决的办法就是设置HOME环境变量，如图：

![设置HOME环境变量](/upload/images/home-var.png)

这个方法不是对所有的软件都有效，但至少Emacs、msysgit会把HOME环境变量的值作为home目录的路径。这也省了很多麻烦，以后使用magit时就会体会到了。

设置好环境变量就可以下载大牛们的配置了，如：[emacs-starter-kit](https://github.com/technomancy/emacs-starter-kit)。也可以考虑自己所在领域的大牛的配置，如我用的是[purcell的配置](https://github.com/purcell/emacs.d) -- 当然后来自己也加了一些 -- [下载](https://github.com/benjycui/emacs.d)之前不要忘了follow + star啊！把配置放到home目录下后再启动Emacs，然后就会有一个漫长的下载&&编译所需package的过程。

### 关于手部护理
手，是程序员的好朋友，特别是单身的程序员 -- 毕竟洗衣做饭只能自己来。可是Emacs的快捷键就是反人类啊，不信你试试同时按下ctrl、alt、v，这可是一个常用的快捷键！所以就有了这么一个解决方案，把caps lock映射为ctrl。网上有不同的方法修改，而我是直接修改注册表，因为很少用到caps lock。

1. 运行注册表编辑器

![运行注册表编辑器](/upload/images/cmd-regedit.png)

2. 转至HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout，新建一个二进制值如下（乱写的，但是有用）：

![新建二进制值](/upload/images/scancode-map.png)

3. 注销后重登入，然后你的caps lock就变成ctrl了，当然你也可以是交换caps lock与ctrl，不过那样你就要自己google找教程咯。

### 快捷键冲突
* Emacs的alt + w与QQ的XX功能有冲突
* Emacs的ctrl + alt + v与Evernote的XX有冲突
* Emacs的ctrl + space与输入法切换有冲突

以上冲突我都是修改其它软件的快捷键，对于一个Emacs初学者而言也比较简单。

### 学习Emacs
没错，Emacs是要学的而且它的学习曲线非常……奇葩。看图：

![编辑器学习曲线](/upload/images/learn-an-editor.jpg)

不过它也自带了教程：ctrl + h放开，再按t。当然，这份教程只能让你了解一些Emacs的基本概念与操作。学习Emacs的最好方法就是使用，例如本文就是在Emacs里面写的。
