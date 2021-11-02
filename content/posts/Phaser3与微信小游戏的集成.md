---
title: Phaser3与微信小游戏的集成
author: WangFan
tags:
  - Phaser3
  - 微信小游戏
categories: 
  - Phaser3
  - 微信小游戏
date: 2021-11-01 23:53:00
---

[Phaser3](https://phaser.io/phaser3) 是一个非常轻巧灵活且活跃的游戏框架，可以用来方便的开发2D游戏，在 [github](https://github.com/photonstorm/phaser) 上也有很多关注，开发团队也在持续维护。
对于我来说，比较关注它的易用性，本身并没有游戏开发经验，所以需要一个文档相当全面的框架来实现游戏逻辑。经过筛选，决定使用这个小型的2D引擎。
如果仅仅用它来开发web版，那可以开箱即用，迅速进入撸代码的环节，但是对于微信小游戏来说，本身提供的 windows 和 document 对象都是经过处理的，不能直接拿来用，所以需要做一个适配，google了一圈确实没有找到现成的东西，于是只能盲人摸象，根据自己的理解结合一些过时的文档资料进行整理和实践。终于找到了一个可行的方案。
<!--more-->

### 自定义编译模块

Phaser3的游戏框架有很多组件，但是可以灵活的编译打包，按需使用，官方提供了定制化编译的实例项目，可以clone下来自行动手。(phaser3-custom-build)[https://github.com/photonstorm/phaser3-custom-build]

```bash
$ git clone https://github.com/photonstorm/phaser3-custom-build
$ cd phaser3-custom-build
$ npm install
```

该项目提供了很多模板，可以全量打包，只打包Core部分，或者自定义。

这是它提供的默认的编译脚本：
```json
{
    "build": "webpack --display-modules",
    "buildlog": "webpack --json --profile > webpack.build-log.json",
    "buildsprite": "webpack --config webpack.config-sprite.js --display-modules",
    "buildspritelog": "webpack --config webpack.config-sprite.js --json --profile > webpack.build-sprite-log.json",
    "buildboth": "webpack --config webpack.config-both.js --display-modules",
    "buildbothlog": "webpack --config webpack.config-both.js --json --profile > webpack.build-both-log.json",
    "buildspritesmall": "webpack --config webpack.config-sprite-small-loader.js --display-modules",
    "buildspritesmalllog": "webpack --config webpack.config-sprite-small-loader.js --json --profile > webpack.build-sprite-small-loader-log.json",
    "buildfull": "webpack --config webpack.config-full.js --display-modules",
    "buildfulllog": "webpack --config webpack.config-full.js --json --profile > webpack.build-full-log.json",
    "buildcore": "webpack --config webpack.config-core.js --display-modules",
    "buildcorelog": "webpack --config webpack.config-core.js --json --profile > webpack.build-core-log.json"
  }
```

执行对应的指令即可在 `/dist` 目录下得到编译好的文件。
```bash
$ npm run buildfull
```

不过可以看到这个文件size还是非常巨大的，要适配小游戏还是尽量压缩一下，去掉一些高级的组件。

```bash
$ ls -lh dist

// output:
-----------------------
6.5M phaser-full.js
8.1M phaser-full.js.map
1016K phaser-full.min.js
```

### 图片加载模块修改

小游戏的框架里面对图片的加载与webkit不同，所以需要做一些手脚。
- 1. 打开 `node_modules/phaser/src/loader/filetypes/ImageFile.js` 进行编辑
- 2. 添加代码：
    ```javascript
        ...
    +   load: function()
    +   {
    +       this.loader.nextFile(this, true);
    +   },

        onProcess: function ()
        {
            this.state = CONST.FILE_PROCESSING;

            this.data = new Image();

            this.data.crossOrigin = this.crossOrigin;

            var _this = this;

            this.data.onload = function ()
            {
                File.revokeObjectURL(_this.data);

                _this.onProcessComplete();
            };


            this.data.onerror = function ()
            {
                File.revokeObjectURL(_this.data);

                _this.onProcessError();
            };

    -       File.createObjectURL(this.data, this.xhrLoader.response, 'image/png');
    +       this.data.src = this.url;
        },
    ...
    ```

此时，对于图片加载的逻辑已经改造好了。


### 配置需要的组件

如下是我在项目中实际用到的组件配置： [phaser-core.js](https://github.com/yfsoftcom/phase3-custom-build/blob/main/phaser-core.js)

```javascript
var Phaser = {

    Cameras: { Scene2D: require('cameras/2d') },
    Events: require('events/index'),
    Game: require('core/Game'),
    Input: {
        Touch: require('input/touch'),
        Events: require('input/events'),
        InputManager: require('input/InputManager'),
        InputPlugin: require('input/InputPlugin'),
        Pointer: require('input/Pointer'),
    },
    GameObjects: {
        DisplayList: require('gameobjects/DisplayList'),
        GameObjectCreator: require('gameobjects/GameObjectCreator'),
        GameObjectFactory: require('gameobjects/GameObjectFactory'),
        UpdateList: require('gameobjects/UpdateList'),
        Sprite: require('gameobjects/sprite/Sprite'),
        Image: require('gameobjects/image/Image'),
        Factories: {
            Image: require('gameobjects/image/ImageFactory'),
            Sprite: require('gameobjects/sprite/SpriteFactory'),
        }
    },
    Loader: {
        LoaderPlugin: require('loader/LoaderPlugin'),
        MultiFile: require('loader/MultiFile'),
        AtlasJSONFile: require('loader/filetypes/AtlasJSONFile'),
        ImageFile: require('loader/filetypes/ImageFile'),
        TilemapJSONFile: require('loader/filetypes/TilemapJSONFile'),
    },
    Scale: require('scale'),
    Scene: require('scene/Scene'),
    Scenes: require('scene'),
    Textures: require('textures'),
    Tweens: require('tweens'),
    Tilemaps: require('tilemaps')
};
```

执行编译之后，文件小了很多，缩小了一半
```bash
$ npm run buildcore
```

```bash
$ ls -lh dist

// output:
-----------------------
3.7M phaser-core.js
4.6M phaser-core.js.map
580K phaser-core.min.js
```

将编译之后的文件，copy到你的小游戏项目中进行保存，然后在`game.js`中进行导入。

```javascript
  import './src/libs/weapp-adapter'
  import './src/libs/symbol'
+ import * as Phaser from './src/libs/phaser-core.min'
  import main from './src/main'

  const ctx = canvas.getContext('2d')
  const screen = wx.getSystemInfoSync()

  main(Phaser, screen, ctx, canvas)
```

### 入口函数调整

对于小游戏，尽量使用默认提供的 `canvas`，所以需要在 `Phaser3` 主入口处的 `config` 进行改造。

```javascript
const config = {
  type: Phaser.CANVAS,
  canvas: canvas,
  input: {
    touch: true
  }
  ...
};
```

基本按照上述的步骤可以完成 Phaser3 和 微信小游戏的集成操作，开发过程中如果遇到什么库找不到了，可以回到 build 项目中，按需找到对应的内容，重新编译导入一次即可。

### 相关引用文章

- https://xiandew.github.io/game%20dev/2021/01/04/Run-Phaser3-on-WeChat-Minigame-Platform.html