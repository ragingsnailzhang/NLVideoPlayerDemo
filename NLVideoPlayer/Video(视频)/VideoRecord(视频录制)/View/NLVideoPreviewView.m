//
//  NLVideoPreviewView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import "NLVideoPlayer.h"
#import "NLWriterVideoRecordManager.h"
@interface NLVideoPreviewView()

@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation NLVideoPreviewView

-(instancetype)initWithFrame:(CGRect)frame Session:(AVCaptureSession *)session{
    
    if (self = [super initWithFrame:frame]){
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = frame;
        [self.layer insertSublayer:self.previewLayer above:0];
    }
    return self;
}




@end
