#import <Foundation/Foundation.h>
#import "ZeroKitURLConnectionDelegate.h"

@class ZeroKitURLConnectionManager;

@interface ZeroKitURLConnection : NSObject {
    ZeroKitURLConnectionManager *myManager;
    NSURLRequest *myRequest;
    NSString *myIdentifier;
    NSMutableData *myData;
    NSURLConnection *myConnection;
    id<ZeroKitURLConnectionDelegate> myDelegate;
}

- (id)initWithURLRequest: (NSURLRequest *)request delegate: (id<ZeroKitURLConnectionDelegate>)delegate manager: (ZeroKitURLConnectionManager *)manager;

#pragma mark -

+ (NSData *)sendSynchronousURLRequest: (NSURLRequest *)request error: (NSError **)error;

#pragma mark -

- (NSString *)identifier;

#pragma mark -

- (id<ZeroKitURLConnectionDelegate>)delegate;

#pragma mark -

- (void)cancel;

@end
