//
//  ServiceContext.h
//  PrinceSon
//
//  Created by wangmingquan on 31/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSKeychain.h"

#define ServiceC [ServiceContext shareInstance]

@interface ServiceContext : NSObject

+ (ServiceContext *)shareInstance;

@property (nonatomic, strong) NSString *channelNum;
@property (nonatomic, strong) NSString *appVersion;

@end

@interface NSObject (UUIDString)

- (NSString *)uuidString;

@end