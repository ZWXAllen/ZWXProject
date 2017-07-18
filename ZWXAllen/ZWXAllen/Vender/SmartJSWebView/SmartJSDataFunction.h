//
//  SmartJSDataFunction.h
//  SmartJSWebView
//
//  Created by pcjbird on 16/6/15.
//  Copyright © 2016年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartJSWebView.h"

typedef void (^CompleteHandler)(id result, NSError * error);

@interface SmartJSDataFunction : NSObject

@property (nonatomic, retain) NSString* funcID;
@property (nonatomic, retain) SmartJSWebView* smartWebView;
@property (nonatomic, assign) BOOL removeAfterExecute;

- (id) initWithSmartWebView:(SmartJSWebView*) webView;

- (void) executeWithCompleteHandler:(CompleteHandler)handler;
- (void) executeWithParam: (NSString*) param completeHandler:(CompleteHandler)handler;
- (void) executeWithParams: (NSArray*) params completeHandler:(CompleteHandler)handler;

@end
