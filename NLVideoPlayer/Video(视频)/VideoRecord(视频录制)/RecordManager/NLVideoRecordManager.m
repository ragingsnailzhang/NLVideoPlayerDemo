//
//  NLVideoRecordManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLVideoRecordManager.h"

@interface NLVideoRecordManager()<AVCaptureFileOutputRecordingDelegate>

@property(nonatomic,strong)AVCaptureConnection *captureConnection;
@property(nonatomic,strong)AVCaptureDeviceInput *videoInput;         //视频输入
@property(nonatomic,strong)AVCaptureDeviceInput *audioInput;         //音频输入
@property(nonatomic,strong)AVCaptureMovieFileOutput *fileOutput;     //文件输出
@property(nonatomic,strong)NSTimer *timer;                           //计时器
@property(nonatomic,assign)CGFloat time;                             //时间
@property(nonatomic,strong)UIView *inView;                           //当前界面
@property(nonatomic,strong)NLRecordParam *recordParam;
@property(nonatomic,strong)NSURL *outputPath;

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

+(UIViewController *)createRecordViewControllerWithRecordParam:(NLRecordParam *)param{
    NLVideoRecordViewController *page = [[NLVideoRecordViewController alloc]init];
    page.param = param;
    return page;
}

//MARK:配置参数
-(void)configVideoParamsWithRecordParam:(NLRecordParam *)param{
    //是否压缩视频质量
    self.recordParam = param;
    //设置分辨率
    AVCaptureSessionPreset preset = AVCaptureSessionPresetHigh;
    switch (self.recordParam.ratio) {
        case NLVideoVideoRatio4To3:
            preset = AVCaptureSessionPreset640x480;
            break;
        case NLVideoVideoRatio16To9:
            preset = AVCaptureSessionPreset1920x1080;
            break;
        case NLVideoVideoRatioFullScreen:
            preset = AVCaptureSessionPresetHigh;
            break;
        default:
            break;
    }
    
    [self setupSessionWithPreset:preset];
    
    [self.session beginConfiguration];
    //设置视频输入
    [self setupVideoInputParamsPosition:self.recordParam.position];
    //设置音频输入
    [self setupAudioInputParams];
    //设置输出源
    [self setupVideoOutputWithMaxTime:self.recordParam.maxTime minTime:self.recordParam.minTime];
    
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
    NSString *folderPath = [NLFileManager folderPathWithName:VIDEO_FOLDER Path:[NLFileManager documentPath]];
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
        
        if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(lightIsHidden:)]) {
            [self.vcDelegate lightIsHidden: position == AVCaptureDevicePositionBack ? NO : YES];
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
//保存视频
-(void)saveVideo{
    
    [self videoCompression:self.recordParam.isCompression Quality:mediumQuality CompletionHandler:^(NSURL *outputURL) {
        if (outputURL) {
            //保存录制到本地
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {NSLog(@"成功保存视频到相簿.");}
            }];
            
            NSData *data = [NSData dataWithContentsOfURL:outputURL];
            if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoData:URL:)]) {
                [self.delegate getVideoData:data URL:outputURL];
            }
            
            UIImage *cover = [NLFileManager getThumbnailImage:outputURL];
            NSString *localCoverPath = [NLFileManager getVideoCoverWithImage:cover AndName:[self.outputPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(getRecordVideoCoverURL:Image:)]) {
                [self.delegate getRecordVideoCoverURL:[NSURL URLWithString:localCoverPath] Image:cover];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoData:DataURL:CoverURL:Image:)]) {
                [self.delegate getVideoData:data DataURL:outputURL CoverURL:[NSURL URLWithString:localCoverPath] Image:cover];
            }
            
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoData:URL:)]) {
                [self.delegate getVideoData:nil URL:nil];
            }
        }
    }];
}

