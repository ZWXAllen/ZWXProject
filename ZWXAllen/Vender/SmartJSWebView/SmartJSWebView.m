//
//  SmartJSWebView.m
//  SmartJSWebView
//
//  Created by pcjbird on 16/6/15.
//  Copyright © 2016年 Zero Status. All rights reserved.
//

#import "SmartJSWebView.h"

@implementation SmartJSWebView

- (id)init
{
    self = [super init];
    if (self)
    {
        _preferWKWebView = NO;
        self.webView = [self createRealWebView];
        [self initEasyJS];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _preferWKWebView = NO;
        self.webView = [self createRealWebView];
        [self initEasyJS];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _preferWKWebView = NO;
        self.webView = [self createRealWebView];
        [self initEasyJS];
    }
    
    return self;
}

-(void)dealloc
{
    if([self.webView isKindOfClass:[WKWebView class]] && self.proxyDelegate)
    {
        [((WKWebView*)self.webView) removeObserver:self.proxyDelegate forKeyPath:@"estimatedProgress"];
    }
}

- (id)createRealWebView
{
    Class wkwebviewClass = NSClassFromString(@"WKWebView");
    if(wkwebviewClass&&self.preferWKWebView)
    {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 设置偏好设置
        config.preferences = [[WKPreferences alloc] init];
        // 默认为0
        config.preferences.minimumFontSize = 10;
        // 默认认为YES
        config.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        // web内容处理池
        config.processPool = [[WKProcessPool alloc] init];
        
        // 通过JS与webview内容交互
        config.userContentController = [[WKUserContentController alloc] init];
        
        WKWebView* webview = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
        [webview setBackgroundColor:[UIColor clearColor]];
        webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:webview];
        return webview;
    }
    else
    {
        UIWebView* webview = [[UIWebView alloc] initWithFrame:self.bounds];
        [webview setBackgroundColor:[UIColor clearColor]];
        webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:webview];
        
        return webview;
    }
}

-(void)setPreferWKWebView:(BOOL)preferWKWebView
{
    if(_preferWKWebView != preferWKWebView)
    {
        _preferWKWebView = preferWKWebView;
        if(self.webView)
        {
            [self.webView removeFromSuperview];
        }
        self.webView = [self createRealWebView];
        [self initEasyJS];
    }
}

- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name
{
    if(self.proxyDelegate)
    {
        [self.proxyDelegate addJavascriptInterfaces:interface WithName:name];
    }
}

-(void)loadPage:(NSString *)pageURL
{
    
    NSURL *url = [NSURL URLWithString:[pageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView loadRequest:request];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView loadRequest:request];
    }
}

-(void)loadRequest:(NSURLRequest*)request
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView loadRequest:request];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView loadHTMLString:string baseURL:baseURL];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView loadHTMLString:string baseURL:baseURL];
    }
}

- (void)goBack
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView goBack];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView goBack];
    }
}

- (void)goForward
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView goForward];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView goForward];
    }
}

- (void)reload
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView reload];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView reload];
    }
}

- (void)stopLoading
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView stopLoading];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView stopLoading];
    }
}

- (BOOL) canGoBack
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView canGoBack];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView canGoBack];
    }
    return NO;
}

- (BOOL) canGoForward
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView canGoForward];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView canGoForward];
    }
    return NO;
}

- (BOOL) isLoading
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView isLoading];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView isLoading];
    }
    return NO;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView setBackgroundColor:backgroundColor];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView setBackgroundColor:backgroundColor];
    }
    
}

-(void)setOpaque:(BOOL)opaque
{
    [super setOpaque:opaque];
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView setOpaque:opaque];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView setOpaque:opaque];
    }
}

- (void) initEasyJS{
    self.proxyDelegate = [[SmartJSWebViewProxyDelegate alloc] init];
    self.delegate = self.proxyDelegate;
}

-(void)setDelegate:(id<UIWebViewDelegate,WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate>)delegate
{
    if (delegate != self.proxyDelegate)
    {
        self.proxyDelegate.realDelegate = delegate;
    }
    
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView setDelegate:self.proxyDelegate];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView setNavigationDelegate:self.proxyDelegate];
        [(WKWebView*)self.webView setUIDelegate:self.proxyDelegate];
        [((WKWebView*)self.webView).configuration.userContentController addScriptMessageHandler:self.proxyDelegate name:@"SmartJS"];
        [self.proxyDelegate injectUserScript:self.webView];
        [((WKWebView*)self.webView) addObserver:self.proxyDelegate forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

-(void)setProgressDelegate:(id<SmartJSWebViewProgressDelegate>)progressDelegate
{
    [self.proxyDelegate setProgressDelegate:progressDelegate];
}


- (NSString*) title
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        
        return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    else
    {
        return [self.webView title];
    }
}


- (NSURL*) url
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        NSString *urlString = [self.webView stringByEvaluatingJavaScriptFromString:@"location.href"];
        if (urlString)
        {
            return [NSURL URLWithString:urlString];
        }
        return nil;
    }
    else
    {
        return [self.webView URL];
    }
}

-(UIScrollView *)scrollView
{
    if([self.webView isKindOfClass:[UIView class]])
    {
        return [self.webView scrollView];
    }
    return nil;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        NSString* res = [(UIWebView*)self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if(completionHandler) completionHandler(res, nil);
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

@end
