//
//  SmartJSWebView+ClearCookies.m
//  BDTools
//
//  Created by allen on 2017/7/13.
//  Copyright © 2017年 allen. All rights reserved.
//

#import "SmartJSWebView+ClearCookies.h"

@implementation SmartJSWebView (ClearCookies)
- (void)clearCookie {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

- (void)clearCache {
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

@end
