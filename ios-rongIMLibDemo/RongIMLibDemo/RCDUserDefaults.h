//
//  RCDUserDefaults.h
//  RongIMLibDemo
//
//  Created by Sin on 16/9/22.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RCUserInfo;

static NSString *user1Key = @"user1";
static NSString *user2Key = @"user2";
static NSString *user1TokenKey = @"user1Token";
static NSString *user2TokenKey = @"user2Token";

@interface RCDUserDefaults : NSObject
+ (RCUserInfo *)getUserInfo1;
+ (RCUserInfo *)getUserInfo2;
+ (void)setTokenOfUserInfo:(NSString *)userId token:(NSString *)token;
+ (NSString *)getTokenOfUserInfo:(NSString *)userId;
@end
