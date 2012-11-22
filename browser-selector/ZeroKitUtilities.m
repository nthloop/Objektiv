//
//  ZeroKitUtilities.m
//  browser-selector
//
//  This file is a stripped-down version of ZeroKitUtilities.m from
//  the ZeroKit project, Copyright (c) Eric Czarny eczarny@gmail.com
//
//  ZeroKit is released under the MIT license.
//


#import "ZeroKitUtilities.h"

@implementation ZeroKitUtilities

+ (BOOL)isLoginItemEnabledForBundle: (NSBundle *)bundle {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [bundle bundlePath];
    CFURLRef applicationPathURL = (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    BOOL result = NO;

    if (sharedFileList) {
        NSArray *sharedFileListArray = nil;
        UInt32 seedValue;

        sharedFileListArray = (NSArray *)LSSharedFileListCopySnapshot(sharedFileList, &seedValue);

        for (id sharedFile in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileListItem = (LSSharedFileListItemRef)sharedFile;

            LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);

            if (applicationPathURL != NULL) {
                NSString *resolvedApplicationPath = [(NSURL *)applicationPathURL path];

                if ([resolvedApplicationPath compare: applicationPath] == NSOrderedSame) {
                    result = YES;

                    break;
                }
            }
        }

        CFRelease(sharedFileListArray);
    } else {
        NSLog(@"Unable to create the shared file list.");
    }

    return result;
}

+ (void)enableLoginItemForBundle: (NSBundle *)bundle {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [bundle bundlePath];
    CFURLRef applicationPathURL = (CFURLRef)[NSURL fileURLWithPath: applicationPath];

    if (sharedFileList) {
        LSSharedFileListItemRef sharedFileListItem = LSSharedFileListInsertItemURL(sharedFileList, kLSSharedFileListItemLast, NULL, NULL, applicationPathURL, NULL, NULL);

        if (sharedFileListItem) {
            CFRelease(sharedFileListItem);
        }

        CFRelease(sharedFileList);
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
}

+ (void)disableLoginItemForBundle: (NSBundle *)bundle {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [bundle bundlePath];
    CFURLRef applicationPathURL = (CFURLRef)[NSURL fileURLWithPath: applicationPath];

    if (sharedFileList) {
        NSArray *sharedFileListArray = nil;
        UInt32 seedValue;

        sharedFileListArray = (NSArray *)LSSharedFileListCopySnapshot(sharedFileList, &seedValue);

        for (id sharedFile in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileListItem = (LSSharedFileListItemRef)sharedFile;

            LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);

            if (applicationPathURL != NULL) {
                NSString *resolvedApplicationPath = [(NSURL *)applicationPathURL path];

                if ([resolvedApplicationPath compare: applicationPath] == NSOrderedSame) {
                    LSSharedFileListItemRemove(sharedFileList, sharedFileListItem);
                }
            }
        }

        CFRelease(sharedFileListArray);
        CFRelease(sharedFileList);
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
}

@end
