---
title: 发布es6写的npm包遇到了这个坑
date: 2016-10-09 17:20:15
tags: ES6
---

今天完成了yf-fpm-server的v2.0版本，是使用es6语法写的，兴致勃勃的 publish，结果使用的时候：
![错误信息](http://yfdocument.qiniudn.com/WechatIMG14.jpeg)
大体的意思就是：不支持import关键字，也就是语法错误。
纠结了一会儿，大概得出了这么个结论，npm install到项目中的库是不能为es6语法的，还必须通过babel进行转译。
根据这个信息整理了一些资料：
- [使用ES6来编写你的Node模块](https://cnodejs.org/topic/557533b9c4e7fbea6e9a3072)
- [using-es6-today](http://mammal.io/articles/using-es6-today/) <=这个真的很有用

解决思路：
1. 将es代码剪切到src目录下
2. 在publish之前通过babel将代码转译到lib目录下
3. 将lib代码设置为main

实施方案：
1. 在项目根目录下创建 .babelrc 文件，并写入转译规则:
```javascript
{
  "presets": ["es2015", "stage-2"],
  "plugins": ["transform-runtime"],
  "comments": false
}
```

2. 修改 package.json 文件：
```javascript
"main": "lib/bin/app.js", //babel转译之后的代码
  "scripts": {
    "compile": "babel -d lib/ src/", //babel转译指令
    "prepublish": "npm run compile", //在publish操作之前触发这个指令
    "server": "node app.babel.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
```

再次执行
`
$ npm publish
`

开发的npm包终于可用了!
