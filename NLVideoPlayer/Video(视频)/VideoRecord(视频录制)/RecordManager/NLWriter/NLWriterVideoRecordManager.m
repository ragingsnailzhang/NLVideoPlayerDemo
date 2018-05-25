//
//  NLWriterVideoRecordManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/22.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLWriterVideoRecordManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface NLWriterVideoRecordManager()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
//视频录制
@property(nonatomic,strong)NLRecordParam *recordParam;
@property(nonatomic,strong)dispatch_queue_t videoQueue;                     //录制子线程
@property(nonatomic,strong)AVCaptureVideoDataOutput *videoOutput;           //视频输出
@property(nonatomic,strong)AVCaptureAudioDataOutput *audioOutput;           //音频输出
@property(nonatomic,strong)AVCaptureDeviceInput *videoInput;                //视频输入
@property(nonatomic,strong)AVCaptureDeviceInput *audioInput;                //音频输入

//视频写入
@property(nonatomic,strong)dispatch_queue_t writeQueue;                     //写入子线程
@property(nonatomic,assign)CGSize outputSize;                               //视频大小
@property(nonatomic,strong)AVAssetWriter *assetWriter;                      //写入管理
@property(nonatomic,strong)AVAssetWriterInput *assetWriterVideoInput;       //视频写入
@property(nonatomic,strong)AVAssetWriterInput *assetWriterAudioInput;       //音频写入
@property(nonatomic,assign)CMTime startTime;                                //视频起始时间

@property(nonatomic,strong)NSURL *outputURL;                                //输出路径
@property(nonatomic,strong)NSTimer *timer;                                  //计时器
@property(nonatomic,assign)CGFloat time;                                    //时间
@property(nonatomic,strong)UIView *inView;                                  //当前界面

@property(nonatomic,assign)BOOL readyToRecordVideo;
@property(nonatomic,assign)BOOL readyToRecordAudio;
@property(nonatomic,assign)BOOL isRecording;

@end

@implementation NLWriterVideoRecordManager

static NLWriterVideoRecordManager *manager = nil;
+(NLWriterVideoRecordManager *)shareVideoRecordManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NLWriterVideoRecordManager alloc]init];
    });
    return manager;
}

+(UIViewController *)createRecordViewControllerWithRecordParam:(NLRecordParam *)param{
    NLWriterVideoRecordViewController *page = [[NLWriterVideoRecordViewController alloc]init];
    page.param = param;
    return page;
}

-(void)initDataParam:(NLRecordParam *)param{
    self.recordParam = param;
    self.writeQueue = dispatch_queue_create("writeQueue", DISPATCH_QUEUE_SERIAL);
    self.videoQueue = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL);
    self.readyToRecordAudio = NO;
    self.readyToRecordVideo = NO;
    self.isRecording = NO;
}
//MARK:配置参数
-(void)configVideoParamsWithRecordParam:(NLRecordParam *)param{
    
    [self initDataParam:param];
    
    [self setupSessionWithPreset:AVCaptureSessionPresetHigh];
    
    [self.session beginConfiguration];
    //设置视频输入/输出
    [self setupVideoInputAndOutputParamsPosition:self.recordParam.position];
    //设置音频输入/输出
    [self setupAudioInputAndOutputParams];
    
    [self.session commitConfiguration];
    
}

//设置分辨率
-(void)setupSessionWithPreset:(AVCaptureSessionPreset)preset{
    if ([self.session canSetSessionPreset:preset]) {
        [self.session setSessionPreset:preset];
    }
}

//设置视频输入/输出
-(void)setupVideoInputAndOutputParamsPosition:(AVCaptureDevicePosition)position{
    AVCaptureDevice *videoDevice = [self getCameraWithPosition:position];
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:videoDevice error:nil];
    if (self.videoInput) {
        if ([self.session canAddInput:self.videoInput]) {
            [self.session addInput:self.videoInput];
        }
    }
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    //立即丢弃旧帧,节省内存
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [self.videoOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    
    AVCaptureConnection *captureConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if ([captureConnection isVideoStabilizationSupported]) {//判断是否支持防抖
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }

}
//设置音频输入/输出
-(void)setupAudioInputAndOutputParams{
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioDevice error:nil];
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
    
    self.audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    [self.audioOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.session canAddOutput:self.audioOutput]) {
        [self.session addOutput:self.audioOutput];
    }
}

