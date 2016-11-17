//
//  RCDConnectStatusManager.m
//  RongIMLibDemo
//
//  Created by Sin on 16/9/18.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "RCDConnectStatusManager.h"
#import "AppDelegate.h"

@implementation RCDConnectStatusManager
+ (instancetype)shareManager {
    static RCDConnectStatusManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

/**
 *  在这里面做IMLib连接状态的监听，比如说用户被踢下线之类的
 *
 *  @param status 参考RCStatusDefine.h获取status的具体含义
 */
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    if(ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT == status) {
        NSLog(@"你的当前账号在其他设备登录，你被迫下线");
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIWindow *window = app.window;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"你的当前账号在其他设备登录，你被迫下线" delegate:window cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        //参考RCStatusDefine.h获取status的具体含义
    }
}
@end
