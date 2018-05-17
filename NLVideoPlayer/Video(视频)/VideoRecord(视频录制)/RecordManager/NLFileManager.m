//
//  NLFileManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLFileManager.h"
#import "NLConfigure.h"
@implementation NLFileManager

+(NSString *)documentPath{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return docPath;
}

+(NSString *)cachesPath{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return cachePath;
}

+(NSString *)folderPathWithName:(NSString *)folderName Path:(NSString *)path{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folderPath = [path stringByAppendingPathComponent:folderName];
    if (![manager isExecutableFileAtPath:folderPath]) {
        [manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folderPath;
}

+(CGFloat)fileSize:(NSURL *)path{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}

+(void)clearMemoryFile{
    NSArray *subFiles = [self listFilesInDirectoryAtPath:[self documentPath] deep:NO];
    BOOL isSuccess = YES;
    
    for (NSString *file in subFiles) {
        NSString *absolutePath = [[self documentPath] stringByAppendingPathComponent:file];
        isSuccess = [[NSFileManager defaultManager]removeItemAtPath:absolutePath error:nil];
    }
}

#pragma mark - 遍历文件夹
+ (NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *listArr;
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (deep) {
        // 深遍历
        NSArray *deepArr = [manager subpathsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = deepArr;
        }else {
            listArr = nil;
        }
    }else {
        // 浅遍历
        NSArray *shallowArr = [manager contentsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = shallowArr;
        }else {
            listArr = nil;
        }
    }
    return listArr;
}

//取得视频封面
+(UIImage *)getThumbnailImage:(NSURL *)videoURL{
    if (videoURL) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        // 设定缩略图的方向
        // 如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的
        gen.appliesPreferredTrackTransform = YES;
        // 设置图片的最大size(分辨率)
        //        gen.maximumSize = CGSizeMake(300, 169);
        CMTime time = CMTimeMakeWithSeconds(0.5, 600); //取第1秒，一秒钟600帧
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (error) {
            UIImage *placeHoldImg = [UIImage imageNamed:@"posters_default_horizontal"];
            return placeHoldImg;
        }
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return thumb;
    } else {
        UIImage *placeHoldImg = [UIImage imageNamed:@"posters_default_horizontal"];
        return placeHoldImg;
    }
}
//取得视频封面路径
+(NSString *)getVideoCoverWithImage:(UIImage *)image AndName:(NSString *)imgName{
    
    NSString *path_document = [self documentPath];
    //设置图片的存储路径
    NSString *imagePath = [[self folderPathWithName:VIDEO_FOLDER Path:path_document] stringByAppendingPathComponent:[NSString stringWithFormat:@"cover_%@.png",[[imgName lowercaseString] componentsSeparatedByString:@".mp4"].firstObject]];
    //把图片直接保存到指定的路径
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    return imagePath;
}
//获取视频时长
+(NSUInteger)durationWithVideo:(NSURL *)videoUrl{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoUrl options:opts]; // 初始化视频媒体文件
    NSUInteger second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    return second;
}





@end
