//
//  MarketDataManagerModule.m
//  PrinceSon
//
//  Created by wangmingquan on 8/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "MarketDataManagerModule.h"
#import "ServiceUtil.h"

@implementation MarketDataManagerModule

+ (MarketDataManagerModule *)shareInstance
{
    static MarketDataManagerModule *module = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        module = [[MarketDataManagerModule alloc] init];
    });
    return module;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - SocketManagerModuleDelegate
- (void)socketDidConnected:(VCSocketManagerModule *)socketModule
{
    
}

- (void)socketDidDisConnected:(VCSocketManagerModule *)socketModule
{
    
}

- (void)socket:(VCSocketManagerModule *)socketModule willDisConnectedError:(NSError *)err
{
    
}

// 解析socket字节流 头部
- (NSDictionary *)socket:(VCSocketManagerModule *)socketModule parseHeaderWithData:(NSData *)data
{
    NSDictionary *headerDic = nil;
    Socket_NORMALHEAD *header = [ServiceUtil packHeaderWithData:data];
    if (header) {
        char tag = header->tag;
        unsigned short type = header->type;
        short attr = (header->attrs & 0x8) >> 3;
        int byteLen = attr==0?sizeof(short):sizeof(int);
        int dataLen = 0;
        NSUInteger headerLen = attr == 1 ? sizeof(Socket_DATAHEAD_EX) : sizeof(Socket_DATAHEAD);
        [data getBytes:&dataLen range:NSMakeRange(sizeof(Socket_NORMALHEAD), byteLen)];
        headerDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:tag], @"tag", [NSNumber numberWithInteger:type], @"type", [NSNumber numberWithUnsignedInteger:dataLen], @"dataLength", [NSNumber numberWithUnsignedInteger:headerLen], @"headerLength", nil];
    }
    return headerDic;
}


@end
