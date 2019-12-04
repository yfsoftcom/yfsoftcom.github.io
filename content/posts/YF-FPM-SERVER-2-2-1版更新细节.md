---
title: '[YF-FPM-SERVER] 2.2.1版更新细节'
id: 1488688319214
author: Wangfan
tags:
  - api
categories:
  - yf-fpm-server
date: 2017-03-05 12:31:00
---


- 1.合并analyse.js 和 auth.js代码
- 2.增强权限匹配的模式
- 3.添加系统异常捕捉绑定函数
- 4.去除2个多余的函数
- 5.新增2个钩子埋入点

<!--more-->

#### 1.合并analyse.js 和 auth.js代码
将2个中间件的代码合并到`auth.js`中，在auth中间件中验证key和root权限

#### 2.增强权限匹配的模式
使用正则表达式来匹配接口权限
```javascript
let method = postData.method
  // 使用正则表达式来匹配信息
  let root = '^' + approot + '$'
  // 涵盖权限
  if(new RegExp(root).test(method)){
    await next()
    return
  }
```
如： 
- `order.*` 可授权order模块下的所有接口权限
- `app.*` 可授权app模块下的所有接口权限
- `(order|app).*` 可授权 order 和 app 两个模块下所有的接口
- `*` 可授权所有权限 


#### 3.添加系统异常捕捉绑定函数

在 fpm 的核心api中添加 `bindErrorHandler(handler)` 绑定koa的系统错误回调。
```javascript
bindErrorHandler(handler){
  this.errorHandler = handler
}
```

#### 4.去除2个多余的函数

删除了 `use(middleware)` , `addRouter(routers, methods)` 2个多余的函数。

#### 5.新增2个钩子埋入点

添加了 `FPM_MIDDLEWARE` , `FPM_ROUTER` 2个钩子埋入点，可在插件开发中利用，可为fpm绑定更多的路由和中间件。
```javascript
this.runAction('FPM_MIDDLEWARE', this, this.app)
this.runAction('FPM_ROUTER', this, this.app)
```
除了传入 `fpm` , 还会将koa的引用一起传入到插件的 `bind()` 函数中。