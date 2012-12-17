#import <Cocoa/Cocoa.h>
#import "ZeroKitHotKeyRecorderDelegate.h"

@class ZeroKitHotKey;

@interface ZeroKitHotKeyRecorder : NSControl {
    
}

- (NSString *)hotKeyName;

- (void)setHotKeyName: (NSString *)hotKeyName;

#pragma mark -

- (ZeroKitHotKey *)hotKey;

- (void)setHotKey: (ZeroKitHotKey *)hotKey;

#pragma mark -

- (id<ZeroKitHotKeyRecorderDelegate>)delegate;

- (void)setDelegate: (id<ZeroKitHotKeyRecorderDelegate>)delegate;

#pragma mark -

- (void)setAdditionalHotKeyValidators: (NSArray *)additionalHotKeyValidators;

@end
