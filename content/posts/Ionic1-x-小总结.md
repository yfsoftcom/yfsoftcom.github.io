---
title: Ionic1.x 小总结
id: 1490144994357
author: WangFan
tags:
  - Ionic
categories: []
date: 2017-03-22 09:21:00
---
一些小牢骚：
>在这个前端框架非常丰富的时代，选择一个合适的框架来做产品或做项目是一个相对纠结的决定；毕竟这些作品都还在发展，很多人甚至还没来得及使用它们就已经不在或者淘汰了，甚至原创团队都不得不做很大的`break change`；用户在发展，需求在变化，前端这个新兴的产业很吸引人又很淘气；用`java`就会用到`spring`，这点已经毋庸置疑；而面对前段这么多的选择，似乎很难统一意见。

---
最近结束了一个小项目，今天做一个小总结：

#### 大致需求
这些基本就是客户的基本诉求；
- 一个智能家居产品公司，有一些家庭电器的智能硬件，需要一款app来进行远程的控制能管理。

- 本身已经有一款`webapp`，使用体验一般，数据交互使用http(后端提供cgi)接口以json格式来传递数据。

- 为了升级体验，并集成更多如监控，语音等模块，需要对其进行封装嵌入到nativeapp中。

#### 选择开发框架
app的结构就是：`native + web`；通常的`hybrid`就是native+web，之前工作中使用过`cordova`(那时候还是`phonegap`)，它本身只是一个web和native交互的框架，没有ui，要么自己实现，要么使用一些开源产品：`jqmobile，appframework，touch`等等；都有尝试过，在android的体验很不好，直到后来出现了`ionic`，这是一个相对企业产品级的框架，做产品的体验还不错；考虑到`cordova`是主web，次native的模式，于是我们决定采用`native + ionic - cordova` 的模式。

#### ionic1.x的基本认识
> 我一直在强调是 *ionic1.x* ，因为 ionic2 和 ionic1 基本不兼容，甚至不是同一个产品。

