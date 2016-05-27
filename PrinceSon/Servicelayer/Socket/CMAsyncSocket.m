//
//  CMAsyncSocket.m
//  sockLib
//
//  Created by Howard Dong on 14-1-20.
//
//

#import "CMAsyncSocket.h"
#import "CMLogManagement.h"
#import<pthread.h>

#define MAXRECVBUFLEN               500 * 1024					// 接收缓冲区长度
#define RECVINTERVAL				100							// 网络接收等待时间，单位毫秒
#define SENDINTERVAL				100							// 网络发送等待时间，单位毫秒

//static void decodeQuantum(unsigned char *dest, const char *src)
//{
//	unsigned int x = 0;
//	int i;
//	char *found;
//	
//	static const char table64[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
//	
//	for(i = 0; i < 4; i++) {
//		if((found = strchr(table64, src[i])) != NULL)
//			x = (x << 6) + (unsigned int)(found - table64);
//		else if(src[i] == '=')
//			x = (x << 6);
//	}
//	
//	dest[2] = (unsigned char)(x & 255);
//	x >>= 8;
//	dest[1] = (unsigned char)(x & 255);
//	x >>= 8;
//	dest[0] = (unsigned char)(x & 255);
//}

//static void BlockSpecialSignalInfo()
//{
//    signal(SIGINT,SIG_IGN);
//	signal(SIGPIPE,SIG_IGN);
//	signal(SIGEMT,SIG_IGN);
//	signal(SIGPROF,SIG_IGN);
//	signal(SIGVTALRM,SIG_IGN);
//	signal(SIGALRM,SIG_IGN);
//	signal(SIGBUS,SIG_IGN);
//    signal(SIGTTOU,SIG_IGN);
//    signal(SIGTTIN,SIG_IGN);
//    signal(SIGTSTP,SIG_IGN);
//    signal(SIGHUP ,SIG_IGN);
//	signal(SIGABRT,SIG_IGN);
//}

#pragma mark - thread callback function
static void* NetThreadProcFunc(void* param)
{
    @autoreleasepool
    {
        int			i;
        int			nDataLen;
        int			nTimeCount  = 0;
        int			nReConCount = 0;
        int			nSendPos    = 0;
        int			fd          = -1;
        CMAsyncSocket *idSelf   = (CMAsyncSocket *)param;
        char*		pRecvBuf    = malloc(idSelf.recvBufLen);
        NSMutableData *sendBuf  = nil;
        
#if CMLOG_NETWORK_INFO
        
         CMLogInfo(@"----idSelf.isThreadStatus:%d  ", idSelf.isThreadStatus);
#endif
        while (idSelf.isThreadStatus)
        {
            if (fd < 0)
            {
                for (i = 0; i < idSelf.netConnRepCount; i++)
                {
                    if ((fd = [idSelf connectServer]) >= 0)
                    {
                        struct sockaddr_in local;
                        socklen_t laddrlen = sizeof(struct sockaddr_in);
                        if (!idSelf.localAddrInfo)
                        {
                            idSelf.localAddrInfo = [[[ServerDataInfo alloc] init] autorelease];
                            int status = getsockname(fd, (struct sockaddr *)&local, &laddrlen);
                            if (status >= 0)
                            {
                                idSelf.localAddrInfo.serverAddr = [NSString stringWithUTF8String:inet_ntoa(local.sin_addr)];
                                idSelf.localAddrInfo.port       = ntohs(local.sin_port);
//                                CMLogDebug(@"!> -->status:%d local Address:%@ port is %d", status, idSelf.localAddrInfo.serverAddr, idSelf.localAddrInfo.port);
                            }
                        }
                        
                        [CMAsyncSocket setNoBlockMode:fd isNoBlock:idSelf.isBlockMode];
                        nTimeCount 	= 0;
                        nSendPos 	= 0;
                        
                        if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkInThread:didConnectToHost:port:)])
                        {
                            ServerDataInfo *svrInfo = idSelf.requestData.serverInfo;
                            [idSelf.delegate rawNetworkInThread:idSelf didConnectToHost:svrInfo.serverAddr port:svrInfo.port];
                        }
                        
                        break;
                    }
                }
                
                if (i == idSelf.netConnRepCount)//连接失败通知客户
                {
                    CMLogError(@"!> connect SOCK_NET_DONOTCON");
                    if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                        [idSelf.delegate rawNetworkInThread:idSelf willDisconnectWithError:NET_DONOTCON];
                    break;
                    sleep(3000);
                }
            }
            else
            {
                if ([CMAsyncSocket canRead:fd waitSecTime:0 waitMiniSecTime:idSelf.recvWaitTime])
                {
                    //接收数据
                    memset(pRecvBuf, 0, idSelf.recvBufLen);
                    nDataLen = recv(fd, pRecvBuf, idSelf.recvBufLen, 0);
#if CMLOG_NETWORK_INFO
                    if (idSelf.isTrade)
                    {
                        CMLogInfo(@"----recv len:%d  error:%d istrade:%d", nDataLen, errno, idSelf.isTrade);
                    }
#endif
                    if (nDataLen > 0)
                    {
                        if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkInThread:didRecvData:)])
                            [idSelf.delegate rawNetworkInThread:idSelf didRecvData:[NSData dataWithBytes:pRecvBuf length:nDataLen]];
                        
                        nTimeCount 	= 0;
                        nReConCount = 0;
                    }
                    else if (nDataLen == 0)
                    {
                        if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                                [idSelf.delegate rawNetworkInThread:idSelf willDisconnectWithError:NET_SOCKCLOSE];
                        close(fd);
                        fd = -1;
                    }else{
                        if (errno == EWOULDBLOCK || errno == EAGAIN || errno == EINTR) {
                            //等待下一次接收
                            continue;
                        }else{
                            if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                                [idSelf.delegate rawNetworkInThread:idSelf willDisconnectWithError:NET_SOCKCLOSE];
                            close(fd);
                            fd = -1;
                        }
                    }
                }
                
                if (([idSelf.requestData.requestQueue count] > 0 || [sendBuf length] > 0) && fd >= 0 && [CMAsyncSocket canWrite:fd waitSecTime:0 waitMiniSecTime:idSelf.sendWaitTime])
                {
                    //发送数据
                    if (sendBuf && !nSendPos && [idSelf.requestData.requestQueue count] > idSelf.maxRequestNum / 2)
                    {
                        //重新连接且有较多数据要发送，对未发送的请求删除
                        sendBuf = nil;
                    }
                    
                    if (!sendBuf && [idSelf.requestData.requestQueue count] > 0)
                    {
                        id data = [idSelf.requestData.requestQueue.firstObject retain];
                        if (data) {
                            pthread_mutex_lock(&(idSelf->mutexNetRequest));
                            sendBuf = [NSMutableData dataWithData:data];
                            [idSelf.requestData.requestQueue removeObject:data];
                            [data release];
                            pthread_mutex_unlock(&(idSelf->mutexNetRequest));
                        }
                    }
                    
                    char *sendData = (char *)[sendBuf bytes];
                    nDataLen = send(fd, sendData+nSendPos, [sendBuf length]-nSendPos, 0);
#if CMLOG_NETWORK_INFO
                    if (idSelf.isTrade)
                    {
                        CMLogInfo(@"----send len:%d, data size:%d error:%d istrade:%d", nDataLen, [sendBuf length], errno, idSelf.isTrade);
                    }
#endif
                    if (nDataLen > 0)
                    {
                        nTimeCount 	= 0;
                        nReConCount = 0;
                        
                        if (nDataLen == [sendBuf length])
                        {
                            nSendPos    = 0;
                            sendBuf     = nil;
                        }
                        else
                        {
                            nSendPos += nDataLen;
                        }
                        
                        if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkDidSendDataInThread:dataLen:)])
                            [idSelf.delegate rawNetworkDidSendDataInThread:idSelf dataLen:nDataLen];
                    }
                    else if (EWOULDBLOCK != errno)
                    {
                        if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                            [idSelf.delegate rawNetworkInThread:idSelf willDisconnectWithError:NET_SOCKCLOSE];
                        close(fd);
                        fd = -1;
                    }
                }
                
                nTimeCount++;
                // 链接创建成功，却连续无收发数据次数超过最大次数
                if (fd >= 0 && idSelf.netAliveTimeout < nTimeCount)
                {  
                    nReConCount++;
                    //timeout
                    close(fd);
                    fd = -1;
                    if (nReConCount >= idSelf.maxConnTimes)
                    {
                        CMLogError(@"send fail NET_CONTIMEOUT\n");
                        //达到最大重试连接次数后，连接成功却不能收到数据
                        if (idSelf.delegate && [idSelf.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                            [idSelf.delegate rawNetworkInThread:idSelf willDisconnectWithError:NET_CONTIMEOUT];
                        break;
                    }
                }
            }
        }
        
        if (fd >= 0) close(fd);
        if (pRecvBuf) free(pRecvBuf);
        
        pthread_mutex_lock(&(idSelf->mutexNetRequest));
        idSelf.requestData = nil;
        [idSelf clearProxyInfo];
        pthread_mutex_unlock(&(idSelf->mutexNetRequest));
        idSelf.isThreadStatus = NO;
        
        CMLogError(@"!> Thread end\n");
        
        return NULL;
    }
}


