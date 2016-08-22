//
//  TestSever.h
//  StoreiPadApplication
//
//  Created by HongDi Huang on 8/22/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Server;
@class ServerBrowser;

// forward declaration so protpcol and be at the top of the file
@protocol ServerDelegate <NSObject>
/**
 *  sent when both sides of the connection are ready to go
 */
- (void)serverRemoteConnectionComplete:(Server *)server;
/**
 *  called when the server is finished stopping
 */
- (void)serverStopped:(Server *)server;
/**
 *  called when something goes wrong in the starup
 *
 */
- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict;
/**
 *  called when data gets here from the remote side of the server
 */
- (void)server:(Server *)server didAcceptData:(NSData *)data;
/**
 *  called when the connection to the remote side is lost
 */
- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict;
/**
 *  called when a new service comes on line
 */
- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more;
/**
 *  called when a service goes off line
 */
- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more;

@end

@interface TestSever : NSObject

@property(nonatomic, copy) NSString *domain;    // the bonjour domain
@property(nonatomic, copy) NSString *protocol;  // the bonjour protocol
@property(nonatomic, copy) NSString *name;      // the bonjour name
@property(nonatomic, assign) uint16_t port;     // the port, reterieved from the OS
@property(nonatomic, assign) CFSocketRef socket;// the socket that data is sent over
@property(nonatomic, strong) NSNetService *netService;      // bonjour net service used to publish this server
@property(nonatomic, strong) NSInputStream *inputStream;    // stream that this side reads from
@property(nonatomic, strong) NSOutputStream *outputStream;  // stream that this side writes two
@property(nonatomic, assign) BOOL inputStreamReady;     // when input stream is ready to read from this turns to YES
@property(nonatomic, assign) BOOL outputStreamReady;    // when output stream is ready to read from this turns to YES
@property(nonatomic, assign) BOOL outputStreamHasSpace; // when there is space in the output stream this is YES
@property(nonatomic, strong) NSNetServiceBrowser *browser;  // the bonjour service browser
@property(nonatomic, strong) NSNetService *currentlyResolvingService;   // the service we are currently trying to resolve
@property(nonatomic, strong) NSNetService *localService;    // the local service that we get back from bonjour

@property(nonatomic, weak) id<ServerDelegate> delegate; // see docs on delegate protocol
@property(nonatomic, assign) uint8_t payloadSize;   // the size i expect to be sending

+ (instancetype)server;
+ (instancetype)serverWithProtocal:(NSString *)protocol;

@end
