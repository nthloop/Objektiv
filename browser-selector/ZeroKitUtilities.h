//
//  ZeroKitUtilities.h
//  browser-selector
//
//  This file is a stripped-down version of ZeroKitUtilities.h from
//  the ZeroKit project, Copyright (c) Eric Czarny eczarny@gmail.com
//
//  ZeroKit is released under the MIT license.
//


#import <Foundation/Foundation.h>

@interface ZeroKitUtilities : NSObject

+ (BOOL)isLoginItemEnabledForBundle: (NSBundle *)bundle;
+ (void)enableLoginItemForBundle: (NSBundle *)bundle;
+ (void)disableLoginItemForBundle: (NSBundle *)bundle;

@end
