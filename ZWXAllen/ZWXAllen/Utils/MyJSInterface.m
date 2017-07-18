//
//  MyJSInterface.m
//  EasyJSWebViewSample
//
//  Created by Lau Alex on 19/1/13.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "MyJSInterface.h"
static MyJSInterface *_sharedSession = nil;


@implementation MyJSInterface

+ (MyJSInterface *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedSession) {
            if (!_sharedSession)
                _sharedSession = [[MyJSInterface alloc] init];
        }
    });
    return _sharedSession;
}



@end
