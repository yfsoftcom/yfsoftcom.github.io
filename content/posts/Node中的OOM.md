---
title: Node中的OOM
date: 2023-03-06 09:25:00
tags: [Node,OOM]
---

> Node.js 中的内存管理和垃圾回收是怎样的? 如何解决内存溢出的问题,以及如何找出导致OOM的根因?

### 内存溢出会怎样？

于其它编程语言一样，Node内存溢出之后会抛出一个OOM的异常，并强行结束当前进程，导致服务不可用，通常的容器编排系统会重新启动一个新的实例，所以如果没有搜集日志并进行分析的话可能会忽略这类型的错误；通常日志会这样

```bash
<--- Last few GCs --->

11629672 ms: Mark-sweep 1174.6 (1426.5) -> 1172.4 (1418.3) MB, 659.9 / 0 ms [allocation failure] [GC in old space requested].
11630371 ms: Mark-sweep 1172.4 (1418.3) -> 1172.4 (1411.3) MB, 698.9 / 0 ms [allocation failure] [GC in old space requested].
11631105 ms: Mark-sweep 1172.4 (1411.3) -> 1172.4 (1389.3) MB, 733.5 / 0 ms [last resort gc].
11631778 ms: Mark-sweep 1172.4 (1389.3) -> 1172.4 (1368.3) MB, 673.6 / 0 ms [last resort gc].

<--- JS stacktrace --->
FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory
 1: node::Abort() [/usr/bin/node]
```

这里有一些关键的信息： `Mark-sweep`, `GC in old space` , `1426.5MB` 

对于此类问题有一个粗暴的解决办法，就是增加 Old space 的 size: 

```bash
$ node --max-old-space-size=4096 yourFile.js
```

这样的话，old space 的size设置到了4G，大大调高了可分配的内存空间，也变相的解决了此类问题；不过代码中的潜在问题还是没有被找出来。

### Node中的内存管理是什么样的？

Node与不同于 C，C++，Rust此类需要手动管理内存的编程语言，它带有一个强大的GC，会在合适的时机进行无用对象的销毁和回收，一个 Node 程序是如何分配和管理内存的？

大致上，内存被区分为堆和栈，其中栈内存用于存放指针，基础类型的数据，函数调用等，通常这里空间很小，访问频次很高，堆内存主要用于存放对象的具体内容。

Node 借助了 Chrome 的V8引擎，在V8中，堆内存还被分为 `new space` 和 `old space` ，简单来说：刚被分配出来的内存变量都是new generate，被放入到 new space 中使用，随着时间的推移，进过2轮的垃圾回收都没有被销毁的对象会被放入到 old space 中，从而为这个 new space 腾出空间来存放新的对象，默认的 new space 空间是 16KB，可以通过参数进行调整，不过不建议调的非常大，因为过大的空间会导致 GC 的负担过重，服务会出现间歇性的停滞，典型的 STW（stop the world）问题。

### 如何进行GC？

V8 位了能优化这个问题，对 new space 和 old space 都分配了不同的GC算法：

- Scavenge for New Space
    
    New Space空间被分配完了之后，如果有新的内存分配需求，会触发一次GC，删除未引用的对象，如果对象经过了2轮的GC依然存活，则转入到 old space，这样的过程会导致 STW 不过时间非常短（1～10ms）这个是在 new space 的默认大小情况下。
    
- Mark-sweep for Old Space
    
    标记删除法是大多的编程语言的gc算法，也是实现方式比较简单的一种，简单来说就是每次GC从根节点开始，向外搜索，有引用就标记成 Black，无引用的标记成 White，全部遍历一遍之后，会在之后扫描全部的 white 对象，然后进行删除。
    

通过添加一个命令行参数 `--trace-gc`，可以track到每一次GC事件的具体信息:

```bash
$ node --trace-gc --max-old-space-size=50 script.js
```

### 如何调试OOM，并定位内存问题？

通过对内存管理和GC的背后逻辑梳理，接下来可以通过一些方法来定位内存问题：

- 运行时添加命令行参数，改小old space的空间大小来尝试复现问题
- 通过引入 v8 和 [performance hooks](https://nodejs.org/api/perf_hooks.html) 模块输出 GC 过程中的详细信息
- 也可以通过一些工具如 mdb 将详细的堆栈内容进行输出以定位具体的行代码问题

扩展阅读：

- [https://nodejs.org/en/docs/guides/diagnostics/memory/using-gc-traces/](https://nodejs.org/en/docs/guides/diagnostics/memory/using-gc-traces/)