//
//  NLFileManager.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Photos/Photos.h>

@interface NLFileManager : NSObject
//document路径
+(NSString *)documentPath;
//caches路径
+(NSString *)cachesPath;
//文件夹路径
+(NSString *)folderPathWithName:(NSString *)folderName Path:(NSString *)path;
//计算压缩大小
+(CGFloat)fileSize:(NSURL *)path;
//清除缓存
+(void)clearMemoryFile;
//取得视频封面
+(UIImage *)getThumbnailImage:(NSURL *)videoURL;
//取得视频封面路径
+(NSString *)getVideoCoverWithImage:(UIImage *)image AndName:(NSString *)imgName;
//获取视频时长
+(NSUInteger)durationWithVideo:(NSURL *)videoUrl;
//获得此目录下文件
+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

@end
