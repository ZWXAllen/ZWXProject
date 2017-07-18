//
//  AppDelegate+Tabbar.m
//  BDTools
//
//  Created by allen on 2017/6/1.
//  Copyright © 2017年 allen. All rights reserved.
//

#import "AppDelegate+Tabbar.h"
#import <CYLTabBarController/CYLTabBarController.h>
#import "UIColor+Hex.h"
#import "ViewController.h"
@implementation AppDelegate (Tabbar)
- (void)setupViewControllers {
    ViewController *vc1 = [[ViewController alloc] init];
    ViewController *vc2 = [[ViewController alloc] init];
    
    CYLTabBarController *tabBarController = [[CYLTabBarController alloc] init];
    [self customizeTabBarForController:tabBarController];
    
    [tabBarController setViewControllers:@[
                                           vc1,
                                           vc2
                                           ]];
    self.tabBarController = tabBarController;
}

- (UIViewController *)topVC
{
    UINavigationController *result =  self.cyl_tabBarController.selectedViewController;
    UIViewController *topvc = result.topViewController;
    return topvc;
}


- (void)customizeInterface {
    
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    
    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor colorWithHexString:GLOBAL_TEXT_COLOR_HEX];
//
//    // 设置文字属性
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    // 设置背景图片
    UITabBar *tabBarAppearance = [UITabBar appearance];
    [tabBarAppearance setBackgroundImage:[UIImage imageNamed:@"底部actionbar"]];
}


/*
 *
 在`-setViewControllers:`之前设置TabBar的属性，
 *
 */
- (void)customizeTabBarForController:(CYLTabBarController *)tabBarController {
    
    NSDictionary *dict1 = @{
                            CYLTabBarItemTitle : @"1",
                            CYLTabBarItemImage : @"资讯",
                            CYLTabBarItemSelectedImage : @"资讯点击",
                            };
    NSDictionary *dict2 = @{
                            CYLTabBarItemTitle : @"2",
                            CYLTabBarItemImage : @"论坛",
                            CYLTabBarItemSelectedImage : @"论坛点击",
                            };
    NSDictionary *dict3 = @{
                            CYLTabBarItemTitle : @"",
                            CYLTabBarItemImage : @"攻略",
                            CYLTabBarItemSelectedImage : @"攻略点击",
                            };
    NSDictionary *dict4 = @{
                            CYLTabBarItemTitle : @"",
                            CYLTabBarItemImage : @"我的",
                            CYLTabBarItemSelectedImage : @"我的点击",
                            };
    
    NSArray *tabBarItemsAttributes = @[ dict1, dict2];
    tabBarController.tabBarItemsAttributes = tabBarItemsAttributes;
    tabBarController.imageInsets = UIEdgeInsetsMake(4.5, 0, -4.5, 0);
    tabBarController.titlePositionAdjustment = UIOffsetMake(0, MAXFLOAT);
    [self customizeInterface];
}
@end
