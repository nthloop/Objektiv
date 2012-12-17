#import <Foundation/Foundation.h>

@class ZeroKitURLConnection;

@protocol ZeroKitURLConnectionDelegate<NSObject>

- (void)request: (NSURLRequest *)request didReceiveData: (NSData *)data;

- (void)request: (NSURLRequest *)request didFailWithError: (NSError *)error;

#pragma mark -

- (BOOL)request: (NSURLRequest *)request canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace;

- (void)request: (NSURLRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)request: (NSURLRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

@end
