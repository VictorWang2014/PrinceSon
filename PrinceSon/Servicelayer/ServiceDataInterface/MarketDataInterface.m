//
//  MarketDataInterface.m
//  PrinceSon
//
//  Created by wangmingquan on 27/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "MarketDataInterface.h"
#import "ServiceUtil.h"

@implementation MarketDataRequestInterface

+ (NSMutableDictionary *)request2955DataWithListType:(unsigned short)listType fieldType:(unsigned short)fieldType sortField:(char)sortField sortType:(char)sortType beginP:(short)beginP reqCount:(short)reqCount stockList:(NSArray *)stockList fillType:(int)fillType
{
    NSMutableDictionary *reqDic = [NSMutableDictionary dictionary];
    NSMutableData *data = [NSMutableData data];
    [ServiceUtil writeInData:data sh:listType];
    [ServiceUtil writeInData:data sh:fieldType];
    if (listType == 106 || listType == 107 || listType >= 60001) {
        [ServiceUtil writeInData:data sh:stockList.count];
        for (NSString *code in stockList){
            [ServiceUtil writeInData:data str:code];
        }
    } else {
        [ServiceUtil writeInData:data byte:sortField];
        [ServiceUtil writeInData:data byte:sortType];
        [ServiceUtil writeInData:data sh:beginP];
        [ServiceUtil writeInData:data sh:reqCount];
        if (listType == 4095 && stockList.count > 0) {
            NSString *pCode = stockList[0];
            [ServiceUtil writeInData:data str:pCode];
        }
    }
    [reqDic setObject:@"2955" forKey:@"reqtype"];
    [reqDic setObject:data forKey:@"reqdata"];
    [reqDic setObject:[NSNumber numberWithBool:YES] forKey:@"needparse"];
    return reqDic;
}

@end
