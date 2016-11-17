//
//  ViewController.m
//  RongIMLibDemo
//
//  Created by Sin on 16/10/25.
//  Copyright © 2016年 Sin. All rights reserved.
//


#import "ViewController.h"
#import "RCDHeaderView.h"
#import "RCDUserManager.h"
#import <RongIMLib/RongIMLib.h>
#import "MBProgressHUD/MBProgressHUD.h"
#import "RCDIMLibCommenDefine.h"
#import <CommonCrypto/CommonDigest.h>
#import "RCDConnectStatusManager.h"
#import "RCDTestMessage.h"
#import "RCDUserDefaults.h"
#import "RCDTipView.h"

#import "AppDelegate.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,RCTypingStatusDelegate>
//UI控件
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,strong) RCDHeaderView *headerView;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) RCDTipView *tipView;
//
@property (nonatomic,copy) NSString *rongCloudToken;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *targetId;
@property (nonatomic,strong) RCUserInfo *currentUserInfo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    self.titleArray = @[@"获取token",//0
                        @"连接融云服务器",//1
                        @"设置远程推送的deviceToken",//2
                        @"设置IMLib的连接状态监听器",//3
                        @"获取当前sdk连接/网络/运行状态",//4
                        @"设置登录用户信息",//5
                        @"注册自定义cell",//6
                        @"发送消息",//7
                        @"发送图片/文件消息",//8
                        @"发送图片/文件信息将数据上传至指定的服务器",//9
                        @"接收消息",//10
                        @"插入向外发送的消息",//11
                        @"下载文件消息和图片消息的多媒体数据",//12
                        @"单聊消息已读回执",//13
                        @"群组/讨论组已读消息回执",//14
                        @"撤回消息",//15
                        @"同步消息阅读状态",//16
                        @"获取本地/服务器历史消息",//17
                        @"获取本地特定消息(消息发送时间)",//18
                        @"删除本地消息",//19
                        @"设置本地某条消息的收发状态",//20
                        @"自定义会话列表操作",//21
                        @"会话中的草稿操作",//22
                        @"未读消息数相关",//23
                        @"会话消息提醒",//24
                        @"全局消息提醒",//25
                        @"输入状态监听(单聊)",//26
                        @"黑名单操作(单聊)",//27
                        @"讨论组操作",//28
                        @"聊天室操作",//29
                        @"公众服务账号相关操作",//30
                        @"推送业务数据统计相关操作",//31
                        @"工具类方法",//32
                        @"客服相关操作",//33
                        @"断开连接(注销/切换账号)",//34
                        ];
    
    self.tipView = [RCDTipView tipView];
    self.tipView.center = self.view.center;
    [self.view addSubview:self.tipView];
    [self.tipView hide];
    [self.view insertSubview:self.tipView aboveSubview:self.tableView];
    
    [self.tableView reloadData];
    [self.headerView updateTitleLabelText:@"IMLib demo" andIsOK:YES];
    
    [self registerNotifications];
}

- (void)registerNotifications {
    //sdk内置通知
    //注册单聊消息已读回执的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMessageHasReadNotification:)
                                                 name:RCLibDispatchReadReceiptNotification
                                               object:nil];
    //demo内置通知
    //注册收到消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasReceiveMessage:) name:RCDIMLibDemoHasReceivedMessageNotification object:nil];
    //注册对方发送的消息撤回的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasReceivedMessageRecalledNotification:) name:RCDIMLibDemoHasReceivedMessageRecalledNotification object:nil];
    //注册群组、讨论组中某成员发送的消息回执请求的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasReceivedMessageReceiptRequestNotification:) name:RCDIMLibDemoHasReceivedMessageReceiptRequestNotification object:nil];
    //注册群组、讨论组中某成员发送的消息回执相应的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasReceivedMessageReceiptResponseNotification:) name:RCDIMLibDemoHasReceivedMessageReceiptResponseNotification object:nil];
}

#pragma mark - 懒加载UI

- (RCDHeaderView *)headerView {
    if(!_headerView){
        _headerView = [RCDHeaderView headerView];
        [self.view addSubview:_headerView];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if(!_tableView){
        CGRect frame = self.view.bounds;
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height-64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (MBProgressHUD *)hud {
    if(!_hud){
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.label.text = @"请等待...";
    }
    return _hud;
}


#pragma mark - table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc]init];
    }
    NSString *indexText = [NSString stringWithFormat:@"%zd:%@",indexPath.row,self.titleArray[indexPath.row]];
    cell.textLabel.text = indexText;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0://获取token
            [self getRongCloudToken];
            break;
        case 1://连接融云服务器
            [self connectRongCloud];
            break;
        case 2://设置远程推送的deviceToken
            [self setRongCloudDeviceToken];
            break;
        case 3://设置IMLib的连接状态监听器
            [self setRongCloudConnectStatusDelegate];
            break;
        case 4://获取当前sdk连接/网络/运行状态
            [self getRongCloudSDKConnectStatus];
            break;
        case 5://设置登录用户信息
            [self setRongCloudLoginUserInfo];
            break;
        case 6://注册自定义cell
            [self registerRongCloudMessage];
            break;
        case 7://发送消息
            [self sendRongCloudMessage];
            break;
        case 8://发送图片/文件消息
            [self sendRongCloudMediaMessage];
            break;
        case 9://发送图片/文件信息将数据上传至指定的服务器
            [self sendRongCloudMediaUploadMessage];
            break;
        case 10://接收消息
            [self receiveRongCloudMessage];
            break;
        case 11://插入向外发送的消息
            [self insertOutgoingRongCloudMessage];
            break;
        case 12://下载文件消息和图片消息的多媒体数据
            [self downloadRongCloudMediaFile];
            break;
        case 13://消息已读回执
            [self sendRongCloudReadReceiptMessage];
            break;
        case 14://群组/讨论组已读消息回执
            [self sendRongCloudGroupReadReceiptMessage];
            break;
        case 15://撤回消息
            [self sendRongCloudRecallMessage];
            break;
        case 16://@"同步消息阅读状态",//16
            [self syncMessageReadStatus];
            break;
        case 17://获取本地(sdk内置数据库的消息)/服务器的历史消息
            [self getHistoryMessage];
            break;
        case 18://获取本地特定消息或消息发送时间
            [self getMessageAndTime];
            break;
        case 19://删除本地消息
            [self deleteMessage];
            break;
        case 20://设置本地某条消息的收发状态
            [self setMessageSendReceiveStatus];
            break;
        case 21://自定义会话列表操作
            [self dealWithConversationList];
            break;
        case 22://会话中的草稿操作
            [self dealWithConversationDraft];
            break;
        case 23://未读消息数相关
            [self dealWithUnreadMessage];
            break;
        case 24://会话消息提醒
            [self configConversatioMention];
            break;
        case 25://全局消息提醒
            [self configGlobalMention];
            break;
        case 26://输入状态监听(单聊)
            [self setTypingStatus];
            break;
        case 27://黑名单操作
            [self dealWithBlackList];
            break;
        case 28://讨论组操作
            [self dealWithDiscussion];
            break;
        case 29://聊天室操作
            [self dealWithChatRoom];
            break;
        case 30://公众服务账号相关操作
            [self dealWithPublicService];
            break;
        case 31://推送业务数据统计相关操作
            [self dealWithPushDatastatistics];
            break;
        case 32://工具类方法
            [self dealWithUtilMethod];
            break;
        case 33://客服相关操作
            [self dealWithCustomService];
            break;
        case 34://断开连接
            [self disconnectRongCloud];
            break;
        default:
            [self unimplementMethod];
            break;
    }
}

