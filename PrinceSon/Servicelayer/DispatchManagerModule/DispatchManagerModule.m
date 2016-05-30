//
//  DispatchManagerModule.m
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "DispatchManagerModule.h"
#import "AFNetworking.h"
#import "ServiceParserModule.h"

@interface DispatchManagerModule ()
{
    AFHTTPSessionManager *_httpManager;
}

@property (nonatomic, strong) NSString *zdNum;
@property (nonatomic, strong) NSString *zdType;
//@property (nonatomic, strong) NSString *

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
- (void)requestMarketServerIPWithSuccess:(DispatchManagerBlock)success failure:(DispatchManagerBlock)failure
{
    
    [_httpManager POST:@"http://www.baidu.com" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


#pragma mark - private

@end
