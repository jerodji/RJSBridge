//
//  NativeMethods.h
//  WKEasyJSBridgeWebView
//
//  Created by 吉久东 on 2019/8/13.
//  Copyright © 2019 JIJIUDONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RJSBridge/RJSBridge.h>

@interface NativeMethods : NSObject

/// 这种方式定义接口是不行的, 因为机制原因`callback`无法匹配, 除非js入参就传入`testWithParams:callback:`,但是为了与java接口名保持一致,不建议使用这种方式.
//- (void)testWithParams:(NSString*)json callback:(RJSBridgeDataFunction*)func;

/// 建议以这种方式定义接口名`testWithParams::`
- (void)testWithParams:(NSString*)json :(RJSBridgeDataFunction*)func;


@end
