#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@class ZeroKitHotKeyAction;

@interface ZeroKitHotKey : NSObject<NSCoding> {
    NSInteger myHandle;
    NSString *myHotKeyName;
    ZeroKitHotKeyAction *myHotKeyAction;
    NSInteger myHotKeyCode;
    NSInteger myHotKeyModifiers;
    EventHotKeyRef myHotKeyRef;
}

- (id)initWithHotKeyCode: (NSInteger)hotKeyCode hotKeyModifiers: (NSInteger)hotKeyModifiers;

#pragma mark -

+ (ZeroKitHotKey *)clearedHotKey;

+ (ZeroKitHotKey *)clearedHotKeyWithName: (NSString *)name;

#pragma mark -

- (NSInteger)handle;

- (void)setHandle: (NSInteger)handle;

#pragma mark -

- (NSString *)hotKeyName;

- (void)setHotKeyName: (NSString *)hotKeyName;

#pragma mark -

- (ZeroKitHotKeyAction *)hotKeyAction;

- (void)setHotKeyAction: (ZeroKitHotKeyAction *)hotKeyAction;

#pragma mark -

- (NSInteger)hotKeyCode;

- (void)setHotKeyCode: (NSInteger)hotKeyCode;

#pragma mark -

- (NSInteger)hotKeyModifiers;

- (void)setHotKeyModifiers: (NSInteger)hotKeyModifiers;

#pragma mark -

- (EventHotKeyRef)hotKeyRef;

- (void)setHotKeyRef: (EventHotKeyRef)hotKeyRef;

#pragma mark -

- (BOOL)isClearedHotKey;

#pragma mark -

- (NSString *)displayString;

#pragma mark -

+ (BOOL)validCocoaModifiers: (NSInteger)modifiers;

#pragma mark -

- (BOOL)isEqual: (id)object;

- (BOOL)isEqualToHotKey: (ZeroKitHotKey *)hotKey;

@end
