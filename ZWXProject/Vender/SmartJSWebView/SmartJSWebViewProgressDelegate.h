//
//  SmartJSWebViewProgressDelegate.h
//  SmartJSWebView
//
//  Created by pcjbird on 16/6/15.
//  Copyright © 2016年 Zero Status. All rights reserved.
//


@protocol SmartJSWebViewProgressDelegate<NSObject>

@required
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end

