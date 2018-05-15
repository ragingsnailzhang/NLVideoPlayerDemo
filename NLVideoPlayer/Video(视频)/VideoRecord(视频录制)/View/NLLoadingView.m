//
//  NLLoadingView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/11.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLLoadingView.h"

@interface NLLoadingView()

@property(nonatomic,strong)UIActivityIndicatorView *testActivityIndicator;
@property(nonatomic,strong)UIView *inView;
@end

@implementation NLLoadingView

+(instancetype)loadingViewWithTitle:(NSString *)title inView:(UIView *)view{
    CGSize size = [title sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.f],NSFontAttributeName,nil]];
    CGFloat width = 0.0f;
    CGFloat height = 60.0f;
    NLLoadingView *loadingView = [[NLLoadingView alloc]init];
    loadingView.inView = view;
    loadingView.layer.masksToBounds = YES;
    loadingView.layer.cornerRadius = 3;
    loadingView.backgroundColor = [UIColor lightGrayColor];
    
    if (size.width >= view.frame.size.width-50) {
        width = view.frame.size.width-50;
    }else{
        width = size.width;
    }
    loadingView.frame = CGRectMake(0, 0, width+20, height);
    loadingView.center = view.center;
    
    loadingView.testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingView.testActivityIndicator.center = CGPointMake(loadingView.bounds.size.width/2, loadingView.testActivityIndicator.frame.size.height);
    loadingView.testActivityIndicator.color = [UIColor whiteColor];
    [loadingView addSubview:loadingView.testActivityIndicator];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, loadingView.testActivityIndicator.frame.size.height*1.1+loadingView.testActivityIndicator.frame.origin.y, loadingView.frame.size.width, 20)];
    titleLab.text = title;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.font = [UIFont systemFontOfSize:12.f];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [loadingView addSubview:titleLab];
    
    for (UIView *ldView in view.subviews) {
        if ([ldView isMemberOfClass:[NLLoadingView class]]) {
            [(NLLoadingView *)ldView stopAnimating];
            [ldView removeFromSuperview];
        }
    }
    [view addSubview:loadingView];
    
    [loadingView startAnimating];
    
    return loadingView;
}

-(void)startAnimating{
    self.inView.userInteractionEnabled = NO;
    if (!self.testActivityIndicator.isAnimating) {
        [self.testActivityIndicator startAnimating];
    }
}
-(void)stopAnimating{
    self.inView.userInteractionEnabled = YES;
    if (self.testActivityIndicator.isAnimating) {
        [self.testActivityIndicator stopAnimating];
    }
    [self.testActivityIndicator setHidesWhenStopped:YES];
}



@end