#pragma mark - RCIMClient的各个接口

/**
 *token默认是一直有效的，建议第一次登录时候获取token并保存到本地，之后直接使用本地的token连接我们的服务器，这样能尽快连接到我们的服务器
 此处token是直接使用写死的，开发者需要通过自己的服务器来获取token，参考server文档http://www.rongcloud.cn/docs/server.html#获取_Token_方法
 *
 */
-(void)getRongCloudToken{
    //注：这里的用户信息是为了方便演示而自动创建的，请开发者自行从自己的服务器获取用户信息
    RCUserInfo *user1 = [RCDUserDefaults getUserInfo1];
    RCUserInfo *user2 = [RCDUserDefaults getUserInfo2];
    NSString *rongCloudToken1 = @"bVTlvcjW0qfbvXNbHLgjIbJNwZccds+d3rQltCcfdiUvQbYrYhA5zKu+myWVP2WAmhOBsfTbFYEKoP3k8VamQg==";
    NSString *rongCloudToken2 = @"NJozkT1LkGFrC0Il4m01c7JNwZccds+d3rQltCcfdiUvQbYrYhA5zKDaOGKIF0P583ZWQUpBZgKaztmlCIEhAA==";
    [RCDUserDefaults setTokenOfUserInfo:user1.userId token:rongCloudToken1];
    [RCDUserDefaults setTokenOfUserInfo:user2.userId token:rongCloudToken2];
    
    self.currentUserInfo = user1;
    
}

/**
 *  连接融云服务器需要token，必须成功获取token之后才能调用此接口
 *  不要多次调用此接口；如果发生错误，请通过RCStatusDefine.h查看错误码的含义
 */
- (void)connectRongCloud {
    if(!self.rongCloudToken){
        [self.headerView updateTitleLabelText:@"token为空" andIsOK:NO];
    }else {
        __weak typeof(self) weakSelf = self;
        [self.hud showAnimated:YES];
        [[RCIMClient sharedRCIMClient] connectWithToken:self.rongCloudToken success:^(NSString *userId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
                [weakSelf.headerView updateTitleLabelText:@"连接融云服务器成功" andIsOK:YES];
            });
        } error:^(RCConnectErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
                [weakSelf.headerView updateTitleLabelText:[NSString stringWithFormat:@"连接融云服务器失败，错误码:%ld",status ]andIsOK:YES];
            });
        } tokenIncorrect:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
                [weakSelf.headerView updateTitleLabelText:@"token错误，请检查你的token" andIsOK:NO];
            });
        }];
    }
    
}

/**
 *  断开与融云服务器的连接，一般当用户退出登录或者切换用户的时候需要调用此接口，但是当用户登录的时候需要再调用connectWithToken方法
 *  断开与融云服务器的连接有三个方法disconnect、disconnect:、logout，有的调用之后可以收到推送，有的不可以，参考RCIMClient.h了解其具体的含义
 */
- (void)disconnectRongCloud {
    [[RCIMClient sharedRCIMClient] disconnect];
    [self.headerView updateTitleLabelText:@"成功断开与融云服务器的连接" andIsOK:YES];
    self.rongCloudToken = nil;
}

/**
 *  如果你需要对方app退出的时候仍旧能够收到消息，那么你就需要配置远程推送，设置deviceToken，将手机的deviceToken传给融云服务器，这是融云服务器进行消息远程推送的前提，然后参考下面的文档来进行远程推送的配置：http://www.rongcloud.cn/docs/ios_push.html
 */
- (void)setRongCloudDeviceToken {
    [[RCIMClient sharedRCIMClient]setDeviceToken:@"your device token"];
    [self.headerView updateTitleLabelText:@"参考RCIMClient.h中对setDeviceToken:方法的描述" andIsOK:NO];
    NSLog(@"参考RCIMClient.h中对setDeviceToken:方法的描述");
}

/**
 *  设置IMLib的连接状态监听器，里面可以对sdk网络连接状态的变化监听，比如说被提掉线之类的
 */
- (void)setRongCloudConnectStatusDelegate {
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:[RCDConnectStatusManager shareManager]];
    NSString *tip = @"请参考RCDConnectStatusManager的实现";
    [self.headerView updateTitleLabelText:tip andIsOK:NO];
    NSLog(@"设置IMLib的连接状态监听器请%@",tip);
}

/**
 *  获取当前sdk连接/网络/运行状态
 */
- (void)getRongCloudSDKConnectStatus {
    RCConnectionStatus connectStatus =  [[RCIMClient sharedRCIMClient] getConnectionStatus];
    if(ConnectionStatus_Connected == connectStatus){
        NSLog(@"sdk连接服务器成功");
    }else {
        //详情查看RCStatusDefine.h中的说明
    }
    RCNetworkStatus networkStatus = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if(RC_ReachableViaWiFi == networkStatus){
        NSLog(@"当前是WiFi环境");
    }else {
        //详情查看RCStatusDefine.h中的说明
    }
    RCSDKRunningMode sdkRunningMode = [RCIMClient sharedRCIMClient].sdkRunningMode;
    if(RCSDKRunningMode_Backgroud == sdkRunningMode){
        NSLog(@"sdk正在后台运行");
    }else {
        NSLog(@"sdk正在前台运行");
    }
    [self rc_defaultUpdateUI];
}

/**
 *  设置登录用户信息
 */
- (void)setRongCloudLoginUserInfo {
    if(!self.currentUserInfo) {
        [self.headerView updateTitleLabelText:@"当前还没有用户登录，不能调用此接口" andIsOK:NO];
    }else {
        [RCIMClient sharedRCIMClient].currentUserInfo = self.currentUserInfo;
        [self rc_defaultUpdateUI];
    }
    
}

/**
 *  自定义消息必须要注册才能被sdk识别
 */
- (void)registerRongCloudMessage {
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCDTestMessage class]];
    [self.headerView updateTitleLabelText:@"自定义消息必须要注册才能被sdk识别" andIsOK:YES];
}

/**
 *  发送消息，发送文本，语音，自定义消息等不需要服务器存储消息数据的消息
 *  具体关于参数的描述，请参考RCIMClient中对该方法的描述
 */