#pragma mark - socket 连接服务器信息
@implementation ServerDataInfo
@synthesize serverAddr      = _serverAddr;          // 服务器地址
@synthesize port            = _port;                // 服务器端口
@synthesize connectTimes    = _connectTimes;        // 当前服务器连接次数

- (void)dealloc
{
    self.serverAddr = nil;
    [super dealloc];
}

@end

#pragma mark - 代理服务器信息

@implementation ProxyDataInfo
@synthesize proxyServerAddr;        // 代理服务器地址
@synthesize userName;               // 代理服务器验证用户名
@synthesize password;               // 代理服务器验证用户密码
@synthesize port;                   // 代理服务器端口
@synthesize isValidate;             // 代理服务器是否有用户验证
@synthesize ucConnectType;          // 代理服务器类型

- (void)dealloc
{
    self.proxyServerAddr    = nil;
    self.userName           = nil;
    self.password           = nil;
    [super dealloc];
}

@end

#pragma mark - 网络线程基础数据
@implementation NetThreadBasicData : NSObject
@synthesize serverInfo;
@synthesize unServerIP;
@synthesize requestQueue;     // 数据发送队列，数据项=>ServerDataInfo

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.requestQueue = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

- (void)dealloc
{
    self.serverInfo     = nil;
    self.requestQueue   = nil;
    [super dealloc];
}

@end


#pragma mark - CMAsyncSocket
@interface CMAsyncSocket ()

- (int)base64Decode:(unsigned char *)dst dlen:(int *)dlen src:(unsigned char *)src slen:(int)slen;
- (unsigned int)urlBase64Encode:(const char *)inp insize:(unsigned int)insize outptr:(char **)outptr;

@end


