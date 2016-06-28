//
//  RequestModule.m
//  PrinceSon
//
//  Created by wangmingquan on 28/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "RequestModule.h"

@implementation RequestModule



+ (NSMutableDictionary *)packageDataWithDataDic:(NSMutableDictionary *)packageDic objectTag:(NSString *)objectTag isGroup:(BOOL)isGroup
{
    if (objectTag.length <= 0) {
        objectTag = @"";
    }
    if ([packageDic allKeys].count <= 0) {
        packageDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:packageDic forKey:@"reqdic"];
    [dic setObject:objectTag forKey:@"objtag"];
    [dic setObject:[NSNumber numberWithBool:isGroup] forKey:@"group"];
    return dic;
}

@end