- (void)sendRongCloudMessage {
    __weak typeof(self) weakSelf = self;
    RCTextMessage *txtMsg = [RCTextMessage messageWithContent:@"Hello,Rong Cloud!"];
    [[RCIMClient sharedRCIMClient]sendMessage:ConversationType_PRIVATE targetId:self.targetId content:txtMsg pushContent:nil pushData:nil success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *tip = [NSString stringWithFormat:@"发送消息成功，user:%@，messageId：%ld",weakSelf.userId,messageId];
            [weakSelf.headerView updateTitleLabelText:tip andIsOK:YES];
            NSLog(@"%@",tip);
        });
    } error:^(RCErrorCode nErrorCode, long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *tip = [NSString stringWithFormat:@"发送消息失败，user:%@，错误码:%ld，messageId:%ld",weakSelf.userId,nErrorCode,messageId];
            [self.headerView updateTitleLabelText:tip andIsOK:NO];
            NSLog(@"%@",tip);
        });
    }];
    
    //发送定向的消息，只支持群组讨论组，给群组讨论组中部分用户发送消息，详情可以看RCIMClient对该方法的描述
    [[RCIMClient sharedRCIMClient] sendDirectionalMessage:ConversationType_GROUP targetId:self.targetId toUserIdList:@[@"user1",@"user2",@"user3"] content:txtMsg pushContent:nil pushData:nil success:^(long messageId) {
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        
    }];
}

/**
 *  发送媒体消息，如图片消息和文件消息等需要将消息数据保存到服务器的，调用此方法默认保存到融云的服务器，具体各个参数的含义请参考RCIMClient.h中对于此方法的描述
 */
- (void)sendRongCloudMediaMessage {
    RCImageMessage *imgMsg = [RCImageMessage messageWithImage:[UIImage imageNamed:@"rongcloud_logo"]];
    [self.hud showAnimated:YES];
    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] sendMediaMessage:ConversationType_PRIVATE targetId:self.targetId content:imgMsg pushContent:nil pushData:nil progress:^(int progress, long messageId) {
        
    } success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.hud hideAnimated:YES];
            NSString *tip = [NSString stringWithFormat:@"发送图片消息成功，user:%@，msgId：%ld",weakSelf.userId,messageId];
            [weakSelf.headerView updateTitleLabelText:tip andIsOK:YES];
            NSLog(@"%@",tip);
        });
    } error:^(RCErrorCode errorCode, long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.hud hideAnimated:YES];
        });
    } cancel:^(long messageId) {
        
    }];
}

/**
 * 这个方法将图片、文件等媒体数据上传至指定的服务器，具体请参考RCIMClient.h中对于此方法的描述
 * 一般是不需要调用此方法的
 */
- (void)sendRongCloudMediaUploadMessage {
    RCImageMessage *imgMsg = [RCImageMessage messageWithImage:[UIImage imageNamed:@"rongcloud_logo"]];
    [[RCIMClient sharedRCIMClient] sendMediaMessage:ConversationType_PRIVATE targetId:self.targetId content:imgMsg pushContent:nil pushData:nil uploadPrepare:^(RCUploadMediaStatusListener *uploadListener) {
        
    } progress:^(int progress, long messageId) {
        
    } success:^(long messageId) {
        
    } error:^(RCErrorCode errorCode, long messageId) {
        
    } cancel:^(long messageId) {
        
    }];
    
    [self rc_defaultUpdateUI];
}

/**
 * 接收消息需要用另一个账号来接收，自己不能给自己发消息
 */
- (void)receiveRongCloudMessage {
    [[RCIMClient sharedRCIMClient] disconnect];
    //如果当前用户是user1，切换至user2
    if([self.userId isEqualToString:user1Key]){
        self.currentUserInfo = [RCDUserDefaults getUserInfo2];
    }else {
        self.currentUserInfo = [RCDUserDefaults getUserInfo1];
    }
    [self connectRongCloud];
    [self.headerView updateTitleLabelText:[NSString stringWithFormat:@"user:%@接收消息成功",self.userId] andIsOK:YES];
}

/**
 *  直接往sdk内置数据库中插入一条发送的消息，注意：这条消息只是插入了本地数据库，自己能够看见，但是不会发送给对方
 *  具体参数的含义请参考RCIMClient
 */
- (void)insertOutgoingRongCloudMessage {
    RCTextMessage *txtMsg = [RCTextMessage messageWithContent:@"Hello,Rong Cloud!"];
    //插入向外发送的消息，这条消息只保存在sdk内置数据库，自己可以看到，但是对方看不到
    [[RCIMClient sharedRCIMClient] insertOutgoingMessage:ConversationType_PRIVATE targetId:self.targetId sentStatus:SentStatus_SENT content:txtMsg];
    
    [self rc_defaultUpdateUI];
}

/**
 *  下载文件消息和图片消息的文件、图片
 */
- (void)downloadRongCloudMediaFile {
    //下载消息内容中的媒体信息，调用该方法下载可以取消的
    long messageId = 7;//消息体的id，参考RCIMClient.h中对于各个参数的声明
    [[RCIMClient sharedRCIMClient] downloadMediaMessage:messageId progress:^(int progress) {
        //下载的时候progress会自动更新，你可以根据progress的值来刷新你的UI
    } success:^(NSString *mediaPath) {
        //下载成功会将返回一个本地路径
    } error:^(RCErrorCode errorCode) {
        //如果下载失败会返回一个错误码
    } cancel:^{
        //如果还没有下载完成你调用下面的取消方法，就会走这个block
    }];
    //取消下载，与上面的下载方法配合使用
    [[RCIMClient sharedRCIMClient] cancelDownloadMediaMessage:messageId];
    
    
    //下载消息内容中的媒体信息，你成功 接收 到一条媒体消息之后可以获得到媒体的网络url，如RCImageMessage的imageUrl，如RCFileMessage的fileUrl，然后将url传给参数mediaUrl
    if(self.userId){//这里做if判断是为了防止开发者没有正常获取连接到我们服务器就调用这个方法导致传入空参数的问题，开发者可以忽略这个if判断
        [[RCIMClient sharedRCIMClient] downloadMediaFile:ConversationType_PRIVATE targetId:self.targetId mediaType:MediaType_IMAGE mediaUrl:@"http://www.rongcloud.cn/images/logo.png" progress:^(int progress) {
            //下载的时候progress会自动更新，你可以根据progress的值来刷新你的UI
        } success:^(NSString *mediaPath) {
            //下载成功会将返回一个本地路径
        } error:^(RCErrorCode errorCode) {
            //如果下载失败会返回一个错误码
        }];
    }
    
    [self rc_defaultUpdateUI];
}

/**
 *  调用下面的接口可以实现消息已读的回执，该接口仅仅适用于单聊，将当前页面最后一条接收到的消息的发送时间戳当参数传递出去
 */
