//
//  MarketDataParseInterface.m
//  PrinceSon
//
//  Created by wangmingquan on 23/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "MarketDataParseInterface.h"
#import "MarketDataItem.h"
#import "ServiceUtil.h"

@implementation MarketDataParseInterface

- (void)parsePackageData:(NSData *)packageData headerL:(NSUInteger)headerL
{
    
}

@end


@implementation VCMarketDataInterface2955

- (void)parsePackageData:(NSData *)packageData headerL:(NSUInteger)headerL
{
    if (packageData.length < headerL) {
        self.isSuccess = NO;
        return;
    }
    self.isSuccess = YES;
    int posit = (int)headerL;
    short listType = [ServiceUtil readShortFromData:packageData pos:&posit];
    short fieldType = [ServiceUtil readShortFromData:packageData pos:&posit];
    short total = [ServiceUtil readShortFromData:packageData pos:&posit];
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:total];
    for (int i = 0; i < total; i++) {
        Market2955Item *item = [[Market2955Item alloc] init];
        item.code = [ServiceUtil readStringFromData:packageData pos:&posit];
        item.name = [ServiceUtil readStringFromData:packageData pos:&posit];
        item.decimal = [ServiceUtil readByteFromData:packageData pos:&posit];        //小数位
        item.type = [ServiceUtil readByteFromData:packageData pos:&posit];        //类型
        item.lastclose = [ServiceUtil readIntFromData:packageData pos:&posit];         //收盘
        item.open = [ServiceUtil readIntFromData:packageData pos:&posit];         //开盘
        item.newprice = [ServiceUtil readIntFromData:packageData pos:&posit];         //最新
        item.high = [ServiceUtil readIntFromData:packageData pos:&posit];         //最高
        item.low = [ServiceUtil readIntFromData:packageData pos:&posit];         //最低
        item.amount = [ServiceUtil readIntFromData:packageData pos:&posit];         //成交额
        if (listType == 105) {//板块的时候 才有此字段
            item.boardID = [ServiceUtil readShortFromData:packageData pos:&posit]; //成分股ID
        }
        item.volumeUnit = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:0];          //成交单位
        item.volume = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:0];            //成交量
        item.sellVolume = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:1];    //内盘成交量
        item.curVolume = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:2];    //现手
        item.volumeRatio = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:3]; //量比
        item.turnover = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:4];  //换手
        item.speedUp = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:5];  //涨速 有正负号
        item.weibi = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:6];  //委比 有正负号
        item.noteCount = [ServiceUtil readByteByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:7];   //公告数目
        item.syRatio = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:8]; //市盈率
        item.sjRatio = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:8]; //市净率
        item.sellOne = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:9];       //卖一
        item.buyOne = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:9];       //买一
        item.riseRate7 = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:10];     //7日涨幅 有正负号
        item.turnoverRate7 = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:10];     //7日换手
        item.riseRate30 = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:10];     //30日涨幅 有正负号
        item.turnoverRate30 = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:10];     //30日换手
        item.ddx = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:11];   //当天ddx 有正负号
        item.ddy = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:11];   //当天ddy 有正负号
        item.ddz = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:11];     //当天ddz 有正负号
        item.ddx60Days = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:11];     //60天ddx 有正负号
        item.ddy60Days = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:11];     //60天ddy 有正负号
        item.ddx10DaysRiseNum = [ServiceUtil readByteByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:11];    //10天ddx红色天数
        item.ddx10DaysConitunedNum = [ServiceUtil readByteByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:11];    //10天ddx连续红色天数
        if ((fieldType >> 12) & 0x1) {
            item.fundIn = [ServiceUtil readIntFromData:packageData pos:&posit];     //当日资金流入
            item.fundOut = [ServiceUtil readIntFromData:packageData pos:&posit];     //当日资金流出
            item.fundIn5 = [ServiceUtil readIntFromData:packageData pos:&posit];
            item.fundOut5 = [ServiceUtil readIntFromData:packageData pos:&posit];
            item.fundAmount5 = [ServiceUtil readIntFromData:packageData pos:&posit];
            item.fundIn30 = [ServiceUtil readIntFromData:packageData pos:&posit];
            item.fundOut30 = [ServiceUtil readIntFromData:packageData pos:&posit];
            item.fundAmount30 = [ServiceUtil readIntFromData:packageData pos:&posit];
        }
        item.yposition = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:13]; // 昨日持仓 [对期货或期指才有意义]
        item.ysettlement = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:13]; // 昨结算价 [前结算价]
        item.position = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:13]; // 持仓    [对期货或期指才有意义]
        item.settlement = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:13]; // 结算
        item.mainBuyOrder = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:14];
        item.mainSellOrder = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:14];
        item.mainBuyDeal = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:14];
        item.mainSellDeal = [ServiceUtil readShortByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:14];
        item.mainBuyAmount = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:14];
        item.mainSellAmount = [ServiceUtil readIntByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:14];
        item.lending = [ServiceUtil readByteByFieldType:packageData ppos:&posit fieldType:fieldType bitNum:15];
        [tmpArr addObject:item];
    }
    self.listArray = [NSMutableArray arrayWithArray:tmpArr];
}

@end









