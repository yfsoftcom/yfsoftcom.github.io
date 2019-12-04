---
title: '[YF-FPM-SERVER] BETA版更新细节'
id: 1488367793113
author: YunPlus.IO
tags:
  - yf-fpm-server
  - nodejs
categories:
  - yf-fpm-server
date: 2017-03-01 19:29:00
---
#### 0. 什么是yf-fpm-server
> yf-fpm-server是一款轻量级的api服务端，可通过插件集成数据库(mysql,mongodb)的数据操作，灵活扩展自定义业务逻辑

* 源码地址: https://github.com/team4yf/yf-fpm-server.git
* 基于koa2框架
* 支持key + secret安全验证
* 支持接口权限验证
* 支持hook钩子扩展
* 支持接口多版本同时在线

<!--more-->
---

### BETA版更新概要

- 1.更新依赖
- 2.支持插件集成
- 3.添加config.json静态配置文件
- 4.文件改动
- 5.示例代码

---

#### 1. 更新依赖
为了让核心代码更轻便，去除了很多臃肿的依赖；除了Babel相关的以外，最终依赖如下一些模块：
```javascript
{
  "koa": "^2.0.0",
  "koa-bodyparser": "^3.2.0",
  "koa-router": "^7.1.0",
  "koa2-cors": "^2.0.3",
  "lodash": "^4.16.1",
  "md5": "^2.1.0",
  "moment": "^2.13.0"
}
```

#### 2. 支持插件集成
在一些主要的操作节点上添加了钩子，可进行插件开发集成。

###### 钩子列表如下：
- INIT  服务初始化时
- BEFORE_ROUTER_ADDED  路由添加之前
- AFTER_ROUTER_ADDED  路由添加之后
- BEFORE_MODULES_ADDED  业务模块添加之前
- AFTER_MODULES_ADDED  业务模块添加之后
- BEFORE_SERVER_START  服务启动之前
- AFTER_SERVER_START  服务启动之后

###### 默认实现的插件包括：
(点击可进入github)

- [fpm-plugin-mysql](https://github.com/team4yf/fpm-plugin-mysql)  操作mysql数据库的插件
- [fpm-plugin-email](https://github.com/team4yf/fpm-plugin-emailer) 发送邮件的插件
- [fpm-plugin-sechdule](https://github.com/team4yf/fpm-plugin-schedule)  定时任务的插件
<!-- more -->
#### 3. 添加config.json静态配置文件

修改之前版本动态配置文件的设计，添加静态配置文件。
在服务初始化之前会进行加载，在之后的中间件均可通过 `getConfig()` 函数进行访问。
默认配置文件包含的字段：
```javascript
{
  server:{
    port: 9999
  },
  defaultVersion: '0.0.1',
  dev: 'DEV',
  log4js: { // log4js config },
  apps: { // fpm 授权应用列表
    '123123': {
      appkey: '123123',
      approot: '*',
      secretkey: '123123',
    }
  },
  mysql: { // mysql配置信息
    host: 'localhost',
    database: 'fpm',
    username: 'xxx',
    password: 'xxx',
    showSql: true
  }
```
配置文件可根据插件和业务的实际情况更改。


#### 4. 文件改动

```bash
create mode 100644 src/middleware/auth.js
delete mode 100644 src/middleware/clientFilter.js
delete mode 100644 src/middleware/defaultConfig.js
```

#### 5. 示例代码

```javascript
import { Fpm, Hook,Biz }  from 'yf-fpm-server'
let app = new Fpm()
let biz = new Biz('0.0.1')
biz.addSubModules('test',{
  foo:async function(args){
    return new Promise( (resolve, reject) => {
	  reject({errno: -3001});
	});
  }
})
app.addBizModules(biz);
app.run();
```