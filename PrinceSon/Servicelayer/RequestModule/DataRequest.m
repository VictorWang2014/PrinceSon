//
//  DataRequest.m
//  PrinceSon
//
//  Created by wangmingquan on 29/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "DataRequest.h"
#import "ServiceContext.h"

@interface DataRequest ()

@property (nonatomic, strong) NSMutableDictionary *callBackDic;
@property (nonatomic, strong) NSString *objectTag;

@end

@implementation DataRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.objectTag = [self uuidString];
        self.callBackDic = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveData:) name:self.objectTag object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:self.objectTag object:nil userInfo:nil];
    }
    return self;
}

- (void)sendRequestWithData:(NSMutableDictionary *)packageDic complete:(DataRequestCallBack)complete success:(DataRequestCallBack)success failure:(DataRequestCallBack)failure
{
    NSString *callBackID = [self uuidString];
    if (complete || success || failure) {
        NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
        [itemDic setObject:complete forKey:@"complete"];
        [itemDic setObject:success forKey:@"success"];
        [itemDic setObject:failure forKey:@"failure"];
        [self.callBackDic setObject:itemDic forKey:callBackID];
    }
    NSMutableDictionary *dic = [[self class] packageDicWithDictionary:packageDic objectTag:self.objectTag callBackId:callBackID];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendrequestdata" object:nil userInfo:dic];
}

- (void)receiveData:(NSNotification *)notify
{
    
}

@end


@implementation DataRequest (PackageDictionary)

+ (NSMutableDictionary *)packageDicWithDictionary:(NSMutableDictionary *)packageDic objectTag:(NSString *)objectTag callBackId:(NSString *)callBackId
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:packageDic forKey:@"reqdic"];
    [dic setObject:objectTag forKey:@"objtag"];
    [dic setObject:callBackId forKey:@"callbackid"];
    return dic;
}


@end