//
//  RCDConnectStatusManager.h
//  RongIMLibDemo
//
//  Created by Sin on 16/9/18.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
/**
 *  融云IMLib连接状态管理者，建议用单例类来实现，最好是设置为AppDelegate
 */
@interface RCDConnectStatusManager : NSObject<RCConnectionStatusChangeDelegate>
+ (instancetype)shareManager;
@end
