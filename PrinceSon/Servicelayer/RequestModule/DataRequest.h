//
//  DataRequest.h
//  PrinceSon
//
//  Created by wangmingquan on 29/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DataRequestCallBack) (id data);


@interface DataRequest : NSObject

- (void)sendRequestWithData:(NSMutableDictionary *)packageDic complete:(DataRequestCallBack)complete success:(DataRequestCallBack)success failure:(DataRequestCallBack)failure;

@end


@interface DataRequest (PackageDictionary)

+ (NSMutableDictionary *)packageDicWithDictionary:(NSMutableDictionary *)packageDic objectTag:(NSString *)objectTag callBackId:(NSString *)callBackId;

@end
