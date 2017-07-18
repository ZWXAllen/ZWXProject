//
//  SmartJSWebProgressView.h
//  SmartJSWebView
//
//  Created by pcjbird on 16/6/15.
//  Copyright © 2016年 Zero Status. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartJSWebViewProgressDelegate.h"
@interface SmartJSWebProgressView : UIView<SmartJSWebViewProgressDelegate>

@property (nonatomic,assign) float progress;
@property (readonly, nonatomic) UIView *progressBarView;
@property (nonatomic) NSTimeInterval barAnimationDuration;// default 0.5
@property (nonatomic) NSTimeInterval fadeAnimationDuration;// default 0.27
@property (copy, nonatomic) UIColor *progressBarColor; //进度条的颜色

@end
