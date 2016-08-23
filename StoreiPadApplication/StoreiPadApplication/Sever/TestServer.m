//
//  TestServer.m
//  StoreiPadApplication
//
//  Created by 黄红迪 on 8/22/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import "TestServer.h"

@interface TestServer()<NSNetServiceBrowserDelegate, NSNetServiceDelegate>{
    NSNetServiceBrowser *_serviceBrowser;
    NSNetService    *_service;
}

@end

@implementation TestServer

+ (instancetype)serverWithProtocol:(NSString *)protocol{
    return [[TestServer alloc] initWithDomainName:@""
                                         protocol:[NSString stringWithFormat:@"%@._tcp.", protocol]
                                             name:@""];
}

+ (instancetype)server{
    return [[TestServer alloc] initWithDomainName:@""
                                         protocol:BASIC_PROTOCOL
                                             name:@""];
}

- (id)initWithDomainName:(NSString *)domain
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

- (void)start{
    [self publishService];
}

- (void)startSearchService{
    [_serviceBrowser stop];
    _serviceBrowser = nil;
    
    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    _serviceBrowser.delegate = self;
    [_serviceBrowser searchForServicesOfType:_protocol inDomain:@"local."];
}

- (BOOL)publishService{
    BOOL successful = NO;
    _service = [[NSNetService alloc] initWithDomain:@""
                                               type:self.protocol
                                               name:self.name
                                               port:self.port];
    if (_service) {
        [_service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _service.delegate = self;
        [_service publish];
        successful = YES;
    }
    return successful;
}

#pragma mark -<NSNetServiceBrowserDelegate>
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing{
    NSLog(@"here");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing{
    NSLog(@"here");
}

#pragma mark -<NSNetServiceDelegate>

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"here");
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"here");
}

- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"here");
    [self startSearchService];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorInfo {
    NSLog(@"here");
}

@end
