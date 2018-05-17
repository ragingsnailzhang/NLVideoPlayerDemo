//
//  NLRecordParam.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLRecordParam.h"

@implementation NLRecordParam

+(instancetype)recordConfigWithVideoRatio:(NLVideoRatio)ratio Position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime Compression:(BOOL)isCompression CurrentVC:(UIViewController *)currentVC{
    return [self recordConfigWithVideoRatio:ratio Position:position maxRecordTime:maxTime minRecordTime:minTime Compression:isCompression WaterMark:nil CurrentVC:currentVC];
}

+(instancetype)recordConfigWithVideoRatio:(NLVideoRatio)ratio Position:(AVCaptureDevicePosition)position maxRecordTime:(CGFloat)maxTime minRecordTime:(CGFloat)minTime Compression:(BOOL)isCompression WaterMark:(NSString *)waterMark CurrentVC:(UIViewController *)currentVC{
    NLRecordParam *params = [[NLRecordParam alloc]init];
    params.ratio = ratio;
    params.position = position;
    params.maxTime = maxTime;
    params.minTime = minTime;
    params.isCompression = isCompression;
    params.waterMark = waterMark;
    params.currentVC = currentVC;
    return params;
}

@end
