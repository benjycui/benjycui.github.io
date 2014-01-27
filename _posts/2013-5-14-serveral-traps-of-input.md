---
layout: article
title: 关于浏览器input控件的几个陷阱
category:
  - browser
---

表单是web应用最主要的收集用户信息的方式，而其中，input控件用得最多，可是关于input的陷阱你又知道多少?

虽然我不是浏览器砖家，但是以下的这些陷阱都是我亲身经历过的（够倒霉了吧），所以还是具有一定的可信度。当然我还会给出尽可能多的细节，有兴趣的童鞋可以自己去测试一下。

1.Chrome ver.26.0 && IE10

html5新增加的input[type="number"]。在这两个浏览器上，如果输入的内容不是数字，那么用$('..').val()返回的将会是一个空字符串，而在Firefox则能够返回输入的内容。

2.IE9-

如果input[type]是浏览器不支持的类型，会怎么样呢？答对了，会当成[type=text]进行处理。可是，在IE9-，浏览器不仅仅会把[type=other]当成[type=text]，还会修改html代码！所以这个时候，你用$('[type=other]')是没办法获取元素的，因为html代码已经被IE很二逼的修改了。不过很神奇的一点是，我自己自定义的一个[type=idcard]反而没有被改。

3.IE8-

难侍候的IE大爷啊！！！IE的安全策略让人蛋疼，在Firefox、Chrome、IE9+上，把一个input[type=password]修改为[type=text]后，你是能够看到明文的，可是在IE8-，就算你已经修改为[type=text]，输入仍然会以星号(*)显示。

4.IE10-

又是安全策略问题……在IE上，如果你是使用js触发input[type=file]的click事件，然后用户自己选择文件，那么其实IE是不会往服务器提交东西的，而Firefox和Chrome就能成功提交。

5.IE10 && IE6

尼玛的IE！在上面这两个浏览器，如果一个input[type=file]被设为透明，那么那怕用户点击了这个按钮，选择了文件，浏览器也还是不会把文件发到服务器的。

以上这些陷阱一般情况下是不会遇到的，但是由于我最近在开发一个<a href="https://github.com/benjycui/jquery-armour">表单增强插件</a>，难免会用到hack，所以就爬出了以上几个陷阱--1、2、3点，4、5点则是以前做的一个项目里面碰到的，现在一并写了下来，以免以后再犯。
