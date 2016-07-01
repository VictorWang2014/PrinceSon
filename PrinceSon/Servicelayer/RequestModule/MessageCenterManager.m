//
//  MessageCenterManager.m
//  PrinceSon
//
//  Created by wangmingquan on 28/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "MessageCenterManager.h"

@interface MessageCenterManager ()

@property (nonatomic, strong) NSMutableDictionary *queueDic;

@end

@implementation MessageCenterManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queueDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addObserver:(NSString *)observer selector:(SEL)selector name:(id)name
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:observer, @"observer", selector, @"selector", name, @"name", nil];
    BOOL isexist = NO;
    NSMutableArray *itemArray = [NSMutableArray array];
    for (int i = 0; i < self.queueDic.allKeys.count; i++) {
        NSString *key = [self.queueDic.allKeys objectAtIndex:i];
        if ([key isEqualToString:name]) {
            isexist = YES;
        }
    }
    if (isexist) {
        itemArray = [NSMutableArray arrayWithArray:[self.queueDic objectForKey:name]];
    }
    [itemArray addObject:dic];
    [self.queueDic setObject:itemArray forKey:name];
}

- (void)postNotificationName:(NSString *)name object:(id)object userInfo:(id)info
{
    
}


@end
