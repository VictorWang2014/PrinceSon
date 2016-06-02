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
#import "FileManagerModule.h"

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
    int idx = arc4random()%self.dispatchAddressArray.count;
    NSString *address = [NSString stringWithFormat:@"http://%@", [self.dispatchAddressArray objectAtIndex:idx]];
    VCLogDispatchLayer(@"idx %d, address %@", idx, address);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
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
            if (parse.dataItem.scheduleAddrList.count > 0) {
                [self _saveDispatchAddress:parse.dataItem.scheduleAddrList];
            }
            success(parse.dataItem);
        } else {
            VCLogDispatchLayer(@"dipatch failure %@", error.description);
            failure(error.description);
        }
    }];
    [task resume];
}


#pragma mark - private
- (void)_saveDispatchAddress:(NSArray *)addressArray
{
    NSArray *tmpArray;
    if (addressArray.count == 0) {
        tmpArray = self.dispatchAddressArray;
    } else {
        tmpArray = addressArray;
        self.dispatchAddressArray = [NSMutableArray arrayWithArray:addressArray];
    }
    if (tmpArray.count > 0) {
        NSMutableArray *tarray = [NSMutableArray array];
        for (int i = 0; i < tmpArray.count; i++) {
            NSString *str = [tmpArray objectAtIndex:i];
            NSArray *a = [str componentsSeparatedByString:@":"];
            if (a.count == 2) {
                NSString *host = [a objectAtIndex:0];
                NSString *port = [a objectAtIndex:1];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:host forKey:@"host"];
                [dic setObject:port forKey:@"port"];
                [tarray addObject:dic];
            }
        }
        if (tarray.count > 0) {
            NSString *dispatchPath = [FileManagerModule getDocumentFileWithName:@"DispatchAddress.plist"];
            [tarray writeToFile:dispatchPath atomically:YES];
        }
        VCLogDispatchLayer(@"save down address %@", tarray);
    }
}

- (void)_getDispatchAddress
{
    NSString *dispatchPath = [FileManagerModule getDocumentFileWithName:@"DispatchAddress.plist"];
    NSArray *tmpArray;
    if ([FileManagerModule isFileExist:dispatchPath]) {
        //本地有保存的文件存在 则不需要从资源文件中读取调度地址
        tmpArray = [NSArray arrayWithContentsOfFile:dispatchPath];
        if ([tmpArray isKindOfClass:[NSArray class]]) {
            self.dispatchAddressArray = [NSMutableArray array];
            for (int i = 0; i < tmpArray.count; i++) {
                NSDictionary *tmpD = [tmpArray objectAtIndex:i];
                NSString *host = [tmpD objectForKey:@"host"];
                NSString *port = [tmpD objectForKey:@"port"];
                NSString *url = [NSString stringWithFormat:@"%@:%@", host, port];
                [self.dispatchAddressArray addObject:url];
            }
        }
    } else {
        // 获取资源文件中的调度地址
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ServerConfig" ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        tmpArray = [dic objectForKey:@"NavServers"];
    }
    if ([tmpArray isKindOfClass:[NSArray class]]) {
        self.dispatchAddressArray = [NSMutableArray array];
        for (int i = 0; i < tmpArray.count; i++) {
            NSDictionary *tmpD = [tmpArray objectAtIndex:i];
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
