//
//  UIColor+Hex.h
//  SoulSlashSagaGuide
//
//  Created by pcjbird on 15/7/8.
//  Copyright (c) 2015年 SnailGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)
+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (UIColor *) colorWithHexString: (NSString *) hexString alpha:(CGFloat)alpha;
@end
