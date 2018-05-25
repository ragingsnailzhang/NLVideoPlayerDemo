//
//  NLConfigure.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#ifndef NLConfigure_h
#define NLConfigure_h

//屏幕宽度
#define kScreenW      [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define kScreenH      [UIScreen mainScreen].bounds.size.height
//下边距安全距离
#define SAFEAREA_BOTTOM_HEIGH                  (kScreenH == 812.0 ? 34.0f : 0.01f)
//上边距安全距离
#define SAFEAREA_TOP_HEIGH                     (kScreenH == 812.0 ? 44.0f : 20.0f)
//状态栏高度
#define STATUS_HEIGHT  20.f
//边距
#define MARGIN      20
//录制按钮大小
#define STARTBTN_WIDTH      75
//时间View高度
#define TIMEVIEW_HEIGHT     30
//进度条宽度
#define PROGRESS_BORDER_WIDTH  8
//取消按钮大小
#define CANCLEBTN_WIDTH  53
//选择按钮大小
#define SELECTEDBTN_WIDTH  53

//MARK:文件夹名称
//原始文件存放文件夹
#define VIDEO_FOLDER  @"VideoFolder"
////压缩文件存放文件夹
//#define COMPRESSION_VIDEO_FOLDER  @"CompressionVideoFolder"
////编辑文件存放文件夹
//#define EDIT_VIDEO_FOLDER  @"EditVideoFolder"
////封面文件存放文件夹
//#define VIDEO_COVER_FOLDER  @"VideoCoverFolder"

#endif /* NLConfigure_h */
