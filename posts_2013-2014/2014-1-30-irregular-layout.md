---
layout: article
title: 不规则照片墙
categories: [css, js]
---
在最近的一个项目中，被迫实现了不规则照片墙的效果TT。经过努力，终于实现了设计师的要求，方法虽然简单，但是实用，所以决定整理出来与各位分享一下:)。

最终效果如图：

![最终效果图](/upload/images/irregular-layout-1.jpg)

[示例代码下载](/upload/code/irregular-layout-example.zip)

### 分析设计稿

拿到设计稿后发现：

* 照片墙可分为4列（图中红色框），前3列的宽度为237px，第四列的宽度为329px
* 四列总共提供了18个能用于展示照片的格子，另外有9个用于装饰的格子
* 每张照片的width和height最大不超过236px

![设计稿分析](/upload/images/irregular-layout-2.jpg)

### 实现思路

先用css把这18+9个格子绝对到相应位置并设置大小，然后用js把照片填充进用于展示照片的格子，考虑到上线后照片的数量将远远不止18张，所以超出4列之后，就循环使用前4列。同时因为每张照片的width和height都不超过236px，所以要求后台先把所有的照片都加工为236X236的规格，然后在css中通过overflow: hidden把照片截成相应的规格。如图，绿色为图片原来的尺寸236X360，红色为裁剪后的大小。

![图片裁剪前后](/upload/images/irregular-layout-3.jpg)

### 代码分析

jade源码：
{% highlight html %}
doctype
html
  head
    title Irregular layout example
    link(rel='stylesheet', href='styles/screen.min.css')

  body
    // 照片墙
    ul#is-album-list

    // 后台提供的照片
    #js-material(hidden)
      - for (var i = 0; i < 20; i++)
        a: img(data-src='holder.js/236x236')

    script(src='scripts/holder.js')
    script(src='scripts/jquery.min.js')
    script(src='scripts/app.js')
{% endhighlight%}

less源码：
{% highlight css %}
// 照片墙上的格子
li {
    border-bottom: 1px solid #8f8c8b;
    border-right: 1px solid #8f8c8b;
    list-style: none;

    // 把图片裁剪到与格子的大小一致
    overflow: hidden;

    // 用绝对定位把每个格子放到相应的位置
    position: absolute;
}

// item类与pad类将会添加到li上
// 每一个item可以放置一张照片
.item1 {
    .size(236px, 89px);
    left: 0;
}
// 省略N多类似代码
.item18 {
    .size(237px, 88px);
    left: 237 * 3px;
    top: 237 + 147px;
}

// pad是照片墙上装饰用的格子
.gray-pad {
    background-color: #413d3c;
}
.pad1 {
    &:extend(#is-album-list .gray-pad);
    .size(56px, 56px);
    left: 0;
    top: 90px;
}
// 省略N多类似代码
.pad9 {
    &:extend(#is-album-list .gray-pad);
    .size(90px, 88px);
    left: 237 * 3 + 238px;
    top: 237 + 147px;
}
{% endhighlight%}

js源码：
{% highlight javascript %}
'use strict';

$(document).ready(function () {
  var $sl = $('#is-album-list'),
      grid;

  // 照片墙上所有的格子都由这个grid控制
  grid = {
    layout: [
      ['item1', 'item2', 'item3', 'item4', 'item5', 'pad1', 'pad2'],
      ['item6', 'item7', 'item8', 'item9'],
      ['item10', 'item11', 'item12', 'pad3', 'pad4','pad5'],
      ['item13', 'item14', 'item15', 'item16', 'item17', 'item18', 'pad6', 'pad7', 'pad8', 'pad9']
    ],

    // 记录当前已经使用到第几列
    colIndex: 0,

    // 当前列可以用于放置相片的格子
    availBox: [],

    width: function () {
      var i, w = 0, cw = [237, 237, 237, 329];

      // 根据已经用了多少列计算出grid的宽度
      for (i = 0; i < this.colIndex; i++) {
        w += cw[i % 4];
      }
      return w;
    },
    colOffset: function () {
      // 从第5列开始循环，所以第5列之后的格子都要加上偏移
      return parseInt(this.colIndex / 4) * 1040;
    },
    newCol: function () {
      var that = this;
      this.availBox = [];

      $.each(this.layout[this.colIndex % 4], function (index, val) {
        var $box = $('<li></li>').addClass(val);
        $sl.append($box);
        $box.css('left', parseInt($box.css('left')) + that.colOffset());

        // 类名含有item就是可以展示照片的格子
        if (val.indexOf('item') !== -1) {
          that.availBox.push($box);
        }
      });

      this.colIndex++;
    }
  };

  // 把照片填充到照片墙上
  $('#js-material').children().each(function () {
    if (grid.availBox.length === 0) {
      grid.newCol();
    }

    grid.availBox.shift().append($(this));
  });
});
{% endhighlight%}
