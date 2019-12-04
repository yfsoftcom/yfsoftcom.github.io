---
title: 使用Python实现简单的单一神经元
id: 1531719990776
author: YunPlus.IO
tags:
  - python
  - machine leaning
categories:
  - wangfan
date: 2018-07-16 13:46:00
---

> 本文是一个笔记帖，是关于 [实现简单神经网络] 的视频课程中使用到的源码整理。视频地址: [https://www.imooc.com/learn/813](https://www.imooc.com/learn/813)。
<!--more-->
#### 本文中提到一些基本概念与线性代数的关联
文中提到了一些机器学习的相关知识，老师介绍的比较浅显易懂，这里记录一些自己的理解。

要深入理解这些概念需要有一定的线性代数的基础。
- 神经元
  一个神经元就是整个神经网络中的一个节点，它允许接受一组信息，并将这些信息做一个简单的处理，并将处理结果反馈给下一个神经元。

  这里接受的一组信息可以理解为一个n维的`列向量`，处理信息的过程就是将这个向量乘以神经元自身的一个列向量的过程，处理的结果会进行一个分类，将其处理为1或者-1 。

- 感知器
  感知器是一个具有自我学习能力的神经元，可以通过一组分类好的数据对其进行训练，使其具有处理信息，将其分类的功能。

  这里分类好的数据可以理解为一个m*(n+1)维的`增广矩阵`，m表示数据集的量，n表示神经元单次处理的输入信息的维度，即输入的列向量的维度。
  而这个矩阵的一般解就是这个神经元的模型，即这个神经元的列向量。

- 简单分类算法
  该算法就是一个简单的数学模型；
  假设： 输入的向量信息为 `(10, 8, 7)`，我们需要神经元经过分类后得到 `1` ；
  那我们可以将这次处理用数据公式表示出来：
  `fn(10 * w1 + 8 * w2 + 7 * w3) = 1`

  而这里的 `(w1, w2, w3)` 正是我们需要知道的神经元的向量。

  将这个转换成通常的公式: 
  `fn(W0 + X1 * W1 + X2 * W2 + ... + Xn * Wn) = Y`

  这个公式表示了一次一般的神经元的向量运算。

  神经元的训练过程就是将已知的若干个`(X1, X2, .... Xn, Y)`带入到该公式中进行运算，以求得 `(W0, W1, W2 ... Wn)` 。而这个向量就是神经元的模型，可以用于预测之后的输入信息。

<!-- more -->
#### 延展的知识
- 矩阵的基本运算
  - 矩阵的转置
  - 矩阵的点乘

具体的过程需要理解 线性代数 课程中的相应的数学逻辑，然后在翻阅一些 python 中 numpy 的api .

#### 完整代码
本文中的代码只实现了简单神经元的实现，未实现课程中后半部分的自适应性神经元的算法。除此之外添加了将训练好的神经元保存的逻辑。
```python
# -*- coding: utf-8 -*-
"""
实现一个神经元的分类算法
https://www.imooc.com/learn/813
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import json, os, time

#分类器代码
class Perceptron(object):
    """
    eta:学习率
    n_iter:权重向量的训练次数
    w_:神经分叉权重向量
    errors_:用于记录神经元判断出错次数
    """
    def __init__(self, eta = 0.01, n_iter = 10):
        self.eta = eta
        self.n_iter = n_iter
        # 是否训练过的标识
        self._fited = self.load_model()
        """
        初始化向量为0
        加一是因为步调函数阈值
        """
        if not self._fited:
            self.w_ = np.zeros(1 + X.shape[1])
        
    def fit(self, X, y):
        """
        输入训练数据，培训神经元
        :param X: 输入样本向量
        :param y: 对应样本分类
         
        X:shape[n_samples, n_features]
        X:[[1,2,3],[4,5,6]]
        n_samples :2
        n_features:3
         
        y:[1,-1]
        """
        self.errors_ = []
 
        for _ in range(self.n_iter):
            errors = 0
            for xi, target in zip(X,y):
                update = self.eta * (target - self.predict(xi))
 
                self.w_[1:] += update * xi
                self.w_[0] += update
 
                errors += int(update!= 0)
                self.errors_.append(errors)

        self.save_model()
 
    def net_input(self, X):
        return np.dot(X, self.w_[1:] + self.w_[0])
        
    """
    将输入信息进行分类
    """
    def predict(self, X):
        return np.where(self.net_input(X) >= 0.0, 1, -1)

    def get_model(self):
        return self.w_

    def save_model(self):
        with open('a.model', 'w') as f:
            f.write(json.dumps(self.w_.tolist()))

    def is_fited(self):
        return self._fited

    def load_model(self):
        if os.path.exists('a.model'):
            with open('a.model', 'r', encoding="UTF-8") as f:
                data = json.load(f)
                self.w_ = np.array(data)
            return True
        else:
            return False
 

 
file = 'https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data'
 
df = pd.read_csv(file,header=None)
# 输出数据集的前10条数据，形式如下
"""
[[5.1 3.5 1.4 0.2 'Iris-setosa']
 [4.9 3.0 1.4 0.2 'Iris-setosa']
 [4.7 3.2 1.3 0.2 'Iris-setosa']
 [4.6 3.1 1.5 0.2 'Iris-setosa']
 [5.0 3.6 1.4 0.2 'Iris-setosa']
 [5.4 3.9 1.7 0.4 'Iris-setosa']
 [4.6 3.4 1.4 0.3 'Iris-setosa']
 [5.0 3.4 1.5 0.2 'Iris-setosa']
 [4.4 2.9 1.4 0.2 'Iris-setosa']
 [4.9 3.1 1.5 0.1 'Iris-setosa']
 [5.4 3.7 1.5 0.2 'Iris-setosa']]
"""
# print(df.loc[0:10,[0,1,2,3,4]].values)

# 使用前100行的作为训练样本
# type(y) is <class 'numpy.ndarray'>
y = df.loc[0:100,4].values
# 将矩阵中的 string 转换成 1/-1，便于运算
y = np.where(y=='Iris-setosa', -1, 1)

#根据整数位置选取单列或单行数据
# x 是一个 m*n 的矩阵，其中 m = 100, n = 2, 
# X11 对应的是数据集中第一行第一列，X12 是数据集中第一行第3列
X = df.loc[0:100,[0,2]].values

"""
# 绘制数据点
plt.scatter(X[:50,0], X[:50,1], color='red', marker='o', label="setosa") 
plt.scatter(X[50:100,0], X[50:100,1], color='blue', marker='x', label="versicolor")

# 设置散点图的坐标和图示
plt.xlabel('huabanchangdu')
plt.ylabel('huajingchangdu')
plt.legend(loc='upper left')
"""

# 定义一个神经元，并进行训练
ppn = Perceptron(eta=0.1, n_iter=100)

# 如果存在已训练过的模型，则无需重复训练
if not ppn.is_fited():
    ppn.fit(X,y)
# print(ppn.get_model())

# 将训练好的简单神经元作为分类器进行输入的分类
def plot_decision_region(X, y, classifier, resolution = 0.02):
    markers=('s','x','o','v')
    colors=('red','blue','lightgreen','gray','cyan')
    cmap = ListedColormap(colors[:len(np.unique(y))])
 
    # 获取矩阵的两列的最小值和最大值
    x1_min, x1_max = X[:, 0].min() - 1, X[:, 0].max()
    x2_min, x2_max = X[:, 1].min() - 1, X[:, 1].max()

    # 生成一个二维的矩阵
    xx1, xx2 = np.meshgrid(
                    np.arange(x1_min, x1_max, resolution),
                    np.arange(x2_min, x2_max, resolution)
               )
    Z = classifier.predict(np.array([xx1.ravel(), xx2.ravel()]).T)
    # print (xx1.ravel())
    # print (xx2.ravel())
    # print (Z)
    Z = Z.reshape(xx1.shape)
    plt.contourf(xx1, xx2, Z, alpha = 0.4, cmap = cmap)
    plt.xlim(xx1.min(), xx1.max())
    plt.ylim(xx2.min(), xx2.max())

    for idx, cl in enumerate(np.unique(y)):
        plt.scatter(x = X[y == cl, 0], y = X[y == cl,1], alpha=0.8, 
                    c = cmap(idx), marker = markers[idx], label = cl)

    plt.xlabel('huajingchang')
    plt.ylabel('huabanchang')
    plt.legend(loc = 'upper left')
    plt.show()

# X = df.iloc[0:100,[0,2]].values
plot_decision_region(X, y, ppn, resolution = 0.03)

```

安装完相应的依赖之后，直接运行该源码即可看到分类结果。