@implementation CMAsyncSocket
@synthesize sockFd          = _sockFd;                      // socket 句柄
@synthesize maxConnTimes    = _maxConnTimes;                // 最大连接次数
@synthesize netAliveTimeout = _netAliveTimeout;             // 网络ALIVE
@synthesize netConnTimeout  = _netConnTimeout;              // 网络连接超时时间，单位秒
@synthesize netConnRepCount = _netConnRepCount;             // 网络连接重复次数
@synthesize maxRequestNum   = _maxRequestNum;               // 最大请求个数
@synthesize recvWaitTime    = _recvWaitTime;                // 接收等待时间(单位毫秒)
@synthesize sendWaitTime    = _sendWaitTime;                // 发送等待时间(单位毫秒)
@synthesize recvBufLen      = _recvBufLen;                  // 接收数据缓冲区大小
@synthesize isThreadStatus  = _isThreadStatus;              // 线程状态
@synthesize isAutoClose     = _isAutoClose;                 // 是否自动关闭socket链接
@synthesize isBlockMode     = _isBlockMode;                 // 是否阻塞模式
@synthesize delegate        = _delegate;
@synthesize serverInfoList  = _serverInfoList;              // 服务器地址信息
@synthesize proxyData       = _proxyData;                   // 代理基本信息
@synthesize localAddrInfo   = _localAddrInfo;               // 本地ip基本信息
@synthesize requestData     = _requestData;                 // 基础请求数据

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _isThreadStatus     = NO;
        _isBlockMode        = YES;
        _isAutoClose        = NO;
        _maxConnTimes       = 2;
        _netAliveTimeout    = 400;
        _netConnRepCount    = 3;
        _netConnTimeout     = 7;
        _maxRequestNum      = 10;
        _recvWaitTime       = RECVINTERVAL;
        _sendWaitTime       = SENDINTERVAL;
        _recvBufLen         = MAXRECVBUFLEN;
        pthread_mutex_init(&mutexNetRequest, NULL);
    }
    
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&mutexNetRequest);
    self.requestData        = nil;
    self.serverInfoList     = nil;
    self.proxyData          = nil;
    self.delegate           = nil;
    self.localAddrInfo      = nil;
    
    [super dealloc];
}

#pragma mark - private methods
- (int)base64Decode:(unsigned char *)dst dlen:(int *)dlen src:(unsigned char *)src slen:(int)slen
{
    int i, j, n;
	unsigned long x;
	unsigned char *p;
	const unsigned char base64_dec_map[128] =
	{
		127, 127, 127, 127, 127, 127, 127, 127, 127, 127,
		127, 127, 127, 127, 127, 127, 127, 127, 127, 127,
		127, 127, 127, 127, 127, 127, 127, 127, 127, 127,
		127, 127, 127, 127, 127, 127, 127, 127, 127, 127,
		127, 127, 127, 62, 127, 127, 127, 63, 52, 53,
		54, 55, 56, 57, 58, 59, 60, 61, 127, 127,
		127, 64, 127, 127, 127, 0, 1, 2, 3, 4,
		5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
		15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
		25, 127, 127, 127, 127, 127, 127, 26, 27, 28,
		29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
		39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
		49, 50, 51, 127, 127, 127, 127, 127
	};
	
	for( i = j = n = 0; i < slen; i++ )
	{
		if((slen - i) >= 2 && src[i] == '\r' && src[i + 1] == '\n')
			continue;
		
		if(src[i] == '\n')
			continue;
		
		if(src[i] == '=' && ++j > 2)
			return(-2);
		
		if(src[i] > 127 || base64_dec_map[src[i]] == 127)
			return(-2);
		
		if(base64_dec_map[src[i]] < 64 && j != 0)
			return(-2);
		
		n++;
	}
	
	if(n == 0)
		return(0);
	
	n = ((n * 6) + 7) >> 3;
	
	if (*dlen < n)
	{
		*dlen = n;
		return(-1);
	}
	
	for(j = 3, n = x = 0, p = dst; i > 0; i--, src++)
	{
		if(*src == '\r' || *src == '\n')
			continue;
		
		j -= (base64_dec_map[*src] == 64);
		x = (x << 6) | (base64_dec_map[*src] & 0x3F);
		
		if(++n == 4)
		{
			n = 0;
			if(j > 0) *p++ = (unsigned char)(x >> 16);
			if(j > 1) *p++ = (unsigned char)(x >> 8);
			if(j > 2) *p++ = (unsigned char)(x);
		}
	}
	
	*dlen = p - dst;
	
	return(0);
}

- (unsigned int)urlBase64Encode:(const char *)inp insize:(unsigned int)insize outptr:(char **)outptr
{
    unsigned char ibuf[3];
	unsigned char obuf[4];
	int i;
	int inputparts;
	char *output;
	char *base64data;
	const char table64[]=  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	char *indata = (char *)inp;
	
	*outptr = NULL; /* set to NULL in case of failure before we reach the end */
	
	if(0 == insize)
		insize = strlen(indata);
	
	base64data = output = malloc(insize*4/3+4);
	if(NULL == output)
		return 0;
	
	while(insize > 0) {
		for (i = inputparts = 0; i < 3; i++) {
			if(insize > 0) {
				inputparts++;
				ibuf[i] = *indata;
				indata++;
				insize--;
			}
			else
				ibuf[i] = 0;
		}
		
		obuf [0] = (ibuf [0] & 0xFC) >> 2;
		obuf [1] = ((ibuf [0] & 0x03) << 4) | ((ibuf [1] & 0xF0) >> 4);
		obuf [2] = ((ibuf [1] & 0x0F) << 2) | ((ibuf [2] & 0xC0) >> 6);
		obuf [3] = ibuf [2] & 0x3F;
		
		switch(inputparts) {
			case 1: /* only one byte read */
				sprintf(output, "%c%c==", table64[obuf[0]], table64[obuf[1]]);
				break;
			case 2: /* two bytes read */
				sprintf(output, "%c%c%c=", table64[obuf[0]], table64[obuf[1]], table64[obuf[2]]);
				break;
			default:
				sprintf(output, "%c%c%c%c", table64[obuf[0]], table64[obuf[1]], table64[obuf[2]], table64[obuf[3]]);
				break;
		}
		output += 4;
	}
	*output=0;
	*outptr = base64data;
	
	return strlen(base64data); /* return the length of the new data */
}

