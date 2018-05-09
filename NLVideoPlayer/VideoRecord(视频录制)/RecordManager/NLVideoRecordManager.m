//
//  NLVideoRecordManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLVideoRecordManager.h"

@interface NLVideoRecordManager()<AVCaptureFileOutputRecordingDelegate>

@property(nonatomic,strong)AVCaptureDeviceInput *videoInput;         //视频输入
@property(nonatomic,strong)AVCaptureDeviceInput *audioInput;         //音频输入
@property(nonatomic,strong)AVCaptureMovieFileOutput *fileOutput;     //文件输出
@property(nonatomic,strong)NSTimer *timer;                           //计时器
@property(nonatomic,assign)CGFloat time;

@property(nonatomic,strong)AVCaptureConnection *captureConnection;

@end

@implementation NLVideoRecordManager

static NLVideoRecordManager *manager = nil;
+(NLVideoRecordManager *)shareVideoRecordManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NLVideoRecordManager alloc]init];
    });
    return manager;
}
//MARK:配置参数
-(void)configVideoParamsWithPosition:(AVCaptureDevicePosition)position Preset:(AVCaptureSessionPreset)preset maxRecordTime:(CGFloat)maxTime{
    //设置分辨率
    [self setupSessionWithPreset:preset];
    
    [self.session beginConfiguration];
    //设置视频输入
    [self setupVideoInputParamsPosition:position];
    //设置音频输入
    [self setupAudioInputParams];
    //设置输出源
    [self setupVideoOutputWithMaxTime:maxTime minTime:1];
    
    [self.session commitConfiguration];

}
//设置分辨率
-(void)setupSessionWithPreset:(AVCaptureSessionPreset)preset{
    if ([self.session canSetSessionPreset:preset]) {
        [self.session setSessionPreset:preset];
    }
}

//设置视频输入
-(void)setupVideoInputParamsPosition:(AVCaptureDevicePosition)position{
    AVCaptureDevice *videoDevice = [self getCameraWithPosition:position];
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:videoDevice error:nil];
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
}
//设置音频输入
-(void)setupAudioInputParams{
    AVCaptureDevice *audioDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
    self.audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioDevice error:nil];
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
}
//设置输出源
-(void)setupVideoOutputWithMaxTime:(CGFloat)maxTime minTime:(CGFloat)minTime{
    self.fileOutput = [[AVCaptureMovieFileOutput alloc]init];
    self.fileOutput.maxRecordedDuration = CMTimeMake(maxTime, 1);
    self.captureConnection = [self.fileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([self.captureConnection isVideoStabilizationSupported]) {//判断是否支持防抖
        self.captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    if ([self.session canAddOutput:self.fileOutput]) {
        [self.session addOutput:self.fileOutput];
    }
}
//获取视频输出路径
-(NSString *)getVideoOutputPath{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderPath = [docPath stringByAppendingPathComponent:@"videoFolder"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *videoPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video_%ld.mp4",time(0)]];
    return videoPath;
}
//MARK:Method
//开始画面采集
-(void)startSessionRunning{
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}
//结束画面采集
-(void)stopSessionRunning{
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
}
//开始录制
-(void)startRecord{
    [self startSessionRunning];
    if (!self.fileOutput.isRecording) {
        [self.fileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self getVideoOutputPath]] recordingDelegate:self];
    }
    
}
//结束录制
-(void)stopRecord{
    if (self.fileOutput.isRecording) {
        [self.fileOutput stopRecording];
    }
    [self stopSessionRunning];
}
//切换摄像头
-(void)turnCamera{
    if (self.session.isRunning) {
        [self.session stopRunning];
        AVCaptureDevicePosition position = self.videoInput.device.position;
        
        if (position == AVCaptureDevicePositionBack) {
            position = AVCaptureDevicePositionFront;
        }else if(position == AVCaptureDevicePositionFront){
            position = AVCaptureDevicePositionBack;
        }else{
            position = AVCaptureDevicePositionBack;
        }
        
        [self.session beginConfiguration];
        [self.session removeInput:self.videoInput];
        AVCaptureDevice *device = [self getCameraWithPosition:position];
        self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
        [self.session addInput:self.videoInput];
        [self.session commitConfiguration];
        
        [self.session startRunning];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(lightIsHidden:)]) {
            [self.delegate lightIsHidden: position == AVCaptureDevicePositionBack ? NO : YES];
        }
    }
}
//闪光灯
-(void)changeLightWithState:(AVCaptureTorchMode)state{
    if ([self.videoInput.device hasTorch]) {
        [self.videoInput.device lockForConfiguration:nil];
        [self.videoInput.device setTorchMode:state];
        [self.videoInput.device unlockForConfiguration];
    }
}
//清除输入源与输出源
-(void)removeOutputAndInput{
    [self.session removeOutput:self.fileOutput];
    [self.session removeInput:self.videoInput];
    [self.session removeInput:self.audioInput];
}

//MARK:lazyLoading
-(AVCaptureSession *)session{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc]init];
    }
    return _session;
}

//MARK:Action
-(void)timeAction{
    self.time = self.time + 0.1f;
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadRecordTime:)]) {
        [self.delegate reloadRecordTime:self.time];
    }
}
//MARK:私有方法
-(AVCaptureDevice *)getCameraWithPosition:(AVCaptureDevicePosition)position{//根据摄像头位置获取摄像机
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == position) {
            return camera;
        }
    }
    return nil;
}

//MARK:AVCaptureFileOutputRecordingDelegate
-(void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    self.time = 0.f;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timeAction) userInfo:nil repeats:YES];

}
-(void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    if (self.time >= 1.0f) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishedWithOutputFilePath:)]) {
            [self.delegate recordFinishedWithOutputFilePath:outputFileURL];
        }
    }else{
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示" message:@"录制时长少于1s" preferredStyle:UIAlertControllerStyleAlert];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alter animated:YES completion:nil];
    }
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


@end
