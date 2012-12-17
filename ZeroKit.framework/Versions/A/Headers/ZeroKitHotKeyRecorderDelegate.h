#import <Foundation/Foundation.h>

@class ZeroKitHotKeyRecorder, ZeroKitHotKey;

@protocol ZeroKitHotKeyRecorderDelegate<NSObject>

- (void)hotKeyRecorder: (ZeroKitHotKeyRecorder *)hotKeyRecorder didReceiveNewHotKey: (ZeroKitHotKey *)hotKey;

- (void)hotKeyRecorder: (ZeroKitHotKeyRecorder *)hotKeyRecorder didClearExistingHotKey: (ZeroKitHotKey *)hotKey;

@end
