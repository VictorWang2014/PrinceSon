//
//  MessageCenterManager.h
//  PrinceSon
//
//  Created by wangmingquan on 28/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageCenterManager : NSObject

- (void)addObserver:(NSString *)observer selector:(SEL)selector name:(id)name;
- (void)postNotificationName:(NSString *)name object:(id)object userInfo:(id)info;


@end
