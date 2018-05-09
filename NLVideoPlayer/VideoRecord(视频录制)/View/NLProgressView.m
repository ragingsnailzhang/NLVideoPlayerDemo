//
//  NLProgressView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLProgressView.h"

@interface NLProgressView()

@property(nonatomic,assign)CGFloat progress;

@property(nonatomic,strong)CAShapeLayer *backLayer;
@property(nonatomic,strong)CAShapeLayer *progressLayer;


@end

@implementation NLProgressView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [self drawCycleView];
}
-(void)drawCycleView{
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    CGFloat radius = self.frame.size.width/2;
    CGFloat start = -M_PI_2;
    CGFloat end = -M_PI_2 + M_PI * 2 * self.progress;

    if (!self.backLayer && self.frame.size.width > 0 && self.frame.size.height > 0) {
        self.backLayer = [[CAShapeLayer alloc]init];
        self.backLayer.frame = self.bounds;
        self.backLayer.fillColor = [UIColor clearColor].CGColor;
        self.backLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.backLayer.opacity = 1.f;
        self.backLayer.lineCap = kCALineCapRound;
        self.backLayer.lineWidth = PROGRESS_BORDER_WIDTH;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        self.backLayer.path = path.CGPath;
        [self.layer addSublayer:self.backLayer];
    }
   
    self.progressLayer = [[CAShapeLayer alloc]init];
    self.progressLayer.frame = self.bounds;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.strokeColor = [UIColor colorWithRed:0.22f green:0.54f blue:0.87f alpha:1.00f].CGColor;
    self.progressLayer.opacity = 1.f;
    self.progressLayer.lineCap = kCALineCapButt;
    self.progressLayer.lineWidth = PROGRESS_BORDER_WIDTH;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:start endAngle:end clockwise:YES];
    self.progressLayer.path = path.CGPath;
    [self.layer addSublayer:self.progressLayer];
    

}
-(void)updateProgressWithValue:(CGFloat)progress{
    self.progress = progress;
    self.progressLayer.opacity = 0.f;
    [self setNeedsDisplay];
}
-(void)resetProgress{
    [self updateProgressWithValue:0];
}

@end