#pragma mark - 设置服务器信息
- (BOOL)addServerInfo:(NSString *)host port:(unsigned short)port
{
    BOOL bRet               = NO;

    if (!self.serverInfoList)
        self.serverInfoList = [NSMutableArray arrayWithCapacity:0];
    
    if (self.serverInfoList && host && port > 0)
    {
        ServerDataInfo *svrInfo = [[ServerDataInfo alloc] init];
        svrInfo.serverAddr      = host;
        svrInfo.port            = port;
        [self.serverInfoList addObject:svrInfo];
        [svrInfo release];
        bRet = YES;
    }
    
    return bRet;
}

#pragma mark - 清除服务器信息
- (void)clearServerInfo
{
    self.serverInfoList = nil;
}

#pragma mark - 再服务器信息列表中移除某台服务器信息
- (void)removeServerInfo:(NSString *)host port:(unsigned short)port
{
    for (int i = 0; i < [self.serverInfoList count]; i++)
    {
        ServerDataInfo *svrInfo = [self.serverInfoList objectAtIndex:i];
        if ([host isEqualToString:svrInfo.serverAddr] && svrInfo.port == port)
        {
            [self.serverInfoList removeObject:svrInfo];
            break;
        }
    }
}

#pragma mark - 更新服务器状态
- (int)changeConnTimes:(NSString *)host prot:(unsigned short)port
{
    for (int i = 0; i < [self.serverInfoList count]; i++)
    {
        ServerDataInfo *svrInfo = [self.serverInfoList objectAtIndex:i];
        if ([host isEqualToString:svrInfo.serverAddr] && svrInfo.port == port)
        {
            if (svrInfo.connectTimes++ >= self.maxConnTimes)
            {
                [self.serverInfoList removeObject:svrInfo];
            }
            break;
        }
    }
    
    return [self.serverInfoList count];
}

- (BOOL)resetConnTimes:(NSString *)host prot:(unsigned short)port
{
    BOOL isRet = NO;
    for (int i = 0; i < [self.serverInfoList count]; i++)
    {
        ServerDataInfo *svrInfo = [self.serverInfoList objectAtIndex:i];
        if ([host isEqualToString:svrInfo.serverAddr] && svrInfo.port == port)
        {
            svrInfo.connectTimes = 0;
            isRet = YES;
            break;
        }
    }
    
    return isRet;
}

#pragma mark - 获取随机服务器地址信息及端口
- (int)getCurSerInfoIndex
{
	int index = -1;
	
	if ([self.serverInfoList count] > 0)
	{
		index = arc4random() % [self.serverInfoList count];
	}
	
	return index;
}

- (ServerDataInfo *)getRandomServerAddr
{
    ServerDataInfo *svrInfo = nil;
    int index = -1;
	
	if ((index = [self getCurSerInfoIndex]) >= 0 && index < [self.serverInfoList count])
	{
        svrInfo = [self.serverInfoList objectAtIndex:index];
//        CMLogDebug(@"!> connect server addr:%@ port:%d", svrInfo.serverAddr, svrInfo.port);
	}
	
	return  svrInfo;
}

- (BOOL)initialInstance:(NSString *)hostName port:(unsigned short)port isAutoClose:(BOOL)isAutoClose
{
	BOOL bSuccess           = NO;
    int index = -1;
	ServerDataInfo *svrInfo = nil;
	
	if ([hostName length] > 0 && port > 0)
	{
        svrInfo = [[[ServerDataInfo alloc] init] autorelease];
        svrInfo.serverAddr  = hostName;
        svrInfo.port        = port;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_NOSERVERINFO];
	}
	else
	{
		if ((index = [self getCurSerInfoIndex]) >= 0 && index < [self.serverInfoList count])
		{
            svrInfo = [self.serverInfoList objectAtIndex:index];
		}
		else
		{
            if (![self.serverInfoList isValidArray]) {
                CMLogInfo(@"---- no server list to connect");
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_NOSERVERINFO];
			CMLogError(@"!> get server list error");
			return bSuccess;
		}
	}
    
    if(svrInfo){
//#ifdef DEBUG
//        if (!self.isTrade) {
//            CMLogWarn(@"----market test----");
//            svrInfo.serverAddr = @"10.15.107.11";
//            svrInfo.port = 12345;
//        }
//#endif
        CMLogInfo(@"----server to connect: %@, port :%d istrade:%d", svrInfo.serverAddr, svrInfo.port, self.isTrade);
    }else{
        CMLogError(@"----no server to connect!");
    }
    
	pthread_mutex_lock(&mutexNetRequest);
    
	if (!self.requestData)
	{
		[self setProxyInfo];
		
		//创建启动线程
		pthread_t  			threadID;
		pthread_attr_t   	thread_attr;
        
        self.isAutoClose    = isAutoClose;
        self.isThreadStatus = YES;
        self.requestData    = [[[NetThreadBasicData alloc] init] autorelease];
        [self.requestData setServerInfo:svrInfo];
        
		pthread_attr_init(&thread_attr);
		/* 设置堆栈大小, 0 成功，-1 失败*/
		if (pthread_attr_setstacksize(&thread_attr, 128*1024))   //128 K
		{
			CMLogError(@"!> pthread_attr_setstacksize error");
			self.requestData    = nil;
            self.isThreadStatus = NO;
		}
		else
		{
			if (pthread_create(&threadID, &thread_attr, &NetThreadProcFunc, (void *)self))
			{
				CMLogError(@"!> net pthread create error");
				self.requestData    = nil;
                self.isThreadStatus = NO;
			}
			else
			{
                CMLogInfo(@"!> net pthread create ok");
				bSuccess = true;
				pthread_detach(threadID);
			}
		}
	}
	pthread_mutex_unlock(&mutexNetRequest);
	
	return bSuccess;
}

- (void)endInstance
{
    self.isThreadStatus = NO;
}

- (void)cancleNetData
{
    pthread_mutex_lock(&mutexNetRequest);
	if (self.requestData)
	{
        [self.requestData.requestQueue removeAllObjects];
	}
	pthread_mutex_unlock(&mutexNetRequest);
}

