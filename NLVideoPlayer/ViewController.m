//
//  ViewController.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/4.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "ViewController.h"
#import "NLVideoRecordViewController.h"
#import "NLRecordParam.h"
#import "NLVideoRecordManager.h"
#import "NLConfigure.h"
@interface ViewController ()<NLVideoRecordManagerDelegate>

@property(nonatomic,strong)UIImageView *imgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake((self.view.frame.size.width-100)/2, self.view.center.y+100, 100, 40);
    [recordBtn setTitle:@"record" forState:UIControlStateNormal];
    [recordBtn setBackgroundColor:[UIColor redColor]];
    [recordBtn addTarget:self action:@selector(recordClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordBtn];
    
    UIImageView *imgView = [[UIImageView alloc]init];
    _imgView = imgView;
    imgView.frame = CGRectMake((self.view.frame.size.width-200)/2,SAFEAREA_TOP_HEIGH+50, 200, 300);
    imgView.backgroundColor = [UIColor lightGrayColor];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgView];
}
-(void)recordClick{
    NLRecordParam *param = [NLRecordParam recordConfigWithVideoRatio:NLVideoVideoRatioFullScreen Position:AVCaptureDevicePositionBack maxRecordTime:10.f minRecordTime:1.f Compression:YES];
    UIViewController *recordVC = [NLVideoRecordManager createRecordViewControllerWithRecordParam:param];
    [NLVideoRecordManager shareVideoRecordManager].delegate = self;
    [self presentViewController:recordVC animated:YES completion:nil];
}

//MARK:NLVideoRecordManagerDelegate
-(void)getVideoData:(NSData *)outputData URL:(NSURL *)outputURL{
    NSLog(@"%@,%d",outputURL,outputData?YES:NO);
}
-(void)getRecordTime:(CGFloat)time{
    NSLog(@"%f",time);
}
-(void)getRecordVideoCoverURL:(NSURL *)coverURL Image:(UIImage *)coverImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_imgView.image = coverImage;
    });
}


@end
