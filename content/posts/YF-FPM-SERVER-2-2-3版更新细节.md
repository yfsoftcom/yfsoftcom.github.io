---
title: '[YF-FPM-SERVER] 2.2.3版更新细节'
id: 1492565070367
author: YunPlus.IO
tags:
  - api
categories:
  - yf-fpm-server
date: 2017-04-19 09:24:00
draft: true
---
> 本次更新主要是移除了一些内核中可插件化的代码，并新增了2个插件 `fpm-plugin-qiniu-upload`,`fpm-plugin-socketio` 。2.2.3版本将是一个lts版本。
<!--more-->
依赖变更

- remove `qiniu`

最新的依赖

```javascript
  "koa": "^2.0.0",
  "koa-bodyparser": "^3.2.0",
  "koa-multer": "^1.0.1",
  "koa-router": "^7.1.0",
  "koa2-cors": "^2.0.3",
  "lodash": "^4.16.1",
  "md5": "^2.1.0",
  "moment": "^2.13.0",
  "pubsub-js": "^1.5.5"
```

移除的特性

- remove `upload` 的路由
```javascript
this.app.use(upload.routes()).use(upload.allowedMethods())
```

插件

- 上传文件到七牛的插件 `fpm-plugin-qiniu-upload`
  - github:  [https://github.com/team4yf/fpm-plugin-qiniu-upload](https://github.com/team4yf/fpm-plugin-qiniu-upload)

- 集成socketio服务插件 `fpm-plugin-socketio`
  - github: [https://github.com/team4yf/fpm-plugin-socketio](https://github.com/team4yf/fpm-plugin-socketio)
  - TODO: 将socketio的逻辑与插件分离

- 已实现的可用插件列表
```javascript
"fpm-plugin-baidu": "^0.0.1",
"fpm-plugin-emailer": "^1.0.3",
"fpm-plugin-mysql": "^1.0.1",
"fpm-plugin-qiniu-upload": "^1.0.0",
"fpm-plugin-schedule": "^1.0.0",
"fpm-plugin-socketio": "^0.0.2",
```