- (int)getAskNum
{
    int nCount = 0;
    pthread_mutex_lock(&mutexNetRequest);
	if (self.requestData)
	{
		nCount = [self.requestData.requestQueue count];
	}
	pthread_mutex_unlock(&mutexNetRequest);
	return nCount;
}

- (BOOL)sendNetAsk:(NSData *)pData
{
	BOOL bSuccess = NO;
    
	pthread_mutex_lock(&(self->mutexNetRequest));
	if(self.requestData && [pData length] > 0)
	{
		if ([self.requestData.requestQueue count] >= self.maxRequestNum)
		{
            //请求的消息太多，删除最早的请求
            [self.requestData.requestQueue removeObjectAtIndex:0];
		}
        
        if (!self.requestData.requestQueue) self.requestData.requestQueue = [NSMutableArray arrayWithCapacity:0];
        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkSendDataRemovedInThread:)])
//            [self.delegate rawNetworkSendDataRemovedInThread:self];
        
        [self.requestData.requestQueue addObject:pData];
        
		bSuccess = YES;
	}
	else
	{
		CMLogError(@"!> sendNetAsk4 invalidData");
		bSuccess = NO;
	}
	pthread_mutex_unlock(&(self->mutexNetRequest));
	
	return bSuccess;
}

- (int)recvUnknowLen:(int)fd pData:(void *)ptr maxLen:(int)maxLen second:(int)nSecond miniSec:(int)nMiniSec
{
    int	n = -1;
	
	if (maxLen > 0)
	{
		while ((n = recv(fd, (char *)ptr, maxLen, 0)) < 0 && self.isThreadStatus)
		{
			if (EWOULDBLOCK == errno)
			{
				if (nSecond||nMiniSec)
				{
                    if ([[self class] canRead:fd waitSecTime:nSecond waitMiniSecTime:nMiniSec] <= 0)
						break;
                    
					nSecond = 0;//nMiniSec只等一次
					nMiniSec = 0;
				}
				else
				{
					break;
				}
			}
			else
			{
				//连接需要关闭
				n = 0;
				break;
			}
		}
	}
	
	return n;//如果返回0连接要关闭
}

- (int)recv:(int)fd pData:(void *)ptr bytes:(unsigned long)nbytes second:(int)nSecond miniSec:(int)nMiniSec
{
    int		n;
	int		num = 0;
	bool	bClose = false;
	
	while (nbytes > 0 && self.isThreadStatus)
	{
		if ((n = recv(fd, (char *)ptr, nbytes, 0)) < 0)
		{
			if (EWOULDBLOCK == errno)
			{
				if (nSecond||nMiniSec)
				{
                    if ([[self class] canRead:fd waitSecTime:nSecond waitMiniSecTime:nMiniSec] <= 0) break;
				}
				else
				{
					break;
				}
			}
			else
			{
				//连接需要关闭
				bClose = true;
				break;
			}
		}
		else if (n)
		{
			num += n;
			nbytes -= n;
			ptr = (char *)ptr + n;
		}
		else
		{
			//连接需要关闭
			bClose = true;
			break;
		}
	}
    
	if (bClose)
	{
		num = 0;
	}
	else if (num)
	{
	}
	else
	{
		num = -1;
	}
	
	return num;
}

- (int)send:(int)fd pData:(const void *)ptr bytes:(int)nbytes second:(int)nSecond miniSec:(int)nMiniSec
{
    int  	n;
	int     num = 0;
	bool	bClose = false;
	
	while (nbytes > 0 && self.isThreadStatus)
	{
		if ((n = send(fd, (const char *)ptr, nbytes, 0)) <= 0)
		{
			if (EWOULDBLOCK == errno)
			{
				if (nSecond||nMiniSec)
				{
                    if ([[self class] canWrite:fd waitSecTime:nSecond waitMiniSecTime:nMiniSec] <= 0) break;
				}
				else
				{
					break;
				}
			}
			else
			{
				//连接需要关闭
				bClose = true;
				break;
			}
		}
		else
		{
			num += n;
			nbytes -= n;
			ptr = (const char *)ptr + n;
		}
	}
	
	if (bClose)
	{
		num = 0;
	}
	else if (num)
	{
	}
	else
	{
		num = -1;
	}
	
	return num;
}

#pragma mark - 代理设置
- (void)clearProxyInfo
{
	self.proxyData = nil;
}

- (void)setProxyInfo
{
    [self clearProxyInfo];
	
	CFDictionaryRef proxyDic = CFNetworkCopySystemProxySettings();
	
	if (proxyDic)
	{
		// http proxy 目前只有http proxy
		CFBooleanRef	proxyEnable	= (CFBooleanRef)CFDictionaryGetValue(proxyDic, kCFNetworkProxiesHTTPEnable);
		
		if (proxyEnable && CFBooleanGetValue(proxyEnable))
		{
			CFStringRef		proxy			= (CFStringRef)CFDictionaryGetValue(proxyDic, kCFNetworkProxiesHTTPProxy);
			CFNumberRef		port			= (CFNumberRef)CFDictionaryGetValue(proxyDic, kCFNetworkProxiesHTTPPort);
			CFBooleanRef	Authenticated	= CFDictionaryGetValue(proxyDic, CFSTR("HTTPProxyAuthenticated")) ?
			(CFBooleanRef)CFDictionaryGetValue(proxyDic, CFSTR("HTTPProxyAuthenticated")) : kCFBooleanFalse;
			CFStringRef		userName		= (CFStringRef)CFDictionaryGetValue(proxyDic,  CFSTR("HTTPProxyUsername"));
			CFStringRef		userPwd			= (CFStringRef)CFDictionaryGetValue(proxyDic,  CFSTR("HTTPProxyPassword"));
			
			const char *addr	= proxy ? CFStringGetCStringPtr(proxy, CFStringGetSystemEncoding()) : "";
			const char *uname	= userName ? CFStringGetCStringPtr(userName, CFStringGetSystemEncoding()) : "";
			const char *upwd	= userPwd ? CFStringGetCStringPtr(userPwd, CFStringGetSystemEncoding()) : "";
			unsigned char type	= CFBooleanGetValue(proxyEnable) ? SocketProxy_HTTP11 : SocketProxy_None;
			bool	isValidate	= Authenticated && CFBooleanGetValue(Authenticated) ? SocketProxy_HTTP11 : SocketProxy_None;
			
			int nport = 0;
			if (port)
			{
				CFNumberGetValue(port, kCFNumberSInt32Type, &nport);
			}
			
			if (addr && strlen(addr) > 0)
			{
				[self addProxyInfo:[NSString stringWithUTF8String:addr] port:nport validate:isValidate username:[NSString stringWithUTF8String:uname] password:[NSString stringWithUTF8String:upwd] type:type];
			}
		}
		
		CFRelease(proxyDic);
		proxyDic = NULL;
	}
}

