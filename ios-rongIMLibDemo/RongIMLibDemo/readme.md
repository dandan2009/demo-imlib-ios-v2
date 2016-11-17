sdk里面所有的代理建议设置给单例类或者AppDelegate，这样保证整个app的声明周期中sdk的代理方法都能够正常使用，如果设置给登录页面等普通VC，不知道什么时候就被系统销毁了，那么就没办法正常调用了

融云集成过程中常见问题的知识库
导出数据库：http://support.rongcloud.cn/kb/Mzk4
数据库所在路径：http://support.rongcloud.cn/kb/MzYx
log重定向：http://support.rongcloud.cn/kb/NDI0
自定义会话列表cell：http://support.rongcloud.cn/kb/MjUz
自定义消息和cell：http://support.rongcloud.cn/kb/MzIz
demo(sealtalk源码)下载地址：参见官网sdk下载页面
直播聊天室地址：参见官网sdk下载页面
弹幕功能参考：http://support.rongcloud.cn/kb/NTQx
iOS8定位不准：http://support.rongcloud.cn/kb/NDEw
收不到推送排查步骤：http://support.rongcloud.cn/kb/MzEy
远程推送和本地通知的区别：http://support.rongcloud.cn/kb/Mjk4
添加好友流程：http://support.rongcloud.cn/kb/MzQ5
与blockKit冲突：http://support.rongcloud.cn/kb/MzI1
音视频通话收到远程推送，弹不出接听页面：http://support.rongcloud.cn/kb/NTI1
适配iOS10的注意事项：http://support.rongcloud.cn/kb/NTI5
使用直播聊天室的SDK后，如何再集成IMKit：http://support.rongcloud.cn/kb/NTI4

sdk获取、展示用户信息的流程：如果你发送消息的时候携带了用户信息，sdk直接从接收到的消息体里面拿用户信息；如果没有携带sdk在需要使用用户信息的时候，先在缓存中查找，如果缓存中不存在，sdk会调用getUserInfo的代理方法获取，然后保存到缓存中(你需要通过getUserInfo方法的block将用户信息传给sdk，参考demo的RCDRCIMDataSource中相关方法的实现)；如果缓存中存在，直接使用；如果你开启了用户信息持久化(RCIM的enablePersistentUserInfoCache设置为yes)，每次app被杀死之后缓存中的用户信息会被保存，再次启动app的时候sdk会把保存的用户信息会自动加载到缓存中；如果没有开启，缓存的用户信息在app被杀死之后就会被删除
