//
//  ServiceUtil.h
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct Socket_NORMALHEAD_t
{
    char tag;
    short type;
    short attrs;
}Socket_NORMALHEAD;

typedef struct Socket_DATAHEAD_t
{
    char	tag;
    short	type;
    short 	attrs;
    unsigned short	length;
}Socket_DATAHEAD,*Socket_LPDATAHEAD;

typedef struct Socket_DATAHEAD_t_EX
{
    char	tag;
    short	type;
    short 	attrs;
    unsigned int	length;
}Socket_DATAHEAD_EX;


@interface ServiceUtil : NSObject

+ (void)writeInData:(NSMutableData *)data str:(NSString *)str;
+ (void)writeInData:(NSMutableData *)data byte:(char)byte;
+ (void)writeInData:(NSMutableData *)data sh:(short)sh;
+ (void)writeInData:(NSMutableData *)data intN:(short)intN;

+ (NSString *)readStringFromData:(NSData *)data pos:(int *)pos;
+ (char)readByteFromData:(NSData *)data pos:(int *)pos;
+ (short)readShortFromData:(NSData *)data pos:(int *)pos;
+ (int)readIntFromData:(NSData *)data pos:(int *)pos;
+ (short)readShortByFieldType:(NSData *)data ppos:(int *)ppos fieldType:(int)fieldType bitNum:(short)bitNum;
+ (int)readIntByFieldType:(NSData *)data ppos:(int *)ppos fieldType:(int)fieldType bitNum:(short)bitNum;
+ (int)readByteByFieldType:(NSData *)data ppos:(int *)ppos fieldType:(int)fieldType bitNum:(short)bitNum;

+ (Socket_NORMALHEAD *)packHeaderWithData:(NSData *)packData;

@end