##### 我觉得好的一些地方
- `ionic`有一个很好的在线原型设计的产品，[creator.ionic.io](http://creator.ionic.io)，它可以直接生成框架代码，这点很棒。前期可以很低的成本来沟通UI和基本交互。
- `ionic`的文档非常丰富，当然如果你有梯子，文档会更好一些，将就一些可以用 ionic.wang。
- 基于`angularjs1.x`的，这是一个很棒的产品，很全面，很强大，却不那么轻便和足够高效。ionic1.x是基于`angularjs`的指令模式，进行的ui封装，所以只要有angularjs的基础，可以轻松驾驭ionic。
- 测试框架很丰富，也是占了google的光了，angularjs就是`TDD`的模式开发出来的，有了很多好的比如：`karma，mocha`这样的开发框架

##### 我觉得不好的一些地方
- 这是一个让web开发者可以做app的框架，所以很多逻辑，交互都是通过js来实现的，大量的代码在webview中运行，android上体验非常差，特别是需要用到listview和较多图片的时候。
- 想要些native的代码就需要用`cordova`插件来实现，这还是比较蛋疼的。
- `ionic`是个spa设计，就是单页应用，在一个wbeview中就加载了所有的页面和js，这样很难在android上进行调优了。

#### 一些尝试
- 去掉`cordova`，也就是说，自己来实现一个基本的native和web的交互，这个其实不难；核心就是实现如何通过java来执行js和如何通过js执行java，下面是一些代码片段 

```
//java调用js
public class PreviewWebview extends WebView {
  //...
  
  //这个方法可以执行到 webview中 javascript 代码中的公开可访问的函数
  //比如 _mWebview.runJS("resetTimer();"); 可以执行js的 window.resetTimer() 函数
  public void runJS(String js){
    this.loadUrl("javascript:" + js);
  }
}

```
```
//js调用java
public class WebviewActivity extends BaseActivity implements IWebAppView, ICheckVersionView{
  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    //这行代码，可以将this作为 window.FPM 注入到 javascript 上下文中
    _mWebview.addJavascriptInterface(this, "FPM");
  }
  
  // 而所有带有 JavascriptInterface 这个注解的方法都会暴露给javascript，可以直接调用
  // 比如 window.FPM.jsLogout()就可以调用该方法
  @JavascriptInterface
  public void jsLogout(){
    // code here
  }
}
```
这里面有一个坑就是，通常我们认为 js 中的 `alert` 和 `confrim` 可以被正常执行，其实不是这样的，android中这些函数是不能正常执行的，需要我们自己去实现它，而`cordova`正是通过这个机制实现的native和web的交互，这里不再赘述。总之通常，还是不要在js中使用 `alert` 这些弹框来实现你的逻辑；会有意想不到的问题。

- 充分的使用angularjs的指令和模块化；指令是angularjs中相对先进的思想，也是很多前端框架实现组件化的设计思路；这个在angularjs2.x中有了充分的证实。当然指令是angularjs中相对复杂的知识点。

```
// 这是一个隐藏底部菜单栏的指令
app.directive('hideTabs', ['$rootScope', function($rootScope) {
  return {
    restrict:'AE',
    link:function(scope, element, attributes){
      scope.$on('$ionicView.beforeEnter', function (event, viewData) {
        viewData.enableBack = true;
        scope.$watch(attributes.hideTabs, function (value) {
          $rootScope.hideTabs = true;
        });
      });
      scope.$on('$ionicView.beforeLeave', function () {
        $rootScope.hideTabs = false;
      });
    }
  }
}])
```
- 使用`websocket + promise`来做数据交互，针对这个，我单独写了一篇博客: [封装ANGULARJS WEBSOCKET并支持PROMISE](http://blog.yunplus.io/%E5%B0%81%E8%A3%85Angularjs-Websocket%E5%B9%B6%E6%94%AF%E6%8C%81Promise/)

#### 一些小收获
- `rootScope` 是全局共享的，每一个`scope`都能使用它
- `angularjs` 的事件机制分为 `boardcast` 和 `emit` 两种，分别是向下分发和向上传递，有些类似于 dom 中的事件冒泡和事件捕获，使用时一定要注意
- ionic中有很多事件可以使用：`$ionicView.enter` , `$ionicView.leave` 等等，可以用来做一些复杂的逻辑。
- android和js交互是没有办法直接访问`$scope`中的函数的，需要一段代码来实现:
```
function goBack(){
  //通过angular.element 来注入scope实现函数的访问
  var appElement = document.querySelector('#app');
  var $scope = angular.element(appElement).scope();
  $scope.goBack();
}
```
- `ionic`在android上，tab默认在上面，可以通过设置来置于底部:
```
.config(['$ionicConfigProvider', '$sceDelegateProvider', function($ionicConfigProvider, $sceDelegateProvider){
  $ionicConfigProvider.platform.android.tabs.position('bottom');
}])
```
- android对于webview有一些安全限制，需要通过代码来实现目地：
```
public class PreviewWebview extends WebView {
  private void init(){
    //为前端h5提供一些PC端的接口，如：启用js,file,cache,localstorage等等
    WebSettings settings = getSettings();
    settings.setJavaScriptEnabled(true);
    settings.setDomStorageEnabled(true);
    settings.setAllowFileAccess(true);
    settings.setAllowUniversalAccessFromFileURLs(true);
    settings.setDefaultTextEncodingName("UTF-8");
    settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
    settings.setAppCacheEnabled(true);
    settings.setDatabaseEnabled(true);
    setWebViewClient(_mWebviewClient);
    setWebChromeClient(_mChromeClient);
  }
}
```

--- 
主要还是不断的实践和总结，还是可以在`ionic`这款产品上学到很多的；不过介于这些总结，后面会开始尝试用 `React` 来做产品。

>生命不息，折腾不止