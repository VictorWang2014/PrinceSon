//
//  DispatchManagerModule.h
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DispatchManagerBlock) (void);

@interface DispatchManagerModule : NSObject

- (void)requestMarketServerIPWithSuccess:(DispatchManagerBlock)success failure:(DispatchManagerBlock)failure;

@end
