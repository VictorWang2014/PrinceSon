//
//  VCSocketManagerModule.m
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "VCSocketManagerModule.h"

@interface VCSocketManagerModule ()

@end

@implementation VCSocketManagerModule

#pragma mark - singleton
+ (VCSocketManagerModule *)shareSocketManager
{
    static VCSocketManagerModule *share = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        share = [[VCSocketManagerModule alloc] init];
    });
    return share;
}

#pragma mark - lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - private

#pragma mark - public


@end