- (void)sendRongCloudReadReceiptMessage {
    //当你阅读了对方发给你的消息之后，发送调动这个接口，对方就会知道这条消息被你读过了
    long long lastReceiveMessageSentTime = 0;
    [[RCIMClient sharedRCIMClient] sendReadReceiptMessage:ConversationType_PRIVATE targetId:self.targetId time:lastReceiveMessageSentTime];
    
    [self rc_defaultUpdateUI];
}

/**
 *  发送撤回消息，当方法此消息是表示发送方想要撤回此消息，接收方接收到此消息之后，应该把聊天页面的这条消息给删除掉
 */
- (void)sendRongCloudRecallMessage {
    
    //发送方的做法
    //此处RCMessage对象是手动创建的
    //你需要根据具体的UI场景来给RCMessage对象赋值，比如说点击或者长按消息cell来获取此消息的对象
    NSArray *currentMessageArray = [NSArray array];//当前页面的所有消息所在的数组
    RCMessage *msg = nil;// currentMessageArray[10];//假如说第10条消息需要被撤回
    [[RCIMClient sharedRCIMClient] recallMessage:msg success:^(long messageId) {
        
    } error:^(RCErrorCode errorcode) {
        
    }];
    [self rc_defaultUpdateUI];
    
    //接收方的做法
    //参考appdelegate中onMessageRecalled:的实现
}


/**
 同步消息的阅读状态
 有这样的一种情况：我的客户端安卓和iOS都有，然后我在iOS读了一条消息之后，我不想在安卓端显示这条消息未读，那么就可以使用下面的方法，在一端收到消息之后，调用sdk的同步消息阅读状态接口，当一端阅读过某些消息之后，其他端的这些消息也会显示成已读的
 */
- (void)syncMessageReadStatus {
    
    NSString *targetId = @"1234";//根据具体情况赋值
    RCConversationType type = ConversationType_GROUP;//根据具体情况赋值
    //该接口主要是面向群组、讨论组(单聊也可以，但是单聊有一个类似的接口sendReadReceiptMessage)，保证一端读过某条消息，那么其他端都会显示已读
    //主要逻辑是在进入和退出页面的时候，倒序遍历所有的消息，找到最后一条接收的消息，就调用这个方法，将最后一条接收消息的时间戳发出去，
    NSArray *conversationDataRepository = [NSArray array];
    if(type == ConversationType_PRIVATE
       ||type == ConversationType_GROUP
       || type == ConversationType_DISCUSSION){
        for (long i = conversationDataRepository.count - 1; i >= 0; i--) {
            RCMessage *model = conversationDataRepository[i];
            if (model.messageDirection == MessageDirection_RECEIVE) {
                [[RCIMClient sharedRCIMClient] syncConversationReadStatus:type
                                                                 targetId:targetId
                                                                     time:model.sentTime
                                                                  success:nil
                                                                    error:nil];
                break;
            }
        }
    }
    
    [self rc_defaultUpdateUI];
}

/**
 *  群组消息已读回执，该过程具体流程如下：用户A如果想要群组Group里面的人收到消息之后给一个回执消息(就是想知道群里面那些人读了这条消息，那些人没有读)，A需要调用sendReadReceiptRequest方法往群组里发送一个请求，当Group里面其他用户如B、C收到这个请求之后(BC会触发RCIMClient的onMessageReceiptRequest方法)，B和C需要将自己当前聊天页面的消息进行过滤，看看那些消息是需要给已读回执的，过滤之后发现存在需要已读回执的消息调用sendReadReceiptResponse方法，A就能知道有多少人读了自己的那条回执消息(A会触发RCIMClient的onMessageReceiptResponse方法)，然后A就可以刷新页面，告诉用户A这条消息群组里面谁读了，谁没有读；如果说当前页面不是聊天页面，或者不是群组Group的聊天页面(即BC这边收到了回执请求的时候没办法直接发送回执给A)，那么当BC进入聊天页面后，加载sdk内置消息的时候会得到一个RCMessage的数组，遍历接收到的消息的RCMessage对象的readReceiptInfo字段来判断消息是否需要回执，如果是，那么就发送回执
 */
- (void)sendRongCloudGroupReadReceiptMessage{
    //发送方这么处理
    //此处RCMessage对象是手动创建的，你需要根据具体的UI场景来给RCMessage对象赋值
    RCMessage *msg = [[RCMessage alloc]init];
    [[RCIMClient sharedRCIMClient] sendReadReceiptRequest:msg success:^{
        
    } error:^(RCErrorCode nErrorCode) {
        
    }];
    
    
    //接收方这么处理
    NSString *targetId = @"1234";//根据具体情况赋值
    RCConversationType type = ConversationType_GROUP;//根据具体情况赋值
    NSMutableArray *array = [NSMutableArray array];//根据具体情况赋值，消息体所在的数组
    if (ConversationType_GROUP == type || ConversationType_DISCUSSION == type) {
        NSMutableArray *readReceiptarray = [NSMutableArray array];//当前页面消息体所组成的数组
        //过滤当前页面的所有的消息
        for (int i = 0; i < array.count; i++) {
            RCMessage *rcMsg = [array objectAtIndex:i];
            if (rcMsg.readReceiptInfo && rcMsg.readReceiptInfo.isReceiptRequestMessage &&!rcMsg.readReceiptInfo.hasRespond && rcMsg.messageDirection == MessageDirection_RECEIVE) {
                [readReceiptarray addObject:rcMsg];
            }
        }
        //过滤完成之后调用接口发送已读回执
        if (readReceiptarray && readReceiptarray.count > 0) {
            [[RCIMClient sharedRCIMClient] sendReadReceiptResponse:type targetId:targetId messageList:readReceiptarray success:^{
                
            } error:^(RCErrorCode nErrorCode) {
                
            }];
        }
    }
    
    [self rc_defaultUpdateUI];
}

/**
 *  获取本地(sdk内置数据库)/服务器的历史消息
 */