- (BOOL)addProxyInfo:(NSString *)host port:(unsigned short)port validate:(bool)isValidate username:(NSString *)user password:(NSString *)pwd type:(unsigned char)type
{
    BOOL bRet = false;
	
	if (!self.proxyData)
	{
        self.proxyData = [[[ProxyDataInfo alloc] init] autorelease];
        self.proxyData.isValidate   = isValidate;
        self.proxyData.ucConnectType= type;
		
		if ([host length] > 0 && port > 0)
		{
            [self.proxyData setProxyServerAddr:host];
            [self.proxyData setPort:port];
		}
		
		if (user)[self.proxyData setUserName:user];
		if (pwd)[self.proxyData setPassword:pwd];
		
		bRet = true;
	}
	
	return bRet;
}

- (int)connectServer
{
    int	fd = -1;
	
	if (self.proxyData)
	{
		CMLogDebug(@"!> Connect Server use proxy");
		switch (self.proxyData.ucConnectType)
		{
			case SocketProxy_None:
                if (self.requestData)
                {
                    ServerDataInfo *svrInfo = self.requestData.serverInfo;
                    fd = [[self class] connect:[svrInfo.serverAddr UTF8String] port:svrInfo.port seconds:self.netConnTimeout isBlock:self.isBlockMode];
                }
				break;
			case SocketProxy_SOCKS4:
			case SocketProxy_SOCKS4A:
				fd = [self connectSock4or4A];
				break;
			case SocketProxy_SOCKS5:
				fd = [self connectSock5];;
				break;
			case SocketProxy_HTTP11:
				fd = [self connectHttp11];
				break;
			default:
				break;
		}
	}
	else
	{
		if (self.requestData)
        {
            ServerDataInfo *svrInfo = self.requestData.serverInfo;
            CMLogInfo(@"---cmasyncsocket start connect:%@ : %d", svrInfo.serverAddr, svrInfo.port);
            fd = [[self class] connect:[svrInfo.serverAddr UTF8String] port:svrInfo.port seconds:self.netConnTimeout isBlock:self.isBlockMode];
        }
	}
	
	return fd;
}

- (int)connectProxyServer
{
    int fd = -1;
	
	if (self.proxyData)
	{
		int i = 0;
		for (i = 0; i < self.netConnRepCount && self.isThreadStatus; i++)
		{
            if ((fd = [[self class] connect:[self.proxyData.proxyServerAddr UTF8String] port:self.proxyData.port seconds:self.netConnTimeout isBlock:self.isBlockMode]) >= 0) break;
		}
		
		if (i == self.netConnRepCount)//连接失败通知客户
		{
			CMLogError(@"!> connect proxy NET_NOTIFY_DONOTCON");
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_DONOTCONPROXY];
		}
	}
		
	return fd;
}

- (int)connectSock4or4A
{
    char    buff[512];
    char	*command = buff;
    int     len = 9, iRetLen;
    int		fd = [self connectProxyServer];
    
    if (fd <= -1) return fd;
    if (!self.requestData) return -1;
    
    command[0] = 4;
    command[1] = 1; //CONNECT or BIND request
    
    ServerDataInfo *svrInfo = self.requestData.serverInfo;
    *((unsigned short *)(command+2)) = htons(svrInfo.port);
    
    if (self.requestData.unServerIP)
    {
        *((DWORD*)(command+4)) = self.requestData.unServerIP;
    }
    else
    {
        //Set the IP to 0.0.0.x (x is nonzero)
        command[4]=0;
        command[5]=0;
        command[6]=0;
        command[7]=1;
        command[8] = 0; //Notice
        
        //Add host as URL
        strcpy(&command[9], [svrInfo.serverAddr UTF8String]);
        len += strlen([svrInfo.serverAddr UTF8String])+1;
    }
    command[len-1] = 0;
    
    if ([self send:fd pData:command bytes:len second:0 miniSec:self.sendWaitTime] != len)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_SENDDATAFAIL];
        
        //关闭
        close(fd);
        fd = -1;
        
        CMLogError(@"!> Sock4往代理服务器发送数据失败！");
        return fd;
    }
    
    iRetLen = [self recvUnknowLen:fd pData:buff maxLen:sizeof(buff) second:0 miniSec:self.sendWaitTime];
    
    if (iRetLen < 8 || buff[1] != 90 || buff[0] != 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_RCVDATAERR];
        
        //关闭
        close(fd);
        fd = -1;
        CMLogError(@"!> Sock4代理服务器返回的数据有误!");
        return fd;
    }
    
    return fd;
}

