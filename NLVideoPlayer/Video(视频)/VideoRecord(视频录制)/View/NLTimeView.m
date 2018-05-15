//
//  NLTimeView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLTimeView.h"

#define TIME_IMG_WIDTH 14

@implementation NLTimeView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

-(void)configView{
    UIImageView *timeView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"time_sign"]];
    timeView.frame = CGRectMake(TIME_IMG_WIDTH, (self.bounds.size.height-TIME_IMG_WIDTH)/2, TIME_IMG_WIDTH, TIME_IMG_WIDTH);
    [self addSubview:timeView];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(TIME_IMG_WIDTH*2, 0, self.bounds.size.width-TIME_IMG_WIDTH*3, self.bounds.size.height)];
    _timeLab = lab;
    lab.text = @"00秒";
    lab.textAlignment = NSTextAlignmentRight;
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:14.f];
    [self addSubview:lab];
}

@end
