//
//  MarketDataParseInterface.h
//  PrinceSon
//
//  Created by wangmingquan on 23/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketDataParseInterface : NSObject

@property (nonatomic, assign) BOOL isSuccess;
- (void)parsePackageData:(NSData *)packageData headerL:(NSUInteger)headerL;

@end

@interface VCMarketDataInterface2955 : MarketDataParseInterface

@property (nonatomic, strong) NSMutableArray *listArray;

@end
