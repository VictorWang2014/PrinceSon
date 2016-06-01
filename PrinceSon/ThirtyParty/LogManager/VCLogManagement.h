//
//  VCLogManagement.h
//  DzhProjectiPhone
//
//  Created by wangmingquan on 17/3/16.
//  Copyright © 2016年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VCLogLevelThreadLayer = 1,
    VCLogLevelDispatchLayer,
    VCLogLevelDataRequet,
    VCLogLevelHomeLayer,
    VCLogLevelUser1,
    VCLogLevelUser2,
    VCLogLevelUser3,
}VCLogLevel;


#define VCLogThreadLayer(format, ...) VCLogPrint(__TIME__, __FUNCTION__,VCLogLevelThreadLayer, __LINE__,format,##__VA_ARGS__);

#define VCLogDispatchLayer(format, ...) VCLogPrint(__TIME__, __FUNCTION__,VCLogLevelDispatchLayer, __LINE__,format,##__VA_ARGS__);

#define VCLogDataRequet(format, ...) VCLogPrint(__TIME__, __FUNCTION__,VCLogLevelDataRequet, __LINE__,format,##__VA_ARGS__);

#define VCLogHomeLayer(format, ...) VCLogPrint(__TIME__, __FUNCTION__,VCLogLevelHomeLayer, __LINE__,format,##__VA_ARGS__);

#define VCLogUser1(format, ...) VCLogPrint(__TIME__, __FUNCTION__,VCLogLevelUser1, __LINE__,format,##__VA_ARGS__);

#define VCLogUser2(format, ...) VCLogPrint(__TIME__, __FUNCTION__,VCLogLevelUser2, __LINE__,format,##__VA_ARGS__);

#define VCLogUser3(format, ...) VCLogPrint(__TIME__, __FUNCTION__,VCLogLevelUser3, __LINE__,format,##__VA_ARGS__);


// 基础日志输出
#define ThreadLayer @"treadlayer"
#define DataRequet @"datarequet"
#define Dispatch @"dispatchlayer"
#define HomeLayer @"homelayer"
// 自定义日志输出  定义的参数中包含基础的输出级别
#define User1 @"user1"ThreadLayer
#define User2 @"user2"ThreadLayer DataRequet
#define User3 @"user3" DataRequet


#define VCLogLevelDefault VCLogLevelDispatchLayer

void VCLogPrint(const char *time,const char *function, int loglevel, int linenum, NSString *format,...);


@interface VCLogManagement : NSObject

+ (VCLogManagement *)sharedManager;
- (BOOL)canOutputWithKey:(int)key;

@end

