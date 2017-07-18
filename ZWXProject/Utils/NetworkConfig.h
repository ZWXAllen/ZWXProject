//
//  NetworkConfig.h
//  NextQueen
//
//  Created by pcjbird on 15/3/5.
//  Copyright (c) 2015年 SnailGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Reachability.h"
typedef enum
{
   NetStatus_None = 0,
   NetStatus_2G,
   NetStatus_3G,
   NetStatus_4G,
   NetStatus_5G, //猜测，未确认
   NetStatus_WIFI = 5,
}NetStatus;

@interface NetworkConfig : NSObject

@property(nonatomic, assign) NetworkStatus status;

+ (NetworkConfig *) sharedConfig;

-(NetStatus) getNetStatus;

//获取运营商
-(NSString *)getGSM;

@end
