//
//  TestServer.h
//  StoreiPadApplication
//
//  Created by 黄红迪 on 8/22/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestServer : NSObject
@property(nonatomic, copy) NSString *domain; // the bonjour domain
@property(nonatomic, copy) NSString *protocol; // the bonjour protocol
@property(nonatomic, copy) NSString *name; // the bonjour name
@property(nonatomic, assign) uint16_t port; // the port, reterieved from the OS
@property(nonatomic, assign) uint8_t payloadSize; // the size you expect to be sending
@property(nonatomic, assign) CFSocketRef socket; // the socket that data is sent over
@property(nonatomic, assign) BOOL outputStreamHasSpace; // when there is space in the output stream this is YES


+ (instancetype)serverWithProtocol:(NSString *)protocol;
+ (instancetype)server;
- (void)start;
@end