- (void)getHistoryMessage {
    RCConversationType type = ConversationType_PRIVATE;
    NSString *targetId = @"userid";
    
    //获取sdk内置数据库消息的方法
    //获取某个会话最新的10条消息
    NSArray *msgArr = [[RCIMClient sharedRCIMClient] getLatestMessages:type targetId:targetId count:10];
    //获取某个会话从messageid为20开始的共计25条消息
    msgArr = [[RCIMClient sharedRCIMClient] getHistoryMessages:type targetId:targetId oldestMessageId:20 count:25];
    //获取某个会话从messageid为11开始的为文本消息的5条消息//获取指定消息类型
    msgArr = [[RCIMClient sharedRCIMClient] getHistoryMessages:type targetId:targetId objectName:@"RC:TxtMsg" oldestMessageId:11 count:5];
    //获取某个会话从messageid为23开始的向前找(更早的)的为图片类型的5条消息
    msgArr = [[RCIMClient sharedRCIMClient] getHistoryMessages:type targetId:targetId objectName:@"RC:ImgMsg" baseMessageId:23 isForward:YES count:5];
    
    
    //获取远端服务器消息的方法,注：必须先开通历史消息云存储功能才能正常使用该接口
    //从特定时间开始的7条历史消息，详细参数参考RCIMClient.h对该方法的说明
    [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:type targetId:targetId recordTime:1000 count:7 success:^(NSArray *messages) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //注：必须先开通聊天室消息云存储功能
    //从2016/11/15 16:20:00起升序拉取100条消息
    [[RCIMClient sharedRCIMClient] getRemoteChatroomHistoryMessages:targetId recordTime:1479198000 count:100 order:RC_Timestamp_Asc success:^(NSArray *messages, long long syncTime) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    
    //获取本地的@我的消息，最多获取10条
    [[RCIMClient sharedRCIMClient] getUnreadMentionedMessages:type targetId:targetId];
    
    [self rc_defaultUpdateUI];
}

/**
 *  获取特定消息(消息发送时间)
 */
- (void)getMessageAndTime {
    long messageId = 10;
    //获取messageid为10的消息的发送时间
    long long msgSendTime = [[RCIMClient sharedRCIMClient] getMessageSendTime:messageId];
    NSLog(@"message %ld send time %lld",messageId,msgSendTime);
    //获取messageId为10的消息
    RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    //根据MessageUID获取消息
    NSString *msgUID = msg.messageUId;
    msg = [[RCIMClient sharedRCIMClient] getMessageByUId:msgUID];
    
    [self rc_defaultUpdateUI];
}

/**
 *  删除消息
 */
- (void)deleteMessage {
    long msgId = 2333;
    //根据消息的messageId删除一批本地消息
    [[RCIMClient sharedRCIMClient] deleteMessages:@[@(msgId)]];
    //删除某个会话的所有本地消息,同时会整理压缩数据库，减少占用空间,不支持聊天室
    RCConversationType type = ConversationType_PRIVATE;
    NSString *targetId = @"userid";
    [[RCIMClient sharedRCIMClient] deleteMessages:type targetId:targetId success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //删除某个会话中的所有本地消息，不支持聊天室
    [[RCIMClient sharedRCIMClient] clearMessages:type targetId:targetId];
    
    [self rc_defaultUpdateUI];
}

/**
 *  设置本地某条消息的收发状态
 */
- (void)setMessageSendReceiveStatus {
    long messageId = 10;
    [[RCIMClient sharedRCIMClient] setMessageSentStatus:messageId sentStatus:SentStatus_SENDING];
    [[RCIMClient sharedRCIMClient] setMessageReceivedStatus:messageId receivedStatus:ReceivedStatus_UNREAD];
    
    [self rc_defaultUpdateUI];
}

/**
 *  自定义会话列表操作
 *
 */
- (void)dealWithConversationList {
    NSArray *arr = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION),
                     @(ConversationType_GROUP),@(ConversationType_CHATROOM),
                     @(ConversationType_SYSTEM)];
    //获取单聊，群聊，讨论组，聊天室，系统会话的会话列表，作为会话列表的数据源
    NSArray *converstionList = [[RCIMClient sharedRCIMClient] getConversationList:arr];
    NSLog(@"current conversion count %zd",converstionList.count);
    //对RCConversation对象的基本处理
    for(int i=0;i<converstionList.count;i++){
        RCConversation *con = converstionList[i];
        NSString *conId = con.targetId;
        BOOL isTop = con.isTop;
        NSLog(@"当前会话id%@，是否置顶显示:%d",conId,isTop);
        RCMessageContent *lastMessage = con.lastestMessage;
        if([lastMessage isMemberOfClass:[RCTextMessage class]]){
            //如果最后一条消息是文本消息
        }else if ([lastMessage isMemberOfClass:[RCImageMessage class]]){
            //如果最后一条消息是图片消息
        }
        NSString *draftStr = con.draft;
        NSLog(@"该会话的草稿是:%@",draftStr);
        //如果有未读的@消息
        BOOL hasUnreadMentioned = con.hasUnreadMentioned;
        if(hasUnreadMentioned){
            NSLog(@"当前会话中有未读的@消息");
        }
        RCUserInfo *senderUserInfo = lastMessage.senderUserInfo;
        NSLog(@"发送者的昵称：%@，头像：%@",senderUserInfo.name,senderUserInfo.portraitUri);
    }
    
    RCConversationType type = ConversationType_PRIVATE;
    NSString *targetId = @"targetId";
    //获取某个会话，可以从con对象中获取该会话的未读消息数，是否置顶，最后一条消息（id，收发时间，收发状态），是否含有@消息
    RCConversation *con = [[RCIMClient sharedRCIMClient] getConversation:type targetId:targetId];
    NSLog(@"last message object name %@",con.objectName);
    
    //获取置顶会话的消息个数
    int messageCount = [[RCIMClient sharedRCIMClient] getMessageCount:type targetId:targetId];
    NSLog(@"top conversation count %d",messageCount);
    
    //删除特定类型的会话，并删除该会话中所有的消息
    BOOL success = [[RCIMClient sharedRCIMClient] clearConversations:arr];
    //删除某个会话，但是不会删除消息
    success = [[RCIMClient sharedRCIMClient] removeConversation:type targetId:targetId];
    //将某个会话置顶
    [[RCIMClient sharedRCIMClient] setConversationToTop:type targetId:targetId isTop:YES];
    
    [self rc_defaultUpdateUI];
}

/**
 *  会话中的草稿操作
 */
- (void)dealWithConversationDraft {
    RCConversationType type = ConversationType_PRIVATE;
    NSString *targetId = @"targetId";
    //获取会话的草稿
    NSString *draft = [[RCIMClient sharedRCIMClient] getTextMessageDraft:type targetId:targetId];
    //设置会话的草稿
    BOOL successs = [[RCIMClient sharedRCIMClient] saveTextMessageDraft:type targetId:targetId content:draft];
    //清除会话的草稿
    successs = [[RCIMClient sharedRCIMClient] clearTextMessageDraft:type targetId:targetId];
    
    [self rc_defaultUpdateUI];
}

/**
 *  未读消息数相关
 */
- (void)dealWithUnreadMessage {
    //获取全部未读消息的数量
    int unreadCount = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    
    //获取特定会话的未读消息数量
    RCConversationType type = ConversationType_PRIVATE;
    NSString *targetId = @"targetId";
    unreadCount = [[RCIMClient sharedRCIMClient] getUnreadCount:type targetId:targetId];
    
    //获取单聊，群聊，讨论组，系统会话的未读消息数量
    NSArray *arr = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION),
                     @(ConversationType_GROUP),@(ConversationType_SYSTEM)];
    unreadCount = [[RCIMClient sharedRCIMClient] getUnreadCount:arr];
    
    //清除某个会话的未读消息的未读状态
    BOOL success = [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:type targetId:targetId];
    
    //
    long long timestamp = 1000000;
    success = [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:type targetId:targetId time:timestamp];
    
    [self rc_defaultUpdateUI];
}

