//
//  MarketDataItem.h
//  PrinceSon
//
//  Created by wangmingquan on 23/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketDataItem : NSObject

@end


@interface Market2955Item : NSObject

@property (nonatomic, strong) NSString *code;       // 代码
@property (nonatomic, strong) NSString *briefCode;  // 简略代码，去掉市场前缀
@property (nonatomic, strong) NSString *name;       // 名称
@property (nonatomic) int lastclose;                // 昨收
@property (nonatomic) int newprice;                 // 最新
@property (nonatomic) char type;                    // 股票类型
@property (nonatomic) char lending;                 //融资融券标记
@property (nonatomic) char decimal;                 // 小数位数
@property (nonatomic) int open;                     // 今开
@property (nonatomic) int high;                     // 最高
@property (nonatomic) int low;                      // 最低
@property (nonatomic) int amount;                   // 成交额
@property (nonatomic) short boardID;                // 请求板块指数成分股的id
//------0位
@property (nonatomic) short volumeUnit;             // 成交量单位
@property (nonatomic) int volume;                   // 成交量
//------1位
@property (nonatomic) int sellVolume;               // 内盘成交量
//------2位
@property (nonatomic) int curVolume;                // 现手
//------3位
@property (nonatomic) short volumeRatio;            // 量比           short×100
//------4位
@property (nonatomic) short turnover;               // 换手           short×10000
//------5位
@property (nonatomic) short speedUp;                // 涨速           short×10000
//------6位
@property (nonatomic) short weibi;                  // 委比           short×10000
//------7位
@property (nonatomic) char noteCount;               // 公告数目       byte 0表示无
//------8位 财务数据
@property (nonatomic) int syRatio;                  // 市盈率	  int×100  有正负号
@property (nonatomic) int sjRatio;                  // 市净率	  int×100  有正负号
//------9位 买卖盘字段
@property (nonatomic) int sellOne;                  // 卖一		  int
@property (nonatomic) int buyOne;                   // 买一		  int
//------10位 统计字段
@property (nonatomic) int riseRate7;                // 7日涨幅	  int×10000  有正负号
@property (nonatomic) int turnoverRate7;            // 7日换手	  int×10000
@property (nonatomic) int riseRate30;               // 30日涨幅	  int×10000  有正负号
@property (nonatomic) int turnoverRate30;           // 30日换手	  int×10000
//------11位 level2统计字段
@property (nonatomic) short ddx;                    // 当日ddx	  short×1000  有正负号
@property (nonatomic) short ddy;                    // 当日ddy	  short×1000  有正负号
@property (nonatomic) int ddz;                      // 当日ddz	  int×1000  有正负号
@property (nonatomic) int ddx60Days;                // 60日ddx	  int×1000  有正负号
@property (nonatomic) int ddy60Days;                // 60日ddy	  int×1000  有正负号
@property (nonatomic) char ddx10DaysRiseNum;        // 10日ddx红色的天数 char
@property (nonatomic) char ddx10DaysConitunedNum;   // 10日ddx连续红色数 char
//------12位 level2统计字段
@property (nonatomic) int fundIn;                   // 当日资金流入
@property (nonatomic) int fundOut;                  // 当日资金流出
@property (nonatomic) int fundIn5;                  // 5日资金流入
@property (nonatomic) int fundOut5;                 // 5日资金流出
@property (nonatomic) int fundAmount5;              // 5日资金成交额
@property (nonatomic) int fundIn30;                 // 30日资金流入
@property (nonatomic) int fundOut30;                // 30日资金流出
@property (nonatomic) int fundAmount30;             // 30日资金成交额
//------13位 商品类特有数据
@property (nonatomic) int yposition;                // 昨日持仓量
@property (nonatomic) int ysettlement;              // 昨日结算价
@property (nonatomic) int position;                 // 持仓量
@property (nonatomic) int settlement;               // 结算价
//------14 level2监控数据
@property (nonatomic) unsigned short mainBuyOrder;  // 机构买单数       short  //无符号
@property (nonatomic) unsigned short mainSellOrder; // 机构卖单数       short  //无符号
@property (nonatomic) unsigned short mainBuyDeal;   // 机构吃货数       short  //无符号
@property (nonatomic) unsigned short mainSellDeal;  // 机构吐货数       short  //无符号
@property (nonatomic) int mainBuyAmount;            // 机构吃货量       int
@property (nonatomic) int mainSellAmount;           // 机构吐货量       int
//------15
@property (nonatomic) char isRong;

//新增用来判断股票类型的字段，比如说小公募债券
@property (nonatomic) char specialType; //DZH_SpeicalType


@end