//
//  CMAsyncSocket.h
//  sockLib
//
//  Created by Howard Dong on 14-1-20.
//
//

#import<stdio.h>
#import<sys/types.h>
#import<MacTypes.h>
#import<pthread.h>
#import<sys/types.h>
#import<sys/socket.h>
#import<netinet/in.h>
#import<arpa/inet.h>
#import<netdb.h>
#import<sys/ioctl.h>
#import<stdlib.h>
#import<errno.h>
#import<unistd.h>
#import<string.h>
#import<fcntl.h>
#import<signal.h>
#import<CFNetwork/CFNetwork.h>

typedef unsigned long DWORD;

// 网络状态类型
typedef enum _NetStatusType
{
	NET_DONOTCON           = 1, 		// 不能连接网络，或者网络断开
	NET_CONTIMEOUT         = 2, 		// 链接超时
	NET_DONOTCONPROXY      = 3, 		// 代理服务器连接失败
    NET_SENDDATAFAIL       = 4,        // 发送数据失败
    NET_RCVDATAERR         = 5,        // 接收数据错误
    NET_SENVERIFYDATAFAIL  = 6,        // 代理服务器发送用户验证数据失败
    NET_RCVVERIFYDATAERR   = 7,        // 代理服务器返回用户验证数据错误
    NET_PROXYNEEDVERIFY    = 8,        // 代理服务器需要用户验证
    NET_PROXYINFOERR       = 9,        // 代理设置错误
	NET_SOCKCLOSE          = 10, 		// 连接关闭
    NET_NOSERVERINFO       = 11,       // 无服务器地址信息
    NET_NETWORKERR         = 12, 		// 本地网络异常
    NET_REQUESTOVERSIZE    = 13,       // 请求超出最大个数
}NetStatusType;

// 代理类型
typedef enum
{
	SocketProxy_None            = 1,
	SocketProxy_HTTP11			= 2,
	SocketProxy_SOCKS4			= 3,
	SocketProxy_SOCKS4A			= 4,
	SocketProxy_SOCKS5			= 5,
}CMAsyncSocketProxyType;


#pragma mark - socket 连接服务器信息
@interface ServerDataInfo : NSObject
@property (nonatomic, copy) NSString *serverAddr;           // 服务器地址
@property (nonatomic) unsigned short port;                  // 服务器端口
@property (nonatomic) unsigned short connectTimes;          // 当前服务器连接次数

@end


#pragma mark - 代理服务器信息
@interface ProxyDataInfo : NSObject
@property (nonatomic, copy) NSString *proxyServerAddr;      // 代理服务器地址
@property (nonatomic, copy) NSString *userName;             // 代理服务器验证用户名
@property (nonatomic, copy) NSString *password;             // 代理服务器验证用户密码
@property (nonatomic) unsigned short port;                  // 代理服务器端口
@property (nonatomic) BOOL isValidate;                      // 代理服务器是否有用户验证
@property (nonatomic) unsigned char ucConnectType;          // 代理服务器类型

@end

#pragma mark - 网络线程基础数据
@interface NetThreadBasicData : NSObject
@property (nonatomic, retain) ServerDataInfo *serverInfo;
@property (nonatomic) unsigned int unServerIP;
@property (nonatomic, retain) NSMutableArray *requestQueue;     // 数据发送队列，数据项=>NSMutableData

@end


@protocol CMAsyncSocketDelegate;

@interface CMAsyncSocket : NSObject
{
@public
    pthread_mutex_t mutexNetRequest;
}

@property (nonatomic, assign) int sockFd;                       // socket 句柄
@property (nonatomic, assign) int maxConnTimes;                 // 最大连接次数
@property (nonatomic, assign) int netAliveTimeout;              // 网络ALIVE
@property (nonatomic, assign) int netConnTimeout;               // 网络连接超时时间，单位秒
@property (nonatomic, assign) int netConnRepCount;              // 网络连接重复次数
@property (nonatomic, assign) unsigned int maxRequestNum;       // 最大请求个数
@property (nonatomic, assign) unsigned int recvWaitTime;        // 接收等待时间(单位毫秒)
@property (nonatomic, assign) unsigned int sendWaitTime;        // 发送等待时间(单位毫秒)
@property (nonatomic, assign) unsigned int recvBufLen;          // 接收数据缓冲区大小
@property (nonatomic, assign) BOOL isThreadStatus;              // 线程状态
@property (nonatomic, assign) BOOL isAutoClose;                 // 是否自动关闭socket链接
@property (nonatomic, assign) BOOL isBlockMode;                 // 是否阻塞模式
@property (nonatomic, assign) id<CMAsyncSocketDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *serverInfoList;   // 服务器地址信息=>数据项ServerDataInfo
@property (nonatomic, retain) ProxyDataInfo *proxyData;         // 代理基本信息
@property (nonatomic, retain) ServerDataInfo *localAddrInfo;  // 本地ip基本信息
@property (nonatomic, retain) NetThreadBasicData *requestData;

