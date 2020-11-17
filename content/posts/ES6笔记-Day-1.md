---
title: ES6笔记(Day 1)
date: 2016-10-09 14:30:12
tags: ES6
---

---

#### 学习目标
- 掌握如何定义变量
- 掌握解构的内部机制
- 掌握字符串模版

---

##### let关键字
> 可以限制变量作用域

- Code 1:
```javascript
{
    let a = 10;
    var b = 1;
}
a // ReferenceError: a is not defined.
b // 1
```

>适合使用使用在for循环中

- Code 2:
```javascript
var a = []; //使用 var会出现 闭包的情况
for (var i = 0; i < 10; i++) {
    a[i] = function () {
        console.log(i);
    };
}
a[6](); // 10
/*-------------------*/
//使用let自动解决闭包的问题
var a = [];
for (let i = 0; i < 10; i++) {
    a[i] = function () {
        console.log(i);
    };
}
a[6](); // 6
```

>不存在变量提升

- Code 3:
```javascript
console.log(foo); // 输出undefined
console.log(bar); // 报错ReferenceError
var foo = 2;
let bar = 2;
```

>在代码块内，使用let命令声明变量之前，该变量都是不可用的。这在语法上，称为“暂时性死区”（temporal dead zone，简称TDZ）。

- Code 4:
```javascript
if (true) {  
    // TDZ开始
    tmp = 'abc'; // ReferenceError
    console.log(tmp); // ReferenceError
    let tmp; // TDZ结束
    console.log(tmp); // undefined
    tmp = 123;
    console.log(tmp); // 123
}
```

考一考，下面2个代码片段的结果如何？
- Code 5:
```javascript
function bar(x = y, y = 2) {
    return [x, y];
}
bar();  // ??
```

- Code 6:
```javascript
function bar(x = 2, y = x) {
    return [x, y];
}
bar();  // ??
```

>同一个作用域不能声明多次

- Code 7:
```javascript
function () {// 报错
    let a = 10;
    var a = 1;
}
```

考一考
- Code 8:
```javascript
var tmp = new Date();
function f() {
    console.log(tmp);
    if (false) {
        var tmp = "hello world";
    }
}
f();  // ？？
```

- Code 9:
```javascript
var tmp = new Date();
function f() {
    console.log(tmp);
    if (false) {
        tmp = "hello world";
    }
}
f();  // ？？
```

> 可以舍弃匿名函数

- Code 10:
```javascript
(function () {
  // IIFE写法
    var tmp = ...;
    ...
}());
//
// 块级作用域写法
{
    let tmp = ...;
    ...
}
```

> 为了兼容不同的es版本，请使用函数表达式

- Code 11:
```javascript
{// 函数声明语句
    let a = 'secret';
    function f() {
        return a;
    }
}
// 函数表达式
{
    let a = 'secret';
    let f = function () {
        return a;
    };
}
```

##### const 申明常量

> 对于复合类型的变量，变量名不指向数据，而是指向数据所在的地址。const
命令只是保证变量名指向的地址不变，并不保证该地址的数据不变

- Code 12:
```javascript
const foo = {};
foo.prop = 123;
foo.prop // 123
foo = {}; // TypeError: "foo" is read-only
```

- Code 13:
```javascript
const a = [];
a.push('Hello'); // 可执行
a.length = 0;    // 可执行
a = ['Dave'];    // 报错
```

##### 变量赋值

疑惑点：
- 解构  ？？
- 解构允许使用默认值 ？？
- Generator函数 ？？
- yield ？？
- Generator函数，原生具有Iterator接口。解构赋值会依次从这个接口获取值 ？？
- 默认表达式使用惰性求值 ？？默认值是个函数 ？？ 有值的话 默认函数会执行么？？
- 对象的解构赋值的内部机制，是先找到同名属性，然后再赋给对应的变量。真正被赋值的是后者，而不是前者 ？？
- 解构赋值时，如果等号右边是数值和布尔值，则会先转为对象 ？？
- 哪些 不能使用圆括号的情况 ？？

- Code 14:
```javascript
function f() {
    console.log('aaa');
}
let [x = f()] = [1];
```
- Code 15:
```javascript
let x;
if ([1][0] === undefined) {
    x = f();
} else {
    x = [1][0];
}
```

** 解构的作用 **

- 交换变量的值

- 从函数返回多个值

- 函数参数的定义

- 提取JSON数据

- 函数参数的默认值

- 遍历Map结构

- 输入模块的指定方法

##### 字符串扩展

- 模板字符串？

- Code 16:

```javascript
`In JavaScript '\\n' is a line-feed.`// 普通字符串

// 多行字符串
`In JavaScript this is
 not legal.`

console.log(`string text line 1
string text line 2`);

// 字符串中嵌入变量
var name = "Bob", time = "today";
`Hello ${name}, how are you ${time}?`
```
