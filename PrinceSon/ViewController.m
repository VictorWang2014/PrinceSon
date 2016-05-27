//
//  ViewController.m
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 110)];
    la.text = @"label";
    [self.view addSubview:la];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
