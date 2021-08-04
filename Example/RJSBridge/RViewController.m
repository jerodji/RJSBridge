//
//  RViewController.m
//  RJSBridge
//
//  Created by 20533206 on 05/13/2021.
//  Copyright (c) 2021 20533206. All rights reserved.
//

#import "RViewController.h"

#import <RJSBridge/WKWebView+RJSBridge.h>

#import "NativeMethods.h"
#import "IOSInterface.h"

@interface RViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation RViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    [self configWebview];
}

- (void)configWebview {
    CGRect rect = CGRectMake(20, 88, self.view.bounds.size.width-40, self.view.bounds.size.height-300);

    // 'JSBridgeListener' iOS,安卓,前端 三端保持一致
    
    // service方式
//    self.webView = [[WKWebView alloc] initWithFrame:rect
//      configuration:[[WKWebViewConfiguration alloc] init]
//       listenerName:@"JSBridgeListener"
//           services:@{
//               @"testService": [NativeMethods new],
//               @"ioService": [IOSInterface new]
//           }];
    
    // 一个交互类的方式
    self.webView = [[WKWebView alloc] initWithFrame:rect configuration:[WKWebViewConfiguration new] listenerName:@"JSBridgeListener" interface:[NativeMethods new]];
    
   [self.view addSubview:self.webView];
    
    NSString* _urlStr = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_urlStr]];
    [self.webView loadRequest:request];
}

- (void)nativeButtonClicked {
    NSLog(@"--- native: 主动调用JS divChangeColor方法");
    // MARK: 主动调用JS
    [self.webView invokeJSFunction:@"divChangeColor" params:@{@"color": [self Ox_randomColor]} completionHandler:^(id response, NSError *error) {
        NSLog(@"--- native: 执行 JS 方法完成.");
    }];
}

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UILabel* l = [UILabel new];
    l.text = @"灰色这里是原生界面";
    l.frame = CGRectMake(20, self.view.bounds.size.height - 150, 310, 20);
    [self.view addSubview:l];
    
    UIButton * b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.backgroundColor = [UIColor yellowColor];
    [b setTitle:@"黄色是原生按钮" forState:UIControlStateNormal];
    [b setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [b setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [b addTarget:self action:@selector(nativeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    b.frame = CGRectMake(20, self.view.bounds.size.height-100, 300, 50);
    [self.view addSubview:b];
}

- (NSMutableString*)Ox_randomColor {
    NSMutableString* color = [[NSMutableString alloc] initWithString:@"#"];
    NSArray * STRING = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F"];
    for (int i=0; i<6; i++) {
        NSInteger index = arc4random_uniform((uint32_t)STRING.count);
        NSString *c = [STRING objectAtIndex:index];
        [color appendString:c];
    }
    return color;
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSURLRequest * req1 = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.taobao.com/"]];
    NSURLSessionDataTask * task1 = [[NSURLSession sharedSession] dataTaskWithRequest:req1 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"task 1 - %@",[NSThread currentThread]);
    }];
    [task1 resume];
}

@end
