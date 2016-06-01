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

@property (nonatomic, strong) NSMutableArray *dispatchAddressArray;//保存的调度地址 得更新

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
        //获取调度地址
        [self _getDispatchAddress];
    }
    return self;
}

#pragma mark - public
- (void)requestMarketServerIPWithSuccess:(DispatchManagerBlock)success failure:(DispatchManagerBlock)failure
{
    NSData *requestData = [ServiceDataInterface service1000RequestDataInterfaceWithVersion:self.version channelID:self.zdNum deviceType:self.zdType];
    NSString *s = @"http://112.124.104.99:12346";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:s] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    NSURLSessionDataTask *task = [_httpManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            Service1000Parser *parse = [[Service1000Parser alloc] init];
            NSData *data = responseObject;
            if ([data isKindOfClass:[NSData class]]) {
                [parse parseWithData:data];
            }
            VCLogDispatchLayer(@"dipatch success %@", parse.dataItem.hqserverAddrlist);
        } else {
            VCLogDispatchLayer(@"dipatch failure %@", error.description);
        }
    }];
    [task resume];
}


#pragma mark - private
- (void)_getDispatchAddress
{
    // 获取资源文件中的调度地址
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ServerConfig" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *array = [dic objectForKey:@"NavServers"];
    if ([array isKindOfClass:[NSArray class]]) {
        self.dispatchAddressArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            NSDictionary *tmpD = [array objectAtIndex:i];
            NSString *host = [tmpD objectForKey:@"host"];
            NSString *port = [tmpD objectForKey:@"port"];
            NSString *url = [NSString stringWithFormat:@"%@:%@", host, port];
            [self.dispatchAddressArray addObject:url];
        }
    }
    for (int i = 0; i < self.dispatchAddressArray.count; i++) {
        VCLogDispatchLayer(@"%@", [self.dispatchAddressArray objectAtIndex:i]);
    }
}

@end
