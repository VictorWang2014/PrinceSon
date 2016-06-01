//
//  TestViewController.m
//  PrinceSon
//
//  Created by wangmingquan on 31/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "TestViewController.h"
#import "SSKeychain.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // SSKeychain service 是唯一标示 所以一般是用应用程序的bundleid来代替
    [SSKeychain setPassword:@"123456" forService:@"com.gw.princeson" account:@"wangmingquan"];
    NSLog(@"%@", [SSKeychain passwordForService:@"com.gw.princeson" account:@"wangmingquan"]);
    //长度
    NSLog(@"char length %lu, byte length %lu, short length %lu, int length %lu, void *length %lu, nsstring length %lu ,@\"12312312312312\" length %lu ", sizeof(char), sizeof(Byte), sizeof(short), sizeof(int), sizeof(void *), sizeof(NSString *), [@"12312312312312" length]);//char length 1, byte length 1, short length 2, int length 4, void *length 8, nsstring length 8 ,@"12312312312312" length 14 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
