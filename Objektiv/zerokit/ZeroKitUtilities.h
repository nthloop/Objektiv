//
//  ZeroKitUtilities.h
//  Objektiv
//
//  A stripped-down version of the ZeroKit's ZeroKitUtilities class,
//  mainly containing code we use in this project.
//

#import <Foundation/Foundation.h>

@interface ZeroKitUtilities : NSObject;

+ (void)registerDefaultsForBundle: (NSBundle *)bundle;
+ (void)enableLoginItemForBundle: (NSBundle *)bundle;
+ (void)disableLoginItemForBundle: (NSBundle *)bundle;

@end
