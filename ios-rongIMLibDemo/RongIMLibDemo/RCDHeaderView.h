//
//  RCDHeaderView.h
//  RongIMLibDemo
//
//  Created by Sin on 16/9/18.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDHeaderView : UIView
+ (instancetype)headerView;

- (void)updateTitleLabelText:(NSString *)title andIsOK:(BOOL)isOK;
@end
