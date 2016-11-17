//
//  AppDelegate.m
//  RongIMLibDemo
//
//  Created by Sin on 16/10/25.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "AppDelegate.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDIMLibCommenDefine.h"


@interface AppDelegate ()<RCIMClientReceiveMessageDelegate,RCLogInfoDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"file path %@",filePaths[0]);
    //sdk初始化，在调用sdk的其他方法之前，必须初始化sdk
    [[RCIMClient sharedRCIMClient] initWithAppKey:RongCloudAppKey];
    //sdk设置接收消息的代理
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    
    //sdk设置log代理，当sdk有log产生的时候都会走这个代理方法
    //然后开发者可以收集sdk内部的log，上传自己服务器或者保存本地等都行
    [[RCIMClient sharedRCIMClient] setRCLogInfoDelegate:self];
    
    //统计app启动事件-推送数据统计1
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
    //获取点击的启动事件中，融云推送服务的扩展字段-推送数据统计4
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromLaunchOptions:launchOptions];
    if (pushServiceData) {
        NSLog(@"该启动事件包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"%@", pushServiceData[key]);
        }
    } else {
        NSLog(@"该启动事件不包含来自融云的推送服务");
    }
    
    //sdk的建议连接流程：将token保存到本地，每次app打开之后，都从本地获取， 如果没有token，表明当前用户是第一次登录，那么建议直接push到登录页面，然后走正常的登录流程（获取token，然后token保存到本地）；如果本地有，那么该用户直接调用接口让sdk连接到我们服务器。如果想点击远程推送直接push指定聊天页面，那么必须在app启动的时候里面成功连接到我们服务器才可以
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    if(token){
        //sdk默认是当成功连接到服务器的时候，sdk才会知道当前登录的是哪个用户，然后加载对应的数据库，但是也有例外
        //如果sdk检测本次登录和上次登录的token是同一个，sdk直接加载该用户的内置数据库，不用等连接服务器成功，这样保证会话列表的数据能够快速加载、显示
        [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
            RCUserInfo *user = [RCUserInfo new];
            user.userId = userId;
            user.name = @"rongcloud";
            user.portraitUri = @"http://www.rongcloud.cn/images/newVersion/log_wx.png?2016";
            [RCIMClient sharedRCIMClient].currentUserInfo = user;
        } error:^(RCConnectErrorCode status) {
            
        } tokenIncorrect:^{
            
        }];
    }else {
        //跳转登录页面，调用开发者自己的服务器接口来获取token
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //统计本地通知事件-推送数据统计2
    [[RCIMClient sharedRCIMClient] recordLocalNotificationEvent:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //统计远程推送事件-推送数据统计3
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
    //获取点击的远程推送中，融云推送服务的扩展字段-推送数据统计5
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient]
                                     getPushExtraFromRemoteNotification:userInfo];
    if (pushServiceData) {
        NSLog(@"该远程推送包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
        }
    } else {
        NSLog(@"该远程推送不包含来自融云的推送服务");
    }
}

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    //如果收到消息，直接发一个全局通知，注册通知的页面接收到通知之后做相关的操作
    NSDictionary *dictLeft = @{@"rcLeft":@(nLeft)};
    [[NSNotificationCenter defaultCenter] postNotificationName:RCDIMLibDemoHasReceivedMessageNotification object:message userInfo:dictLeft];
    NSLog(@"message %@",message);
    //如果说你在收到消息的时候就需要立即处理消息体
    //如果消息是文本消息
    if([message.content isMemberOfClass:[RCTextMessage class]]){
        RCTextMessage *msg = (RCTextMessage *)message.content;
        NSLog(@"text message content : %@",msg.content);
    }
    //如果消息是图片消息
    else if([message.content isMemberOfClass:[RCImageMessage class]]){
        RCImageMessage *msg = (RCImageMessage *)message.content;
        UIImage *thumbnailImage = msg.thumbnailImage;
        NSLog(@"图片消息缩略图为:%@",thumbnailImage);
        
        //注：发送方图片消息的原图地址为一个本地路径，接收方图片消息的原图地址为一个网络url
        NSString *imageUrl = msg.imageUrl;
        NSLog(@"原图地址为：%@",imageUrl);
    }
}

#pragma mark - RCLogInfoDelegate
- (void)didOccurLog:(NSString *)logInfo {
    NSLog(@"rong cloud log %@",logInfo);
    //可以把我们sdk内部的log写入文件，或者上传到开发者自己的服务器
}

#pragma mark 收到消息撤回请求
//如果对方发送了一个消息撤回，那么自己能够在这个代理方法里面拿到对方要撤回那条消息的messageId，然后自己这边发一个通知给聊天页面，如果聊天页面收到这个通知，然后需要遍历整个聊天页面的消息体，如果要撤回的那条消息在当前页面，那么将该消息删除并更新UI，如果不是在当前页面，那么可以将该消息直接删除
- (void)onMessageRecalled:(long)messageId {
    NSDictionary *recalledDic = @{@"msgId":@(messageId)};
    [[NSNotificationCenter defaultCenter] postNotificationName:RCDIMLibDemoHasReceivedMessageRecalledNotification object:nil userInfo:recalledDic];
}
#pragma mark 收到消息回执请求
//对方调用了RCIMClient的sendReadReceiptRequest方法，自己就会走这个方法
//那么就知道对方要求对消息id为messageId的消息进行回执，自己这边需要对当前回话列表的消息进行过滤，如果当前页面有需要回执的消息，那么就需要调用RCIMClient的sendReadReceiptResponse方法，告诉对方，我已经读了你的这条消息
- (void)onMessageReceiptRequest:(RCConversationType)conversationType targetId:(NSString *)targetId messageUId:(NSString *)messageUId {
    NSDictionary *dic = @{@"conversationType":@(conversationType),@"targetId":targetId,@"messageUId":messageUId};
    [[NSNotificationCenter defaultCenter] postNotificationName:RCDIMLibDemoHasReceivedMessageReceiptRequestNotification object:nil userInfo:dic];
}
#pragma mark 收到消息回执相应
//对方调用了RCIMClient的sendReadReceiptResponse方法，自己就会走这个方法
//那么就知道对方已经读了消息id为messageId的消息，自己这边就需要更新UI表示群里某人(targetId)已经读了你的那条消息
- (void)onMessageReceiptResponse:(RCConversationType)conversationType targetId:(NSString *)targetId messageUId:(NSString *)messageUId readerList:(NSMutableDictionary *)userIdList {
    NSDictionary *dic = @{@"conversationType":@(conversationType),@"targetId":targetId,@"messageUId":messageUId,@"userIdList":userIdList};
    [[NSNotificationCenter defaultCenter] postNotificationName:RCDIMLibDemoHasReceivedMessageReceiptResponseNotification object:nil userInfo:dic];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
