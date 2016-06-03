//
//  VCLogManagement.m
//  DzhProjectiPhone
//
//  Created by wangmingquan on 17/3/16.
//  Copyright © 2016年 gw. All rights reserved.
//

#import "VCLogManagement.h"

void VCLogPrint(const char *time, const char *function, int loglevel, int linenum, NSString *format,...)
{
    if ([[VCLogManagement sharedManager] canOutputWithKey:loglevel]) {
        va_list args;
        va_start(args, format);
        NSString* str = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        fprintf(stderr,"%s %s [%d] ---> %s\n", time,function,linenum,[str UTF8String]);
    }
}


@interface VCLogManagement ()

@property (nonatomic, retain) NSString *level;

@end


@implementation VCLogManagement

+ (VCLogManagement *)sharedManager
{
    static VCLogManagement *logManagerment = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        logManagerment = [[self alloc] init];
    });
    return logManagerment;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        switch (VCLogLevelDefault) {
            case VCLogLevelThreadLayer:
                self.level = ThreadLayer;
                break;
            case VCLogLevelDataRequet:
                self.level = DataRequet;
                break;
            case VCLogLevelUser1:
                self.level = User1;
                break;
            case VCLogLevelUser2:
                self.level = User2;
                break;
            case VCLogLevelHomeLayer:
                self.level = HomeLayer;
                break;
            case VCLogLevelUser3:
                self.level = User3;
                break;
            case VCLogLevelDispatchLayer:
                self.level = Dispatch;
                break;
            case VCLogLevelSocketLayer:
                self.level = SocketLayer;
                break;
            default:
                break;
        }
    }
    return self;
}

- (BOOL)canOutputWithKey:(int)key
{
    NSString *level = @"";
    switch (key) {
        case VCLogLevelThreadLayer:
            level = ThreadLayer;
            break;
        case VCLogLevelDataRequet:
            level = DataRequet;
            break;
        case VCLogLevelHomeLayer:
            level = HomeLayer;
            break;
        case VCLogLevelUser1:
            level = User1;
            break;
        case VCLogLevelUser2:
            level = User2;
            break;
        case VCLogLevelUser3:
            level = User3;
            break;
        case VCLogLevelDispatchLayer:
            level = Dispatch;
            break;
        case VCLogLevelSocketLayer:
            level = SocketLayer;
            break;
        default:
            break;
    }
    if ([self.level containsString:level]) {
        return YES;
    }
    return NO;
}


@end
