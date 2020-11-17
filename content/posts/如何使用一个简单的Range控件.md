---
title: 如何使用一个简单的Range控件
date: 2017-01-08 11:54:10
tags: [HTML5,Range]
---

> Range控件是HTML5中新增的控件，很常用，尤其是手机端。

#### 如何使用？
```html
<!-- HTML Code -->
<input type="range" value="50" id="range"/>
```
在苹果设备上的效果还不错：

![默认的range控件](http://upload-images.jianshu.io/upload_images/1449977-a22d987c8191b5ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其它的就... 真的还好：

#### 不能忍，优化
大概思路：
- 去除系统默认的样式
```html
/* CSS Code */
  input[type=range] {
  	-webkit-appearance: none;
  	width: 100%;
  	border-radius: 10px; /*这个属性设置使填充进度条时的图形为圆角*/
  }

  input[type=range]:focus {
  	outline: none;
  }
```
- 给滑动轨道(track)添加样式
```html
/* CSS Code */
input[type=range]::-webkit-slider-runnable-track {
  	height: 10px;
  }
```
- 给滑块(thumb)添加样式
```html
/* CSS Code */
  input[type=range]::-webkit-slider-thumb {
  	-webkit-appearance: none;
  	height: 25px;
  	width: 25px;
  	margin-top: -8px; /*使滑块超出轨道部分的偏移量相等*/
  	background: #ffffff;
  	border-radius: 50%; /*外观设置为圆形*/
  	border: solid 0.125em rgba(205, 224, 230, 0.5); /*设置边框*/
  	box-shadow: 0 .125em .125em #3b4547; /*添加底部阴影*/
  }
```

这样就可以完成一个简单的Range控件了

![美化过的range](http://upload-images.jianshu.io/upload_images/1449977-981d89e901a96105.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

---

以上是样式部分，怎么获取Range控件中的值呢？
于其它input控件一下，value属性可以获取到他的值

```javascript
//Javascript code
document.getElementById('range').value
```


---


###### 完整的页面代码就是这样的：
```html
<html>
<head>
  <style>
  body{ background:#eee;}
  input[type=range] {
  	-webkit-appearance: none;
  	width: 100%;
  	border-radius: 10px; /*这个属性设置使填充进度条时的图形为圆角*/
  }

  input[type=range]:focus {
  	outline: none;
  }

  input[type=range]::-webkit-slider-runnable-track {
  	height: 10px;
  }

  input[type=range]::-webkit-slider-thumb {
  	-webkit-appearance: none;
  	height: 25px;
  	width: 25px;
  	margin-top: -8px; /*使滑块超出轨道部分的偏移量相等*/
  	background: #ffffff;
  	border-radius: 50%; /*外观设置为圆形*/
  	border: solid 0.125em rgba(205, 224, 230, 0.5); /*设置边框*/
  	box-shadow: 0 .125em .125em #3b4547; /*添加底部阴影*/
  }

  </style>
  <script>
    window.onload = function(){
      alert(document.getElementById('range').value);
    }
  </script>
</head>
<body>
  <input type="range" value="50" id="range"/>
</body>
</html>
```

---

##### PS:关于Range的其它的一些补充：
属性说明

| 属性名 | 描述 |
|:-----:|:-----:|
|max|设置或返回滑块控件的最大值|
|min	|设置或返回滑块控件的最小值|
|step	|设置或返回每次拖动滑块控件时的递增量|
|value	|设置或返回滑块控件的 value 属性值|
|defaultValue	|设置或返回滑块控件的默认值|
|autofocus	|设置或返回滑块控件在页面加载后是否应自动获取焦点|

常用事件说明

| 事件名 | 描述 |
|:-----:|:-----:|
|input|滑块活动时触发的事件|
|change|滑块移动后出发的事件，一般使用这个事件|
