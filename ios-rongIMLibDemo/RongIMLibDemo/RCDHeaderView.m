//
//  RCDHeaderView.m
//  RongIMLibDemo
//
//  Created by Sin on 16/9/18.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "RCDHeaderView.h"

@interface RCDHeaderView ()
@property(nonatomic,strong) UILabel *titleLabel;
@end

@implementation RCDHeaderView
+ (instancetype)headerView {
    return [[[self class] alloc]init];
}

- (instancetype)init
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, width, 64)];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, width, 44)];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    
    [self addSubview:self.titleLabel];
}

- (void)updateTitleLabelText:(NSString *)title andIsOK:(BOOL)isOK {
    self.titleLabel.textColor = isOK ? [UIColor blackColor]:[UIColor redColor];
    self.titleLabel.text = title;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
