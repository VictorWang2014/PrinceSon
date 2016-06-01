//
//  ServiceParserModule.h
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceDataItemModule.h"

@interface ServiceParserModule : NSObject



@end


@interface Service1000Parser : NSObject

@property (nonatomic, strong) Service1000DataItem *dataItem;
- (void)parseWithData:(NSData *)data;

@end