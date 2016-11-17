//
//  RCDIMLibCommenDefine.h
//  RongIMLibDemo
//
//  Created by Sin on 16/9/18.
//  Copyright © 2016年 Sin. All rights reserved.
//

#ifndef RCDIMLibCommenDefine_h
#define RCDIMLibCommenDefine_h

//客户端appkey，仅供客户端使用
#define RongCloudAppKey @"e5t4ouvptkm2a"

//当接收到消息的通知
static NSString * RCDIMLibDemoHasReceivedMessageNotification = @"RCDIMLibDemoHasReceivedMessageNotification";

//收到对方的消息撤回请求的通知
static NSString * RCDIMLibDemoHasReceivedMessageRecalledNotification = @"RCDIMLibDemoHasReceiveeMessageRecalledNotification";

//收到群组、讨论组某个成员的某条消息回执请求的通知
static NSString * RCDIMLibDemoHasReceivedMessageReceiptRequestNotification = @"RCDIMLibDemoHasReceivedMessageReceiptRequestNotification";

//收到群组、讨论组某个成员对某条消息的回执相应的通知
static NSString * RCDIMLibDemoHasReceivedMessageReceiptResponseNotification = @"RCDIMLibDemoHasReceivedMessageReceiptResponseNotification";

#endif /* RCDIMLibCommenDefine_h */
