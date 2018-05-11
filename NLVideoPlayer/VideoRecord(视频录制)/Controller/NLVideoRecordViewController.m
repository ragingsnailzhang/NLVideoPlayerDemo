//
//  NLVideoRecordViewController.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLVideoRecordViewController.h"
#import <objc/runtime.h>

@interface NLVideoRecordViewController ()<NLVideoRecordManagerVCDelegate,NLBottomOptionsViewDelegate>

@property(nonatomic,strong)UIButton *closeBtn;                       //关闭按钮
@property(nonatomic,strong)UIButton *cameraBtn;                      //摄像头按钮
@property(nonatomic,strong)UIButton *lightBtn;                       //闪光灯按钮
@property(nonatomic,strong)NLVideoPreviewView *previewView;          //预览View
@property(nonatomic,strong)NLTimeView *timeView;                     //倒计时View
@property(nonatomic,strong)NLProgressView *progressView;             //进度
@property(nonatomic,strong)NLBottomOptionsView *optionsView;         //选项View
@property(nonatomic,strong)NSURL *outputFilePath;                    //视频输出路径

@end

@implementation NLVideoRecordViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self configureView];
    [self readyRecordVideo];

}
//准备录制
-(void)readyRecordVideo{
    [[NLVideoRecordManager shareVideoRecordManager] configVideoParamsWithVideoRatio:self.param.ratio Position:self.param.position maxRecordTime:self.param.maxTime Compression:self.param.isCompression];
    [[NLVideoRecordManager shareVideoRecordManager]startSessionRunning];
    [NLVideoRecordManager shareVideoRecordManager].vcDelegate = self;
}

