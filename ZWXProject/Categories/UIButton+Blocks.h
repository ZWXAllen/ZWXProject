/*
 * Copyright (c) 2011,
 * All rights reserved.
 *
 * 文件名称：UIButton+Blocks.h
 * 文件标识：
 * 摘 要：
 *
 * 当前版本：1.0
 * 作 者：qitao
 * 完成日期：2011年10月19日
 */


#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


typedef void (^ActionBlock)();

@interface UIButton(Block)


- (void)bk_addEventHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;
@end
