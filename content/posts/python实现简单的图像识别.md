---
title: python实现简单的图像识别
id: 1491871982142
author: WangFan
tags:
  - python
categories:
  - python
date: 2017-04-11 08:53:00
---
*这里说的图像识别只是简单的图片对比，并不是通过机器学习之后实现的人脸识别等。*

## 实现目标
- 1.截取屏幕中的一块区域并保存到硬盘中
- 2.将图片中的内容识别为数字
- 3.调用鼠标和键盘模拟操作

## 实现代码
#### 1.python的图像库 `PIL`
python神器 PIL 可以对图片进行很多有趣的操作，大概和ps差不多吧，截屏、切割、模糊、旋转等等。
  ```python
  from PIL import Image, ImageGrab
  import os
  im = ImageGrab.grab()
  img_path = '.\\__snap__.png')
  im.save(img_path, 'PNG')
  ```
  当然这里不是重点，详细的PIL的api可以自行百度
  
  ---
#### 2.识别图片中的内容
将图片识别为：`2454132643`
![目标图片](http://olk3bzfd5.bkt.clouddn.com/pasted-1491872249193.png)
##### 实现思路：
- 1.将目标图片中的细节与样本中的细节图片做比较，差别最小的那个就很可能是目标数据；
- 2.每张图片都是由像素组成的，因此可以将图片识别为一个数组；
- 3.为了提高效率，可以将图片进行灰化，以减少像素值的计算；
- 4.对比两张图片的像素数组，差值接近0，则表示两张图片非常相似；

##### 操作步骤：
  - 获取样本图片并以规则的名称来命名: 
  大概就是下面这个样子
  ![样本图片](http://olk3bzfd5.bkt.clouddn.com/pasted-1491873564134.png)
  ![样本图片](http://olk3bzfd5.bkt.clouddn.com/pasted-1491873639637.png)
  
  - 获取样本图片的指纹并加载到内存中
```python
import itertools, operator, time, sys, os, re, string
from PIL import Image
meta_datas = {}

# 获取图片的指纹
def get_hash(img):  
  image = img.resize(img.size, Image.ANTIALIAS).convert("L")
  pixels = list(image.getdata())
  avg = sum(pixels) / len(pixels)
  return "".join(map(lambda p : "1" if p > avg else "0", pixels))
  
# 加载样本图片数据,返回一个样本指纹集合
# scope: 样本集合名称; path: 样本所在目录，样本必须是png格式
def load_sample(scope, path):
  metas = {}
  for root, dirs, files in os.walk(path, topdown = False):
    for name in files:
      hash = get_hash(Image.open( os.path.join(path, name) ))
      key = string.replace(name, '.png', '')
      metas[key] = hash
  meta_datas[scope] = metas
  return metas
```
  - 将目标图片进行分割
  `PIL` 提供了一个图片剪裁的api `crop` 
```python
# 切割目标图片
def crop_target(self, image):
  total_x = 164
  ceil_y = total_y = 16
  ceil_x = 12
  margin_x = 2
  sep = 4

  ceils = []
  s = 0
  for i in range(0, 11):
    if i % 3 is 0 and i > 0:
    s = s + 1
    box = (total_x - ((i + 1) * ceil_x) - (i * margin_x) - (s * sep), 0, total_x - (i * ceil_x) - (i * margin_x) - (s * sep), ceil_y)
    ceils.append(box)
  images = []
  for i in range(0, len(ceils) ):
    im = image.crop(ceils[i])
    images.append(im)
  return images
```
  - 每个小图片和样本图片进行对比，并返回最匹配的内容
```python
# 比较汉明距离
def hamming_dist(hash1, hash2):
  return sum(itertools.imap(operator.ne, hash1, hash2))
  
# 从样本集合中识别图片，返回最接近的样本名称
def read_images(scope, images, quality = 1):
  metas = meta_datas[scope]
  datas = []
  for image in images:
    min_dist = 100000
    min_name = None
    for name, hash in metas.items():
      dist = hamming_dist(hash, get_hash(image))
      if dist < quality:
        min_name = name
        break
      else:
        if dist < min_dist:
          min_dist = dist
          min_name = name
    datas.append(min_name)
  return datas
```

---
如此便完成了一个简单的图像识别的逻辑了。完整的图像操作我整理了起来：
```python
# -*- coding: utf-8 -*-
# 用于图像处理的工具
import itertools, operator, time, sys, os, re, string
import winapi
from PIL import Image, ImageGrab

CWD = os.getcwd()

# 加载图片
def load_image(path):
  return Image.open(path)

# 图像逆时针旋转指定角度
# angle >0 逆时针  <0 顺时针
def rotate(image, angle):
  return image.rotate(angle)

# 剪裁图片
def crop(image, start, size):
  x, y = start
  w, h = size
  return image.crop((x, y , x + w, y + h ))

# 填充颜色
def fill(image, start, size, color = (255, 255, 255)):
  x, y = start
  w, h = size
  image.paste(color, (x, y, x + w, y + h) )
  return image

# 截取屏幕
def grab(box, gray = True, clipboard = True):
  if clipboard:
    winapi.press_key(44) # sys rq
    time.sleep(0.2)
    im = ImageGrab.grabclipboard()
    if isinstance(im, Image.Image):
      im = im.crop(box)
    else:
      return None
  else:
    im = ImageGrab.grab(box)

  if gray:
    im = im.convert('L')
  return im

# 截取屏幕并保存
def grab_and_save(box, gray = True, dir = CWD, ext = 'PNG'):
  im = grab(box, gray)
  img_path = os.path.join(dir, str(int(time.time())) + '.' + ext.lower())
  im.save(img_path, ext)
  return im, img_path
```

```python
# -*- coding: utf-8 -*-
# 用于图像识别处理的工具
import itertools, operator, time, sys, os, re, string
from PIL import Image

meta_datas = {}

# 加载样本图片数据,返回一个样本指纹集合
# scope: 样本集合名称; path: 样本所在目录，样本必须是png格式
def load_sample(scope, path):
  metas = {}
  for root, dirs, files in os.walk(path, topdown = False):
    for name in files:
      hash = get_hash(Image.open( os.path.join(path, name) ))
      key = string.replace(name, '.png', '')
      metas[key] = hash
  meta_datas[scope] = metas
  return metas

# 样本和图片进行比较，返回比较结果
# true: 图片在样本集合中
def compare_image(scope, image, key = None , quality = 1):
  metas = meta_datas[scope]
  if metas is None:
    return False
  if key is None:
    for hash in metas.values():
      dist = hamming_dist(hash, get_hash(image))
      if dist < quality:
        return True
    return False
  else:
    hash = metas[key]
    if hash is None:
      return False
    return hamming_dist(hash, get_hash(image)) < quality

# 从样本集合中识别图片，返回最接近的样本名称
def read_images(scope, images, quality = 1):
  metas = meta_datas[scope]
  datas = []
  for image in images:
    min_dist = 100000
    min_name = None
    for name, hash in metas.items():
      dist = hamming_dist(hash, get_hash(image))
      if dist < quality:
        min_name = name
        break
      else:
        if dist < min_dist:
          min_dist = dist
          min_name = name
    datas.append(min_name)
  return datas

# 获取图片的指纹
def get_hash(img):  
  image = img.resize(img.size, Image.ANTIALIAS).convert("L")
  pixels = list(image.getdata())
  avg = sum(pixels) / len(pixels)
  return "".join(map(lambda p : "1" if p > avg else "0", pixels))

# 比较汉明距离
def hamming_dist(hash1, hash2):
  return sum(itertools.imap(operator.ne, hash1, hash2))
```