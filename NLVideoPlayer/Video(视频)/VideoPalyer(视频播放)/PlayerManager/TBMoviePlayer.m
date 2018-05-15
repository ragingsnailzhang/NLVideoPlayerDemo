//
//  ViewController.m
//  VideoPlayerTestDemo
//
//  Created by xiaoling on 2018/5/11.
//  Copyright © 2018年 LSJ. All rights reserved.
//

#import "TBMoviePlayer.h"
#import "sys/utsname.h"

@interface TBMoviePlayer ()<ZFPlayerDelegate>
@property(nonatomic,strong)UIView * fatherView;
@property(nonatomic,strong)ZFPlayerView * player;
@end

@implementation TBMoviePlayer
    
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
#pragma clang diagnostic pop

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#pragma clang diagnostic pop

}
    

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.fatherView = [UIView new];
    self.fatherView.frame = CGRectMake(0, [self.class tz_isIPhoneX]?24:0, [UIScreen mainScreen].bounds.size.width, [self.class tz_isIPhoneX]?[UIScreen mainScreen].bounds.size.height-24-34:[UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:self.fatherView];

    self.model.fatherView = self.fatherView;
    
    self.player = [[ZFPlayerView alloc]init];
    self.player.delegate = self;
    [self.player playerModel:self.model];
    [self.player autoPlayTheVideo];
}
- (void)zf_playerBackAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
+ (BOOL)tz_isIPhoneX {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
        // 模拟器下采用屏幕的高度来判断
        return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
                CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)));
    }
    // iPhone10,6是美版iPhoneX 感谢hegelsu指出：https://github.com/banchichen/TZImagePickerController/issues/635
    BOOL isIPhoneX = [platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"];
    return isIPhoneX;
}
    
+ (CGFloat)tz_statusBarHeight {
    return [self tz_isIPhoneX] ? 44 : 20;
}
    
- (ZFPlayerModel *)model{
    if(!_model){
        _model = [ZFPlayerModel new];
    }
    return _model;
}
    


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
