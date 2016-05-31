//
//  ServiceUtil.m
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "ServiceUtil.h"

@implementation ServiceUtil

+ (void)writeInData:(NSMutableData *)data str:(NSString *)str
{
    unsigned short len = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [data appendBytes:&len length:sizeof(len)];
    [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)writeInData:(NSMutableData *)data byte:(char)byte
{
    [data appendBytes:&byte length:sizeof(byte)];
}

+ (void)writeInData:(NSMutableData *)data sh:(short)sh
{
    [data appendBytes:&sh length:sizeof(sh)];
}

+ (void)writeInData:(NSMutableData *)data intN:(short)intN
{
    [data appendBytes:&intN length:sizeof(intN)];
}

@end
