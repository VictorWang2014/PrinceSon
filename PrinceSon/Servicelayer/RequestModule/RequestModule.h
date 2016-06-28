//
//  RequestModule.h
//  PrinceSon
//
//  Created by wangmingquan on 28/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestModule : NSObject


+ (NSMutableDictionary *)packageDataWithDataDic:(NSMutableDictionary *)packageDic objectTag:(NSString *)objectTag isGroup:(BOOL)isGroup;

@end
