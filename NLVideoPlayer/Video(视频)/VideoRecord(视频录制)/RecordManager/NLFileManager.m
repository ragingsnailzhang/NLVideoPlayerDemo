//
//  NLFileManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLFileManager.h"
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



@end
