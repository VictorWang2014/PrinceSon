//
//  ViewController.m
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"
#import "DispatchManagerModule.h"
#import "VCSocketManagerModule.h"
#import "ServiceDataItemModule.h"
#import "FileManagerModule.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    DispatchManagerModule *_dispatchModule;
    VCSocketManagerModule *_socketModule;
}

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSMutableArray *marketAddressArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.marketAddressArray = [NSMutableArray array];
    self.list = [@[@"request marketserver IP", @"connect to socket", @"test"] copy];
    _dispatchModule = [[DispatchManagerModule alloc] init];
    _socketModule = [[VCSocketManagerModule alloc] init];
    
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"judge"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"judge"];
    }
    cell.textLabel.text = [self.list objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [_dispatchModule requestMarketServerIPWithSuccess:^(id data) {
            Service1000DataItem *item = (Service1000DataItem *)data;
            if (item.hqserverAddrlist.count > 0) {
                self.marketAddressArray = [NSMutableArray arrayWithArray:item.hqserverAddrlist];
                NSString *marketAddressPath = [FileManagerModule getDocumentFileWithName:@"MarketAddress.plist"];
                [self.marketAddressArray writeToFile:marketAddressPath atomically:YES];
            }
            NSLog(@"success");
        } failure:^(id data) {
            NSLog(@"failure");
        }];
    } else if (indexPath.row == 1) {
        if (self.marketAddressArray.count > 0) {
            int idx = arc4random()%self.marketAddressArray.count;
            NSString *addressPath = [self.marketAddressArray objectAtIndex:idx];
            VCLogUser1(@"addresspath %@", addressPath);
            NSArray *a = [addressPath componentsSeparatedByString:@":"];
            if (a.count == 2) {
                NSString *host = [a objectAtIndex:0];
                NSString *p = [a objectAtIndex:1];
                UInt16 port = [p integerValue];
                [_socketModule connectToServerWithHost:host port:port];
            }
        } else {
            UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有行情地址" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ac = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
            [aler addAction:ac];
            [self presentViewController:aler animated:YES completion:nil];
        }
    } else if (indexPath.row == self.list.count-1) {
        TestViewController *vc = [[TestViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
