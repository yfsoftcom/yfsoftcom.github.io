---
title: "Node中的Cluster"
date: 2023-03-23T02:47:19Z
Description: "Node中的Cluster"
Tags: ["Node", "Cluster"]
Categories: ["Node"]
---

> Node.js 通常采用 Single-threaded 的模式运行，即始终只有一个进程，也就是只能使用到计算机的一颗CPU，因此在选择服务器作为 Node 的运行环境时，CPU的主频是关键，而不是核心的数量。如何能够激发更多的核心参与运算，Cluster模块被设计了出来，使用 IPC 的基本通讯方式，在master进程中fork出若干的worker进程，彼此协调，共同完成任务。这个对于从未接触过分布式的开发者来说非常适合学习和理解。
> 

### 基本概念

- `IPC` (Inter-Process Communication) 一种非常通用的多进程通讯方式，可以实现不同程序之间的协作，举个简单的例子：`cat ~/foo.txt | grep bar` 这样一个简单的linux指令就是一次 IPC 通信，中间的管道符用于将前面的程序的输出作为输入给到后面的程序，`cat`  和 `grep` 就是2个独立的进程。由此可见，现代计算机中普遍使用IPC，只是我们尚未察觉。不过IPC只限于一台机器内部通讯，区别于传统意义上的分布式。
- Node中的Cluster可以监听本地的一个端口，并将请求转发到不同的 worker 内进行处理，每一个worker都是一个独立的进程，可以享用单独的CPU，在资源不够的情况下也会根其它的worker进程共享。Master进程内部有一个简单的负载机制，可以通过轮询或者饥饿模式（不知这么翻译是否妥当？）下面有原文的引用：
    
    > The cluster module supports two methods of distributing incoming connections. The first one (and the default one on all platforms except Windows) is the round-robin approach, where the primary process listens on a port, accepts new connections and distributes them across the workers in a round-robin fashion, with some built-in smarts to avoid overloading a worker process. The second approach is where the primary process creates the listen socket and sends it to interested workers. The workers then accept incoming connections directly.
    > 
    
    除了简单的转发请求之外，master和workers之间也可以进行通讯，相互之间发送指令，限于 master → all workers 以及 worker → master 之间，也就是 worker 之间无法直接通讯，master 也无法单独给某一个 worker 发信息，当然可以通过编码的方式来实现，方案也非常简单。
    
<!--more-->
### 深入**思考**

- 如果cluster的worker进程挂了会怎么样？会自动重启嘛？master进程挂了又会怎么样呢？
- 对应的传统的分布式算法又是如何解决这个问题的？比如：`zookeeper`，`etcd`
- 如果请求的负载非常不平均，该如何更好的协调worker之间的load？比如第一个请求包含了1w次的浮点运算，第二个请求只有1次整数运算，2个worker之间的工作量极度不平衡，后面的请求分配到一个overload的worker会出现什么情况？
- 优秀的负载均衡是如何做到的？

### 猜想实验

- 创建一个http服务接受请求，输出worker信息（进程编号），连续发多次请求，查看输出结果，如果workerID按顺序交替输出，则采用了轮训模式。
- 运行之后，查看CPU的负载，如果每个CPU都有负载说明确实运用到了多核算力。

### 动手操作

- 创建测试代码：（该代码片段来自官网）
    
    ```bash
    const cluster = require('node:cluster');
    const http = require('node:http');
    const numCPUs = require('node:os').cpus().length;
    const process = require('node:process');
    
    if (cluster.isPrimary) {
      console.log(`Primary ${process.pid} is running`);
    
      // Fork workers.
      for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
      }
    
      cluster.on('exit', (worker, code, signal) => {
        console.log(`worker ${worker.process.pid} died! signal: ${signal}`);
        // 这里是监听worker退出事件的，如果重新 fork 可以自动重启，但会产生一个新的 worker，而不是启动原来的
        // 并且，重新生成的worker会随机的插入到原来的队列
        cluster.fork();
      });
    } else {
      // Workers can share any TCP connection
      // In this case it is an HTTP server
      http.createServer((req, res) => {
        res.writeHead(200);
        res.end(`response from worker: ${process.pid}\n`);
      }).listen(8000);
    
      console.log(`Worker ${process.pid} started`);
    }
    ```
    
- Case1: 依次发送请求，查看workerId是否顺序的
    
    ```bash
    # 启动之后的输出，其中的ID是顺序的
    Primary 27997 is running
    Worker 27998 started
    Worker 27999 started
    Worker 28000 started
    Worker 28001 started
    Worker 28002 started
    Worker 28003 started
    Worker 28004 started
    Worker 28005 started
    
    # 发送http请求查看响应
    # 使用 for 循环连续发送 20 个请求，发现响应的输出 ID 也是按照启动的顺序连续的
    # 由此可以推断，master的分配是轮训的机制
    ➜  ~ for i in {1..20}
    do
    curl localhost:8000
    done
    response from worker: 28004
    response from worker: 28005
    response from worker: 27998
    response from worker: 27999
    response from worker: 28000
    response from worker: 28001
    response from worker: 28002
    response from worker: 28003
    response from worker: 28004
    response from worker: 28005
    response from worker: 27998
    response from worker: 27999
    response from worker: 28000
    response from worker: 28001
    response from worker: 28002
    response from worker: 28003
    response from worker: 28004
    response from worker: 28005
    response from worker: 27998
    response from worker: 27999
    ```
    
- Case 2: 通过 kill 命令关闭了worker进程
    
    ```bash
    Primary 28494 is running
    Worker 28495 started
    Worker 28496 started
    Worker 28497 started
    Worker 28498 started
    Worker 28499 started
    Worker 28501 started
    Worker 28500 started
    Worker 28502 started
    worker 28500 died! signal: SIGTERM   # kill 28500 ，获得 SIGTERM 信号
    Worker 28532 started                 # 重新 fork 了一个新的 worker
    worker 28499 died! signal: SIGKILL   # kill -9 28499 ，获得 SIGKILL 信号，强制退出
    Worker 28561 started
    ```
    
    总的来说，worker可以emit对应的退出事件，通过处理可以完成重启并自动添加到worker队列，但是如果 master 进程关闭了，整个程序都退出了。
    

### 总结归纳

- Cluster模块封装了一个简单的IPC实现的水平扩展和流量分发以更高效的运用CPU的多核心能力，但master进程没有得到保护，虽然启动了多实例，但是没有保活能力。
- 其流量分发的逻辑也非常简单，一次轮训，可以深入学习一下，是否可以修改其算法（作为思考题）
- `pm2` 模块是一个借助 cluster 方便的部署多实例 node 服务的开源项目，可参考阅读，当然不止 node 任何可运行的网络服务都可以用它去运行。
- 本文没有深入的使用压力测试，查看CPU的负载，如果需要，可以通过 loadtest(类似于apache ab测试工具) 进行动手实验。

### 扩展阅读

- [https://nodejs.org/api/cluster.html](https://nodejs.org/api/cluster.html)
- [https://github.com/Unitech/pm2](https://github.com/Unitech/pm2)
- [https://github.com/alexfernandez/loadtest](https://github.com/alexfernandez/loadtest)