//
//  NLWriterVideoRecordViewController.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/22.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLWriterVideoRecordViewController.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "NLWriterVideoRecordManager.h"
#import "NLSettingView.h"
#import "NLTopOptionsView.h"
#import "NLFilterPreviewView.h"

@interface NLWriterVideoRecordViewController ()<NLBottomOptionsViewDelegate,NLWriterVideoRecordManagerVCDelegate>

@property(nonatomic,strong)NLTopOptionsView *topView;                //顶部View
@property(nonatomic,strong)NLVideoPreviewView *previewView;          //无滤镜预览View
@property(nonatomic,strong)NLFilterPreviewView *filterView;          //有滤镜预览View
@property(nonatomic,strong)NLTimeView *timeView;                     //倒计时View
@property(nonatomic,strong)NLProgressView *progressView;             //进度
@property(nonatomic,strong)NLBottomOptionsView *optionsView;         //选项View
@property(nonatomic,strong)NSURL *outputFileURL;                     //视频输出路径
@property(nonatomic,strong)NLSettingView *setView;                   //设置界面
@property(nonatomic,assign)NSInteger flag;



@end

@implementation NLWriterVideoRecordViewController

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
    self.flag = 0;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self checkPhotoStatus];
    
}
//准备录制
-(void)readyRecordVideo{
    [[NLWriterVideoRecordManager shareVideoRecordManager] configVideoParamsWithRecordParam:self.param];
    [[NLWriterVideoRecordManager shareVideoRecordManager] startSessionRunning];
    [NLWriterVideoRecordManager shareVideoRecordManager].vcDelegate = self;
}

//MARK:ConfigureView
-(void)configureView{
    //预览View
    CGRect rect = CGRectZero;
    switch (self.param.ratio) {
        case NLVideoVideoRatio1To1:
            rect = CGRectMake(0, 0, kScreenW, kScreenW);
            break;
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
    if (self.param.isFilter) {
        self.filterView = [[NLFilterPreviewView alloc]initWithFrame:rect];
        [self.view addSubview:self.filterView];
    }else{
        self.previewView = [[NLVideoPreviewView alloc]initWithFrame:rect Session:[NLWriterVideoRecordManager shareVideoRecordManager].session];
        [self.view addSubview:self.previewView];
    }
    
    self.topView = [[NLTopOptionsView alloc]initWithFrame:CGRectMake(0, SAFEAREA_TOP_HEIGH-STATUS_HEIGHT/2, kScreenW, 40)];
    [self.topView.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.cameraBtn addTarget:self action:@selector(turnCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.lightBtn addTarget:self action:@selector(light:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topView];
    
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
-(NLSettingView *)setView{
    if (_setView == nil) {
        _setView = [[NLSettingView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH) SuperVC:self];
    }
    return _setView;
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
    [[NLWriterVideoRecordManager shareVideoRecordManager] turnCamera];
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
        [[NLWriterVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeOn];
        
    }else if ([state isEqualToString:@"record_light_on"]){
        objc_setAssociatedObject(sender, "light_state", @"record_light_auto", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage imageNamed:@"record_light_auto"] forState:UIControlStateNormal];
        [[NLWriterVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeAuto];
        
    }else{
        objc_setAssociatedObject(sender, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sender setImage:[UIImage imageNamed:@"record_light_off"] forState:UIControlStateNormal];
        [[NLWriterVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeOff];
    }
}
//录制
-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self updateViewWithOptionsViewHidden:YES];
        [[NLWriterVideoRecordManager shareVideoRecordManager] startRecord];
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        [self updateViewWithOptionsViewHidden:NO];
        [[NLWriterVideoRecordManager shareVideoRecordManager] stopRecord];
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
    [[NLWriterVideoRecordManager shareVideoRecordManager] stopRecord];
    [[NLWriterVideoRecordManager shareVideoRecordManager] removeOutputAndInput];
    
    objc_setAssociatedObject(self.topView.lightBtn, "light_state", @"record_light_off", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.topView.lightBtn setImage:[UIImage imageNamed:@"record_light_off"] forState:UIControlStateNormal];
    [[NLWriterVideoRecordManager shareVideoRecordManager]changeLightWithState:AVCaptureTorchModeOff];
}
//MARK:NLWriterVideoRecordManagerDelegate
-(void)recordFinishedWithOutputFileURL:(NSURL *)fileURL RecordTime:(CGFloat)recordTime{
    if (recordTime < self.param.minTime) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"录制时长少于%fS,请重新录制!",self.param.minTime] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self cancleClick];
        }];
        [alter addAction:action];
        [self presentViewController:alter animated:YES completion:nil];
    }
    self.outputFileURL = fileURL;
    
}
//更新时间状态
-(void)reloadRecordTime:(CGFloat)time{
    self.timeView.hidden = time>0 ? NO:YES;
    self.timeView.timeLab.text = [NSString stringWithFormat:@"%02ld秒",(long)floorf(time)];
    [self.progressView updateProgressWithValue:time/self.param.maxTime];
}
//闪光灯隐藏与否
-(void)lightIsHidden:(BOOL)isHidden{
    self.topView.lightBtn.hidden = isHidden;
}
//滤镜
-(CVPixelBufferRef)showView:(CMSampleBufferRef)sampleBuffer{
    return [self.filterView showView:sampleBuffer];
}
//MARK:NLBottomOptionsViewDelegate
-(void)selectedClick{
    //保存视频
    [[NLWriterVideoRecordManager shareVideoRecordManager]saveVideo];
    
    [self updateViewWithOptionsViewHidden:YES];
    [self reloadRecordTime:0];
    [self close];
    
}
-(void)previewClick{
    NLVideoPreviewViewController *page = [NLVideoPreviewViewController new];
    page.fileURL = self.outputFileURL;
    [self presentViewController:page animated:YES completion:nil];
}

-(void)cancleClick{
    [self updateViewWithOptionsViewHidden:YES];
    [self reloadRecordTime:0];
    [[NLWriterVideoRecordManager shareVideoRecordManager] startSessionRunning];
}

//麦克风状态
-(BOOL)checkAudioStatus{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        if (self.flag == 0) {
            UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"无法使用麦克风" message:@"您未开启麦克风,录制视频将没有声音" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
                [self close];
                self.flag = 0;
            }];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                self.flag = 0;
            }];
            
            [alter addAction:action];
            [alter addAction:action1];
            [self showViewController:alter sender:nil];
        }
        return NO;
    }else{
        return YES;
    }
}

//相机状态
-(void)checkPhotoStatus{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined){
        [self.view addSubview:self.setView];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self checkPhotoStatus];
                });
            }
        }];
    }else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [self.view addSubview:self.setView];
    }else{
        [self.setView removeFromSuperview];
        [self configureView];
        [self readyRecordVideo];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkAudioStatus];
        });
    }
}

@end
