//
//  NLBottomOptionsView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NLBottomOptionsViewDelegate<NSObject>

-(void)selectedClick;

-(void)previewClick;

-(void)cancleClick;


@end

@interface NLBottomOptionsView : UIView

@property(nonatomic,weak)id<NLBottomOptionsViewDelegate>delegate;

@end
