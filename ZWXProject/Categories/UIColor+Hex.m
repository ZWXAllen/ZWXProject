//
//  UIColor+Hex.m
//  SoulSlashSagaGuide
//
//  Created by pcjbird on 15/7/8.
//  Copyright (c) 2015年 SnailGames. All rights reserved.
//

#import "UIColor+Hex.h"

@interface UIColor()

@end

@implementation UIColor (Hex)

+ (UIColor *) colorWithHexString: (NSString *) hexString
{
    return [self colorWithHexString:hexString alpha:1];
}

+ (UIColor *) colorWithHexString: (NSString *) hexString alpha:(CGFloat)alpha{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat  red = 0.0f, blue = 0.0f, green = 0.0f;
    BOOL bResult = TRUE;
    switch ([colorString length]) {
        case 3: // #RGB
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #RGBA
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 6: // #RRGGBB
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #RRGGBBAA
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        default:
            bResult = FALSE;
            break;
    }
    return (bResult ? [UIColor colorWithRed: red green: green blue: blue alpha: alpha] : nil);
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length
{
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end
