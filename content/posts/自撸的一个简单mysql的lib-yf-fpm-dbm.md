---
title: '自撸的一个简单mysql的lib[yf-fpm-dbm]'
id: 1487585117646
author: wangfan
tags:
  - Nodejs
  - Mysql
  - yf-fpm-dbm
categories:
  - yf-fpm
date: 2017-02-20 18:05:00
---
### 0. 起因

为了省事，不想引入太多的npm包来实现一个简单的小应用，要足够自由，直接通过json来定义数据就可以实现数据库的操作。
如果你和我一样追求简单的快乐，欢迎前来拍砖；奉上gayhub地址: [https://github.com/team4yf/yf-fpm-dbm](https://github.com/team4yf/yf-fpm-dbm)。

### 1. 特性

- 只使用了2个依赖 ['lodash', 'mysql']
- 所有的代码加上格式化的空行不超过 600 行
- 目前支持mysql
- 通过delflag实现逻辑删除
- 默认带有四个字段：id,createAt,updateAt,delflag
- 支持批量插入
- 支持事务处理
- 如果你熟知bluebird,可以更优雅的使用

### 2. 使用

- 安装
`npm install yf-fpm-dbm`

- 配置数据库链接信息
```javascript
var C = {
  host:'192.168.1.1',
  database:'test',
  username:'root',
  password:'root',
};
var M = require('yf-fpm-dbm')(C);
```
- 运行
```javascript
var arg = {
　table: "test",
　condition: "delflag=0",
　fields: "id,article,ptags,product"
};
M.first(arg, function(error, data){
  if(error){
  　// do error here
  }else{
    // do success here
  }
});
```
- 说一下事务的用法
```javascript
M.transation(function(err, atom){
  var arg = {
  　table: "test",
  　condition: "...",
    row: { ... }
  };
  atom.update(arg, function(err, result1){
    if(err){
      atom.rollback();
      return ;
    }
    arg = {
    　table: "test",
    　condition: "...",
      row:{ ... }
    };
    atom.update(arg, function(err, result2){
      if(err){
        atom.rollback(function(){
          //do rollback code
        });
      }else{
        atom.commit(function(err){
          // do commit code
        });
      }
    });
  });
});
```
是不是足够的简单?

### 3. 小总结
- 造小而精的轮子是个好习惯
- 努力做到明显没有bug,像 lodash 这样的lib一样
- 持续改进,每次改进都可以减少一些代码,让它更轻更冥界,但更强壮更易读

> 我来自扬州,一个正在努力成为开源世界一员的一位新人.