- (int)connectSock5
{
    char			buff[512];
    unsigned char	*command = (unsigned char *)buff;
    int				len, iRetLen;
    int				fd = [self connectProxyServer];
    
    if (fd <= -1) return fd;
    if (!self.proxyData || !self.requestData) return -1;
    
    command[0] = 5;
    //CAsyncProxySocket supports to logon types: No logon and
    //cleartext username/password (if set) logon
    command[1] = self.proxyData.isValidate ? 2 : 1;	//Number of logon types,
    //如果self.proxyData.isValidate为0没有用户验证
    //如果self.proxyData.isValidate为1,有用户验证
    command[2] = self.proxyData.isValidate ? 2 : 0;	//2=user/pass, 0=no logon
    command[3] = 0;
    len = self.proxyData.isValidate ? 4 : 3;			// length of request
    
    if ([self send:fd pData:command bytes:len second:0 miniSec:self.sendWaitTime] != len)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_SENDDATAFAIL];
        close(fd);
        fd = -1;
        CMLogError(@"!> Sock5往代理服务器发送数据失败!");
        
        return fd;
    }
    
    iRetLen = [self recv:fd pData:buff bytes:2 second:0 miniSec:self.recvWaitTime];
    
    if (iRetLen != 2 || buff[1] == -1 || buff[0] != 5)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_RCVDATAERR];
        
        close(fd);
        fd = -1;
        
        CMLogError(@"!> Sock5代理服务器返回数据错误！");
        return fd;
    }
    
    if (buff[1])
    {
        if (buff[1] != 2 || self.proxyData.isValidate == false)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_PROXYNEEDVERIFY];
            
            close(fd);
            fd = -1;
            CMLogError(@"!> Sock5代理服务器要求用户验证!");
            
            return fd;
        }
        
        const char *userName    = [self.proxyData.userName UTF8String];
        const char *userPwd     = [self.proxyData.password UTF8String];
        unsigned char ucNameLen = (unsigned char)(strlen(userName));
        unsigned char ucCodeLen = (unsigned char)(strlen(userPwd));
        
        sprintf(buff, "%s %s", userName, userPwd);
        buff[0] = 5;
        buff[1] = ucNameLen;
        
        buff[2+ucNameLen] = ucCodeLen;
        len = 3+ucNameLen+ucCodeLen;
        
        if ([self send:fd pData:buff bytes:len second:0 miniSec:self.sendWaitTime] != len)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_SENVERIFYDATAFAIL];
            
            close(fd);
            fd = -1;
            CMLogError(@"!> Sock5往代理服务器发送用户验证数据失败！");
            
            return fd;
        }
        
        iRetLen = [self recv:fd pData:buff bytes:2 second:0 miniSec:self.recvWaitTime];
        if (iRetLen != 2 || buff[1] != 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_RCVVERIFYDATAERR];
            
            close(fd);
            fd = -1;
            CMLogError(@"Scok5代理服务器返回用户验证数据错误！");
            
            return fd;
        }
    }
    
    //////////////////send server address
    memset(command,0,256);
    command[0] = 5;
    command[1] = 1;
    command[2] = 0;
    command[3] = self.requestData.unServerIP ? 1 : 3;
    len = 4;
    
    ServerDataInfo *svrInf = self.requestData.serverInfo;
    
    if (self.requestData.unServerIP)
    {
        unsigned int unServerIP = self.requestData.unServerIP;
        memcpy(&command[len], &unServerIP, 4);
        len += 4;
    }
    else
    {
        command[len] = strlen([svrInf.serverAddr UTF8String]);
        strcpy((char *)&command[len+1], [svrInf.serverAddr UTF8String]);
        len += strlen([svrInf.serverAddr UTF8String]) + 1;
    }
    
    *((unsigned short *)(command+len)) = htons(svrInf.port);
    len += 1;
    
    if ([self send:fd pData:command bytes:len second:0 miniSec:self.sendWaitTime] != len)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_SENDDATAFAIL];
        
        close(fd);
        fd = -1;
        CMLogError(@"!> Sock5往代理服务器发送数据失败！");
        
        return fd;
    }
    else if ([self recvUnknowLen:fd pData:buff maxLen:256 second:0 miniSec:self.recvWaitTime] < 5 || buff[1] != 0 || buff[0] != 5)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_RCVDATAERR];
        
        close(fd);
        fd = -1;
        CMLogError(@"!> Sock5接收代理服务器返回数据失败！\n");
        
        return fd;
    }
    
    return fd;
}

- (int)connectHttp11
{
    int     len;
    char    str[4096];
    int		fd = [self connectProxyServer];
    
    if (fd <= -1) return fd;
    if (!self.proxyData || !self.requestData) return -1;
    
    ServerDataInfo *svrInf = self.requestData.serverInfo;
    
    if (self.proxyData)
    {
        if (self.proxyData.isValidate)
        {
            char userpass[512];
            memset(userpass, 0, sizeof(userpass));
            sprintf(userpass, "%s:%s", [self.proxyData.userName UTF8String], [self.proxyData.password UTF8String]);
            char *base64str;
            [self urlBase64Encode:userpass insize:strlen(userpass) outptr:&base64str];
            
            sprintf(str, "CONNECT %s:%d HTTP/1.0\r\nProxy-Authorization: Basic %s\r\n\r\n", [svrInf.serverAddr UTF8String], svrInf.port, base64str);
            
            if (base64str)
            {
                free(base64str);
                base64str = NULL;
            }
        }
        else
        {
            sprintf(str, "CONNECT %s:%d HTTP/1.1\r\nHost:%s:%d\r\n\r\n", [svrInf.serverAddr UTF8String], svrInf.port, [self.proxyData.proxyServerAddr UTF8String], self.proxyData.port);
        }
        
        len = strlen(str);
        
        if ([self send:fd pData:str bytes:len second:0 miniSec:self.sendWaitTime] != len)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_SENDDATAFAIL];
            
            close(fd);
            fd = -1;
            CMLogError(@"!> http11往代理服务器发送数据失败！");
            
            return fd;
        }
        
        if ((len = [self recvUnknowLen:fd pData:str maxLen:sizeof(str) second:0 miniSec:self.recvWaitTime]) < 7)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_RCVDATAERR];
            
            close(fd);
            fd = -1;
            CMLogError(@"!> http11代理服务器返回数据错误！");
            
            return fd;
        }
        str[len] = '\0';
        
        char *type1 = "HTTP/1.0 200";
        char *type2 = "HTTP/1.1 200";
        if (strncmp(str, type1, strlen(type1)) && strncmp(str, type2, strlen(type2)))
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
                [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_SOCKCLOSE];
            
            close(fd);
            fd = -1;
            
            return fd;
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rawNetworkInThread:willDisconnectWithError:)])
            [self.delegate rawNetworkInThread:self willDisconnectWithError:NET_PROXYINFOERR];
        
        close(fd);
        fd = -1;
    }
    
    return fd;
}

