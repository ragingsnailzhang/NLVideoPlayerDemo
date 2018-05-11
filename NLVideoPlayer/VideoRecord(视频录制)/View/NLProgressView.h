//
//  NLProgressView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLProgressView : UIView

//进度更新
-(void)updateProgressWithValue:(CGFloat)progress;
//重置
-(void)resetProgress;

@end
