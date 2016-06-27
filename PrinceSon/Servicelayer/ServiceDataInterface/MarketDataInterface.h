//
//  MarketDataInterface.h
//  PrinceSon
//
//  Created by wangmingquan on 27/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketDataRequestInterface : NSObject

+ (NSMutableDictionary *)request2955DataWithListType:(unsigned short)listType fieldType:(unsigned short)fieldType sortType:(char)sortType beginP:(short)beginP reqCount:(short)reqCount stockList:(NSArray *)stockList fillType:(int)fillType;

@end
