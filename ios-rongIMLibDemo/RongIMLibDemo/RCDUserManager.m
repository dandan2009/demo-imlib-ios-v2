//
//  RCDUserManager.m
//  RongIMLibDemo
//
//  Created by Sin on 16/9/18.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "RCDUserManager.h"
#import <RongIMLib/RongIMLib.h>

@interface RCDUserManager ()
@property (nonatomic,strong) NSMutableArray *userArray;
@end

@implementation RCDUserManager
+ (instancetype)sharedUserManager {
    static RCDUserManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userArray = [NSMutableArray new];
        for(int i=0;i<7;i++){
            //此处的用户信息是为了方便伪造的，开发者应该从自己的服务来获取用户信息
            RCUserInfo *userInfo = [[RCUserInfo alloc]init];
            userInfo.userId = [NSString stringWithFormat:@"%d",i];
            userInfo.name = [NSString stringWithFormat:@"user%d",i];
            userInfo.portraitUri = [NSString stringWithFormat:@"http://demo.%d.png",i];
            [self.userArray addObject:userInfo];
        };
    }
    return self;
}

- (RCUserInfo *)userInfoForIndex:(int)index {
    return self.userArray[index];
}

@end
