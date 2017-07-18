//
//  SmartJSWebView.h
//  SmartJSWebView
//
//  Created by pcjbird on 16/6/15.
//  Copyright © 2016年 Zero Status. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "SmartJSWebViewProxyDelegate.h"
#import "SmartJSWebViewProgressDelegate.h"

@interface SmartJSWebView : UIView

/*!
 *  The real webview object.
 */
@property(nonatomic, strong) id webView;

/*!
 *  The scrollview of the real webview.
 */
@property(nonatomic, readonly, strong) UIScrollView* scrollView;

/*!
 *  A Boolean val indicate whether prefer to user WKWebView when it is available.
 */
@property(nonatomic, assign) BOOL preferWKWebView;


@property (nonatomic, retain) id<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> delegate;
@property (nonatomic, retain) SmartJSWebViewProxyDelegate* proxyDelegate;
@property (nonatomic, retain) id<SmartJSWebViewProgressDelegate> progressDelegate;


-(void)loadPage:(NSString *)pageURL;

-(void)loadRequest:(NSURLRequest*)request;

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (void)goBack;

- (void)goForward;

- (void)reload;

- (void)stopLoading;

- (BOOL) canGoBack;

- (BOOL) canGoForward;

- (BOOL) isLoading;


/*!
 * Inject javascript model to webview.
 */
- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name;

/*!
 * Return the webview title.
 */
- (NSString*) title;

/*!
 * Return current url.
 */
- (NSURL*) url;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler;

@end
