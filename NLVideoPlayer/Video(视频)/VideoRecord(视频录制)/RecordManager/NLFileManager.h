//
//  NLFileManager.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


@interface NLFileManager : NSObject

+(NSString *)documentPath;

+(NSString *)cachesPath;

+(NSString *)folderPathWithName:(NSString *)folderName Path:(NSString *)path;

//计算压缩大小
+(CGFloat)fileSize:(NSURL *)path;

@end
