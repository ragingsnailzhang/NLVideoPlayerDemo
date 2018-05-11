//
//  NLLoadingView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/11.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLLoadingView : UIView

+(instancetype)loadingViewWithTitle:(NSString *)title inView:(UIView *)view;

-(void)startAnimating;

-(void)stopAnimating;

@end
