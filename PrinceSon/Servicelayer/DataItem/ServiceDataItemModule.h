//
//  ServiceDataItemModule.h
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceDataItemModule : NSObject

@end

@interface Service1000DataItem : NSObject

@property (nonatomic, strong) NSMutableArray *hqserverAddrlist;	// 行情服务器地址数组
@property (nonatomic, strong) NSMutableArray *wtserverAddrlist;	// 委托服务器地址数组
@property (nonatomic, strong) NSString *noticeText;			// 公告信息
@property (nonatomic, strong) NSString *freshVersionNum;		// 新版本号
@property (nonatomic, strong) NSString *downloadAddrs;		// 下载地址
@property BOOL isAlertUpdate;		// 是否提醒升级
@property BOOL isForceUpdate;		// 是否强制升级
@property BOOL isAlertLogin;		// 是否提示登录
@property char operatorsIP;		// 用户运营商ip   byte      0表示未知；非0表示有效，2011-7-4增加
@property short	statInfoInterval;	// 统计信息时间间隔 short   单位秒,如果为0表示不统计信息.	//20120307日增加
@property (nonatomic, strong) NSString * updateNotice;			// 升级提示文字
@property short crc;                // 公告crc
@property char tipType;             // 公告提示类型
@property (nonatomic, strong) NSMutableArray *scheduleAddrList;     // 调度地址
@property (nonatomic, strong) NSMutableDictionary *serverDict;      // 不同服务器地址列表

@end