// 音频源数据写入配置
- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription{
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    
    NSData *currentChannelLayoutData = nil;
    if (currentChannelLayout && aclSize > 0){
        currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    } else {
        currentChannelLayoutData = [NSData data];
    }
    NSDictionary *audioCompressionSettings = @{AVFormatIDKey: [NSNumber numberWithInteger: kAudioFormatMPEG4AAC],
                                               AVSampleRateKey: [NSNumber numberWithFloat: currentASBD->mSampleRate],
                                               AVEncoderBitRatePerChannelKey: [NSNumber numberWithInt: 64000],
                                               AVNumberOfChannelsKey: [NSNumber numberWithInteger: currentASBD->mChannelsPerFrame],
                                               AVChannelLayoutKey: currentChannelLayoutData};
//   NSDictionary *audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
//                                               AVFormatIDKey : @(kAudioFormatMPEG4AAC),
//                                               AVNumberOfChannelsKey : @(1),
//                                               AVSampleRateKey : @(22050) };
    
    if ([self.assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType: AVMediaTypeAudio]){
        self.assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings:audioCompressionSettings];
        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]){
            [self.assetWriter addInput:self.assetWriterAudioInput];
        }else {
            return NO;
        }
    } else {
        return NO;
    }
    return YES;
}

-(CGSize)getVideoOutputSize:(CMFormatDescriptionRef)currentFormatDescription{
    CGSize outputSize;
    NSInteger width = kScreenW;
    NSInteger height = kScreenH;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    width = dimensions.width;
    height = dimensions.height;
    switch (self.recordParam.ratio) {
        case NLVideoVideoRatio1To1:
            outputSize = CGSizeMake(width, width);
            break;
        case NLVideoVideoRatio4To3:
            outputSize = CGSizeMake(width, width*4/3);
            break;
        case NLVideoVideoRatio16To9:
            outputSize = CGSizeMake(width, width*16/9);
            break;
        case NLVideoVideoRatioFullScreen:
            outputSize = CGSizeMake(width, height);
            break;
        default:
            outputSize = CGSizeMake(width, height);
            break;
    }
    return outputSize;
}

// 视频源数据写入配置
- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription{
    
    self.outputSize = [self getVideoOutputSize:currentFormatDescription];
    NSInteger width = self.outputSize.width;
    NSInteger height = self.outputSize.height;
    NSUInteger numPixels = width * height;
    CGFloat bitsPerPixel = 6.f;
    NSUInteger bitsPerSecond = numPixels * bitsPerPixel;
    NSDictionary *videoCompressionSettings = @{AVVideoCodecKey:AVVideoCodecH264,
                                               AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                               AVVideoWidthKey:@(width),
                                               AVVideoHeightKey:@(height),
//                                               AVVideoWidthKey:[NSNumber numberWithInteger:dimensions.width],
//                                               AVVideoHeightKey:[NSNumber numberWithInteger:dimensions.height],
                                               AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:bitsPerSecond],
                                                                                 AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:30],
                                                                                 AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel}
                                               };
    if ([self.assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]){
        self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;

        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]){
            [self.assetWriter addInput:self.assetWriterVideoInput];
        }else {
            return NO;
        }
    } else {
        return NO;
    }
    return YES;
}
- (BOOL)inputsReadyToRecord{
    return _readyToRecordVideo && _readyToRecordAudio;
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
    dispatch_async(self.writeQueue, ^{
        if (!self.assetWriter) {
            self.outputURL = [NSURL fileURLWithPath:[self getVideoOutputPath]];
            self.assetWriter = [[AVAssetWriter alloc]initWithURL:self.outputURL fileType:AVFileTypeMPEG4 error:nil];
        }
        self.isRecording = YES;
    });
    
    self.time = 0.f;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    
}
//结束录制
-(void)stopRecord{
    self.isRecording = NO;
    [self stopSessionRunning];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    __weak __typeof(self)weakSelf = self;
    if(self.assetWriter && self.assetWriter.status == AVAssetWriterStatusWriting){
        dispatch_async(self.writeQueue, ^{
            [weakSelf.assetWriter finishWritingWithCompletionHandler:^{
                switch (weakSelf.assetWriter.status){
                    case AVAssetWriterStatusCompleted:{
                        weakSelf.readyToRecordVideo = NO;
                        weakSelf.readyToRecordAudio = NO;
                        weakSelf.assetWriter = nil;
                        if (weakSelf.vcDelegate && [weakSelf.vcDelegate respondsToSelector:@selector(recordFinishedWithOutputFileURL:RecordTime:)]) {
                            [weakSelf.vcDelegate recordFinishedWithOutputFileURL:weakSelf.outputURL RecordTime:weakSelf.time];
                        }
                        break;
                    }
                    case AVAssetWriterStatusFailed:{
                        break;
                    }
                    default:
                        break;
                }
            }];
        });
    }
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
        [self.session removeOutput:self.videoOutput];
        [self setupVideoInputAndOutputParamsPosition:position];
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
    [self.session removeOutput:self.videoOutput];
    [self.session removeOutput:self.audioOutput];
    [self.session removeInput:self.videoInput];
    [self.session removeInput:self.audioInput];
}
//保存视频
-(void)saveVideo{
    
    [self videoCompression:self.recordParam.isCompression Quality:mediumQuality CompletionHandler:^(NSURL *url) {
        //保存录制到本地
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) return ;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *videoRequest = [PHAssetCreationRequest creationRequestForAsset];
                [videoRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:url options:nil];
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                if (success) {NSLog(@"成功保存视频到相簿.");}
            }];
        }];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoData:URL:)]) {
            [self.delegate getVideoData:data URL:url];
        }
        
        UIImage *cover = [NLFileManager getThumbnailImage:url];
        NSString *localCoverPath = [NLFileManager getVideoCoverWithImage:cover AndName:[url.absoluteString componentsSeparatedByString:@"/"].lastObject];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(getRecordVideoCoverURL:Image:)]) {
            [self.delegate getRecordVideoCoverURL:[NSURL URLWithString:localCoverPath] Image:cover];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoData:DataURL:CoverURL:Image:)]) {
            [self.delegate getVideoData:data DataURL:url CoverURL:[NSURL URLWithString:localCoverPath] Image:cover];
        }
    }];
    
}
//视频压缩
-(void)videoCompressionURL:(NSURL *)videoURL CompletionHandler:(void (^)(NSURL *))handler{
    self.outputURL = videoURL;
    [self videoCompression:YES Quality:mediumQuality CompletionHandler:handler];
}
//视频压缩
-(void)videoCompression:(BOOL)isComorossion Quality:(CompressionQuality)quality CompletionHandler:(void (^)(NSURL *))handler{
    NSLog(@"before == %f M",[NLFileManager fileSize:self.outputURL]);
    AVAssetExportSession *exportSession = nil;
    NSString *presetName = AVAssetExportPresetMediumQuality;
    if (quality == lowQuality) {
        presetName = AVAssetExportPresetLowQuality;
    }else if (quality == mediumQuality){
        presetName = AVAssetExportPresetMediumQuality;
    }else if (quality == highestQuality){
        presetName = AVAssetExportPresetHighestQuality;
    }
    
    if (self.recordParam.currentVC.view) {
        self.inView = self.recordParam.currentVC.view;
    }else{
        self.inView = [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.lastObject.view;
    }
    if (![NSThread currentThread].isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NLLoadingView loadingViewWithTitle:@"正在处理视频..." inView:self.inView];
        });
    }else{
        [NLLoadingView loadingViewWithTitle:@"正在处理视频..." inView:self.inView];
    }
    
    if (isComorossion) {//压缩
        if (self.recordParam.waterMark) {//添加水印
            exportSession = [[NLWaterMarkManager shareWaterMarkManager]addWaterMarkWithTitle:self.recordParam.waterMark FilePath:self.outputURL PresetName:presetName];
        }else{
            AVAsset *asset = [AVAsset assetWithURL:self.outputURL];
            NSString *exportFileName = [self.outputURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
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
            exportSession = [[NLWaterMarkManager shareWaterMarkManager]addWaterMarkWithTitle:self.recordParam.waterMark FilePath:self.outputURL PresetName:AVAssetExportPresetHighestQuality];
        }else{
            if (handler) {
                handler(self.outputURL);
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

//MARK:lazyLoading
-(AVCaptureSession *)session{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc]init];
    }
    return _session;
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
//获取视频输出路径
-(NSString *)getVideoOutputPath{
    NSString *folderPath = [NLFileManager folderPathWithName:VIDEO_FOLDER Path:[NLFileManager documentPath]];
    NSString *videoPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video_%ld.mp4",time(0)]];
    return videoPath;
}

//MARK:Action
-(void)timeAction{
    
    if (self.time >= self.recordParam.maxTime) {
        [self stopRecord];
    }
    self.time = self.time + 0.1f;
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(reloadRecordTime:)]) {
        [self.vcDelegate reloadRecordTime:self.time];
    }
}

