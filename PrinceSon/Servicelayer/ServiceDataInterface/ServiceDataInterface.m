//
//  ServiceDataInterface.m
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "ServiceDataInterface.h"
#import "ServiceUtil.h"

@implementation ServiceDataInterface

+ (NSData *)service1000RequestDataInterfaceWithVersion:(NSString *)version channelID:(NSString *)channelID deviceType:(NSString *)deviceType
{
    version = @"8.34";
    NSMutableData *bodyData = [NSMutableData data];
    [ServiceUtil writeInData:bodyData str:version];
    [ServiceUtil writeInData:bodyData str:channelID];
    [ServiceUtil writeInData:bodyData str:deviceType];
    [ServiceUtil writeInData:bodyData byte:0];
    [ServiceUtil writeInData:bodyData byte:0];
    [ServiceUtil writeInData:bodyData sh:1];
    [ServiceUtil writeInData:bodyData intN:1];

    NSMutableData *data = [NSMutableData data];
    char tag = '{';
    unsigned short type = 1000;
    short attrs = 0;
    unsigned short len = [bodyData length];
    [data appendBytes:&tag length:sizeof(tag)];
    [data appendBytes:&type length:sizeof(type)];
    [data appendBytes:&attrs length:sizeof(attrs)];
    [data appendBytes:&len length:sizeof(len)];
    [data appendData:bodyData];
    return data;
}

@end
