//
//  NLFilterPreviewView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/28.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface NLFilterPreviewView : UIView

-(CVPixelBufferRef)showView:(CMSampleBufferRef)sampleBuffer;


@end
