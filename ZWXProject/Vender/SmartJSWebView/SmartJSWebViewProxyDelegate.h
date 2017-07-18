//
//  SmartJSWebViewProxyDelegate.h
//  SmartJSWebView
//
//  Created by pcjbird on 16/6/15.
//  Copyright © 2016年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "SmartJSWebViewProgressDelegate.h"

@interface SmartJSWebViewProxyDelegate : NSObject<UIWebViewDelegate,WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>


@property (nonatomic, strong) NSMutableDictionary* javascriptInterfaces;
@property (nonatomic, retain) id<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> realDelegate;
@property (nonatomic, retain) id<SmartJSWebViewProgressDelegate> progressDelegate;

- (void) injectUserScript:(WKWebView*)webView;
- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name;

@end
