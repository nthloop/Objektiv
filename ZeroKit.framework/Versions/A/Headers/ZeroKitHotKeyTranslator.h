#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <CoreServices/CoreServices.h>

@class ZeroKitHotKey;

@interface ZeroKitHotKeyTranslator : NSObject {
    NSDictionary *mySpecialHotKeyTranslations;
}

+ (ZeroKitHotKeyTranslator *)sharedTranslator;

#pragma mark -

+ (NSInteger)convertModifiersToCarbonIfNecessary: (NSInteger)modifiers;

#pragma mark -

+ (NSString *)translateCocoaModifiers: (NSInteger)modifiers;

- (NSString *)translateKeyCode: (NSInteger)keyCode;

#pragma mark -

- (NSString *)translateHotKey: (ZeroKitHotKey *)hotKey;

@end
