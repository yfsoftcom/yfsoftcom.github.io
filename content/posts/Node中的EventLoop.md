---
title: Node中的Event Loop
date: 2023-03-19 09:25:00
tags: [Node,EventLoop]
---

# Node中的Event Loop

> Node.js 借助于V8的加持，在性能方面表现优异，在 single-thread 的基本架构下，可以达到NIO的惊人效果，这里必然存在一个超强的任务处理框架，那就是 Event Loop.
<!--more-->

### Basic Concepts

- Queue
    - 队列，一种数据结构，遵循 FIFO 的原则，先进的数据先出；与之对应的是 Stack，先进后出的原则。
- Event-Driven
    - 事件驱动，当事件完成时触发对应的回调函数，减少代码之间的相互堵塞。
- I/O
    - Input / Output 即输入输出，通常指操作系统和网络通讯中的输入输出，如：磁盘读写，网络读写等；这类操作通常由操作系统完成，并提供了一组底层API供Node去调用，并不是由Node去完成的，并不在 Node 的主线中去操作。
- 本轮循环 & 次轮循环
    - 在EventLoop的执行过程中，需要在本次结束之前完成的即为本轮循环，本轮完成之后去执行的，则放入到次轮循环。
- MacroTask & MicroTask
- libuv
    - 实现了 EventLoop 的 C++ 库，通常是在 *uix 系统中安装 Node 之后即可使用。
- epoll

### Event Loop Workflow

```jsx
   ┌───────────────────────────┐
┌─>│           timers          │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │     pending callbacks     │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │       idle, prepare       │
│  └─────────────┬─────────────┘      ┌───────────────┐
│  ┌─────────────┴─────────────┐      │   incoming:   │
│  │           poll            │<─────┤  connections, │
│  └─────────────┬─────────────┘      │   data, etc.  │
│  ┌─────────────┴─────────────┐      └───────────────┘
│  │           check           │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
└──┤      close callbacks      │
   └───────────────────────────┘
```

1. timers: 处理 `setTimeout` 和 `setInterval` 函数的回调
2. pending callbacks: 处理 I/O 相关的回调函数，并在下一次的循环中处理
3. idle, prepare: 处理系统相关调用
4. poll: 处理 I/O 相关的回调函数
5. check: 处理 `setImmediate` 相关的回调函数
6. close callbacks: 处理 `close` 相关的回调函数

### MacroTask & MicroTask

Event Loop 中将任务分类成了 MacroTask & MicroTask，并对其执行的顺序做了限定。

setTimeout & setInterval & setImmediate 都属于宏任务；Promise & process.nextTick 都属于微任务。

微任务追加在本轮循环，在同步任务执行完之后，立即执行，宏任务追加在次轮循环。

微任务中 process.nextTick 任务总是优先执行；因为微任务的队列中有2个独立的子队列：nextTickQuene 和 microTaskQuene；其中一个队列清空之后才会处理下一个队列。

### Example

```jsx
setTimeout(() => console.log(1));
Promise.resolve().then(() => console.log(4));
process.nextTick(() => console.log(3));
setImmediate(() => console.log(2));
Promise.resolve().then(() => console.log(4.1));
Promise.resolve().then(() => console.log(4.2));
Promise.resolve().then(() => console.log(4.3));
process.nextTick(() => console.log(3.3));
process.nextTick(() => console.log(3.2));
Promise.resolve().then(() => console.log(4.4));
process.nextTick(() => console.log(3.1));
```

上面这段代码，会在 node 11 以上的版本稳定输出：

```jsx
3
3.3
3.2
3.1
4
4.1
4.2
4.3
4.4
1
2
```

可以对照上述的 Event Loop 的处理逻辑来对照。

### Conclusion

EventLoop 的执行在 Node 和 Browser 上有部分行为上的差异，不过可以通过创建一些测试代码进行测试。

### Reference

[https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick)