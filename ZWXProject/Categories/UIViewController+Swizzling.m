//
//  UIViewController+Swizzling.m
//  ZWXProject
//
//  Created by allen on 2017/7/18.
//  Copyright © 2017年 allen. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"
@implementation UIViewController (Swizzling)
+ (void)load {
    
#ifdef DEBUG
    [[self class] jr_swizzleMethod:@selector(viewDidLoad) withMethod:@selector(m_viewDidLoad) error:nil];
    [[self class] jr_swizzleMethod:NSSelectorFromString(@"dealloc") withMethod:@selector(m_dealloc) error:nil];
    [[self class] jr_swizzleMethod:@selector(viewWillDisappear:) withMethod:@selector(m_viewWillDisappear:) error:nil];
#else
    [[self class] jr_swizzleMethod:@selector(viewWillDisappear:) withMethod:@selector(m_viewWillDisappear:) error:nil];
#endif
}

- (void)m_viewDidLoad {
    NSLog(@"%@ viewDidLoad", NSStringFromClass([self class]));
    if (IsiOS7Later)
    {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    [self m_viewDidLoad];
}

- (void)m_dealloc {
    NSLog(@"%@ released", NSStringFromClass([self class]));
    
    [self m_dealloc];
}

- (void)m_viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.translucent = NO;
    [self m_viewWillDisappear:animated];
}
@end
