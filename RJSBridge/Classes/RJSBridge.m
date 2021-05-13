//
//  JSBridge.m
//  WKEasyJSWebView
//
//  Created by Jerod on 2019/8/13.
//  Copyright © 2019 JIJIUDONG. All rights reserved.
//

#import "RJSBridge.h"
#import <objc/message.h>
#import "NSObject+RJsonString.h"


// MARK: bridge.js
NSString * const BRIDGE_JS_FORMAT = @"\
!function () {\
if (window.JSBridge) {\
    return;\
}\
window.JSBridge = {\
    __callbacks: {},\
    __events: {},\
    call: function (api = '', param = '', callback) {\
        let formatArgs = [api, param];\
        if (callback && typeof callback === 'function') {\
            const cbID = '__cb' + (+new Date) + Math.random();\
            JSBridge.__callbacks[cbID] = callback;\
            formatArgs.push(cbID);\
        } else {\
            formatArgs.push('');\
        }\
        const msg = JSON.stringify(formatArgs);\
        window.webkit.messageHandlers.%@.postMessage(msg);\
    },\
    _callback: function (cbID, removeAfterExecute) {\
        let args = Array.prototype.slice.call(arguments);\
        args.shift();\
        args.shift();\
        for (let i = 0, l = args.length; i < l; i++) {\
            args[i] = decodeURIComponent(args[i]);\
        }\
        let cb = JSBridge.__callbacks[cbID];\
        if (removeAfterExecute) {\
            JSBridge.__callbacks[cbID] = undefined;\
        }\
        return cb.apply(null, args);\
    },\
    registor: function (funcName, handler) {\
        JSBridge.__events[funcName] = handler;\
    },\
    _invokeJS: function (funcName, paramsJson) {\
        let handler = JSBridge.__events[funcName];\
        if (handler && typeof (handler) === 'function') {\
            let args = '';\
            try {\
                if (typeof JSON.parse(paramsJson) == 'object') {\
                    args = JSON.parse(paramsJson);\
                } else {\
                    args = paramsJson;\
                }\
                return handler(args);\
            } catch (error) {\
                console.log(error);\
                args = paramsJson;\
                return handler(args);\
            }\
        } else {\
            console.log(funcName + '函数未定义');\
        }\
    }\
};\
}()\
";


#pragma mark - RJSBridgeListener

@implementation RJSBridgeListener

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (![message.name isEqualToString:self.name]) return;
    
    __weak WKWebView *webView = (WKWebView *)message.webView;
    NSString *bodyJson = message.body; // exg: "[\"testService/testWithParams:callback:\",\"abc\",\"__cb16100015743360.8558109851298374\"]"
    NSData *bodyData = [bodyJson dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *bodyArr = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:&err];
    if (err) {
        NSLog(@"*** error : %@", err.localizedFailureReason);
        return;
    }
    if (bodyArr.count < 2 ) {
        NSAssert(NO, @"*** 缺少传参, 需要依次传入 '方法名, 入参, 回调' 3个参数; 如果js不需要回调, 第三个参数可不传.");
        return;
    }
    
    if (self.interface)
    {
        // eg:
        // ["testWithParams::", params, "__cb16100015743360.8558109851298374"]
        // ["testWithParams", {"params":params,"callback":_cb}]
        
        NSString * method  = [bodyArr objectAtIndex:0];
        NSString * args = [bodyArr objectAtIndex:1];
        NSString * cbID = nil;
        if (bodyArr.count > 2 ) {
            cbID = [bodyArr objectAtIndex:2];
        }
        RJSBridgeDataFunction *func = [[RJSBridgeDataFunction alloc] initWithWebView:webView];
        func.funcID = cbID;
        
        [self _msgSend:self.interface method:method args:args func:func];
    }
    else if (self.services)
    {
        // eg:
        // ["testService/testWithParams::", params, "__cb16100015743360.8558109851298374"]
        // ["testService/testWithParams::", {"params":params,"callback":_cb}]
        
        NSString * api  = [bodyArr objectAtIndex:0];
        NSArray * apiArr = [api componentsSeparatedByString:@"/"];
        if (apiArr.count != 2 || [apiArr[0] isEqualToString:@""]) {
            NSAssert(NO, @"*** 传参不符合service格式, 需要 xxx/xxx 这种格式");
            return;
        }
        NSString * service  = [apiArr objectAtIndex:0];
        NSString * method   = [apiArr objectAtIndex:1];
        NSString * args = [bodyArr objectAtIndex:1];
        NSString * cbID = nil;
        if (bodyArr.count > 2 ) {
            cbID = [bodyArr objectAtIndex:2];
        }
        RJSBridgeDataFunction *func = [[RJSBridgeDataFunction alloc] initWithWebView:webView];
        func.funcID = cbID;
        
        NSObject * obj = [self.services objectForKey:service];
        if (!obj || ![obj isKindOfClass:[NSObject class]]) {
            NSAssert(NO, @"*** service不存在");
            return;
        }
        
        [self _msgSend:obj method:method args:args func:func];
    }
    else
    {
        NSAssert(NO, @"*** 缺少交互类");
    }
}

