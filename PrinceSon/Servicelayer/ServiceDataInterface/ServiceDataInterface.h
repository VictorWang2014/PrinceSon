//
//  ServiceDataInterface.h
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceDataInterface : NSObject

+ (NSData *)service1000RequestDataInterfaceWithVersion:(NSString *)version channelID:(NSString *)channelID deviceType:(NSString *)deviceType;

@end
