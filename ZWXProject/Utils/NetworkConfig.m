//
//  NetworkConfig.m
//  NextQueen
//
//  Created by pcjbird on 15/3/5.
//  Copyright (c) 2015年 SnailGames. All rights reserved.
//

#import "NetworkConfig.h"

@implementation NetworkConfig
static NetworkConfig* _sharedConfig = nil;

+ (NetworkConfig *)sharedConfig
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedConfig) {
            if (!_sharedConfig) _sharedConfig=[[NetworkConfig alloc] init];
        }
    });
    return _sharedConfig;
}

-(NetStatus) getNetStatus
{
    NetStatus netType = NetStatus_None;
    switch (self.status)
    {
        case NotReachable:
            netType = NetStatus_None;
            break;
        case ReachableViaWWAN:
            netType = NetStatus_3G;
            break;
        case ReachableViaWiFi:
            netType = NetStatus_WIFI;
            break;
        default:
            netType = 10000;
            break;
    }
       return netType;
}

-(NSString *)getGSM{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    NSString *carrier_country_code = carrier.isoCountryCode;
    
    if (carrier_country_code == nil) {
        
        carrier_country_code = @"";
        
    }
    
    //国家编号
    
    NSString *CountryCode = carrier.mobileCountryCode;
    
    if (CountryCode == nil) {
        
        CountryCode = @"";
        
    }
    
    //网络供应商编码
    
    NSString *NetworkCode = carrier.mobileNetworkCode;
    
    if (NetworkCode == nil)
        
    {
        
        NetworkCode = @"";
        
    }
    
    
    
    NSString *mobile_country_code = [NSString stringWithFormat:@"%@%@",CountryCode,NetworkCode];
    
    if (mobile_country_code == nil)
        
    {
        
        mobile_country_code = @"";
        
    }
    
    
    
    NSString *carrier_name = nil;    //网络运营商的名字
    
    NSString *code = [carrier mobileNetworkCode];
    
    
    
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        
        //移动
        
        carrier_name = @"中国移动";
        
    }
    
    
    
    if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"])
        
    {
        
        // ret = @"电信";
        
        carrier_name =  @"中国电信";
        
    }
    
    
    
    if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"])
        
    {
        
        // ret = @"联通";
        
        carrier_name =  @"中国联通";
        
    }
    
    
    
    if (code == nil)
        
    {
        
        carrier_name = @"";
        
    }
    
    
    
    carrier_name = [[NSString stringWithFormat:@"%@-%@",carrier_name,carrier.carrierName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return carrier.carrierName;
}
@end
