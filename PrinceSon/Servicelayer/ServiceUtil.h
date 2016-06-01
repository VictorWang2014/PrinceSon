//
//  ServiceUtil.h
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceUtil : NSObject

+ (void)writeInData:(NSMutableData *)data str:(NSString *)str;
+ (void)writeInData:(NSMutableData *)data byte:(char)byte;
+ (void)writeInData:(NSMutableData *)data sh:(short)sh;
+ (void)writeInData:(NSMutableData *)data intN:(short)intN;

+ (NSString *)readStringFromData:(NSData *)data pos:(int *)pos;
+ (char)readByteFromData:(NSData *)data pos:(int *)pos;
+ (short)readShortFromData:(NSData *)data pos:(int *)pos;
+ (int)readIntFromData:(NSData *)data pos:(int *)pos;

@end
