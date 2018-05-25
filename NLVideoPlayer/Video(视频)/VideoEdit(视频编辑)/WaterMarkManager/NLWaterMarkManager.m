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
    
    //视频采集
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:filePath options:opts];
    
    //声音采集
    AVURLAsset * audioAsset = [[AVURLAsset alloc] initWithURL:filePath options:opts];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //音频通道
    AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime startTime = kCMTimeZero;
    CMTime endTime = CMTimeMakeWithSeconds(videoAsset.duration.value/videoAsset.duration.timescale-0.4, videoAsset.duration.timescale);
    //把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    [videoTrack insertTimeRange:CMTimeRangeMake(startTime, endTime) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    //音频采集通道
    AVAssetTrack * audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack insertTimeRange:CMTimeRangeMake(startTime, endTime) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    //AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    
    //AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait_ = YES;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:endTime];
    //Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    //AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    }
    mainCompositionInst.renderSize = naturalSize;
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 25);
    
    [self applyVideoEffectsToComposition:mainCompositionInst WaterMark:waterMarkStr size:naturalSize];
    
    // 5 - 视频文件输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];

    NSString *exportFileName = [filePath.absoluteString componentsSeparatedByString:@"/"].lastObject;
    NSString *folderPath = [NLFileManager folderPathWithName:VIDEO_FOLDER Path:[NLFileManager documentPath]];
    NSURL *fileURL = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"edit_%@",exportFileName]]];
    exporter.outputURL = fileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    return exporter;

}

-(void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition WaterMark:(NSString*)waterMark size:(CGSize)size {
    
    CGFloat rate = (CGFloat)size.height/kScreenH;
    CGFloat fontSize = 20.0*rate;
    CATextLayer *subtitleText = [[CATextLayer alloc] init];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    [subtitleText setFontSize:fontSize];
    [subtitleText setString:waterMark];
    [subtitleText setAlignmentMode:kCAAlignmentLeft];
    [subtitleText setForegroundColor:[[UIColor whiteColor] CGColor]];
    CGSize textSize = [waterMark sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    [subtitleText setFrame:CGRectMake(20*rate, 20*rate, textSize.width+rate*5, textSize.height)];
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