/**
 *  会话消息提醒，设置是否屏蔽某人、某群的消息提醒
 */
- (void)configConversatioMention {
    //设置会话的消息提醒
    RCConversationType type = ConversationType_PRIVATE;
    NSString *targetId = @"targetId";
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:type targetId:targetId isBlocked:YES success:^(RCConversationNotificationStatus nStatus) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //获取该该会话的消息提醒状态，设置完成之后可以通过该接口来查询是否设置成功
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:type targetId:targetId success:^(RCConversationNotificationStatus nStatus) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    [self rc_defaultUpdateUI];
}

/**
 *  全局消息提醒，屏蔽某个时间段内的消息提醒
 */
- (void)configGlobalMention {
    //屏蔽晚八点到早八点的消息提醒
    NSString *hour = @"20:00:00";
    int spanMins = 60*12;
    [[RCIMClient sharedRCIMClient] setNotificationQuietHours:hour spanMins:spanMins success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //移除之前的屏蔽
    [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //查询屏蔽的时间段
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    [self rc_defaultUpdateUI];
}

/**
 *  输入状态监听(单聊)
 */
- (void)setTypingStatus {
    //设置代理，设置给聊天页面，需要配合下面的代理方法
    [[RCIMClient sharedRCIMClient] setRCTypingStatusDelegate:self];
    
    //当对方在输文本或者录音的时候，对方调用下面这个方法发送一个消息状态，自己就会走上面这个代理的代理方法，然后在代理方法中给用户提示“对方正在输入...”等信息
    RCConversationType type = ConversationType_PRIVATE;
    NSString *targetId = @"targetId";
    NSString *objName = @"RC:TxtMsg";
    [[RCIMClient sharedRCIMClient] sendTypingStatus:type targetId:targetId contentType:objName];
    
    [self rc_defaultUpdateUI];
}

- (void)onTypingStatusChanged:(RCConversationType)conversationType targetId:(NSString *)targetId status:(NSArray *)userTypingStatusList {
    NSString *currentUserId;
    //如果是单聊并且targetId是当前用户，并且有输入状态数组有值
    if(ConversationType_PRIVATE == conversationType && [targetId isEqualToString:currentUserId] && userTypingStatusList.count > 0){
        RCUserTypingStatus *typingStatus = (RCUserTypingStatus *)userTypingStatusList[0];
        if ([typingStatus.contentType isEqualToString:[RCTextMessage getObjectName]]) {
            self.navigationItem.title = @"对方正在输入...";
        }else if ([typingStatus.contentType isEqualToString:[RCVoiceMessage getObjectName]]){
            self.navigationItem.title = @"对方正在说话...";
        }
    }
    
    [self rc_defaultUpdateUI];
}

/**
 *  黑名单操作(只适用单聊)，将对方添加到黑名单之后可以给对方发消息，但是对方不能给自己发消息
 */
- (void)dealWithBlackList {
    //设置黑名单
    NSString *targetId = @"targetId";
    [[RCIMClient sharedRCIMClient] addToBlacklist:targetId success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //移除黑名单
    [[RCIMClient sharedRCIMClient] removeFromBlacklist:targetId success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //检测某人是否在黑名单中
    [[RCIMClient sharedRCIMClient] getBlacklistStatus:targetId success:^(int bizStatus) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //获取已经设置的黑名单列表
    [[RCIMClient sharedRCIMClient] getBlacklist:^(NSArray *blockUserIds) {
        for(int i=0;i<blockUserIds.count;i++){
            NSLog(@"user %@ in your black list",blockUserIds[i]);
        }
    } error:^(RCErrorCode status) {
        
    }];
    
    [self rc_defaultUpdateUI];
}

/**
 *  讨论组操作
 */
- (void)dealWithDiscussion {
    //创建讨论组，成功之后该会话就能够通过getConversation获取到
    NSString *title = @"讨论组的标题";
    NSString *targetId1 = @"targetId1";
    NSString *targetId2 = @"targetId2";
    NSArray *arr = @[targetId1,targetId2];//邀请加入讨论组的成员列表
    __block NSString *disId = nil;
    [[RCIMClient sharedRCIMClient] createDiscussion:title userIdList:arr success:^(RCDiscussion *discussion) {
        //成功之后可以获取一个RCDiscussion对象，里面有discussionId，后面的操作都需要这个discussionId
        disId = discussion.discussionId;
        NSArray *userArr = discussion.memberIdList;
        for(int i=0;i<userArr.count;i++){
            NSLog(@"member id %@",userArr[i]);
        }
    } error:^(RCErrorCode status) {
        
    }];
    
    //往讨论组中批量添加新的用户，如果讨论组创建者没有开放加人权限，只能由创建者加人（默认开放加人权限）
    NSArray *newArr = @[@"targetId3"];
    [[RCIMClient sharedRCIMClient] addMemberToDiscussion:disId userIdList:newArr success:^(RCDiscussion *discussion) {
        //加人成功，这个时候需要更新UI
        NSArray *userArr = discussion.memberIdList;
        NSLog(@"current member count %zd",userArr.count);
    } error:^(RCErrorCode status) {
        
    }];
    
    //从讨论组中踢除一个用户(创建者才可以)，注：没有同时移除多个用户的接口
    NSString *targetId = @"targetId1";
    [[RCIMClient sharedRCIMClient] removeMemberFromDiscussion:disId userId:targetId success:^(RCDiscussion *discussion) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //退出讨论组
    [[RCIMClient sharedRCIMClient] quitDiscussion:disId success:^(RCDiscussion *discussion) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //获取讨论组信息，可以获取讨论组id，名称，创建者id，成员id列表，是否开发加人权限
    [[RCIMClient sharedRCIMClient] getDiscussion:disId success:^(RCDiscussion *discussion) {
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //设置讨论组名称
    NSString *newName = @"newDiscussionName";
    [[RCIMClient sharedRCIMClient] setDiscussionName:disId name:newName success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    //设置讨论组加人权限，成功之后一般成员也可以加人，但是一般成员是不能踢人的
    [[RCIMClient sharedRCIMClient] setDiscussionInviteStatus:disId isOpen:YES success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    [self rc_defaultUpdateUI];
}

/**
 *  聊天室相关操作
 */
- (void)dealWithChatRoom {
    //加入聊天室，如果存在id为chatRoomId的讨论组，那么直接加入；如果不存在那么直接创建一个id为chatRoomId的讨论组
    //从服务器获取count条历史消息，历史消息个数范围在(0,50]之间
    NSString *chatRoomId = @"chatRoomId";
    int count = 10;
    [[RCIMClient sharedRCIMClient] joinChatRoom:chatRoomId messageCount:count success:^{
        NSLog(@"加入聊天室%@成功",chatRoomId);
    } error:^(RCErrorCode status) {
        
    }];
    
    //加入一个id为chatRoomId的存在的聊天室，如果id为chatRoomId的聊天室不存在，那么就错误
    [[RCIMClient sharedRCIMClient] joinExistChatRoom:chatRoomId messageCount:count success:^{
        NSLog(@"加入聊天室%@成功",chatRoomId);
    } error:^(RCErrorCode status) {
        
    }];
    
    //退出讨论组
    [[RCIMClient sharedRCIMClient] quitChatRoom:chatRoomId success:^{
        NSLog(@"退出聊天室%@成功",chatRoomId);
    } error:^(RCErrorCode status) {
        
    }];
    
    //获取讨论组信息，并按照加入时间排序获取特定个数的成员信息
    int memberCount = 15;
    [[RCIMClient sharedRCIMClient] getChatRoomInfo:chatRoomId count:memberCount order:RC_ChatRoom_Member_Desc success:^(RCChatRoomInfo *chatRoomInfo) {
        //在RCChatRoomInfo中可以获取到聊天室id，聊天室memberCount个用户的信息，聊天室当前总的成员个数
        int totalMemberCount = chatRoomInfo.totalMemberCount;
        NSArray *users = chatRoomInfo.memberInfoArray;
        NSLog(@"当前聊天室总人数为%d，获取到详细信息的用户个数为%zd",totalMemberCount,users.count);
        
    } error:^(RCErrorCode status) {
        
    }];
    
    [self rc_defaultUpdateUI];
}

/**
 *  公众服务账号相关操作
 */
- (void)dealWithPublicService {
    __block NSString *pubicServiceId = nil;
    RCSearchType searchType = RC_SEARCH_TYPE_FUZZY;//模糊匹配
    NSString *keyWord = @"融云";//关键字
    //以模糊匹配的方法搜索关键字
    [[RCIMClient sharedRCIMClient] searchPublicService:searchType searchKey:keyWord success:^(NSArray *accounts) {
        //成功的话数组里面是RCPublicServiceProfile对象的数组
        if(accounts.count>0){
            RCPublicServiceProfile *psProfile = accounts[0];
            pubicServiceId = psProfile.publicServiceId;
        }
    } error:^(RCErrorCode status) {
        
    }];
    
    //按公众账号类型来搜索（应用内外的公众号）
    RCPublicServiceType serviceType = RC_APP_PUBLIC_SERVICE;
    [[RCIMClient sharedRCIMClient] searchPublicServiceByType:serviceType searchType:searchType searchKey:keyWord success:^(NSArray *accounts) {
        if(accounts.count>0){
            RCPublicServiceProfile *psProfile = accounts[0];
            NSString *psName = psProfile.name;
            NSString *psIntroduction = psProfile.introduction;
            NSLog(@"public service name %@ , introduction %@",psName,psIntroduction);
        }
    } error:^(RCErrorCode status) {
        
    }];
    
    //关注某个公众号
    [[RCIMClient sharedRCIMClient] subscribePublicService:serviceType publicServiceId:pubicServiceId success:^{
        NSLog(@"关注公众号%@成功",pubicServiceId);
    } error:^(RCErrorCode status) {
        
    }];
    
    //取消关注某个公众号
    [[RCIMClient sharedRCIMClient] unsubscribePublicService:serviceType publicServiceId:pubicServiceId success:^{
        NSLog(@"取消关注公众号%@成功",pubicServiceId);
    } error:^(RCErrorCode status) {
        
    }];
    
    RCPublicServiceProfile *psProfile = nil;
    //获取已经关注的公众账号的列表，里面是RCPublicServiceProfile数组
    NSArray *psArray = [[RCIMClient sharedRCIMClient] getPublicServiceList];
    if(psArray.count>0){
        psProfile = psArray[0];
    }
    
    //获取特定公众服务账号的信息，该方法从本地缓存中拿
    psProfile = [[RCIMClient sharedRCIMClient] getPublicServiceProfile:serviceType publicServiceId:pubicServiceId];
    
    //获取特定公众服务账号的信息，该方法从服务器拿
    RCConversationType type = ConversationType_APPSERVICE;//这个类型只能选7和8
    [[RCIMClient sharedRCIMClient] getPublicServiceProfile:pubicServiceId conversationType:type onSuccess:^(RCPublicServiceProfile *serviceProfile) {
        
    } onError:^(NSError *error) {
        
    }];
    
    //根据url打开一个webview
    NSString *url = @"www.rongcloud.cn";
    UIViewController *vc = [[RCIMClient sharedRCIMClient] getPublicServiceWebViewController:url];
    [self.navigationController pushViewController:vc animated:YES];
    
    [self rc_defaultUpdateUI];
}

/**
 * 推送业务数据统计相关操作
 */
- (void)dealWithPushDatastatistics {
    NSString *tips = @"参考appdelegate中的实现，在AppDelegate中搜索‘推送数据统计’";
    NSLog(@"%@",tips);
    [self.headerView updateTitleLabelText:tips andIsOK:YES];
}

/**
 *  工具类方法
 */
- (void)dealWithUtilMethod {
    //获取sdk版本号，如2.7.2
    NSString *sdkVersion = [[RCIMClient sharedRCIMClient] getSDKVersion];
    NSLog(@"current IMLib sdk version %@",sdkVersion);
    
    //音频数据AMR格式转WAV格式
    NSData *amrData = nil;
    NSData *wavData = [[RCIMClient sharedRCIMClient] decodeAMRToWAVE:amrData];
    
    //音频数据WAV格式转AMR格式，（8KHz采样）
    amrData = [[RCIMClient sharedRCIMClient] encodeWAVEToAMR:wavData channel:1 nBitsPerSample:16];
    
    //设置日志级别，设置为info，保证能打印更多的log信息，方便根据log查找问题
    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Info;
    //获取文件消息的下载路径,您可以通过修改RCConfig.plist中的RelativePath来修改该路径
    NSString *filePath = [RCIMClient sharedRCIMClient].fileStoragePath;
    NSLog(@"current file download path %@",filePath);
    
    [self rc_defaultUpdateUI];
}

/**
 *  客服相关操作
 */
- (void)dealWithCustomService {
    NSString *kefuId = @"kefuId";
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc]init];
    [[RCIMClient sharedRCIMClient] startCustomerService:kefuId info:csInfo onSuccess:^(RCCustomerServiceConfig *config) {
        //连接客服成功
    } onError:^(int errorCode, NSString *errMsg) {
        //连接客服失败
    } onModeType:^(RCCSModeType mode) {
        switch (mode) {
            case RC_CS_RobotOnly://机器人客服
                //切换到人工客服
                [[RCIMClient sharedRCIMClient] switchToHumanMode:kefuId];
                break;
            case RC_CS_HumanOnly://人工客服
                break;
            case RC_CS_RobotFirst://机器人客服优先
                break;
            case RC_CS_NoService://无客服
                break;
            default:
                break;
        }
    } onPullEvaluation:^(NSString *dialogId) {
        //客服请求评价
        //评价机器人客服
        [[RCIMClient sharedRCIMClient] evaluateCustomerService:kefuId knownledgeId:nil robotValue:YES suggest:@"这个机器还可以"];
        
        //评价人工客服，5星好评
        [[RCIMClient sharedRCIMClient] evaluateCustomerService:kefuId dialogId:dialogId humanValue:5 suggest:@"这货谁呀"];
    } onSelectGroup:^(NSArray<RCCustomerServiceGroupItem *> *groupList) {
        if (groupList && groupList.count > 0) {
            RCCustomerServiceGroupItem *item = groupList[0];
            NSString *groupId = item.groupId;
            [[RCIMClient sharedRCIMClient] selectCustomerServiceGroup:groupId withGroupId:nil];
        }
        
    } onQuit:^(NSString *quitMsg) {
        //退出客服
    }];
    
    //结束客服聊天，当离开客服页面的时候调用此方法结束与客服的聊天
    [[RCIMClient sharedRCIMClient] stopCustomerService:kefuId];
    
    [self rc_defaultUpdateUI];
}



- (void)setCurrentUserInfo:(RCUserInfo *)currentUserInfo {
    self.userId = currentUserInfo.userId;
    if([self.userId isEqualToString:user1Key]){
        self.targetId = user2Key;
    }else {
        self.targetId = user1Key;
    }
    self.rongCloudToken = [RCDUserDefaults getTokenOfUserInfo:self.userId];
    _currentUserInfo = currentUserInfo;
    
    [self rc_defaultUpdateUI];
}


- (void)rc_defaultUpdateUI {
    [self.headerView updateTitleLabelText:@"参考源码的实现" andIsOK:NO];
}


- (void)unimplementMethod {
    [self.headerView updateTitleLabelText:@"该方法未实现" andIsOK:NO];
}

#pragma mark - notification methods
- (void)receiveMessageHasReadNotification:(NSNotification *)notification {
    NSNumber *ctype = [notification.userInfo objectForKey:@"cType"];
    NSNumber *time = [notification.userInfo objectForKey:@"messageTime"];
    NSString *targetId = [notification.userInfo objectForKey:@"tId"];
    NSString *fromUserId = [notification.userInfo objectForKey:@"fId"];
    if ([fromUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:[ctype unsignedIntegerValue] targetId:targetId time:[time longLongValue]];
    }
    
}

//收到消息的通知
- (void)hasReceiveMessage:(NSNotification *)noti {
    RCMessage *message = noti.object;
    NSDictionary *dictLeft = noti.userInfo;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tipView show];
        if([message.content isMemberOfClass:[RCTextMessage class]]){
            RCTextMessage *txtMsg = (RCTextMessage *)message.content;
            [weakSelf.tipView updateContentText:txtMsg.content];
        }else if ([message.content isMemberOfClass:[RCImageMessage class]]){
            RCImageMessage *imgMsg = (RCImageMessage *)message.content;
            [weakSelf.tipView updateImageView:imgMsg.thumbnailImage];
        }
        [weakSelf.tipView updateLeftTip:[NSString stringWithFormat:@"%@",dictLeft[@"rcLeft"]]];
    });
    
}

//收到对方的消息撤回请求，当自己这边收到对方撤回的消息A之后，sdk会自动将A消息替换成一个RCRecallNotificationMessage，这个时候检测当前页面有这条消息的时候，当前页面需要刷新UI，如果当前页面不存在，则无需处理，当进入到撤回消息所在页面，撤回消息能自动刷新
- (void)hasReceivedMessageRecalledNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    long msgId = [dic[@"msgId"] longValue];
    //此时已经知道对方想要撤回id为msgId的消息
    NSArray *msgArr = [NSArray array];//假如msgArr是当前聊天页面的所有消息的数据源
    for(RCMessage *msg in msgArr){
        //如果当前页面的消息中包含对方想要撤回的消息，那么当前页面需要删除此消息并更新UI
        if(msg.messageId == msgId){
            //更新UI
        }
    }
    
}

//收到对方发送的已读消息回执的请求（对方调用了RCIMClient的sendReadReceiptRequest）
- (void)hasReceivedMessageReceiptRequestNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    RCConversationType type = [dic[@"conversationType"] integerValue];
    NSString *targetId = dic[@"targetId"];
    NSString *messageUId = dic[@"messageUId"];
    
    //接收方这么处理
    NSArray *messageArray = [NSArray array];//当前页面所有消息体所在的数组，demo用空数组表示
    for (int i = 0;i < messageArray.count;i++) {
        RCMessage *model = messageArray[i];
        //如果检测到当前页面的消息中包含了对方要求已读回执的消息，那么自己这里就需要想群里发一条消息已读响应，告诉对方自己已经读了这条消息
        if ([model.messageUId isEqualToString:messageUId] && model.messageDirection == MessageDirection_RECEIVE) {
            RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:model.messageId];
            NSArray *msgList = [NSArray arrayWithObject:msg];
            //收到对方的已读回执请求，并且自己的页面里面有这条消息，那么自己给对方发一个已读回执的相应
            [[RCIMClient sharedRCIMClient]sendReadReceiptResponse:type targetId:targetId messageList:msgList success:^{
                
            } error:^(RCErrorCode nErrorCode) {
                
            }];
            if (!model.readReceiptInfo) {
                model.readReceiptInfo = [[RCReadReceiptInfo alloc]init];
            }
            //设置一下
            model.readReceiptInfo.isReceiptRequestMessage = YES;
            model.readReceiptInfo.hasRespond = YES;
        }
    }
    
}
//收到对方发送的已读消息回执的响应（对方调用了RCIMClient的sendReadReceiptResponse）
- (void)hasReceivedMessageReceiptResponseNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    RCConversationType type = [dic[@"conversationType"] integerValue];
    NSString *targetId = dic[@"targetId"];
    NSString *messageUId = dic[@"messageUId"];
    
    RCConversationType currentConversationType = ConversationType_GROUP;//当前页面的会话类型
    NSString *currentId = @"groupid";
    NSArray *messageArray = [NSArray array];//当前页面所有消息体所在的数组，demo用空数组表示
    //如果是当前的回话类型，并且是当前的这个群组会话
    if([currentId isEqualToString:targetId] && currentConversationType == type){
        for (int i = 0;i < messageArray.count;i++) {
            RCMessage *model = messageArray[i];
            if ([model.messageUId isEqualToString:messageUId] && model.messageDirection == MessageDirection_SEND) {
                //说明对方已经已经收到了你的那条消息并给出了已读响应
                //那么这个时候需要更新UI，来告诉用户有多少人已经读了他的那条消息
            }
        }
    }
}

- (void)dealloc {
    //移除所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
