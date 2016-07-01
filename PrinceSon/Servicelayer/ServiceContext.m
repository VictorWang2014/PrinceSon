//
//  ServiceContext.m
//  PrinceSon
//
//  Created by wangmingquan on 31/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "ServiceContext.h"

@implementation ServiceContext

+ (ServiceContext *)shareInstance
{
    static ServiceContext *con;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        con = [[ServiceContext alloc] init];
    });
    return con;
}

- (NSString *)_getUUIDString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    NSString *str = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuid);
    str = [str length] >= 12 ? [str substringFromIndex:[str length]-12] : str;
    return str;
}

#pragma mark - setter getter
- (NSString *)appVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appV = [infoDictionary objectForKey:@"CFBundleShortVersionString"];// app版本
    return appV;
}

- (NSString *)channelNum
{
    NSString *cha = nil;
    NSString *service = @"com.gw.princeSon";
    NSString *account = @"princeSonChannelNum";
    cha = [SSKeychain passwordForService:service account:account];
    if (cha.length <= 0) {
        NSString *prefix = @"213";
        NSString *suffix = [self _getUUIDString];
        NSString * retVal = [NSString stringWithFormat:@"%@%@", prefix, suffix];
        int nLen	= 19 - (int)[retVal length];
        int nRand	= 0;
        // 随机生成填补位数
        for (int i = 0; i < nLen; i++) {
            nRand = arc4random() % 10;
            retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"%d",nRand]];
        }
        [SSKeychain setPassword:retVal forService:service account:account];
        cha = retVal;
    }
    return cha;
}

@end

@implementation NSObject (UUIDString)

- (NSString *)uuidString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    
    return uuidString;
}

@end
