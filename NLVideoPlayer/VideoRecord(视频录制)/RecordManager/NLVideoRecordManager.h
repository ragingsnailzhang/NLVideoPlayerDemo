//
//  NLVideoRecordManager.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@protocol NLVideoRecordManagerDelegate <NSObject>
//录制完成
-(void)recordFinishedWithOutputFilePath:(NSURL *)filePath;
//录制时间
-(void)reloadRecordTime:(CGFloat)time;
//隐藏闪光灯
-(void)lightIsHidden:(BOOL)isHidden;

@end

@interface NLVideoRecordManager : NSObject

@property(nonatomic,strong)AVCaptureSession *session;

@property(nonatomic,weak)id <NLVideoRecordManagerDelegate>delegate;

+(NLVideoRecordManager *)shareVideoRecordManager;

//配置参数
-(void)configVideoParamsWithPosition:(AVCaptureDevicePosition)position Preset:(AVCaptureSessionPreset)preset maxRecordTime:(CGFloat)maxTime;
//开始画面采集
-(void)startSessionRunning;
//结束画面采集
-(void)stopSessionRunning;
//开始录制
-(void)startRecord;
//结束录制
-(void)stopRecord;
//切换摄像头
-(void)turnCamera;
//闪光灯
-(void)changeLightWithState:(AVCaptureTorchMode)state;
//清除输入源与输出源
-(void)removeOutputAndInput;

@end
