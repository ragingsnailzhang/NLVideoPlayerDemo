//
//  NLTopOptionsView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/23.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLTopOptionsView.h"
#import "NLConfigure.h"
#import <objc/runtime.h>
@implementation NLTopOptionsView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutViews];
    }
    return self;
}

-(void)layoutViews{
    //关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.frame = CGRectMake(MARGIN,(self.frame.size.height-23)/2, 23, 23);
    [self.closeBtn setImage:[UIImage imageNamed:@"record_close"] forState:UIControlStateNormal];
    [self addSubview:self.closeBtn];
    
    //摄像头按钮
    self.cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraBtn.frame = CGRectMake(kScreenW-MARGIN-35, self.closeBtn.center.y-15, 35, 30);
    [self.cameraBtn setImage:[UIImage imageNamed:@"record_camera"] forState:UIControlStateNormal];
    [self addSubview:self.cameraBtn];
    
    //闪光灯按钮
    self.lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lightBtn.frame = CGRectMake(self.cameraBtn.frame.origin.x-19-34, self.closeBtn.center.y-15, 19, 30);
    [self.lightBtn setImage:[UIImage imageNamed:@"record_light_off"] forState:UIControlStateNormal];
    objc_setAssociatedObject(self.lightBtn, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:self.lightBtn];
}

@end
