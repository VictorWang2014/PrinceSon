//
//  DispatchManagerModule.m
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "DispatchManagerModule.h"
#import "AFNetworking.h"

@interface DispatchManagerModule ()
{
    AFHTTPSessionManager *_httpManager;
}


@end

@implementation DispatchManagerModule

#pragma mark - lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _httpManager = [AFHTTPSessionManager manager];
    }
    return self;
}

#pragma mark - public

#pragma mark - private

@end
