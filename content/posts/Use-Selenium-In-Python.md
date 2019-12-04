---
title: Use Selenium In Python
id: 1531098990712
author: Wangfan
tags:
  - python
  - selenium
categories:
  - wangfan
date: 2018-07-09 09:16:00
---

本文中主要分享一些关于 Windows 环境下使用 Selenium 来操作 IE11 的一些细节和问题。
<!--more-->
## Selenium For Python
#### 1. 如何使用 IE
  - 1.1 下载对应版本的 `webdriver.exe`
    这里指的对应的版本指的是 浏览器的软件版本 64/86。如果版本不对，会导致 sendKeys 函数执行效率很慢。
  - 1.2 将 `webdriver.exe` 放在 windows 的 `PATH` 中
  - 1.3 设置 IE11 的安全策略，全部保持一致，全部信任或者不信任
  - 1.4 一些遇到的问题
    - 1.4.1 一些没有证书的 https 站点，会提示 `继续前往` ，可以通过模拟点击A标签来绕过错误提示
    - 1.4.2 第一次操作的时候，IE11 的安全策略会弹出添加到信任站点，否则弹框会导致一些未知问题

#### 2. 如何重复使用已开启的浏览器回话？
  *这是本文的重点之一*。

  - 2.1 关于 chrome 的会话保持
    ##### 实现思路：
    - i. 打开一个 selenium 会生成一个 `sessionid` , 只要将该id保存下来，下次继续使用这个id就可以重新使用 。
    - ii. 通过 `driver.session_id` 可以获取到当前回话的 `sessionid` 。
    - iii. 将这个 `sessionid` 赋值给新的 driver 实例，或许可以重连到上一次的会话。

    ##### 编码目标：
    - i. 继承 `Remote` 类，并复写 `start_session` 函数，阻止生成新的 session_id
    
      ```python
      # -*- coding: utf-8 -*-
      from selenium.webdriver import Remote
      from selenium.webdriver.chrome import options
      from selenium.common.exceptions import InvalidArgumentException

      class ReuseChrome(Remote):

          def __init__(self, command_executor, session_id):
              self.r_session_id = session_id
              Remote.__init__(self, command_executor=command_executor, desired_capabilities={})

          def start_session(self, capabilities, browser_profile=None):
              """
              重写start_session方法
              """
              if not isinstance(capabilities, dict):
                  raise InvalidArgumentException("Capabilities must be a dictionary")
              if browser_profile:
                  if "moz:firefoxOptions" in capabilities:
                      capabilities["moz:firefoxOptions"]["profile"] = browser_profile.encoded
                  else:
                      capabilities.update({'firefox_profile': browser_profile.encoded})

              self.capabilities = options.Options().to_capabilities()
              self.session_id = self.r_session_id
              self.w3c = False
      ```
  - 2.2 关于 ie 的会话保持
    实现了 Chrome 的 reuse， ie 的实现思路也是类似，只是 IEWebDriver 有些参数和 Remote 的有些不同；需要翻阅一些 selenium 的源码。思路都一样，就不重复说了，直接贴代码。

    ```python
    # -*- coding: utf-8 -*-
    from selenium.webdriver.ie.webdriver import WebDriver as IEWebDriver
    from selenium.common.exceptions import InvalidArgumentException
    from selenium.webdriver.ie import options

    class ReuseIe(IEWebDriver):

        def __init__(self, executable_path, port, session_id):
            self.r_session_id = session_id
            IEWebDriver.__init__(self, port=port, desired_capabilities={})

        def start_session(self, capabilities, browser_profile=None):
            """
            重写start_session方法
            """
            if not isinstance(capabilities, dict):
                raise InvalidArgumentException("Capabilities must be a dictionary")
            if browser_profile:
                if "moz:firefoxOptions" in capabilities:
                    capabilities["moz:firefoxOptions"]["profile"] = browser_profile.encoded
                else:
                    capabilities.update({'firefox_profile': browser_profile.encoded})

            self.capabilities = options.Options().to_capabilities()
            self.session_id = self.r_session_id
            self.w3c = True
    ```

---

#### 3. 如何等待一些异步执行的js执行完立即执行？
  *这是本文的另一个重点*。

##### 实际使用的过程中，会遇到异步执行的js代码，执行下一步操作需要等待这个js执行完。
  
  在不了解 selenium 的一些特性之前，会想到 `time.sleep(?)` ，这样确实可以让操作等待；且等待的时间是固定的，无法与dom或者js真正的交互；为了安全只能尽量设置得大一些，这样也白白浪费了时间。
  selenium 为我们提供了一些非常友好的 api 来解决这个问题。

  ```python
  WebDriverWait(_driver, seconds).until(EC.element_to_be_clickable((By.ID, id)))
  ```
  意思就是：等待若干秒直到某个元素可被点击，则立即返回该元素，超时则抛出相应的异常。
  通过这个api可以确保异步或者网络延迟导致dom结构变化的时间在一个范围内，脚本可以按照设计的流程执行下去，并且不消耗多余的等待时间。
  使用前，需要导入它们
  ```python
  from selenium.webdriver.support.ui import WebDriverWait
  from selenium.webdriver.support import expected_conditions as EC
  ```
  更多的相关api可以安装了 selenium 之后在 site-package 中找到它的源代码。

#### 4. 如何确保dom被完全渲染出来了？
  判断dom有没有正常的显示可以使用：
  ```python
  _driver.find_element_by_id(id).is_displayed()
  ```
  当然这是立即判断，没有等待。
  想要等待某个元素显示好了再执行，则需要 
  ```python
  WebDriverWait(_driver, seconds).until(EC.visibility_of_element_located((By.ID, id)))
  ```
  同样也是用到了 `expected_conditions` 库中的api。

#### 5. 如何执行单元测试

  想要测试 selenium 的脚本，需要先编写一个 html 页面，提供一些dom元素：`button`，`input`，`alert` 等等，然后通过脚本去控制它们；再使用 python 的 `unittest` 框架的断言库去测试它们。

#### 6. Bug: 使用之前的浏览器回话，操作 iframe 时会无法在父子框架之间进行正常的切换

  如果在一个 frame 中，脚本异常退出，重连之后，无法再次获取到该frame，这个问题暂时没有解决。