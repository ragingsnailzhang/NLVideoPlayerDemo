//
//  NLSettingView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/23.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLSettingView.h"
#import "NLConfigure.h"

@interface NLSettingView()

@property(nonatomic,strong)UIViewController *superVc;

@end

@implementation NLSettingView

-(instancetype)initWithFrame:(CGRect)frame SuperVC:(UIViewController *)superVC{
    if (self = [super initWithFrame:frame]) {
        self.superVc = superVC;
        self.backgroundColor = [UIColor whiteColor];
        [self layoutView];
    }
    return self;
}
-(void)layoutView{
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, kScreenW, 60)];
    lab.numberOfLines = 0;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中,\r\n允许「%@」访问您的手机相机",[self getAppName]];
    lab.font = [UIFont systemFontOfSize:16];
    [self addSubview:lab];
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    setBtn.frame = CGRectMake(0, 180, kScreenW, 40);
    [setBtn setTitle:@"设置" forState:UIControlStateNormal];
    setBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [setBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [setBtn addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:setBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(MARGIN, MARGIN, 40, 40);
    [closeBtn setTitle:@"取消" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
}
-(void)setClick{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}
-(void)closeClick{
    if (self.superVc) {
        [self.superVc dismissViewControllerAnimated:YES completion:nil];
    }
}

-(NSString*)getAppName{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    return appName;
}

@end
