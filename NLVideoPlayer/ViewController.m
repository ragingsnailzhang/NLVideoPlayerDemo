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
#import "NLVideoPlayer.h"
@interface ViewController ()<NLVideoRecordManagerDelegate>

@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)NSData *fileData;
@property(nonatomic,strong)NSURL *outputURL;
@property(nonatomic,strong)UIButton *uploadBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake(self.view.center.x-100-20, self.view.center.y+100, 100, 40);
    [recordBtn setTitle:@"录制" forState:UIControlStateNormal];
    [recordBtn setBackgroundColor:[UIColor redColor]];
    [recordBtn addTarget:self action:@selector(recordClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordBtn];
    
    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadBtn = uploadBtn;
    uploadBtn.frame = CGRectMake(self.view.center.x+20, self.view.center.y+100, 100, 40);
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn setTitle:@"上传完成" forState:UIControlStateDisabled];
    [uploadBtn setBackgroundColor:[UIColor redColor]];
    [uploadBtn addTarget:self action:@selector(uploadVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadBtn];
    
    UIImageView *imgView = [[UIImageView alloc]init];
    _imgView = imgView;
    imgView.userInteractionEnabled = YES;
    imgView.frame = CGRectMake((self.view.frame.size.width-200)/2,SAFEAREA_TOP_HEIGH+50, 200, 300);
    imgView.backgroundColor = [UIColor whiteColor];
    imgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imgView.layer.borderWidth = 0.6f;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVideo)];
    [imgView addGestureRecognizer:tap];
    
    
}
-(void)recordClick{
    self.uploadBtn.enabled = YES;
    NLRecordParam *param = [NLRecordParam recordConfigWithVideoRatio:NLVideoVideoRatioFullScreen Position:AVCaptureDevicePositionBack maxRecordTime:10.f minRecordTime:1.f Compression:YES CurrentVC:self];
    UIViewController *recordVC = [NLVideoRecordManager createRecordViewControllerWithRecordParam:param];
    [NLVideoRecordManager shareVideoRecordManager].delegate = self;
    [self presentViewController:recordVC animated:YES completion:nil];
}

//MARK:NLVideoRecordManagerDelegate
-(void)getVideoData:(NSData *)outputData URL:(NSURL *)outputURL{
    NSLog(@"%@,%d",outputURL,outputData?YES:NO);
    self.fileData = outputData;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self.view.subviews) {
            if ([view isMemberOfClass:[NLLoadingView class]]) {
                [(NLLoadingView *)view stopAnimating];
                [view removeFromSuperview];
                break;
            }
        }
    });
}
-(void)getRecordTime:(CGFloat)time{
    NSLog(@"%f",time);
}
-(void)getRecordVideoCoverURL:(NSURL *)coverURL Image:(UIImage *)coverImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_imgView.image = coverImage;
    });
}
//MARK:上传视频
-(void)uploadVideo{
    if (!self.fileData) {
        return;
    }
    NLLoadingView *loadingView = [NLLoadingView loadingViewWithTitle:@"正在上传..." inView:self.view];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [NLVideoUploadManager requestDataNetWorkWithMethod:POSTFILE APIMethod:@"chenggou.file.upload" Params:params Domain:@"https://xxx.com/router/rest" constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:self.fileData name:@"file" fileName:@"video.mp4" mimeType:@"video/mp4"];
        
    } progress:^(NSProgress * _Nonnull progress) {
        NSLog(@"%lld",progress.completedUnitCount);
    } success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@",responseDict);
        [loadingView stopAnimating];
        [loadingView removeFromSuperview];
        self->_uploadBtn.enabled = NO;
        self.outputURL = [NSURL URLWithString:((NSArray *)responseDict[@"file_result_response"][@"file_urls"][@"file_url"]).firstObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        NSLog(@"%@",error);
    }];
}
//MARK:播放视频
-(void)playVideo{
    if (!self.outputURL) {
        return;
    }
    TBMoviePlayer * playerVC = [TBMoviePlayer new];
    playerVC.model.title = @"标题";
    playerVC.model.videoURL= self.outputURL;
    //playVC.model.placeholderImage = img; //初始加载时封面
    [self presentViewController:playerVC animated:YES completion:nil];
}




@end
