//
//  NLVideoPreviewViewController.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/9.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLVideoPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NLVideoPlayer.h"

@interface NLVideoPreviewViewController ()

@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayerItem *item;
@property(nonatomic,strong)AVPlayerLayer *playerLayer;

@property(nonatomic,strong)UIButton *closeBtn;                       //关闭按钮


@end

@implementation NLVideoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.item = [AVPlayerItem playerItemWithURL:self.fileURL];
    self.player = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.frame;
    [self.view.layer addSublayer:self.playerLayer];
    [self.player play];
    
    //关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.frame = CGRectMake(MARGIN, MARGIN, 23, 23);
    [self.closeBtn setImage:[UIImage imageNamed:@"record_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeBtn];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runloopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

-(void)runloopTheMovie:(NSNotification *)notify{
    AVPlayerItem *item = notify.object;
//    CMTimeMake(0.1, 1)
    [item seekToTime:kCMTimeZero];
    [self.player play];
}

-(void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