//MARK:AVCaptureDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (self.isRecording) {
        CFRetain(sampleBuffer);
        dispatch_async(self.writeQueue, ^{
            if (self.assetWriter) {
                //视频
                if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
                    if (!self.readyToRecordVideo){
                        self.readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    if ([self inputsReadyToRecord]){
                        [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
                    }
                    
                }
                
                //音频
                if (connection == [self.audioOutput connectionWithMediaType:AVMediaTypeAudio]) {
                    if (!self.readyToRecordAudio){
                        self.readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    if ([self inputsReadyToRecord]){
                        [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
                    }
                }
            }
            CFRelease(sampleBuffer);
        });
    }
    
    
    
}
//开始写入数据
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType{
    if (sampleBuffer == NULL){
        NSLog(@"empty sampleBuffer");
        return;
    }
    if (self.assetWriter.status == AVAssetWriterStatusUnknown){
        if ([self.assetWriter startWriting]){
            [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
    }
    if(self.assetWriter.status == AVAssetWriterStatusWriting){
        //写入视频数据
        if (mediaType == AVMediaTypeVideo) {
            if (self.assetWriterVideoInput.readyForMoreMediaData) {
                BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                if (!success) {
                    @synchronized (self) {
                        [self stopRecord];
                    }
                }
            }
        }
        
        //写入音频数据
        if (mediaType == AVMediaTypeAudio) {
            if (self.assetWriterAudioInput.readyForMoreMediaData) {
                BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                if (!success) {
                    @synchronized (self) {
                        [self stopRecord];
                    }
                }
            }
        }
    }
}

@end
