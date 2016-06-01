//
//  ServiceParserModule.m
//  PrinceSon
//
//  Created by wangmingquan on 30/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "ServiceParserModule.h"
#import "ServiceUtil.h"

@implementation ServiceParserModule

@end

@implementation Service1000Parser

- (void)parseWithData:(NSData *)data
{
    self.dataItem = [[Service1000DataItem alloc] init];
    int pos = 7;//headerlength
    short servcount = [ServiceUtil readShortFromData:data pos:&pos];
    NSMutableArray *serverList = [NSMutableArray arrayWithCapacity:servcount];
    for (int i=0; i< servcount; i++)
        [serverList addObject:[ServiceUtil readStringFromData:data pos:&pos]];
    self.dataItem.hqserverAddrlist = [serverList count] > 0 ? serverList : nil;
    
    // 解析委托五福器地址
    short wtsercount = [ServiceUtil readShortFromData:data pos:&pos];
    NSMutableArray *wtserverList = [NSMutableArray arrayWithCapacity:wtsercount];
    for (int i=0; i<wtsercount; i++)
        [wtserverList addObject:[ServiceUtil readStringFromData:data pos:&pos]];
    self.dataItem.wtserverAddrlist = [wtserverList count] > 0 ? wtserverList : nil;
    
    self.dataItem.noticeText = [ServiceUtil readStringFromData:data pos:&pos];		// 解析公告信息
    self.dataItem.freshVersionNum = [ServiceUtil readStringFromData:data pos:&pos];		// 解析新版本号
    self.dataItem.downloadAddrs = [ServiceUtil readStringFromData:data pos:&pos];		// 解析下载地址
    self.dataItem.isAlertUpdate = [ServiceUtil readByteFromData:data pos:&pos];		// 提醒升级       byte      1提醒 0不提醒
    self.dataItem.isForceUpdate = [ServiceUtil readByteFromData:data pos:&pos];		// 强制升级       byte      1强制 0不强制
    self.dataItem.isAlertLogin = [ServiceUtil readByteFromData:data pos:&pos];		// 是否提示登录   byte      1提示 0不提示，如果没有该位表示不提示
    self.dataItem.operatorsIP = [ServiceUtil readByteFromData:data pos:&pos];		// 用户运营商ip   byte      0表示未知；非0表示有效，2011-7-4增加
    self.dataItem.statInfoInterval = [ServiceUtil readShortFromData:data pos:&pos];		// 统计信息时间间隔 short   单位秒,如果为0表示不统计信息.	//20120307日增加
    self.dataItem.updateNotice = [ServiceUtil readStringFromData:data pos:&pos];		// 升级提示文字   String
    self.dataItem.crc = [ServiceUtil readShortFromData:data pos:&pos];      // 公告crc
    self.dataItem.tipType = [ServiceUtil readByteFromData:data pos:&pos];       // 公告提示类型
    
    // 解析调度地址信息
    short sedSvrNum = [ServiceUtil readShortFromData:data pos:&pos];      // 调度地址个数 地址格式为 ip:port
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:sedSvrNum];
    for (int i = 0; i < sedSvrNum; i++)
        [tmpArr addObject:[ServiceUtil readStringFromData:data pos:&pos]];
    self.dataItem.scheduleAddrList = [tmpArr count] > 0 ? tmpArr : nil;
    
    // 不同服务地址列表信息
    short svrNum = [ServiceUtil readShortFromData:data pos:&pos];
    NSMutableDictionary *dic= [NSMutableDictionary dictionary];
    for (int i = 0; i < svrNum; i++) {
        int serviceId           = [ServiceUtil readIntFromData:data pos:&pos];
        short tmpSvrNum         = [ServiceUtil readShortFromData:data pos:&pos];
        NSMutableArray *tmpArr  = [NSMutableArray arrayWithCapacity:tmpSvrNum];
        for (int j = 0; j < tmpSvrNum; j++)
            [tmpArr addObject:[ServiceUtil readStringFromData:data pos:&pos]];
        if ([tmpArr count] > 0)[dic setObject:tmpArr forKey:[NSNumber numberWithInt:serviceId]];
    }
    self.dataItem.serverDict = [[dic allKeys] count] > 0 ? dic : nil;
}

@end