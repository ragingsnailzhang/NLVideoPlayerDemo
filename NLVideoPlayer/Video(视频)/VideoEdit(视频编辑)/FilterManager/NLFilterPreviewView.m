//
//  NLFilterPreviewView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/28.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLFilterPreviewView.h"
#import <GLKit/GLKit.h>
@interface NLFilterPreviewView()

@property(nonatomic,strong) GLKView *videoPreviewView;
@property(nonatomic,strong) CIContext *ciContext;
@property(nonatomic,strong) EAGLContext *eaglContext;
@property(nonatomic,assign) CGRect videoPreviewViewBounds;
@property(nonatomic,strong) NSArray *fiterENArray;
@property(nonatomic,strong) NSArray *fiterCNArray;
@property(nonatomic,strong) NSString *currentFilterName;
@property(nonatomic,strong) UILabel *filterNameLab;
@end

@implementation NLFilterPreviewView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.fiterENArray = @[@"NONE",@"CIPhotoEffectInstant",@"CIPhotoEffectMono",@"CIPhotoEffectNoir",@"CIPhotoEffectFade",@"CIPhotoEffectTonal",@"CIPhotoEffectProcess",@"CIPhotoEffectTransfer",@"CIPhotoEffectChrome"];
        self.fiterCNArray = @[@"无",@"怀旧",@"单色",@"黑白",@"褪色",@"色调",@"冲印",@"岁月",@"铬黄"];
        self.currentFilterName = self.fiterENArray.firstObject;
        [self layoutViews];
    }
    return self;
}

-(void)layoutViews{
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // create the CIContext instance, note that this must be done after _videoPreviewView is properly set up
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    _videoPreviewView = [[GLKView alloc] initWithFrame:self.bounds context:_eaglContext];
    _videoPreviewView.enableSetNeedsDisplay = NO;
    _videoPreviewView.frame = self.bounds;
    [self addSubview:_videoPreviewView];
    [_videoPreviewView bindDrawable];
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = _videoPreviewView.drawableHeight;
    
    self.filterNameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.frame.size.height-50)/2, self.frame.size.width, 50)];
    self.filterNameLab.textAlignment = NSTextAlignmentCenter;
    self.filterNameLab.textColor = [UIColor whiteColor];
    self.filterNameLab.font = [UIFont systemFontOfSize:15.f];
    self.filterNameLab.hidden = YES;
    [_videoPreviewView addSubview:self.filterNameLab];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeActions:)];
    [leftSwipe setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_videoPreviewView addGestureRecognizer:leftSwipe];

    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeActions:)];
    [rightSwipe setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_videoPreviewView addGestureRecognizer:rightSwipe];
}

-(CVPixelBufferRef)showView:(CMSampleBufferRef)sampleBuffer{
    
    CVPixelBufferRef imageBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
    CGRect sourceExtent = sourceImage.extent;
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = _videoPreviewViewBounds.size.width  / _videoPreviewViewBounds.size.height;
    CIImage *filteredImage = sourceImage;

    if (![self.currentFilterName isEqualToString:@"NONE"]) {
        CIFilter *effectFilter = [CIFilter filterWithName:self.currentFilterName];
        [effectFilter setValue:sourceImage forKey:kCIInputImageKey];
        filteredImage = [effectFilter outputImage];
    }
    [_ciContext render:filteredImage toCVPixelBuffer:imageBuffer];
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceExtent;
    if (sourceAspect > previewAspect){
        // use full height of the video image, and center crop the width
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
    }
    else{
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
    }
    
    [_videoPreviewView bindDrawable];
    
    if (_eaglContext != [EAGLContext currentContext])
        [EAGLContext setCurrentContext:_eaglContext];
    
    // clear eagl view to grey
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // set the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (filteredImage){
        [_ciContext drawImage:filteredImage inRect:_videoPreviewViewBounds fromRect:drawRect];
    }
    [_videoPreviewView display];
    
    return imageBuffer;
}
-(void)swipeActions:(UISwipeGestureRecognizer *)gesture{
    gesture.enabled = NO;
    NSInteger currentIndex = [self.fiterENArray indexOfObject:self.currentFilterName];
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {//左滑
        if (currentIndex == self.fiterENArray.count - 1) {
            self.currentFilterName = self.fiterENArray.firstObject;
        }else{
            self.currentFilterName = self.fiterENArray[currentIndex+1];
        }
    }else if (gesture.direction == UISwipeGestureRecognizerDirectionRight){//右滑
        if (currentIndex == 0) {
            self.currentFilterName = self.fiterENArray.lastObject;
        }else{
            self.currentFilterName = self.fiterENArray[currentIndex-1];
        }
    }
    
    self.filterNameLab.text = self.fiterCNArray[[self.fiterENArray indexOfObject:self.currentFilterName]];
    self.filterNameLab.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.filterNameLab.hidden = YES;
        gesture.enabled = YES;
    });
}

@end
