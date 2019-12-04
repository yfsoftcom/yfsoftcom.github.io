---
title: '[YF-FPM-SERVER] 核心api'
id: 1488371507406
author: YunPlus.IO
tags:
  - api
categories:
  - yf-fpm-server
  - ''
date: 2017-03-01 20:31:00
---

> 本文简单罗列 `yf-fpm-server` 的核心api .

<!--more-->
```javascript
// 1.获取app，即koa对象
getApp()

// 2.添加业务模块，要求biz为 Biz 类型
addBizModules(biz)

// 3.注册系统级action钩子，传入可用的action钩子名和钩子代码
registerAction(actionName, action)

// 4.执行系统级钩子
runAction(actionName)

// 5.直接执行业务代码，业务函数名，参数，版本号
async execute(method, args, v)

// 6.添加业务函数的钩子，要求hook为 Hook 类型
addHook(hook)

// 7.获取config.json中的配置信息，或通过插件注入的配置信息
getConfig(c)

// 8.扩展config.json的配置信息，注意：此函数只会将信息暂存到内存中，重启之后会失效
extendConfig(c)

// 9.获取配置信息中的所有的客户端授权信息
getClients()

// 10.绑定系统错误函数
bindErrorHandler(handler)

// 11.启动服务
run()
```