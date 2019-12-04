---
title: Convert RTSP to RTMP with FFMPEG
id: 1532567618985
author: YunPlus.IO
tags:
  - rtsp
  - rtmp
  - ffmpeg
categories:
  - wangfan
date: 2018-07-26 09:13:00
---

本文主要介绍在浏览器上播放监控摄像头的方法。一些主流的监控摄像头都提供了 rtsp 流媒体协议，这种协议只能通过特定的播放器才能正常播放，想要在浏览器中播放，必须要通过转码；具体细节这里不一一列举，可以搜索`rtsp` 转 `rtmp` 的原理。
<!--more-->
## 通过`ffmpeg`将 RTSP 的流媒体转换成 RTMP 格式

> 如果有问题需要交流，可以联系我，手机号也是微信号: `13770683580` . 或者在下方留言。

### 主要实现思路

- nginx部署一个rtmp流媒体服务端
- ffmpeg转换rtsp流到服务端
- 浏览器通过flash播放

### Linux上的实现

- 编译 nginx 并添加 rtmp 模块
  ```bash
  git clone https://github.com/arut/nginx-rtmp-module.git  
  # centos redhat
  # yum -y install openssl openssl-devel
  # ubuntu debain
  apt-get install openssl libssl-dev
  wget http://nginx.org/download/nginx-1.14.0.tar.gz  
  tar -zxvf nginx-1.14.0.tar.gz  
  cd nginx-1.14.0  
  ./configure --prefix=/usr/local/nginx  --add-module=../nginx-rtmp-module  --with-http_ssl_module    
  make && make install
  ```

  编译成功之后，修改`nginx.conf`的配置信息。

  ```bash
  # insert into the root element
  rtmp {  
    server {  
        listen 1935;  

        application live {  
            live on;  
        }
      application hls {      
            live on;      
            hls on;      
            hls_path data/misc/hls;    
            hls_fragment 1s;     
            hls_playlist_length 3s;   
        }  
    }  
  }
  # insert after the http server element
  location /stat {    
    rtmp_stat all;    
    rtmp_stat_stylesheet stat.xsl;    
  }    

  location /stat.xsl {    
    root nginx-rtmp-module/;    
  }    
      
  location /control {    
    rtmp_control all;    
  } 
  location /hls {    
    types {    
        application/vnd.apple.mpegurl m3u8;    
        video/mp2t ts;    
    }    
    root data/misc;    
    add_header Cache-Control no-cache;    
  } 
  ```


- 编译安装 ffmpeg
  ```bash
  sudo apt-get install yasm nasm \
          build-essential automake autoconf \
          libtool pkg-config libcurl4-openssl-dev \
          intltool libxml2-dev libgtk2.0-dev \
          libnotify-dev libglib2.0-dev libevent-dev \
          checkinstall
  wget https://www.ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
  tar jxvf ffmpeg-snapshot.tar.bz2
  cd ffmpeg
  ./configure --prefix=/usr
  time make -j 8
  cat RELEASE
  sudo checkinstall
  sudo dpkg --install ffmpeg_*.deb
  ```

- 调试一下视频流
  - 需要下载一个 vlc 的播放器
  - 打开流

- 执行转码命令
  `ffmpeg -i "rtsp://admin:admin123@192.168.1.205:554/h264/ch1/main/av_stream" -f flv -r 25 -s 1960*1280 -an "rtmp://localhost:1935/live/test"`

- 使用 `video.js` 在浏览器中播放
  ```html
  <!DOCTYPE html>
  <html lang="en">
      <head>
          <title>Video.js | HTML5 Video Player</title>
          <link href="https://unpkg.com/video.js@5.20.1/dist/video-js.min.css" rel="stylesheet">
      </head>
      <body>
          <video id="example_video_1" class="video-js vjs-default-skin" controls preload="auto" width="640" height="360" poster="" data-setup="{}">
              <source src="rtmp://192.168.100.196:1935/live/test" type="rtmp/flv">
              <p class="vjs-no-js">Allow Browser Enable Flash Plugin</p>
          </video>
          <script src="https://unpkg.com/video.js@5.20.1/dist/video.js"></script>
      </body>
  </html>
  ```
  实际使用 video.js 的过程中会出现一些问题，其主要原因是较新的版本不支持 flash 播放，需要使用 5.x 的版本来进行播放。


