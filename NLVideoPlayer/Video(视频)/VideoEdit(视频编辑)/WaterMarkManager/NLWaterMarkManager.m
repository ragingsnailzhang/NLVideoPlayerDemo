//
//  NLWaterMarkManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/11.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLWaterMarkManager.h"

@implementation NLWaterMarkManager
static NLWaterMarkManager *manager = nil;
+(NLWaterMarkManager *)shareWaterMarkManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NLWaterMarkManager alloc]init];
    });
    return manager;
}


-(AVAssetExportSession *)addWaterMarkWithTitle:(NSString *)waterMarkStr FilePath:(NSURL *)filePath PresetName:(NSString *)presetName{
    if (!filePath || !presetName) {
        return nil;
    }
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(YES) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    //初始化视频文件
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:filePath options:opts];
    
    CMTime startTime = CMTimeMakeWithSeconds(0.2f, 600);
    CMTime endTime = CMTimeMakeWithSeconds(videoAsset.duration.value/videoAsset.duration.timescale-0.2,videoAsset.duration.timescale);
    
    //声音采集
    AVURLAsset *audioAsset = [[AVURLAsset alloc]initWithURL:filePath options:opts];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc]init];
    //视频通道
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeFromTimeToTime(startTime, endTime) ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
    
    //音频通道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:CMTimeRangeFromTimeToTime(startTime, endTime) ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero, videoTrack.timeRange.duration);
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    BOOL isVideoPortrait = NO;
    CGAffineTransform videoTransform = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1 && videoTransform.c == -1 && videoTransform.d == 0) {
        isVideoPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1 && videoTransform.c == 1 && videoTransform.d == 0) {
        isVideoPortrait = YES;
    }
    [videoLayerInstruction setTransform:videoTransform atTime:kCMTimeZero];
    [videoLayerInstruction setOpacity:0.f atTime:endTime];
    
    mainInstruction.layerInstructions = @[videoLayerInstruction];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if (isVideoPortrait) {
        naturalSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
    }else{
        naturalSize = videoTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    videoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    videoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    videoComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    videoComposition.frameDuration = CMTimeMake(1, 25);
    
    [self applyVideoEffectsToComposition:videoComposition WaterMark:waterMarkStr size:CGSizeMake(renderWidth, renderHeight)];
    
    // 5 - 视频文件输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];
    NSString *exportFileName = [filePath.absoluteString componentsSeparatedByString:@"/"].lastObject;
    NSString *folderPath = [NLFileManager folderPathWithName:VIDEO_FOLDER Path:[NLFileManager documentPath]];
    NSURL *fileURL = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"edit_%@",exportFileName]]];
    exporter.outputURL = fileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComposition;
    return exporter;

}

-(void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition WaterMark:(NSString*)waterMark size:(CGSize)size {
    UIFont *font = [UIFont systemFontOfSize:60.0];
    CATextLayer *subtitleText = [[CATextLayer alloc] init];
    [subtitleText setFontSize:60];
    [subtitleText setString:waterMark];
    [subtitleText setAlignmentMode:kCAAlignmentCenter];
    [subtitleText setForegroundColor:[[UIColor whiteColor] CGColor]];
    subtitleText.masksToBounds = YES;
    subtitleText.cornerRadius = 10.0f;
//    [subtitleText setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor];
    CGSize textSize = [waterMark sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    [subtitleText setFrame:CGRectMake(50, 100, textSize.width+20, textSize.height+10)];

    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer addSublayer:subtitleText];
    [overlayLayer setMasksToBounds:YES];

    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:overlayLayer];

    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:overlayLayer inLayer:parentLayer];
}

@end
