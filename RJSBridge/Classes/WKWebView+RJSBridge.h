//
//  WKWebView+RuntimeJSBridge.h
//  WKEasyJSWebView
//
//  Created by Jerod on 2019/8/13.
//  Copyright © 2019 JIJIUDONG. All rights reserved.
//

#import <WebKit/WebKit.h>



@interface WKWebView (RJSBridge)


/// 初始化
/// @param frame frame
/// @param configuration 配置
/// @param listenerName 监听名称, iOS,安卓,前端 三端保持一致
/// @param interface 交互类实例
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration*)configuration listenerName:(NSString*)listenerName interface:(NSObject*)interface;

/// 初始化
/// @param frame 位置
/// @param configuration 配置
/// @param listenerName 监听名称, iOS,安卓,前端 三端保持一致
/// @param services JS 交互服务 {'service1': [Interface1 new], 'service2': [Interface2 new] }
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration*)configuration listenerName:(NSString*)listenerName services:(NSDictionary<NSString*, NSObject*>*)services;


/// native 调用 h5 方法
- (void)invokeJSFunction:(NSString*)jsFuncName params:(id)params completionHandler:(void (^)(id response, NSError *error))completionHandler;


/// 主线程执行js
- (void)mainThreadEvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;


@end