@property (nonatomic, assign) BOOL isTrade;         //是否委托使用的socket

+ (int)setNoBlockMode:(int)fd isNoBlock:(BOOL)isNoBlock;
+ (int)canRead:(int)fd waitSecTime:(int)waitSeconds waitMiniSecTime:(int)waitMiniSeconds;
+ (int)canWrite:(int)fd waitSecTime:(int)waitSeconds waitMiniSecTime:(int)waitMiniSeconds;
+ (int)select:(int)maxFd readSet:(fd_set *)readSet writeSet:(fd_set *)writeSet exceptSet:(fd_set *)exceptSet timeOut:(struct timeval *)timeOut;
+ (int)connectTimeOut:(int)fd sockAddrInf:(const struct sockaddr *)sockAddrInf sockLength:(socklen_t)sockLength seconds:(int)seconds isBlock:(BOOL)isBlock;
+ (int)connect:(const char *)host port:(unsigned short)port seconds:(int)seconds isBlock:(BOOL)isBlock;

#pragma mark - 设置服务器信息
- (BOOL)addServerInfo:(NSString *)host port:(unsigned short)port;

#pragma mark - 清除服务器信息
- (void)clearServerInfo;

#pragma mark - 再服务器信息列表中移除某台服务器信息
- (void)removeServerInfo:(NSString *)host port:(unsigned short)port;

#pragma mark - 更新服务器状态
- (int)changeConnTimes:(NSString *)host prot:(unsigned short)port;
- (BOOL)resetConnTimes:(NSString *)host prot:(unsigned short)port;

#pragma mark - 获取当前服务器列表索引序号
- (int)getCurSerInfoIndex;

#pragma mark - 获取随机服务器地址信息及端口
- (ServerDataInfo *)getRandomServerAddr;

- (BOOL)initialInstance:(NSString *)hostName port:(unsigned short)port isAutoClose:(BOOL)isAutoClose;
- (void)endInstance;
- (void)cancleNetData;
- (int)getAskNum;
- (BOOL)sendNetAsk:(NSData *)pData;

- (int)recvUnknowLen:(int)fd pData:(void *)ptr maxLen:(int)maxLen second:(int)nSecond miniSec:(int)nMiniSec;
- (int)recv:(int)fd pData:(void *)ptr bytes:(unsigned long)nbytes second:(int)nSecond miniSec:(int)nMiniSec;
- (int)send:(int)fd pData:(const void *)ptr bytes:(int)nbytes second:(int)nSecond miniSec:(int)nMiniSec;

#pragma mark - 代理设置
- (void)setProxyInfo;
- (void)clearProxyInfo;
- (BOOL)addProxyInfo:(NSString *)host port:(unsigned short)port validate:(bool)isValidate username:(NSString *)user password:(NSString *)pwd type:(unsigned char)type;

- (int)connectServer;
- (int)connectProxyServer;
- (int)connectSock4or4A;
- (int)connectSock5;
- (int)connectHttp11;

@end


@protocol CMAsyncSocketDelegate <NSObject>
@optional
// 连接已成功回调
- (void)rawNetworkInThread:(CMAsyncSocket *)net didConnectToHost:(NSString *)host port:(UInt16)port;

// 连接断开回调
- (void)rawNetworkInThread:(CMAsyncSocket *)net willDisconnectWithError:(NSInteger)errCode;

// 接收数据
- (void)rawNetworkInThread:(CMAsyncSocket *)net didRecvData:(NSData *)data;

// 发送数据
- (void)rawNetworkDidSendDataInThread:(CMAsyncSocket *)net dataLen:(NSUInteger)dataLen;

// 因为发送请求超出最大个数，移除最开始发送数据
- (void)rawNetworkSendDataRemovedInThread:(CMAsyncSocket *)net;

@end
