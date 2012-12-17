#import <Foundation/Foundation.h>

@class ZeroKitHotKey;

@protocol ZeroKitHotKeyValidatorProtocol<NSObject>

- (BOOL)isHotKeyValid: (ZeroKitHotKey *)hotKey;

@end
