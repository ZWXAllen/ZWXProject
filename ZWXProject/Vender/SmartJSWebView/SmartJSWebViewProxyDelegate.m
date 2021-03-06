//
//  SmartJSWebViewProxyDelegate.m
//  SmartJSWebView
//
//  Created by pcjbird on 16/6/15.
//  Copyright © 2016年 Zero Status. All rights reserved.
//

#import "SmartJSWebViewProxyDelegate.h"
#import "SmartJSDataFunction.h"
#import <objc/runtime.h>

#define completeRPCURLPath @"/easyjswebviewprogressproxy/complete"

static const float SmartJSWebViewProgressInitialValue = 0.7f;
static const float SmartJSWebViewProgressInteractiveValue = 0.9f;
static const float SmartJSWebViewProgressFinalProgressValue = 0.9f;

/*
 This is the content of easyjs-inject.js
 Putting it inline in order to prevent loading from files
 */
#define INJECT_JS @"window.EasyJS = {\
__callbacks: {},\
\
invokeCallback: function (cbID, removeAfterExecute){\
var args = Array.prototype.slice.call(arguments);\
args.shift();\
args.shift();\
\
for (var i = 0, l = args.length; i < l; i++){\
args[i] = decodeURIComponent(args[i]);\
}\
\
var cb = EasyJS.__callbacks[cbID];\
if (removeAfterExecute){\
EasyJS.__callbacks[cbID] = undefined;\
}\
return cb.apply(null, args);\
},\
\
call: function (obj, functionName, args){\
var formattedArgs = [];\
for (var i = 0, l = args.length; i < l; i++){\
if (typeof args[i] == \"function\"){\
formattedArgs.push(\"f\");\
var cbID = \"__cb\" + (+new Date);\
EasyJS.__callbacks[cbID] = args[i];\
formattedArgs.push(cbID);\
}else{\
formattedArgs.push(\"s\");\
formattedArgs.push(encodeURIComponent(args[i]));\
}\
}\
\
var argStr = (formattedArgs.length > 0 ? \":\" + encodeURIComponent(formattedArgs.join(\":\")) : \"\");\
\
var target = window.webkit;\
if(undefined == target)\
{\
var iframe = document.createElement(\"IFRAME\");\
iframe.setAttribute(\"src\", \"easy-js:\" + obj + \":\" + encodeURIComponent(functionName) + argStr);\
document.documentElement.appendChild(iframe);\
iframe.parentNode.removeChild(iframe);\
iframe = null;\
\
var ret = EasyJS.retValue;\
EasyJS.retValue = undefined;\
\
if (ret){\
return decodeURIComponent(ret);\
}\
}\
else\
{\
target = window.webkit.messageHandlers.SmartJS;\
target.postMessage({className: obj, functionName: encodeURIComponent(functionName), data: argStr});\
var ret = EasyJS.retValue;\
EasyJS.retValue = undefined;\
\
if (ret){\
return decodeURIComponent(ret);\
}\
\
}\
},\
\
inject: function (obj, methods){\
window[obj] = {};\
var jsObj = window[obj];\
\
for (var i = 0, l = methods.length; i < l; i++){\
(function (){\
var method = methods[i];\
var jsMethod = method.replace(new RegExp(\":\", \"g\"), \"\");\
jsObj[jsMethod] = function (){\
return EasyJS.call(obj, method, Array.prototype.slice.call(arguments));\
};\
})();\
}\
}\
};\
function EasyJSGetHTMLElementsAtPoint(x,y) {\
var tags = \",\";\
var e = document.elementFromPoint(x,y);\
while (e) {\
if (e.tagName) {\
tags += e.tagName + ',';\
}\
e = e.parentNode;\
}\
return tags;\
}\
function EasyJSGetFirstImage(){\
var imgs = document.getElementsByTagName('img');\
for(var i = 0; i < imgs.length; i += 1)\
{\
if(imgs[i].width > 200)\
{\
return imgs[i].src;\
}\
}\
return undefined;\
}\
"


@interface SmartJSWebViewProxyDelegate()
{
    int _loadingCount;
    int _maxLoadCount;
    NSURL *_currentURL;
    BOOL _interactive;
    float _progress;
}
@end

@implementation SmartJSWebViewProxyDelegate

@synthesize realDelegate;
@synthesize javascriptInterfaces;
@synthesize progressDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        _maxLoadCount = _loadingCount = 0;
        _interactive = NO;
    }
    
    return self;
}

- (void)startProgress
{
    if (_progress < SmartJSWebViewProgressInitialValue) {
        [self setProgress:SmartJSWebViewProgressInitialValue];
    }
}

- (void)incrementProgress
{
    float progress = _progress;
    float maxProgress = _interactive ? SmartJSWebViewProgressFinalProgressValue : SmartJSWebViewProgressInteractiveValue;
    float remainPercent = (float)_loadingCount/_maxLoadCount;
    float increment = (maxProgress-progress) * remainPercent;
    progress += increment;
    progress = fminf(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress
{
    [self setProgress:1.f];
}

- (void)setProgress:(float)progress
{
    if (progress > _progress || progress == 0)
    {
        _progress = progress;
        
        if (self.progressDelegate)
        {
            [self.progressDelegate setProgress:progress animated:YES];
        }
    }
}

- (void)reset
{
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.f];
}

- (BOOL)checkIfRPCURL:(NSURLRequest *)request
{
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return YES;
    }
    
    return NO;
}


- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name{
    if (! self.javascriptInterfaces){
        self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
    }
    
    [self.javascriptInterfaces setValue:interface forKey:name];
}

- (void) injectUserScript:(WKWebView*)webView
{
    NSString * functionjs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"function-inject" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *functionScript = [[WKUserScript alloc] initWithSource:functionjs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [webView.configuration.userContentController addUserScript:functionScript];
    
    NSString * deferredjs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"deferredjs-inject" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *deferredScript = [[WKUserScript alloc] initWithSource:deferredjs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [webView.configuration.userContentController addUserScript:deferredScript];
    
    NSString * smartjs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smartjs-inject" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:smartjs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [webView.configuration.userContentController addUserScript:userScript];
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.realDelegate webView:webView didFailLoadWithError:error];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if (! self.javascriptInterfaces){
        self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableString* injection = [[NSMutableString alloc] init];
    
    //inject the javascript interface
    for(id key in self.javascriptInterfaces) {
        NSObject* interface = [self.javascriptInterfaces objectForKey:key];
        
        [injection appendString:@"EasyJS.inject(\""];
        [injection appendString:key];
        [injection appendString:@"\", ["];
        
        unsigned int mc = 0;
        Class cls = object_getClass(interface);
        Method * mlist = class_copyMethodList(cls, &mc);
        for (int i = 0; i < mc; i++){
            [injection appendString:@"\""];
            [injection appendString:[NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))]];
            [injection appendString:@"\""];
            
            if (i != mc - 1){
                [injection appendString:@", "];
            }
        }
        
        free(mlist);
        
        [injection appendString:@"]);"];
    }
    
    NSString* js = INJECT_JS;
    //inject the basic functions first
    [webView stringByEvaluatingJavaScriptFromString:js];
    //inject the function interface
    [webView stringByEvaluatingJavaScriptFromString:injection];
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.realDelegate webViewDidFinishLoad:webView];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = interactive;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);",
                                       webView.request.mainDocumentURL.scheme,
                                       webView.request.mainDocumentURL.host,
                                       completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([self checkIfRPCURL:request]) {
        return NO;
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (!isFragmentJump && isHTTP && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
    
    NSString *requestString = [[request URL] absoluteString];
    
    if ([requestString hasPrefix:@"easy-js:"]) {
        /*
         A sample URL structure:
         easy-js:MyJSTest:test
         easy-js:MyJSTest:testWithParam%3A:haha
         */
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        //NSLog(@"req: %@", requestString);
        
        NSString* obj = (NSString*)[components objectAtIndex:1];
        NSString* method = [(NSString*)[components objectAtIndex:2]
                            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSObject* interface = [javascriptInterfaces objectForKey:obj];
        if (!interface) return NO;
        // execute the interfacing method
        SEL selector = NSSelectorFromString(method);
        NSMethodSignature* sig = [[interface class] instanceMethodSignatureForSelector:selector];
        if (!sig) return NO;
        NSInvocation* invoker = [NSInvocation invocationWithMethodSignature:sig];
        invoker.selector = selector;
        invoker.target = interface;
        
        NSMutableArray* args = [[NSMutableArray alloc] init];
        
        if ([components count] > 3){
            NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                      stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSArray* formattedArgs = [argsAsString componentsSeparatedByString:@":"];
            for (int i = 0, j = 0, l = (int)[formattedArgs count]; i < l; i+=2, j++){
                NSString* type = ((NSString*) [formattedArgs objectAtIndex:i]);
                NSString* argStr = ((NSString*) [formattedArgs objectAtIndex:i + 1]);
                
                if ([@"f" isEqualToString:type]){
                    SmartJSDataFunction* func = [[SmartJSDataFunction alloc] initWithSmartWebView:(SmartJSWebView *)[webView superview]];
                    func.funcID = argStr;
                    [args addObject:func];
                    [invoker setArgument:&func atIndex:(j + 2)];
                }else if ([@"s" isEqualToString:type]){
                    NSString* arg = [argStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [args addObject:arg];
                    [invoker setArgument:&arg atIndex:(j + 2)];
                }
            }
        }
        [invoker invoke];
        
        //return the value by using javascript
        if ([sig methodReturnLength] > 0){
            
            const char* returnType = sig.methodReturnType;
            if(!strcmp(returnType, @encode(id)))
            {
                void* _retValue;
                [invoker getReturnValue:&_retValue];
                id retValue = (__bridge id)_retValue;
                if (retValue == NULL || retValue== nil)
                {
                    [webView stringByEvaluatingJavaScriptFromString:@"EasyJS.retValue=null;"];
                }
                else
                {
                    if ([retValue isKindOfClass:[NSString class]])
                    {
                        retValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) retValue, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
                        [webView stringByEvaluatingJavaScriptFromString:[@"" stringByAppendingFormat:@"EasyJS.retValue=\"%@\";", retValue]];
                    }
                    else
                    {
                        [webView stringByEvaluatingJavaScriptFromString:[@"" stringByAppendingFormat:@"EasyJS.retValue=\"%@\";", retValue]];
                    }
                }
                return NO;
            }
            NSUInteger length = [sig methodReturnLength];
            //根据长度申请内存
            void *_retValue = (void *)malloc(length);
            [invoker getReturnValue:_retValue];
            
            if(!strcmp(returnType, @encode(BOOL)))
            {
                BOOL result = *((BOOL*)_retValue);
                [webView stringByEvaluatingJavaScriptFromString:[@"" stringByAppendingFormat:@"EasyJS.retValue=%@;", result ? @"true" : @"false"]];
            }
            else if(!strcmp(returnType, @encode(int)))
            {
                int result = *((int*)_retValue);
                [webView stringByEvaluatingJavaScriptFromString:[@"" stringByAppendingFormat:@"EasyJS.retValue=%d;", result]];
            }
            else if(!strcmp(returnType, @encode(float)))
            {
                float result = *((float*)_retValue);
                [webView stringByEvaluatingJavaScriptFromString:[@"" stringByAppendingFormat:@"EasyJS.retValue=%f;", result]];
            }
            else
            {
                [webView stringByEvaluatingJavaScriptFromString:@"EasyJS.retValue=\"notsupport\";"];
            }
        }
        
        return NO;
    }
    
    if (! self.realDelegate){
        return YES;
    }
    else
    {
        if([self.realDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        {
            return [self.realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [self.realDelegate webViewDidStartLoad:webView];
    
    _loadingCount++;
    
    _maxLoadCount = fmax(_loadingCount, _maxLoadCount);
    [self startProgress];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //所传过来的参数message.body，只支持NSNumber, NSString, NSDate, NSArray, NSDictionary, and NSNull类型
    
    if ([message.name isEqualToString:@"SmartJS"])
    {
        NSDictionary *body = message.body;
        if([body isKindOfClass:[NSDictionary class]])
        {
            NSString* callbackID = [body objectForKey:@"callbackID"];
            NSString* obj = [body objectForKey:@"className"];
            if(![obj isKindOfClass:[NSString class]]) return;
            NSString* encodedfun = [body objectForKey:@"functionName"];
            if(![encodedfun isKindOfClass:[NSString class]]) return;
            NSString* method = [encodedfun stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSObject* interface = [self.javascriptInterfaces objectForKey:obj];
            if (![interface isKindOfClass:[NSObject class]]) return;
            
            // execute the interfacing method
            SEL selector = NSSelectorFromString(method);
            NSMethodSignature* sig = [[interface class] instanceMethodSignatureForSelector:selector];
            if (![sig isKindOfClass:[NSMethodSignature class]]) return;
            NSInvocation* invoker = [NSInvocation invocationWithMethodSignature:sig];
            invoker.selector = selector;
            invoker.target = interface;
            
            NSMutableArray* args = [[NSMutableArray alloc] init];
            
            NSString *argStr = [body objectForKey:@"argument"];
            if([argStr isKindOfClass:[NSString class]] && [argStr length] > 0)
            {
                NSString *argsAsString = [[argStr substringFromIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSArray* formattedArgs = [argsAsString componentsSeparatedByString:@":"];
                for (int i = 0, j = 0, l = (int)[formattedArgs count]; i < l; i+=2, j++)
                {
                    NSString* type = ((NSString*) [formattedArgs objectAtIndex:i]);
                    NSString* argStr = ((NSString*) [formattedArgs objectAtIndex:i + 1]);
                    
                    if ([@"f" isEqualToString:type])
                    {
                        SmartJSDataFunction* func = [[SmartJSDataFunction alloc] initWithSmartWebView:(SmartJSWebView *)[message.webView superview]];
                        func.funcID = argStr;
                        [args addObject:func];
                        [invoker setArgument:&func atIndex:(j + 2)];
                    }
                    else if ([@"s" isEqualToString:type])
                    {
                        NSString* arg = [argStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        [args addObject:arg];
                        [invoker setArgument:&arg atIndex:(j + 2)];
                    }
                }
            }
            [invoker invoke];
            
            //return the value by using javascript
            if ([sig methodReturnLength] > 0){
                
                const char* returnType = sig.methodReturnType;
                if(!strcmp(returnType, @encode(id)))
                {
                    void* _retValue;
                    [invoker getReturnValue:&_retValue];
                    id retValue = (__bridge id)_retValue;
                    if (retValue == NULL || retValue== nil)
                    {
                        [message.webView evaluateJavaScript:[NSString stringWithFormat:@"EasyJS.asyncCallback(\"%@\", \"success\", [null]);", callbackID] completionHandler:nil];
                    }
                    else
                    {
                        if ([retValue isKindOfClass:[NSString class]])
                        {
                            retValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) retValue, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
                            [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"EasyJS.asyncCallback(\"%@\", \"success\",[\"%@\"]);", callbackID,retValue] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                                
                            }];
                        }
                        else
                        {
                            [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"EasyJS.asyncCallback(\"%@\", \"success\",[\"%@\"]);", callbackID,retValue] completionHandler:nil];
                        }
                    }
                    return;
                }
                NSUInteger length = [sig methodReturnLength];
                //根据长度申请内存
                void *_retValue = (void *)malloc(length);
                [invoker getReturnValue:_retValue];
                
                if(!strcmp(returnType, @encode(BOOL)))
                {
                    BOOL result = *((BOOL*)_retValue);
                    [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"EasyJS.asyncCallback(\"%@\", \"success\",[\"%@\"]);", callbackID, result ? @"true" : @"false"] completionHandler:nil];
                }
                else if(!strcmp(returnType, @encode(int)))
                {
                    int result = *((int*)_retValue);
                    [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"EasyJS.asyncCallback(\"%@\", \"success\", [%d]);", callbackID, result] completionHandler:nil];
                }
                else if(!strcmp(returnType, @encode(float)))
                {
                    float result = *((float*)_retValue);
                    [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"EasyJS.asyncCallback(\"%@\", \"success\", [%f]);", callbackID, result] completionHandler:nil];
                }
                else
                {
                    [message.webView evaluateJavaScript:@"EasyJS.asyncCallback(\"%@\", \"success\", [\"notsupport\"]);" completionHandler:nil];
                }
            }
        }
    }
    /*
    
    
    
    */
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        WKWebView *webView = object;
        if([webView isKindOfClass:[WKWebView class]])
        {
            [self setProgress:webView.estimatedProgress];
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)])
    {
        [self.realDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)])
    {
        [self.realDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)])
    {
        [self.realDelegate webView:webView didStartProvisionalNavigation:navigation];
        return;
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)])
    {
        [self.realDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)])
    {
        [self.realDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didCommitNavigation:)])
    {
        [self.realDelegate webView:webView didCommitNavigation:navigation];
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (! self.javascriptInterfaces){
        self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableString* injection = [[NSMutableString alloc] init];
    
    //inject the javascript interface
    for(id key in self.javascriptInterfaces) {
        NSObject* interface = [self.javascriptInterfaces objectForKey:key];
        
        [injection appendString:@"EasyJS.inject(\""];
        [injection appendString:key];
        [injection appendString:@"\", ["];
        
        unsigned int mc = 0;
        Class cls = object_getClass(interface);
        Method * mlist = class_copyMethodList(cls, &mc);
        for (int i = 0; i < mc; i++){
            [injection appendString:@"\""];
            [injection appendString:[NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))]];
            [injection appendString:@"\""];
            
            if (i != mc - 1){
                [injection appendString:@", "];
            }
        }
        
        free(mlist);
        
        [injection appendString:@"]);"];
    }
    
    //inject the function interface
    [webView evaluateJavaScript:injection completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didFinishNavigation:)])
    {
        [self.realDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    if(self.realDelegate &&[self.realDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)])
    {
        [self.realDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)])
    {
        [self.realDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        return;
    }
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)])
    {
        [self.realDelegate webViewWebContentProcessDidTerminate:webView];
    }
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webViewDidClose:)])
    {
        [self.realDelegate webViewDidClose:webView];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"JS Alert Pannel Message:%@.", message);
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)])
    {
        [self.realDelegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    NSLog(@"JS Confirm Pannel Message:%@.", message);
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)])
    {
        [self.realDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"JS TextInput Pannel Prompt:%@, defaultText:%@.", prompt, defaultText);
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)])
    {
        [self.realDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler(@"");
}


@end
