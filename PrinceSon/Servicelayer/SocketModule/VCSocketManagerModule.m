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
    }
    return self;
}

#pragma mark - private

#pragma mark - public
- (void)connectToServerWithHost:(NSString *)host port:(UInt16)port
{
    NSError *error;
    [_socket connectToHost:host onPort:port error:&error];
}

- (void)sendRequestData:(NSData *)data
{
    [_socket writeData:data withTimeout:-1 tag:0];
}

- (void)disConnectSocket
{
    [_socket disconnect];
}

#pragma mark - AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    VCLogSocketLayer(@"socket will disconnectwitherror %@", err.description);
    
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
    if (self.receiveData != nil) {
        [self.receiveData appendData:data];
    } else {
        self.receiveData = [NSMutableData dataWithData:data];
    }
    
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
