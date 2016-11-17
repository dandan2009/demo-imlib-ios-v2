//
//  RCDTipView.m
//  RongIMLibDemo
//
//  Created by Sin on 16/9/22.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "RCDTipView.h"

@interface RCDTipView ()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *leftTipLabel;
@property (nonatomic,strong) UILabel *contentTipLabel;
@property (nonatomic,strong) UILabel *contentLabel;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *confirmButton;
@end

#define kWidth 200.0f
#define kHeight 220.0f

@implementation RCDTipView

+ (instancetype)tipView {
    return [[self alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)initSubviews {
    self.backgroundColor = [[UIColor alloc]initWithRed:248.0 green:248.0 blue:248.0 alpha:1.0];
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, kWidth, 20)];
    self.titleLabel.text = @"您收到了一条消息!";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = [UIColor redColor];
    
    self.leftTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, CGRectGetMaxY(self.titleLabel.frame), kWidth, 20)];
    self.leftTipLabel.text = @"剩余:0";
    self.leftTipLabel.font = [UIFont systemFontOfSize:13];
    
    self.contentTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, CGRectGetMaxY(self.leftTipLabel.frame), kWidth, 20)];
    self.contentTipLabel.text = @"内容";
    self.contentTipLabel.font = [UIFont systemFontOfSize:13];
    
    self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.contentTipLabel.frame)+10, kWidth-20, 100)];
    self.contentLabel.numberOfLines = 5;
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
    self.contentLabel.font = [UIFont systemFontOfSize:15];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.contentLabel.frame];
    
    self.confirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentLabel.frame)+10, kWidth, 40)];
    [self.confirmButton setTitle:@"朕知道了" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.leftTipLabel];
    [self addSubview:self.contentTipLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.imageView];
    [self addSubview:self.confirmButton];
//    [self hide];
}

- (void)confirmButtonEvent {
    [self hide];
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

- (void)updateLeftTip:(NSString *)leftStr {
    self.leftTipLabel.text = [NSString stringWithFormat:@"剩余:%@",leftStr];
}
- (void)updateContentText:(NSString *)text {
    self.contentLabel.hidden = NO;
    self.imageView.hidden = YES;
    self.contentTipLabel.text = @"内容:文本消息";
    self.contentLabel.text = text;
}
- (void)updateImageView:(UIImage *)image {
    self.contentLabel.hidden = YES;
    self.imageView.hidden = NO;
    self.contentTipLabel.text = @"内容:图片消息";
    self.imageView.image = image;
}
@end
