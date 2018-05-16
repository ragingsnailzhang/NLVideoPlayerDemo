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
#import "NLVideoPlayer.h"

typedef NS_ENUM(NSInteger,CompressionQuality) {
    lowQuality = 1,
    mediumQuality,
    highestQuality,
};


@protocol NLVideoRecordManagerVCDelegate <NSObject>
//录制完成
-(void)recordFinishedWithOutputFilePath:(NSURL *)filePath RecordTime:(CGFloat)recordTime;
//录制时间
-(void)reloadRecordTime:(CGFloat)time;
//隐藏闪光灯
-(void)lightIsHidden:(BOOL)isHidden;

@end

@protocol NLVideoRecordManagerDelegate <NSObject>
//获取视频数据流
-(void)getVideoData:(NSData *)outputData URL:(NSURL *)outputURL;
//录制时间
-(void)getRecordTime:(CGFloat)time;
//录制封面
-(void)getRecordVideoCoverURL:(NSURL *)coverURL Image:(UIImage *)coverImage;

@end

@interface NLVideoRecordManager : NSObject

@property(nonatomic,strong)AVCaptureSession *session;

@property(nonatomic,weak)id <NLVideoRecordManagerVCDelegate>vcDelegate;

@property(nonatomic,weak)id <NLVideoRecordManagerDelegate>delegate;

+(NLVideoRecordManager *)shareVideoRecordManager;

+(UIViewController *)createRecordViewControllerWithRecordParam:(NLRecordParam *)param;

//配置参数
-(void)configVideoParamsWithRecordParam:(NLRecordParam *)param;
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
//保存视频
-(void)saveVideo;

@end
