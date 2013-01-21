//
//  ZeroKitUtilities.m
//  Objektiv
//
//  A stripped-down version of the ZeroKit's ZeroKitUtilities class,
//  mainly containing code we use in this project.
//

#import "ZeroKitUtilities.h"

@implementation ZeroKitUtilities

+ (void)registerDefaultsForBundle: (NSBundle *)bundle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [bundle pathForResource: @"Defaults" ofType: @"plist"];
    NSDictionary *applicationDefaults = [[[NSDictionary alloc] initWithContentsOfFile: path] autorelease];

    [defaults registerDefaults: applicationDefaults];
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
