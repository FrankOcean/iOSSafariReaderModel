//
//  PYArticleDetailController.m
//  PYPingWestProject
//
//  Created by Frank on 2017/4/12.
//  Copyright © 2017年 Frank. All rights reserved.
//

/*
 <img id="wx-share" src="http://s.jiathis.com/qrcode.php?url=http://www.pingwest.com/the-name-of-people/?via=wechat_qr">
 <img id="wx-share" src="http://s.jiathis.com/qrcode.php?url=http://www.pingwest.com/future-machine-ruin/?via=wechat_qr">
 */


/*
 涉及字段	文章标题、文章正文
 文章正文-特殊格式	"图片
 小标题
 加粗
 超链接
 正文
 引用
 
 文章表中对应“正文”字段数据转义后显示"
 单击-超链接	"如果是文章详情页【】或者黑镜详情页【】或者快讯详情页【】的地址，则跳转原生页面
 如果是其他页面，则跳转进入外部浏览器"
 */

#import "PYArticleDetailController.h"
#import <WebKit/WebKit.h>
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface PYArticleDetailController ()<WKNavigationDelegate,WKScriptMessageHandler> {
//    BOOL isNavigationBarHidden;
    
    NSString *readerHTMLString;
    NSString *readerArticleTitle;
}

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) WKWebView *readerWebView;

@end

@implementation PYArticleDetailController

#pragma mark - Life Cycle

- (id)initWithURL:(NSURL *)url {

    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (id)initWithURLString:(NSString *)urlString {
    
    self = [super init];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
  
    [self loadWebContent];
    [self.view addSubview:self.readerWebView];

}

- (void)loadWebContent {
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.readerWebView.frame = CGRectMake(0, 20.5f, SCREEN_WIDTH, SCREEN_HEIGHT - 50.5f - 20.5f);
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20.5f, SCREEN_WIDTH, SCREEN_HEIGHT - 50.5f - 20.5f) configuration:[self configuration]];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (WKWebView *)readerWebView {
    if (!_readerWebView) {
        _readerWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:[self configuration]];
      //  _readerWebView.navigationDelegate = self;
        _readerWebView.layer.masksToBounds = YES;
    }
    return _readerWebView;
}

#pragma mark - Private

- (WKWebViewConfiguration *)configuration {
    // Load reader mode js script
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *readerScriptFilePath = [bundle pathForResource:@"safari-reader" ofType:@"js"];
    NSString *readerCheckScriptFilePath = [bundle pathForResource:@"safari-reader-check" ofType:@"js"];
    
    NSString *indexPageFilePath = [bundle pathForResource:@"index" ofType:@"html"];
    
    // Load HTML for reader mode
    readerHTMLString = [[NSString alloc] initWithContentsOfFile:indexPageFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *script = [[NSString alloc] initWithContentsOfFile:readerScriptFilePath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    NSString *check_script = [[NSString alloc] initWithContentsOfFile:readerCheckScriptFilePath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *check_userScript = [[WKUserScript alloc] initWithSource:check_script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:userScript];
    [userContentController addUserScript:check_userScript];
    [userContentController addScriptMessageHandler:self name:@"JSController"];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    
    return configuration;
}

- (void)webViewToolbarDidSwitchReaderMode{
        [_webView evaluateJavaScript:
         @"var ReaderArticleFinderJS = new ReaderArticleFinder(document);"
         "var article = ReaderArticleFinderJS.findArticle(); article.element.outerHTML" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
             if ([object isKindOfClass:[NSString class]]) {
                 [_webView evaluateJavaScript:@"ReaderArticleFinderJS.articleTitle()" completionHandler:^(id _Nullable object_in, NSError * _Nullable error) {
                     readerArticleTitle = object_in;
                     
                     NSMutableString *mut_str = [readerHTMLString mutableCopy];
                     
                     // Replace page title with article title
                     [mut_str replaceOccurrencesOfString:@"Reader" withString:readerArticleTitle options:NSLiteralSearch range:NSMakeRange(0, 300)];
                     NSRange t = [mut_str rangeOfString:@"<div id=\"article\" role=\"article\">"];
                     NSInteger location = t.location + t.length;
                     
                     NSString *t_object = [NSString stringWithFormat:@"<div style=\"position: absolute; top: -999em\">%@</div>",object];
                     [mut_str insertString:t_object atIndex:location];
                     
                     //NSRange r = [mut_str rangeOfString:@"<img style=\"display:none;\" class=\"wxshareimg\""];
                     
                     [_readerWebView loadHTMLString:mut_str baseURL:nil];
                     
                     [_webView evaluateJavaScript:@"ReaderArticleFinderJS.prepareToTransitionToReader();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {}];
                 }];
             }
         }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {

    // Set reader mode button status when navigation finished
    [webView evaluateJavaScript:@"var ReaderArticleFinderJS = new ReaderArticleFinder(document); ReaderArticleFinderJS.isReaderModeAvailable();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        if ([object integerValue] == 1) {
            NSLog(@"可以打开阅读模式");
            [self webViewToolbarDidSwitchReaderMode];
        } else {
            NSLog(@"不可以打开阅读模式");
        }
    }];
    
}

// 拦截非 Http:// 和 Https:// 开头的请求，转成应用内跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([webView isEqual:self.readerWebView]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if (![navigationAction.request.URL.absoluteString containsString:@"http://"] && ![navigationAction.request.URL.absoluteString containsString:@"https://"]) {
        
        UIApplication *application = [UIApplication sharedApplication];
#ifndef __IPHONE_10_0
#define __IPHONE_10_0  100000
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        } else {
            [application openURL:navigationAction.request.URL];
        }
#else
        [application openURL:navigationAction.request.URL];
#endif
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"接收到了JS消息");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.1f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            //self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, _readerWebView.frame.size.height);
//        } completion:^(BOOL finished) {
//           // _readerWebView.userInteractionEnabled = YES;
//        }];
//    });
    
}



@end
