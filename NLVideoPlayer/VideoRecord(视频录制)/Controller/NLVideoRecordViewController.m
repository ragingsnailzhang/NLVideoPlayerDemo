//
//  NLVideoRecordViewController.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLVideoRecordViewController.h"
#import "NLVideoPreviewView.h"
#import "NLVideoRecordManager.h"
#import "NLTimeView.h"
#import "NLProgressView.h"
#import "NLBottomOptionsView.h"
#import <objc/runtime.h>
#import "NLVideoPreviewViewController.h"

#define MAX_RECORD_TIME 10.f

@interface NLVideoRecordViewController ()<NLVideoRecordManagerDelegate,NLBottomOptionsViewDelegate>

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
    [[NLVideoRecordManager shareVideoRecordManager] configVideoParamsWithPosition:AVCaptureDevicePositionBack Preset:AVCaptureSessionPresetHigh maxRecordTime:MAX_RECORD_TIME];
    [[NLVideoRecordManager shareVideoRecordManager]startSessionRunning];
    [NLVideoRecordManager shareVideoRecordManager].delegate = self;
}

//MARK:ConfigureView
-(void)configureView{
    //预览View
    self.previewView = [[NLVideoPreviewView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.previewView];
    
    //关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (@available(iOS 11.0, *)) {
        self.closeBtn.frame = CGRectMake(MARGIN,SAFEAREA_TOP_HEIGH, 23, 23);
    } else {
        // Fallback on earlier versions
    }
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
-(void)recordFinishedWithOutputFilePath:(NSURL *)filePath{
    self.outputFilePath = filePath;
    //结束录制
    [self recordFinished];
}
//更新时间状态
-(void)reloadRecordTime:(CGFloat)time{
    self.timeView.hidden = time>0 ? NO:YES;
    self.timeView.timeLab.text = [NSString stringWithFormat:@"%02ld秒",(NSInteger)floorf(time)];
    [self.progressView updateProgressWithValue:time/MAX_RECORD_TIME];
}
-(void)lightIsHidden:(BOOL)isHidden{
    self.lightBtn.hidden = isHidden;
}
//MARK:NLBottomOptionsViewDelegate
-(void)selectedClick{
    //保存录制到本地
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.outputFilePath];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
        }else{
            NSLog(@"成功保存视频到相簿.");
        }
    }];
    
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
