# RJSBridge

[![Version](https://img.shields.io/cocoapods/v/RJSBridge.svg?style=flat)](https://cocoapods.org/pods/RJSBridge)
[![License](https://img.shields.io/cocoapods/l/RJSBridge.svg?style=flat)](https://cocoapods.org/pods/RJSBridge)
[![Platform](https://img.shields.io/cocoapods/p/RJSBridge.svg?style=flat)](https://cocoapods.org/pods/RJSBridge)

An bridge to JavaScript, easy to use, simple and fast, without invading.

## Installation

RJSBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RJSBridge'
```

## Introduce

轻量快速无入侵的 JS 与 iOS 通信方式。

JS 侧基于 `window.webkit` 发送 `postMessage()` 消息，可以安全地实现跨源通信。也是当下HTML5通用的一种方案，[了解更多关于postMessage](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/postMessage)。

iOS 侧基于 Runtime 消息转发。

基本原理简介：

如果按传统的方式建立很多桥，在 `iOS加载转换` 和 `JS解析挂载` 过程中会花费很多时间。

而 RJSBridge 在 iOS 与 JS 之间**只构建一个桥**，然后，JS 通过桥将调用的接口名发送到 iOS，iOS 通过 runtime `objc_msgSend` 转发执行具体的方法。即所有的方法都用过**同一个桥**传入，iOS动态转发完成。

## Use

### 自定义接口类

请创建一个 NSObject 子类，定义与 JS 的交互方法。

建议的方法命名方式 `testWithParams::`，不建议的方法命名方式 `testWithParams:callback:` , 这是为了匹配 JS 和 Java，因为他们没有 OC 的 `xxx:xxx:` 一类的方法命名语法，你懂的。

```objc
#import <Foundation/Foundation.h>
#import <RJSBridge/RJSBridge.h>

@interface NativeMethods : NSObject

/// 这种方式定义接口是不行的, 因为机制原因`callback`无法匹配, 除非js入参就传入`testWithParams:callback:`,但是为了与java接口名保持一致,不建议使用这种方式.
//- (void)testWithParams:(NSString*)json callback:(RJSBridgeDataFunction*)func;

/// 建议以这种方式定义接口名`testWithParams::`
- (void)testWithParams:(NSString*)json :(RJSBridgeDataFunction*)func;

@end
  
#import "NativeMethods.h"
@implementation NativeMethods
- (void)testWithParams:(NSString *)json :(id)func {
    //接收h5 参数
    NSLog(@">>> 1 : JS 执行 native, 参数 : %@", json);
    
    NSString *letter = [NSString stringWithFormat:@"%C", (unichar)(arc4random_uniform(26) + 'A')];
    NSDictionary* p1 = @{@"letter": letter, @"b": @"bb", @"c": @"cc"};
    NSString* p2 = @"param_p2";
    NSString* p3 = @"param_p3";
    NSArray* nativeParams = @[p1, p2, p3];
    //回调h5
    [func callbackJSWithParams:nativeParams completionHandler:^(id response, NSError *error) {
        NSLog(@">>> 3 : Native 回调 JS 完成");
    }];
}
@end
```

### 使用方式1、交互类 method 方式

只传入一个交互类即可，js 调用时直接传入方法名即可。`@“JSBridgeListener”` 请与 安卓端 保持一致。

```objc
/**
 init
 */
self.webView = [[WKWebView alloc] initWithFrame:rect 
                configuration:[WKWebViewConfiguration new] 
                listenerName:@"JSBridgeListener" 
                interface:[NativeMethods new]];

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

### 使用方式2、service

可以定义多个不同的交互类，js 调用时请使用 api 风格 `testService/testWithParams` 的方式。`@“JSBridgeListener”` 请与 安卓端 保持一致。如果安卓也支持这种 api 风格的话，那么 services 中的 key 也请尽量保持一致。

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
