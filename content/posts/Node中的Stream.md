---
title: Node中的Stream
date: 2022-03-03 09:25:00
tags: [Node,Stream]
---

> Node.js 中的 Stream 模块是非常厉害，高效却不容易理解的模块。

常常因为不太理解而不太敢用。

<!--more-->

Node 以非阻塞式 IO 的概念进入编程市场，IO 包含文件读写，网络传输等。非阻塞式 IO 如何高效，这个牵扯到底层的事件轮询，epoll 模型等。

stream模块的设计秉承了 NIO 的思想，通过数据的流动来驱动系统资源的调配。

引用的文章提供了一个非常好的案例，对于一个 400 MB 左右的文件，通过非 stream 的方式传输，系统的内存占用会增加到 400+ MB，也就是说，程序会将文件全部加载内存，再通过建立好的链接进行数据传输。这点也非常符合直觉，很好理解。

但是 Node.js 的 stream 是那么巧妙而高效，可以以非常小的内存消耗满足同样的性能表现；进过测试的内存表现并没有明显增加，只是增加到 40+ MB 左右，也就是按需获取，只加载即将需要的数据，清理已经消费过的数据；也有点类似于缓冲区。

stream 不仅可以用于以上场景，还可以非常方便的将不同的输入输出进行链接，类似于 Linux 的管道，输入输出建立管道就可以单向的流入，流出数据，同样也会高效的利用内存资源。

为了更好的利用好这种模型，Node 抽象出了 Readable & Writeable 接口，通过实现对应的接口函数，即可创建对应的 stream 对象，进行大量数据的传输。

不过有些场景下需要特殊的接口，比如 Duplex 接口，既可以作为输入也可以作为输出，比如 TCP 链接，可读可写。

这些接口都是利用了 EventEmit 这个模块，通过订阅系统事件来进行逻辑控制。

很多跟 IO 相关的开源 package 都是运用了这个模块，比如：db, redis 相关的模块都是这样的。

### 给本文带来启发的文章

[https://www.freecodecamp.org/news/node-js-streams-everything-you-need-to-know-c9141306be93/](https://www.freecodecamp.org/news/node-js-streams-everything-you-need-to-know-c9141306be93/)

[https://nodesource.com/blog/understanding-streams-in-nodejs/](https://nodesource.com/blog/understanding-streams-in-nodejs/)
