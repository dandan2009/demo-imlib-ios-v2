//
//  RCDUserManager.h
//  RongIMLibDemo
//
//  Created by Sin on 16/9/18.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RCUserInfo;
/**
 *  该类模仿从服务器获取用户信息，实际开发的用户信息需要从开发者自己的服务获取
 */
@interface RCDUserManager : NSObject
+ (instancetype)sharedUserManager;
- (RCUserInfo *)userInfoForIndex:(int)index;
@end
