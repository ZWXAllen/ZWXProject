//
//  DataParseUtil.h
//  FreeStore
//
//  Created by pcjbird on 14-6-9.
//  Copyright (c) 2014年 SnailGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataParseUtil : NSObject

+ (NSString*)getDataAsString:(id)data;
+ (BOOL) getDataAsBool:(id)data;
+ (int) getDataAsInt:(id)data;
+ (long) getDataAsLong:(id)data;
+ (float) getDataAsFloat:(id)data;
+ (double) getDataAsDouble:(id)data;
+ (NSDate*) getDataAsDate:(id)data;
+ (NSData*) toJSONData:(id)data;
+ (id) toJsonObject:(id)data;
+ (NSString*) toJSONString:(id)data;
+ (int) getDateAsAge:(NSDate*)date;

@end
