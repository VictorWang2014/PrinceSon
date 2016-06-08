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

+ (NSString *)readStringFromData:(NSData *)data pos:(int *)pos
{
    NSString *st = @"";
    short len = 0;
    if (data.length >= *pos+sizeof(short)) {
        [data getBytes:&len range:NSMakeRange(*pos, sizeof(short))];
        *pos = *pos+sizeof(short);
        if (data.length >= *pos+len) {
            char *y = calloc(len+1, 1);
            [data getBytes:y range:NSMakeRange(*pos, len)];
            *pos = *pos+len;
            st = [NSString stringWithUTF8String:y];
            if(!st){//针对非utf8编码字符串做特殊处理
                st = [NSString stringWithCString:y encoding:[NSString defaultCStringEncoding]];
            }
            free(y);
        }
    }
    return st;
}

+ (char)readByteFromData:(NSData *)data pos:(int *)pos
{
    char tmp = 0;
    if (*pos+sizeof(tmp) <= [data length]) {
        [data getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos += sizeof(tmp);
    }
    return tmp;
}

+ (short)readShortFromData:(NSData *)data pos:(int *)pos
{
    short sh = 0;
    if (data.length >= *pos+sizeof(short)) {
        [data getBytes:&sh range:NSMakeRange(*pos, sizeof(short))];
        *pos = *pos+sizeof(short);
    }
    return sh;
}

+ (int)readIntFromData:(NSData *)data pos:(int *)pos
{
    int da = 0;
    if (data.length >= *pos+sizeof(int)) {
        [data getBytes:&da range:NSMakeRange(*pos, sizeof(int))];
        *pos = *pos+sizeof(int);
    }
    return da;
}

+ (Socket_NORMALHEAD *)packHeaderWithData:(NSData *)packData
{
    Socket_NORMALHEAD *head = nil;
    if (packData.length > sizeof(Socket_NORMALHEAD)) {
        head = (Socket_NORMALHEAD *)((char *)[packData bytes]);
    }
    return head;
}

@end
