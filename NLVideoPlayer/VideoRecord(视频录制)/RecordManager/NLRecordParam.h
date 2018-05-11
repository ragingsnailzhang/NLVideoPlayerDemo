//
//  NLRecordParam.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,NLVideoRatio){
    NLVideoVideoRatio4To3,         // 4:3
    NLVideoVideoRatio16To9,        // 16:9
    NLVideoVideoRatioFullScreen    // 全屏
};

@interface NLRecordParam : NSObject
//摄像头位置
@property(nonatomic,assign)AVCaptureDevicePosition position;
//最大时长
@property(nonatomic,assign)CGFloat maxTime;
//最小时长
@property(nonatomic,assign)CGFloat minTime;
//是否压缩
@property(nonatomic,assign)BOOL isCompression;
//视频比例
@property (nonatomic, assign)NLVideoRatio ratio;

+(instancetype)recordConfigWithVideoRatio:(NLVideoRatio)ratio Position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime Compression:(BOOL)isCompression;

@end
