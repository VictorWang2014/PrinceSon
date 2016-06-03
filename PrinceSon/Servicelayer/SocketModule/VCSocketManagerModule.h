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

@end

@interface VCSocketManagerModule : NSObject

@property (nonatomic, assign) id<SocketManagerModuleDelegate>delegate;
//+ (VCSocketManagerModule *)shareSocketManager;

- (void)connectToServerWithHost:(NSString *)host port:(UInt16)port;

- (void)disConnectSocket;

- (void)sendRequestData:(NSData *)data;

@end
