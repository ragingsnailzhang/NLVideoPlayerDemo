//
//  NLVideoPreviewView.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface NLVideoPreviewView : UIView

-(instancetype)initWithFrame:(CGRect)frame Session:(AVCaptureSession *)session;

@end