//视频压缩
-(void)videoCompression:(BOOL)isComorossion Quality:(CompressionQuality)quality CompletionHandler:(void (^)(NSURL *))handler{
    NSLog(@"before == %f M",[NLFileManager fileSize:self.outputPath]);
    AVAssetExportSession *exportSession = nil;
    NSString *presetName = AVAssetExportPresetMediumQuality;
    if (quality == lowQuality) {
        presetName = AVAssetExportPresetLowQuality;
    }else if (quality == mediumQuality){
        presetName = AVAssetExportPresetMediumQuality;
    }else if (quality == highestQuality){
        presetName = AVAssetExportPresetHighestQuality;
    }
    if (isComorossion) {//压缩
        if (![NSThread currentThread].isMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.recordParam.currentVC.view) {
                    self.inView = self.recordParam.currentVC.view;
                }else{
                    self.inView = [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.lastObject.view;
                }
                [NLLoadingView loadingViewWithTitle:@"正在压缩..." inView:self.inView];
            });
        }else{
            if (self.recordParam.currentVC.view) {
                self.inView = self.recordParam.currentVC.view;
            }else{
                self.inView = [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.lastObject.view;
            }
            [NLLoadingView loadingViewWithTitle:@"正在压缩..." inView:self.inView];
        }
        
        if (self.recordParam.waterMark) {//添加水印
            exportSession = [[NLWaterMarkManager shareWaterMarkManager]addWaterMarkWithTitle:self.recordParam.waterMark FilePath:self.outputPath PresetName:presetName];
        }else{
            AVAsset *asset = [AVAsset assetWithURL:self.outputPath];
            NSString *exportFileName = [self.outputPath.absoluteString componentsSeparatedByString:@"/"].lastObject;
            if ([[exportFileName lowercaseString]hasSuffix:@".mov"]) {
                exportFileName = [NSString stringWithFormat:@"%@.mp4",[[exportFileName lowercaseString] componentsSeparatedByString:@".mov"].firstObject];
            }
            exportSession = [[AVAssetExportSession alloc]initWithAsset:asset presetName:presetName];
            exportSession.shouldOptimizeForNetworkUse = YES;
            NSString *folderPath = [NLFileManager folderPathWithName:VIDEO_FOLDER Path:[NLFileManager documentPath]];
            NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"compression_%ld_%@",time(0),exportFileName]];
            exportSession.outputURL = [NSURL fileURLWithPath:filePath];
            exportSession.outputFileType = AVFileTypeMPEG4;
        }
        
    }else{
        if (self.recordParam.waterMark) {//添加水印
            exportSession = [[NLWaterMarkManager shareWaterMarkManager]addWaterMarkWithTitle:self.recordParam.waterMark FilePath:self.outputPath PresetName:AVAssetExportPresetHighestQuality];
        }else{
            if (handler) {
                handler(self.outputPath);
            }
        }
    }
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if ([NSThread currentThread].isMainThread) {
            for (UIView *view in self.inView.subviews) {
                if ([view isMemberOfClass:[NLLoadingView class]]) {
                    [(NLLoadingView *)view stopAnimating];
                    [view removeFromSuperview];
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                for (UIView *view in self.inView.subviews) {
                    if ([view isMemberOfClass:[NLLoadingView class]]) {
                        [(NLLoadingView *)view stopAnimating];
                        [view removeFromSuperview];
                    }
                }
            });
        }
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"AVAssetExportSessionStatusCompleted");
                NSLog(@"after == %f M",[NLFileManager fileSize:exportSession.outputURL]);
                if (handler) {
                    handler(exportSession.outputURL);
                }
                break;
            default:
                NSLog(@"AVAssetExportSessionStatusFailed");
                if (handler) {
                    handler(nil);
                }
                break;
        }
    }];

}

//视频压缩
-(void)videoCompressionURL:(NSURL *)videoURL CompletionHandler:(void (^)(NSURL *))handler{
    self.outputPath = videoURL;
    [self videoCompression:YES Quality:mediumQuality CompletionHandler:handler];
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
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(reloadRecordTime:)]) {
        [self.vcDelegate reloadRecordTime:self.time];
    }
}


//MARK:AVCaptureFileOutputRecordingDelegate
-(void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    self.time = 0.f;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timeAction) userInfo:nil repeats:YES];

}
-(void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    self.outputPath = outputFileURL;
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(recordFinishedWithOutputFilePath:RecordTime:)]) {
        [self.vcDelegate recordFinishedWithOutputFilePath:outputFileURL RecordTime:self.time];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(getRecordTime:)]) {
        [self.delegate getRecordTime:self.time];
    }
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
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

@end
