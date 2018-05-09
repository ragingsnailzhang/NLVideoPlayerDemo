//
//  NLBottomOptionsView.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/7.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLBottomOptionsView.h"
#import "NLConfigure.h"
@interface NLBottomOptionsView()

@property(nonatomic,strong)UIButton *cancleBtn;    //取消
@property(nonatomic,strong)UIButton *previewBtn;   //预览
@property(nonatomic,strong)UIButton *selectedBtn;  //选择


@end

@implementation NLBottomOptionsView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureView];
    }
    return self;
}
-(void)configureView{
    
    _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancleBtn.frame = CGRectMake(MARGIN, (self.frame.size.height-CANCLEBTN_WIDTH)/2, CANCLEBTN_WIDTH, CANCLEBTN_WIDTH);
    [_cancleBtn setBackgroundImage:[UIImage imageNamed:@"record_cancle"] forState:UIControlStateNormal];
    [_cancleBtn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancleBtn];
    
    _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewBtn.frame = CGRectMake(self.center.x-CANCLEBTN_WIDTH*1.3/2, (self.frame.size.height-CANCLEBTN_WIDTH*1.3)/2, CANCLEBTN_WIDTH*1.3, CANCLEBTN_WIDTH*1.3);
    [_previewBtn setBackgroundImage:[UIImage imageNamed:@"record_preview"] forState:UIControlStateNormal];
    [_previewBtn addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_previewBtn];
    
    _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedBtn.frame = CGRectMake(self.frame.size.width-SELECTEDBTN_WIDTH-MARGIN, (self.frame.size.height-SELECTEDBTN_WIDTH)/2, SELECTEDBTN_WIDTH, SELECTEDBTN_WIDTH);
    [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"record_save"] forState:UIControlStateNormal];
    [_selectedBtn addTarget:self action:@selector(selected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectedBtn];
    
}
//保存
-(void)selected{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedClick)]) {
        [self.delegate selectedClick];
    }
}
//预览
-(void)preview{
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewClick)]) {
        [self.delegate previewClick];
    }
}
//删除
-(void)cancle{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancleClick)]) {
        [self.delegate cancleClick];
    }
}

@end
