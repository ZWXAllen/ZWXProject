//
//  GlobalDefine.h
//  SoulSlashSagaGuide
//
//  Created by pcjbird on 15/7/7.
//  Copyright (c) 2015年 SnailGames. All rights reserved.
//

#ifndef SoulSlashSagaGuide_GlobalDefine_h
#define SoulSlashSagaGuide_GlobalDefine_h


//APP 信息
#define APP_NAME ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] ? [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"])
#define APP_VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define APP_BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

//网络状态指示器
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#define ENABLE_LOGCOLOR             0         //xcode8不支持颜色插件

#ifdef DEBUG
#define ENABLE_ASSERT_STOP          1
#define ENABLE_DEBUGLOG             1
#endif

// 颜色日志
#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color
#define LogBlue(format, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,150,255;" format XCODE_COLORS_RESET), ##__VA_ARGS__)
#define LogRed(format, ...) NSLog((XCODE_COLORS_ESCAPE @"fg250,0,0;" format XCODE_COLORS_RESET), ##__VA_ARGS__)
#define LogGreen(format, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,100,0;" format XCODE_COLORS_RESET), ##__VA_ARGS__)

//调试日志
#ifdef ENABLE_DEBUGLOG
#define APP_LOG(format, ...) NSLog(format, ## __VA_ARGS__)
#define APP_LOGBLUE(format, ...) (ENABLE_LOGCOLOR ? LogBlue(format, ## __VA_ARGS__) : NSLog(format, ## __VA_ARGS__))
#define APP_LOGRED(format, ...) (ENABLE_LOGCOLOR ? LogRed(format, ## __VA_ARGS__) : NSLog(format, ## __VA_ARGS__))
#define APP_LOGGREEN(format, ...) (ENABLE_LOGCOLOR ? LogGreen(format, ## __VA_ARGS__) : NSLog(format, ## __VA_ARGS__))
#else
#define APP_LOG(format, ...) do { } while (0);
#define APP_LOGBLUE(format, ...) do { } while (0);
#define APP_LOGRED(format, ...) do { } while (0);
#define APP_LOGGREEN(format, ...) do { } while (0);
#endif

// 断言
#ifdef ENABLE_ASSERT_STOP
#define APP_ASSERT_STOP                     {LogRed(@"APP_ASSERT_STOP"); NSAssert1(NO, @" \n\n\n===== APP Assert. =====\n%s\n\n\n", __PRETTY_FUNCTION__);}
#define APP_ASSERT(condition, desc)         {NSAssert(condition, desc);}
#else
#define APP_ASSERT_STOP                     do {} while (0);
#define APP_ASSERT(condition, desc)         do {} while (0);
#endif


//KeyWindow
#define KeyWindow                           [[UIApplication sharedApplication] keyWindow]

//状态栏高度
#define StatusBarHeight                     [UIApplication sharedApplication].statusBarFrame.size.height
//TabBar高度
#define TabBarHeight                        49.0f
//系统导航高度
#define SYSNAVBARHEIGHT ((self.navigationController.navigationBar && !self.navigationController.navigationBarHidden) ? self.navigationController.navigationBar.frame.size.height : 0)

//屏幕尺寸
#define ScreenRect                          [[UIScreen mainScreen] bounds]
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define ScreenScale                         [UIScreen mainScreen].scale

#define Is35Inch                                 [DeviceUtil is35InchScreen]
#define Is4Inch                                  [DeviceUtil is4InchScreen]
#define Is47Inch                                 [DeviceUtil is47InchScreen]
#define Is55Inch                                 [DeviceUtil is55InchScreen]
#define Is79Inch                                 [DeviceUtil is79InchScreen]

//系统版本
#define IOSVersion                          [[[UIDevice currentDevice] systemVersion] floatValue]
#define IsiOS7Later                         !(IOSVersion < 7.0)
#define IsiOS8Later                         !(IOSVersion < 8.0)
#define IsiOS9Later                         !(IOSVersion < 9.0)
#define IsiOS10Later                         !(IOSVersion < 10.0)

//颜色
#define RGB(r, g, b)                        [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

//打开URL
#define APP_CANOPENURL(s) [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:s]]
#define APP_OPENURL(s) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:s]]

#define SINGLE_LINE_WIDTH (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET ((1 / [UIScreen mainScreen].scale) / 2)


#define IS_IPHONE4S        [[UIScreen mainScreen] currentMode].size.height < 1136 ? YES : NO
#define IS_IPHONE5         [[UIScreen mainScreen] currentMode].size.height == 1136 ? YES : NO
#define IS_IPHONE5ORLATER  [[UIScreen mainScreen] currentMode].size.height >= 1136 ? YES : NO
#define IS_IPHONE6         [[UIScreen mainScreen] currentMode].size.height == 1334 ? YES : NO
#define IS_IPHONE6ORLATER  [[UIScreen mainScreen] currentMode].size.height >= 1334  ? YES : NO
#define IS_6PLUS           [[UIScreen mainScreen] currentMode].size.height == 2208 ? YES : NO

//NavigationBar字体/颜色
#define NAVBAR_BACKCOLOR  RGB(0xff, 0xff, 0xff)
#define NAVBAR_TITLECOLOR FONT_O_COLOR
#define NAVBARBTN_NORMALCOLOR RGB(0x33, 0x33, 0x33)
#define NAVBARBTN_HIGHLIGHTCOLOR RGB(0x88, 0x88, 0x88)
#define NAVBARLIGHT_TITLECOLOR RGB(0xff, 0xff, 0xff)
#define NAVBARLIGHTBTN_NORMALCOLOR RGB(0xff, 0xff, 0xff)
#define NAVBARLIGHTBTN_HIGHLIGHTCOLOR RGB(0x99, 0x99, 0x99)
#define NAVBARBTN_DISABLECOLOR [UIColor lightGrayColor]
#define NAVBAR_TITLEFONT FONT_O
#define NAVBAR_BTNFONT CUSTOMBOLDFONT(12.0f)
//weak
#define weak(v) __weak typeof(self) v = self
#define GLOBAL_TEXT_COLOR_HEX @"C0855d"



#define LOGIN_SUCCESS_NOTIFICATION @"LOGIN_SUCCESS_NOTIFICATION"
#define EXIT_SUCCESS_NOTIFICATION @"EXIT_SUCCESS_NOTIFICATION"
//远程通知数量发生变化
#define REMOTEPUSHMSGCOUNTCHANGEDNOTIFICATION @"RemotePushMsgCountChangedNotification"
#define kNOREACHABILITY_NOTIFATION @"kNOREACHABILITY_NOTIFATION"
#define kUSER_LOGIN_SSO_SUCCESS @"kUSER_LOGIN_SSO_SUCCESS"
#endif
