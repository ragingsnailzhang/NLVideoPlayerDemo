//
//  ViewController.h
//  VideoPlayerTestDemo
//
//  Created by xiaoling on 2018/5/11.
//  Copyright © 2018年 LSJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>

@interface TBMoviePlayer : UIViewController

//播放模型 需要设置下面这些参数
// model.title 设置播放标题(可设为空)
// model.videoURL = [NSURL URLWithString:@"https://file.oodso.com/s/52855/f/2665849-1309245.mp4"];
// model.placeholderImage  初始加载时的默认图片
@property(nonatomic,strong)ZFPlayerModel * model;

@end

