//
//  RCDTipView.h
//  RongIMLibDemo
//
//  Created by Sin on 16/9/22.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDTipView : UIView
+ (instancetype)tipView;
- (void)show;
- (void)hide;
- (void)updateLeftTip:(NSString *)leftStr;
- (void)updateContentText:(NSString *)text;
- (void)updateImageView:(UIImage *)image;
@end