//MARK:ConfigureView
-(void)configureView{
    //预览View
    CGRect rect = CGRectZero;
    switch (self.param.ratio) {
        case NLVideoVideoRatio4To3:
            rect = CGRectMake(0, 0, kScreenW, kScreenW*4/3);
            break;
        case NLVideoVideoRatio16To9:
            rect = CGRectMake(0, 0, kScreenW, kScreenW*16/9);
            break;
        case NLVideoVideoRatioFullScreen:
            rect = CGRectMake(0, 0, kScreenW, kScreenH);
            break;
        default:
            rect = self.view.frame;
            break;
    }
    self.previewView = [[NLVideoPreviewView alloc]initWithFrame:rect];
    [self.view addSubview:self.previewView];
    
    //关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.frame = CGRectMake(MARGIN,SAFEAREA_TOP_HEIGH, 23, 23);
    [self.closeBtn setImage:[UIImage imageNamed:@"record_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeBtn];
    
    //摄像头按钮
    self.cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraBtn.frame = CGRectMake(kScreenW-MARGIN-35, self.closeBtn.center.y-15, 35, 30);
    [self.cameraBtn setImage:[UIImage imageNamed:@"record_camera"] forState:UIControlStateNormal];
    [self.cameraBtn addTarget:self action:@selector(turnCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cameraBtn];
    
    //闪光灯按钮
    self.lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lightBtn.frame = CGRectMake(self.cameraBtn.frame.origin.x-19-34, self.closeBtn.center.y-15, 19, 30);
    [self.lightBtn setImage:[UIImage imageNamed:@"record_light_off"] forState:UIControlStateNormal];
    objc_setAssociatedObject(self.lightBtn, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.lightBtn addTarget:self action:@selector(light:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.lightBtn];
    
    //倒计时View
    self.timeView = [[NLTimeView alloc]initWithFrame:CGRectMake((kScreenW-STARTBTN_WIDTH)/2,kScreenH-SAFEAREA_BOTTOM_HEIGH-TIMEVIEW_HEIGHT-STARTBTN_WIDTH-MARGIN*1.5, STARTBTN_WIDTH, TIMEVIEW_HEIGHT)];
    self.timeView.hidden = YES;
    [self.view addSubview:self.timeView];

    //进度条
    self.progressView = [[NLProgressView alloc]initWithFrame:CGRectMake((kScreenW-STARTBTN_WIDTH)/2, self.timeView.frame.origin.y+self.timeView.frame.size.height, STARTBTN_WIDTH, STARTBTN_WIDTH)];
    self.progressView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.progressView];
    [self.progressView resetProgress];
    
    UILongPressGestureRecognizer *lpGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self.progressView addGestureRecognizer:lpGes];
    
    //保存取消View
    self.optionsView = [[NLBottomOptionsView alloc]initWithFrame:CGRectMake(0, self.timeView.frame.origin.y+self.timeView.frame.size.height, kScreenW, STARTBTN_WIDTH)];
    self.optionsView.hidden = YES;
    self.optionsView.delegate = self;
    [self.view addSubview:self.optionsView];
    
}
//MARK:Action
//关闭界面
-(void)close{
    [self recordFinished];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//切换摄像头
-(void)turnCamera:(UIButton *)sender{
    sender.enabled = NO;
    [[NLVideoRecordManager shareVideoRecordManager] turnCamera];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}
//闪光灯
-(void)light:(UIButton *)sender{
    NSString *state = objc_getAssociatedObject(sender, "light_state");
    if ([state isEqualToString:@"record_light_off"]) {
        objc_setAssociatedObject(sender, "light_state", @"record_light_on", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage imageNamed:@"record_light_on"] forState:UIControlStateNormal];
        [[NLVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeOn];

    }else if ([state isEqualToString:@"record_light_on"]){
        objc_setAssociatedObject(sender, "light_state", @"record_light_auto", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage imageNamed:@"record_light_auto"] forState:UIControlStateNormal];
        [[NLVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeAuto];

    }else{
        objc_setAssociatedObject(sender, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage imageNamed:@"record_light_off"] forState:UIControlStateNormal];
        [[NLVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeOff];
    }
}
//录制
-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self updateViewWithOptionsViewHidden:YES];
        [[NLVideoRecordManager shareVideoRecordManager] startRecord];
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        [self updateViewWithOptionsViewHidden:NO];
        [[NLVideoRecordManager shareVideoRecordManager] stopRecord];
    }
    
}
//更新界面
-(void)updateViewWithOptionsViewHidden:(BOOL)isHidden{
    self.optionsView.hidden = isHidden;
    self.timeView.hidden = !self.optionsView.hidden;
    self.progressView.hidden = !self.optionsView.hidden;
}
//结束录制
-(void)recordFinished{
    [[NLVideoRecordManager shareVideoRecordManager] stopRecord];
    [[NLVideoRecordManager shareVideoRecordManager] removeOutputAndInput];
    
    objc_setAssociatedObject(self.lightBtn, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.lightBtn setImage:[UIImage imageNamed:@"record_light_off"] forState:UIControlStateNormal];
    [[NLVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeOff];
}
//MARK:NLVideoRecordManagerDelegate
-(void)recordFinishedWithOutputFilePath:(NSURL *)filePath RecordTime:(CGFloat)recordTime{
    if (recordTime < self.param.minTime) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"录制时长少于%fS,请重新录制!",self.param.minTime] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self cancleClick];
        }];
        [alter addAction:action];
        [self presentViewController:alter animated:YES completion:nil];
    }
    //结束录制
    [self recordFinished];
    self.outputFilePath = filePath;

}
//更新时间状态
-(void)reloadRecordTime:(CGFloat)time{
    self.timeView.hidden = time>0 ? NO:YES;
    self.timeView.timeLab.text = [NSString stringWithFormat:@"%02ld秒",(long)floorf(time)];
    [self.progressView updateProgressWithValue:time/self.param.maxTime];
}
-(void)lightIsHidden:(BOOL)isHidden{
    self.lightBtn.hidden = isHidden;
}
//MARK:NLBottomOptionsViewDelegate
-(void)selectedClick{
    //保存视频
    [[NLVideoRecordManager shareVideoRecordManager]saveVideo];
    
    [self updateViewWithOptionsViewHidden:YES];
    [self reloadRecordTime:0];
    [self close];

}
-(void)previewClick{
    NLVideoPreviewViewController *page = [NLVideoPreviewViewController new];
    page.fileURL = self.outputFilePath;
    [self presentViewController:page animated:YES completion:nil];
}

-(void)cancleClick{
    [self updateViewWithOptionsViewHidden:YES];
    [self reloadRecordTime:0];
    [self readyRecordVideo];
}

@end
