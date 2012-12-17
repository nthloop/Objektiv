#import <Foundation/Foundation.h>
#import "ZeroKitURLConnectionDelegate.h"

@class ZeroKitURLConnection;

@interface ZeroKitURLConnectionManager : NSObject {
    NSMutableDictionary *myConnections;
}

+ (ZeroKitURLConnectionManager *)sharedManager;

#pragma mark -

- (NSString *)spawnConnectionWithURLRequest: (NSURLRequest *)request delegate: (id<ZeroKitURLConnectionDelegate>)delegate;

#pragma mark -

- (NSArray *)activeConnectionIdentifiers;

- (int)numberOfActiveConnections;

#pragma mark -

- (ZeroKitURLConnection *)connectionForIdentifier: (NSString *)identifier;

#pragma mark -

- (void)closeConnectionForIdentifier: (NSString *)identifier;

- (void)closeConnections;

@end
