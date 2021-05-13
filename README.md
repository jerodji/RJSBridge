# RJSBridge

[![CI Status](https://img.shields.io/travis/20533206/RJSBridge.svg?style=flat)](https://travis-ci.org/20533206/RJSBridge)
[![Version](https://img.shields.io/cocoapods/v/RJSBridge.svg?style=flat)](https://cocoapods.org/pods/RJSBridge)
[![License](https://img.shields.io/cocoapods/l/RJSBridge.svg?style=flat)](https://cocoapods.org/pods/RJSBridge)
[![Platform](https://img.shields.io/cocoapods/p/RJSBridge.svg?style=flat)](https://cocoapods.org/pods/RJSBridge)



## Installation

RJSBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RJSBridge'
```

## Use

### 交互类 method 方式

```objc
/**
 init
 */
self.webView = [[WKWebView alloc] initWithFrame:rect configuration:[WKWebViewConfiguration new] listenerName:@"JSBridgeListener" interface:[NativeMethods new]];

/**
 js call native
 */
const method = 'testWithParams';
const parmas = {'key1':'abc','key2':'mkl'};
const callback = (p1, p2, p3) => {
    console.log(p1, p2, p3);
    var obj1 = JSON.parse(p1);
    let div = document.getElementById("op");
    div.innerHTML = obj1.letter;
};
JSBridge.call(method, parmas, callback);

/** 
 call back js
 */
[func callbackJSWithParams:nativeParams completionHandler:^(id response, NSError *error) {
    NSLog(@">>> 3 : Native 回调 JS 完成");
}];
```

### service方式

```objc
/**
 init
 */
self.webView = [[WKWebView alloc] initWithFrame:rect
  configuration:[[WKWebViewConfiguration alloc] init]
   listenerName:@"JSBridgeListener"
       services:@{
           @"testService": [NativeMethods new],
           @"ioService": [IOSInterface new]
       }];

/**
 js call native
 */
const apiTest = 'testService/testWithParams';
const apiLog = 'ioService/log';
// JS调用Native方法
//第一个参数: native方法api, 如testService服务的testWithParams方法
//第二个参数: 入参
//第三个参数: 回调函数
JSBridge.call(apiTest, {'key1':'abc','key2':'mkl'}, (p1, p2, p3) => {
    console.log(p1, p2, p3);
    var obj1 = JSON.parse(p1);
    JSBridge.call(apiLog, obj1.letter);
    let div = document.getElementById("op");
    div.innerHTML = obj1.letter;
});

/** 
 call back js
 */
[func callbackJSWithParams:nativeParams completionHandler:^(id response, NSError *error) {
    NSLog(@">>> 3 : Native 回调 JS 完成");
}];
```

### native call js

First register js function to native

```js
// js function
function changeColor(param) {
    let div = document.getElementById("oi");
    div.style.backgroundColor = param.color;
    div.innerHTML = param.color;
};

// 将 changeColor 方法 注册给原生
JSBridge.registor("divChangeColor", changeColor);
```

Then, native can call js

```objc
[self.webView invokeJSFunction:@"divChangeColor" params:@{@"color": [self Ox_randomColor]} completionHandler:^(id response, NSError *error) {
    NSLog(@"--- native: 执行 JS 方法完成.");
}];
```



## Author

Jerod, jjd510@163.com

## License

RJSBridge is available under the MIT license. See the LICENSE file for more info.
