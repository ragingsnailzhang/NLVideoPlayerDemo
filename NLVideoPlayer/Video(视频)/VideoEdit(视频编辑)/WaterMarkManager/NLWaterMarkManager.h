//
//  NLWaterMarkManager.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/11.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NLVideoPlayer.h"
#import <Photos/Photos.h>

@interface NLWaterMarkManager : NSObject

+(NLWaterMarkManager *)shareWaterMarkManager;

-(AVAssetExportSession *)addWaterMarkWithTitle:(NSString *)waterMarkStr FilePath:(NSURL *)filePath PresetName:(NSString *)presetName;

@end
