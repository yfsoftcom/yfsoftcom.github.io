---
title: windows上安装python2.7记录
id: 1489200355876
author: WangFan
tags:
  - 爬虫
categories:
  - python
date: 2017-03-11 10:45:00
---
本人不是专业搞python的，写这个只为做个记录；高手请自动略过。

---
## 因为爬虫 所以python
最近需要折腾一个爬虫，之前试过用nodejs，折腾了好久，分别用到了
- 1.jsdom + xpath 通过fetch下载页面，然后进行dom解析，通过xpath来获取数据
- 2.phantomjs + jquery + lodash 通过phantomjs来模拟客户端浏览器，通过运行前端js脚本来处理页面数据
两种方案都做了实现，一段时间运行下来之后，还是有一些问题的：
- 1.扩展性为0，每个页面的爬取都要单独写脚本，而且是js脚本，异步回调的问题很麻烦
- 2.爬虫程序可读性不高，爬虫是一个高io的程序，nodejs对于io又是异步的，所以写出来的爬虫程序较难维护

## 安装python的过程
### 折腾版本
上来就搞了个最新版，于是安装了 3.6，用一些基本的功能没问题，但`3.*` 和 `2.*` 的语法有不少变化，之前电脑上安装python是为了跑 `phantomjs` ，现在为了写python程序，所以想了想还是回到 `2.7.*`的版本。
### 依赖管理
写爬虫需要用到一些第三方库 `beautifulsoup` or `lxml` 等等，于是就会需要一个依赖管理的东西，比如java的 `maven` or `gradle` or Nodejs的 `npm` 等等。`pip`是python官方推荐的，就是它了。

之前看了一个比较久的帖子，安装了2.7.6，看着他的过程，安装pip安装不上；后来看了pip的官网
```
pip is already installed if you're using Python 2 >=2.7.9 or Python 3 >=3.4 binaries downloaded from python.org, but you'll need to upgrade pip.
```
于是又更新了版本，现在是2.7.13。

### 轻松安装
版本搞定之后，后面就简单了。先下载脚本[https://bootstrap.pypa.io/get-pip.py](https://bootstrap.pypa.io/get-pip.py)

然后运行命令 `python get-pip.py` 安装.

运行 ` pip -V ` 看到下面的信息就OK了
![pip -V](http://olk3bzfd5.bkt.clouddn.com/pasted-1489201547724.png)