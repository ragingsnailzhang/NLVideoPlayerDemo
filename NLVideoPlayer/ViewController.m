//
//  ViewController.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "ViewController.h"
#import "NLVideoRecordViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake((self.view.frame.size.width-100)/2, self.view.center.y, 100, 40);
    [recordBtn setTitle:@"record" forState:UIControlStateNormal];
    [recordBtn setBackgroundColor:[UIColor redColor]];
    [recordBtn addTarget:self action:@selector(recordClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordBtn];
}
-(void)recordClick{
    NLVideoRecordViewController *recordVC = [[NLVideoRecordViewController alloc]init];
    [self presentViewController:recordVC animated:YES completion:nil];
}


@end