#pragma mark - static methods
+ (int)setNoBlockMode:(int)fd isNoBlock:(BOOL)isNoBlock
{
    int value = fcntl(fd, F_GETFL, 0);
	int ret = value&O_NONBLOCK;
	if (isNoBlock)
	{
		value |= O_NONBLOCK;
	}
	else
	{
		int temp = O_NONBLOCK;
		temp = ~temp;
		value &= temp;
	}
	fcntl(fd, F_SETFL, value);
	
	return ret;
}

+ (int)canRead:(int)fd waitSecTime:(int)waitSeconds waitMiniSecTime:(int)waitMiniSeconds
{
    fd_set          set;
	struct timeval  waitTime;
	
	FD_ZERO(&set);
	FD_SET(fd, &set);
	waitTime.tv_sec     = waitSeconds;
	waitTime.tv_usec    = waitMiniSeconds*1000;
    
    return [self select:fd+1 readSet:&set writeSet:NULL exceptSet:NULL timeOut:&waitTime];
}

+ (int)canWrite:(int)fd waitSecTime:(int)waitSeconds waitMiniSecTime:(int)waitMiniSeconds
{
    fd_set          set;
	struct timeval  waitTime;
	
	FD_ZERO(&set);
	FD_SET(fd, &set);
	waitTime.tv_sec     = waitSeconds;
	waitTime.tv_usec    = waitMiniSeconds*1000;
    
    return [self select:fd+1 readSet:NULL writeSet:&set exceptSet:NULL timeOut:&waitTime];
}

+ (int)select:(int)maxFd readSet:(fd_set *)readSet writeSet:(fd_set *)writeSet exceptSet:(fd_set *)exceptSet timeOut:(struct timeval *)timeOut
{
    int ret;
	int nCount = 0;
    
//    CMLogInfo(@"----before select time:%@", [CommonFormatFunc getCurTimeStr]);
    while ((ret = select(maxFd, readSet, writeSet, exceptSet, timeOut)) < 0
           && (EINTR == errno)
           && nCount < 2)
    {
        nCount++;
    }
    
//    CMLogInfo(@"----after select ret:%d, time:%@", nCount,  [CommonFormatFunc getCurTimeStr]);

	return ret;
}

+ (int)connectTimeOut:(int)fd sockAddrInf:(const struct sockaddr *)sockAddrInf sockLength:(socklen_t)sockLength seconds:(int)seconds isBlock:(BOOL)isBlock
{
    //设置非阻塞方式连接
    int prestate    = [self setNoBlockMode:fd isNoBlock:isBlock];
	int ret         = connect(fd, sockAddrInf, sockLength);
    
	if (ret < 0)
	{
		if(errno == EINPROGRESS)
		{
			//正在建立连接
			fd_set          set;
			struct timeval  waitTime;
			
			FD_ZERO(&set);
			FD_SET(fd, &set);
			waitTime.tv_sec     = seconds > 0 ? seconds : 5;
			waitTime.tv_usec    = 0;
            ret = [self select:fd+1 readSet:NULL writeSet:&set exceptSet:NULL timeOut:&waitTime] == 1 ? 0 : -1;
		}
	}
    
    if (ret == 0) {
        CMLogWarn(@"!> connect successful (error code:%d -%s ret:%d prestate:%d)", errno, strerror(errno), ret, prestate);
    }else{
        CMLogWarn(@"!> connect fail (error code:%d -%s ret:%d prestate:%d)", errno, strerror(errno), ret, prestate);
    }
	
	if (!prestate)
	{
        [self setNoBlockMode:fd isNoBlock:NO];
	}
    
	return ret;
}

+ (int)connect:(const char *)host port:(unsigned short)port seconds:(int)seconds isBlock:(BOOL)isBlock
{
    struct sockaddr_in server;
    
    int fd                  = -1;
    server.sin_family       = AF_INET;
    server.sin_port         = htons(port);
    server.sin_addr.s_addr  = inet_addr(host);
    
    if (server.sin_addr.s_addr == INADDR_NONE)
    {
        struct hostent *inhost = gethostbyname(host);
        if (inhost)
        {
            for (int i = 0; inhost->h_addr_list[i]; i++)
            {
                fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
                memcpy(&server.sin_addr, inhost->h_addr_list[i], inhost->h_length);
                
                if (fd >= 0)
                {
                    if (seconds > 0)
                    {
                        if ([self connectTimeOut:fd sockAddrInf:(struct sockaddr *)&server sockLength:sizeof(server) seconds:seconds isBlock:isBlock] == 0)
                            break;
                    }
                    else
                    {
                        if (connect(fd, (struct sockaddr *)&server, sizeof(server)) == 0)
                            break;
                    }
                }
                close(fd);
                fd = -1;
            }
        }
    }
    else
    {
        fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        
        if (fd >= 0)
        {
            if (seconds > 0)
            {
                if ([self connectTimeOut:fd sockAddrInf:(struct sockaddr *)&server sockLength:sizeof(server) seconds:seconds isBlock:isBlock])
                {
                    close(fd);
                    fd = -1;
                }
            }
            else
            {
                if (connect(fd, (struct sockaddr *)&server, sizeof(server)) < 0)
                {
                    close(fd);
                    fd = -1;
                }
            }
        }
    }
    return fd;
}

@end

