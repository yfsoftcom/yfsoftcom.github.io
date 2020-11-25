---
title: '[YF-FPM-SERVER] 2.3.0版更新概要'
id: 1526696206109
author: YunPlus.IO
tags:
  - changelog
categories:
  - yf-fpm-server
date: 2018-05-19 10:17:00
draft: true
---

> 框架设计之初为了提供一个相对标准的api入口，节约项目开发的前后端沟通成本，前端可以通过已实现好的sdk库可以很方便的与后端进行数据交互.
<!--more-->
yf-fpm-server 框架一直在做的就是：
- 如果你是个人，小规模，实力不强，但可以使用nodejs，想做一个规模不是很大的项目，这个框架就很适合你（们）。它是个能将项目从初期到中后期过度的很好的框架。当然，我们是实践了若干的商业项目之后才会如此力荐的。
- 充分结合nodejs的特性和koa框架的简洁,不断的精简和优化代码
    - 最终的依赖：
    ```javascript
    "koa": "^2.0.0",
    "koa-bodyparser": "^3.2.0",
    "koa-router": "^7.1.0",
    "koa2-cors": "^2.0.3",
    "lodash": "^4.16.1",
    "pubsub-js": "^1.5.5"
    ```
- 一些变动的api
    - `extendModule(name, module, version)` 该函数多用于开发插件的过程中很快的注入业务函数
    - `getPlugins()` 获取已安装的插件信息
    - `isPluginInstalled(name)` 检测是否已安装了某个插件
    - `_counter` 该字段用于记录api被调用的次数
    - `_prject_info` 该字段包含了项目的package.json信息
    - `_start_time` 该字段记录了项目启动的时间戳 通过 `_.now()` 生成
    
  ---
  **WARNING：**这里有一些重要的变化，对于所有的业务函数增加了2个参数
  ```javascript
  /*
  * args: 前端传来的业务参数
  * ctx: koa 的上下文
  * before: 前置钩子函数执行的结果，通过是个 Array 
  */
  (args, ctx, before) => { //.. }
  ```
  再此之前是没有后面2个参数的
  ```javascript
  (args) => { //.. }
  ```
  需要注意的是，一些通过插件调用了系统的`fpm.execute()`函数，通常没有`ctx`参数，所以需要做个谨慎的非空判断     

- 利用插件的机制将非必要的功能拆分到插件库中,项目开发过程中结合业务添加插件到系统中即可，已实现的插件有：
    - [fpm-plugin-mysql](https://github.com/team4yf/fpm-plugin-mysql) 
    
    用于连接mysql数据库的插件
    - [fpm-plugin-logger](https://github.com/team4yf/fpm-plugin-logger)
    
    用于日志管理的插件
    - [fpm-plugin-sms](https://github.com/team4yf/fpm-plugin-sms)
    
    用于短信推送的插件
    - [fpm-plugin-rbac-fs](https://github.com/team4yf/fpm-plugin-rbac-fs)
    
    实现rbac权限体系的插件
    - [fpm-plugin-schedule](https://github.com/team4yf/fpm-plugin-schedule) 
    
    任务调度的插件
    - [fpm-plugin-socket](https://github.com/team4yf/fpm-plugin-socket) 
    
    Socket的插件，通常用于和硬件的交互
    - [fpm-plugin-socketio](https://github.com/team4yf/fpm-plugin-socketio) 
    
    Socket.IO的插件
    - [fpm-plugin-emailer](https://github.com/team4yf/fpm-plugin-emailer) 
    
    邮件推送的插件
    - [fpm-plugin-qiniu-upload](https://github.com/team4yf/fpm-plugin-qiniu-upload) 
    
    七牛文件上传的插件
    
  ---
  除此之外，还有一些插件正在开发过程中，比如用于后台查看的 fpm-plugin-admin，方便用户直观的查看系统运行的状态。
    
    



