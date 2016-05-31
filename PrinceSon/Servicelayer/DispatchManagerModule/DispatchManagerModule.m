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
#import "ServiceContext.h"
#import "ServiceDataInterface.h"

@interface DispatchManagerModule ()
{
    AFHTTPSessionManager *_httpManager;
}

@property (nonatomic, strong) NSString *version;//版本
@property (nonatomic, strong) NSString *zdNum;//终端编号
@property (nonatomic, strong) NSString *zdType;//终端类型
@property (nonatomic, strong) NSString *sfUserTag;//收费用户标记
@property (nonatomic, strong) NSString *yysTag;//运营商标记

@end

@implementation DispatchManagerModule

#pragma mark - lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _httpManager = [AFHTTPSessionManager manager];
        _httpManager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
        _httpManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
        self.zdType = @"iphone";
        self.zdNum = ServiceC.channelNum;
        self.version = ServiceC.appVersion;
    }
    return self;
}

#pragma mark - public
- (void)requestMarketServerIPWithSuccess:(DispatchManagerBlock)success failure:(DispatchManagerBlock)failure
{
    NSData *requestData = [ServiceDataInterface service1000RequestDataInterfaceWithVersion:self.version channelID:self.zdNum deviceType:self.zdType];
    NSString *s = @"http://112.124.104.99:12346";
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:s] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
//    request.HTTPMethod = @"POST";
//    request.HTTPBody = requestData;
    [_httpManager POST:s parameters:requestData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure();
    }];
}


#pragma mark - private

@end
