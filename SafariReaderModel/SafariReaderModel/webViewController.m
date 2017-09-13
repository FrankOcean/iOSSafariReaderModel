//
//  webViewController.m
//  selfwebview
//
//  Created by Frank on 2017/4/13.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "webViewController.h"
#import <WebKit/WebKit.h>

@interface webViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation webViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // noping   快讯   普通文章   黑镜
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];

    NSString * readString = [[NSString alloc] initWithContentsOfFile:self.pathStr encoding:NSUTF8StringEncoding error:nil];
    
    //[self.view addSubview:self.webView];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *indexPageFilePath = [bundle pathForResource:@"safari_test" ofType:@"html"];
    // Load HTML for reader mode
    NSString * readerHTMLString = [[NSString alloc] initWithContentsOfFile:indexPageFilePath encoding:NSUTF8StringEncoding error:nil];

    NSMutableString *mut_str = [readerHTMLString mutableCopy];

    NSRange t = [mut_str rangeOfString:@"<div id=\"article\" role=\"article\">"];
    NSInteger location = t.location + t.length;
    
    NSString *t_object = [NSString stringWithFormat:@"<div>%@</div>",readString];
    [mut_str insertString:t_object atIndex:location];
    
    [_webView loadHTMLString:mut_str baseURL:nil];
    
    [self initWKWebView];
}

    
- (void)initWKWebView
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 30.0;
    configuration.preferences = preferences;
    
   // self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    
    //    NSString *urlStr = @"http://www.baidu.com";
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    //    [self.webView loadRequest:request];
    
//    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
//    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
//    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
}

    
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
    {
        NSURL *URL = navigationAction.request.URL;
        NSString *scheme = [URL scheme];
      
        if ([scheme isEqualToString:@"https"] || [scheme isEqualToString:@"http"]) {
            
         //   [self handleCustomAction:URL];

            NSLog(@"跳转新的页面");
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
    {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completionHandler();
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }


@end
