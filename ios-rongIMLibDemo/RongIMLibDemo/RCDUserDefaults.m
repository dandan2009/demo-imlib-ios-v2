//
//  RCDUserDefaults.m
//  RongIMLibDemo
//
//  Created by Sin on 16/9/22.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "RCDUserDefaults.h"
#import <RongIMLib/RongIMLib.h>

#define RCDUserDefaultsSet(value,key) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key]
#define RCDUserDefaultsGet(key) [[NSUserDefaults standardUserDefaults] valueForKey:key]


@implementation RCDUserDefaults

+ (RCUserInfo *)getUserInfo1 {
    return [[RCUserInfo alloc]initWithUserId:user1Key name:user1Key portrait:user1Key];
}
+ (RCUserInfo *)getUserInfo2 {
    return [[RCUserInfo alloc]initWithUserId:user2Key name:user2Key portrait:user2Key];
}
+ (void)setTokenOfUserInfo1:(NSString *)token {
    RCDUserDefaultsSet(token, user1TokenKey);
}
+ (void)setTokenOfUserInfo2:(NSString *)token {
    RCDUserDefaultsSet(token, user2TokenKey);
}
+ (NSString *)getTokenOfUserInfo1 {
    return RCDUserDefaultsGet(user1TokenKey);
}
+ (NSString *)getTokenOfUserInfo2 {
    return RCDUserDefaultsGet(user2TokenKey);
}

+ (void)setTokenOfUserInfo:(NSString *)userId token:(NSString *)token {
    if([userId isEqualToString:user1Key]){
        [self setTokenOfUserInfo1:token];
    }else {
        [self setTokenOfUserInfo2:token];
    }
}
+ (NSString *)getTokenOfUserInfo:(NSString *)userId {
    if([userId isEqualToString:user1Key]){
        return [self getTokenOfUserInfo1];
    }else {
        return [self getTokenOfUserInfo2];
    }
}
@end
