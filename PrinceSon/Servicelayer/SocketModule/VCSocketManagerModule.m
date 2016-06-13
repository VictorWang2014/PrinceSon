//
//  VCSocketManagerModule.m
//  PrinceSon
//
//  Created by wangmingquan on 27/5/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "VCSocketManagerModule.h"

@interface VCSocketManagerModule ()<AsyncSocketDelegate>
{
    AsyncSocket *_socket;
}

@property (nonatomic, strong) NSMutableData *receiveData;
@property (nonatomic, strong) NSMutableArray *queueArray;
@property (nonatomic, strong) dispatch_queue_t socketQueue;//

@end

@implementation VCSocketManagerModule

//#pragma mark - singleton
//+ (VCSocketManagerModule *)shareSocketManager
//{
//    static VCSocketManagerModule *share = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//        share = [[VCSocketManagerModule alloc] init];
//    });
//    return share;
//}

#pragma mark - lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
        self.queueArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - private
- (void)_readData:(NSData *)data
{
    if (self.receiveData != nil) {
        [self.receiveData appendData:data];
    } else {
        self.receiveData = [NSMutableData dataWithData:data];
    }
    //{@"tag":返回包标记,@"dataLength":数据包内容实体长度, @"type":数据包类型, @"headerLength":数据包包头长度}
    NSDictionary *headerDict = [self.delegate socket:self parseHeaderWithData:self.receiveData];
    NSUInteger dataL = [[headerDict objectForKey:@"dataLength"] integerValue];
    NSUInteger headerL = [[headerDict objectForKey:@"headerLength"] integerValue];
    if (self.receiveData.length >= dataL+headerL) {
        //截取接受到的数据，然后解析
        NSData *packageData = [NSData dataWithBytes:[self.receiveData bytes] length:headerL+dataL];
        NSInteger tag = [self.delegate socket:self headerTagWithData:packageData];
        NSMutableDictionary *packageItem = [self _getPackageItemWithTag:tag];
        //判断是否是组包数据
        int groupTag = [[packageItem objectForKey:@"group"] intValue];
        if (groupTag == 1) {
            
        } else {
            
        }
        
        //之后将数据从receivedata中剔除
        if ([packageItem allKeys].count > 0) {
            [self _removePackageItemWithTag:tag];
        }
        [self _deleteDataLength:dataL+headerL];
    } else {//包数据还没有接收全
        
    }
    
}

- (void)_fillPackageItem:(NSMutableDictionary *)item withData:(NSData *)data
{
    
}

- (void)_deleteDataLength:(NSInteger)length
{
    if (length > 0 && [self.receiveData length] > length) {
        CFDataDeleteBytes((CFMutableDataRef)self.receiveData, CFRangeMake(0,length));
    }
}

- (NSMutableDictionary *)_getPackageItemWithTag:(NSInteger)tag//获取tag在queuearray中的对应的item
{
    __block NSMutableDictionary *packageItem = [NSMutableDictionary dictionary];
    if (tag > 0) {
        [self.queueArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *tmp = (NSDictionary *)obj;
            if ([tmp isKindOfClass:[NSDictionary class]]) {
                NSString *tagKey = [tmp objectForKey:@"tag"];
                if ([tagKey integerValue] == tag) {
                    packageItem = [NSMutableDictionary dictionaryWithDictionary:tmp];
                    *stop = YES;
                }
            }
        }];
    }
    return packageItem;
}

- (void)_removePackageItemWithTag:(NSInteger)tag
{
    if (tag > 0) {
        __block int index = -1;
        [self.queueArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *tmp = (NSDictionary *)obj;
            if ([tmp isKindOfClass:[NSDictionary class]]) {
                NSString *tagKey = [tmp objectForKey:@"tag"];
                int groupTag = [[tmp objectForKey:@"group"] intValue];
                if ([tagKey integerValue] == tag) {
                    if (groupTag == 1) {//组包的数据
                        int repCount = [[tmp objectForKey:@"repcount"] intValue];
                        NSArray *reqArray = [tmp objectForKey:@"reqdic"];
                        if (repCount == reqArray.count) {
                            index = (int)idx;
                        }
                    } else {//非组包的数据
                        index = (int)idx;
                    }
                    *stop = YES;
                }
            }
        }];
        if (index > -1) {
            [self.queueArray removeObjectAtIndex:index];
        }
    }
}

#pragma mark - public
- (void)connectToServerWithHost:(NSString *)host port:(UInt16)port
{
    NSError *error;
    [_socket connectToHost:host onPort:port error:&error];
}

- (void)sendRequestData:(NSMutableDictionary *)dataDic
{
    [self.queueArray addObject:dataDic];
    
    [_socket writeData:nil withTimeout:-1 tag:0];
}

- (void)disConnectSocket
{
    [_socket disconnect];
}

#pragma mark - AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    VCLogSocketLayer(@"socket will disconnectwitherror %@", err.description);
    [self disConnectSocket];
    [self.queueArray removeAllObjects];
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:willDisConnectedError:)]) {
        [self.delegate socket:self willDisConnectedError:err];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    VCLogSocketLayer(@"socket did disconnect");
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidDisConnected:)]) {
        [self.delegate socketDidDisConnected:self];
    }
}

//- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
//{
//    
//}

//- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket
//{
//    
//}

//- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
//{
//    
//}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    VCLogSocketLayer(@"socket connect success host %@, port %lu", host, port);
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidConnected:)]) {
        [self.delegate socketDidConnected:self];
    }
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    VCLogSocketLayer(@"socket did read data");
    [self _readData:data];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

//- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
//{
//
//}

//- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
//{
//    
//}

//- (NSTimeInterval)onSocket:(AsyncSocket *)sock
//  shouldTimeoutReadWithTag:(long)tag
//                   elapsed:(NSTimeInterval)elapsed
//                 bytesDone:(NSUInteger)length
//{
//    
//}

//- (NSTimeInterval)onSocket:(AsyncSocket *)sock
// shouldTimeoutWriteWithTag:(long)tag
//                   elapsed:(NSTimeInterval)elapsed
//                 bytesDone:(NSUInteger)length
//{
//    
//}

//- (void)onSocketDidSecure:(AsyncSocket *)sock
//{
//    
//}

@end
