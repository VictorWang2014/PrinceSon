//
//  MarketDataManagerModule.h
//  PrinceSon
//
//  Created by wangmingquan on 8/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCSocketManagerModule.h"


@interface MarketDataManagerModule : NSObject

+ (MarketDataManagerModule *)shareInstance;

@property (nonatomic, assign) id<SocketManagerModuleDelegate>delegate;

@end
