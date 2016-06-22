//
//  VCSocketManagerModule.h
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@class VCSocketManagerModule;
@protocol SocketManagerModuleDelegate <NSObject>

- (void)socketDidConnected:(VCSocketManagerModule *)socketModule;
- (void)socketDidDisConnected:(VCSocketManagerModule *)socketModule;
- (void)socket:(VCSocketManagerModule *)socketModule willDisConnectedError:(NSError *)err;

- (NSDictionary *)socket:(VCSocketManagerModule *)socketModule parseHeaderWithData:(NSData *)data;

- (NSInteger)socket:(VCSocketManagerModule *)socketModule headerTagWithData:(NSData *)data;

// 根据packagedic 解析返回的包数据 并通知给对应的组件
- (void)socket:(VCSocketManagerModule *)socketModule parseWithPackageDic:(NSMutableDictionary *)packageDic;

@end

@interface VCSocketManagerModule : NSObject

@property (nonatomic, assign) id<SocketManagerModuleDelegate>delegate;
//+ (VCSocketManagerModule *)shareSocketManager;

- (void)connectToServerWithHost:(NSString *)host port:(UInt16)port;

- (void)disConnectSocket;

- (void)sendRequestData:(NSMutableDictionary *)dataDic;

@end
