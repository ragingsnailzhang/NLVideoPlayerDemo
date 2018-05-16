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




@end
