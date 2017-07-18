//
//  StringUtil.m
//  feicui
//
//  Created by pcjbird on 2016/11/11.
//  Copyright © 2016年 Zero Status. All rights reserved.
//

#import "StringUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation StringUtil

+(BOOL) isStringBlank:(NSString*)val
{
    if(!val) return YES;
    if(![val isKindOfClass:[NSString class]]) return YES;
    val = [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([val isEqualToString:@""]) return YES;
    if([val isEqualToString:@"(null)"]) return YES;
    if([val isEqualToString:@"<null>"]) return YES;
    return NO;
}


+(BOOL) isStringHasChineseCharacter:(NSString*)val
{
    if([StringUtil isStringBlank:val]) return NO;
    for(int i=0; i< [val length];i++)
    {
        int a = [val characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}


+(NSString *)stringMD5:(NSString *)string{
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
