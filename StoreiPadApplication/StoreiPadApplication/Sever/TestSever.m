//
//  TestSever.m
//  StoreiPadApplication
//
//  Created by HongDi Huang on 8/22/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import "TestSever.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

@implementation TestSever


+ (instancetype)server{
    return [[TestSever alloc] initWithDomainName:@"" protocol:BASIC_PROTOCOL name:@""];
}

+ (instancetype)serverWithProtocal:(NSString *)protocol{
    return [[TestSever alloc] initWithDomainName:@"" protocol:[NSString stringWithFormat:@"%@tcp", protocol] name:@""];
}

/**
 *  uses protocol as the bonjour protocol publishes under domain
 *  with name as its bonjour name, remember that name is advisory
 *  make sure that after you start that you get the servers name
 *  property to ensure that you have it correct
 */
- (instancetype)initWithDomainName:(NSString *)domain
                protocol:(NSString *)protocol
                    name:(NSString *)name {
    self = [super init];
    if(nil != self) {
        self.domain = domain;
        self.protocol = protocol;
        self.name = name;
        self.outputStreamHasSpace = NO;
        self.payloadSize = 128;
    }
    return self;
}

/**
 *  star the server, returns YES if successful and NO if not
 *  if NO is returned there will be more detail in the error object
 *  if you don't care about the error you can pass NULL
 */
- (void)start:(NSError **)error{
    BOOL successful = YES;
    CFSocketContext soketContext = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _socket = CFSocketCreate(kCFAllocatorDefault,
                             PF_INET,
                             SOCK_STREAM,
                             IPPROTO_TCP,
                             kCFSocketAcceptCallBack,
                             (CFSocketCallBack)&SocketAcceptedConnectionCallBack,
                             &socketCtxt);
}

- (void)_connectedToInputStream:(NSInputStream *)inputStream
                   outputStream:(NSOutputStream *)outputStream {
    // need to close existing streams
    [self _stopStreams];
    
    self.inputStream = inputStream;
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    
    self.outputStream = outputStream;
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}

- (void)_stopStreams {
    if(nil != self.inputStream) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
        self.inputStream = nil;
        self.inputStreamReady = NO;
    }
    if(nil != self.outputStream) {
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSRunLoopCommonModes];
        self.outputStream = nil;
        self.outputStreamReady = NO;
    }
}


@end

static void SocketAcceptedConnectionCallBack(CFSocketRef socket,
                                             CFSocketCallBackType type,
                                             CFDataRef address,
                                             const void *data, void *info) {
    // the server's socket has accepted a connection request
    // this function is called because it was registered in the
    // socket create method
    if (kCFSocketAcceptCallBack == type) {
        Server *server = (__bridge Server *)info;
        // on an accept the data is the native socket handle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        // create the read and write streams for the connection to the other process
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle,
                                     &readStream, &writeStream);
        if(NULL != readStream && NULL != writeStream) {
            CFReadStreamSetProperty(readStream,
                                    kCFStreamPropertyShouldCloseNativeSocket,
                                    kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream,
                                     kCFStreamPropertyShouldCloseNativeSocket,
                                     kCFBooleanTrue);
            [server _connectedToInputStream:(__bridge NSInputStream *)readStream
                               outputStream:(__bridge NSOutputStream *)writeStream];
        } else {
            // on any failure, need to destroy the CFSocketNativeHandle
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}