- (void)_msgSend:(id)obj method:(NSString*)method args:(NSString*)args func:(RJSBridgeDataFunction*)func {
    if (!obj) return;
    
    SEL sel = NSSelectorFromString(method);
    
    NSString * method1 = [method stringByAppendingString:@":"];
    SEL sel1 = NSSelectorFromString(method1);
    
    NSString * method2 = [method stringByAppendingString:@"::"];
    SEL sel2 = NSSelectorFromString(method2);
    
    SEL selector = sel;
    if ([obj respondsToSelector:sel]) {
        selector = sel;
    } else if ([obj respondsToSelector:sel1]) {
        selector = sel1;
    } else if ([obj respondsToSelector:sel2]) {
        selector = sel2;
    } else {
        NSString *msg = [NSString stringWithFormat:@"*** %@ %@ 方法没有实现", NSStringFromClass([obj class]), method];
        NSAssert(NO, msg);
        return;
    }
    
    ((void(*)(id, SEL, id, id))objc_msgSend)(obj, selector, args, func);
}

@end

#pragma mark - RJSBridgeDataFunction

@implementation RJSBridgeDataFunction

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
    }
    return self;
}

- (void)callbackJS:(void (^)(id response, NSError *error))completionHandler {
    [self callbackJSWithParams:nil completionHandler:^(id response, NSError *error) {
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (void)callbackJSWithParams:(NSArray *)params completionHandler:(void (^)(id response, NSError *error))completionHandler
{
    if (!self.funcID || [self.funcID isEqual:[NSNull null]]) return; // 不需要回调
    if (!params) params = @[];
    NSMutableArray * args = [NSMutableArray arrayWithArray:params];
    for (int i=0; i<params.count; i++) {
        NSString* json = [params[i] r_JSONString];
        [args replaceObjectAtIndex:i withObject:json];
    }
    
    NSMutableString* injection = [[NSMutableString alloc] init];
    [injection appendFormat:@"JSBridge._callback(\"%@\", %@", self.funcID, self.removeAfterExecute ? @"true" : @"false"];
    
    if (args) {
        for (unsigned long i = 0, l = args.count; i < l; i++){
            NSString* arg = [args objectAtIndex:i];
            NSCharacterSet *chars = [NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"];
            NSString *encodedArg = [arg stringByAddingPercentEncodingWithAllowedCharacters:chars];
            [injection appendFormat:@", \"%@\"", encodedArg];
        }
    }
    
    [injection appendString:@");"];
    
    if (_webView){
        [_webView mainThreadEvaluateJavaScript:injection completionHandler:^(id response, NSError *error) {
            if (completionHandler) {completionHandler(response, error);}
        }];
    }
}


@end
