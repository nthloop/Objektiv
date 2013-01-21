//
//  Browsers.m
//  Objektiv
//
//  Created by Ankit Solanki on 19/01/13.
//  Copyright (c) 2013 nth loop. All rights reserved.
//

#import "Browsers.h"
#import "Constants.h"
#import "NSWorkspace+Utils.h"

@implementation Browsers {
    NSArray *_browsers;
}

+ (Browsers*)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

+ (NSArray*) browsers
{
    return [[Browsers sharedInstance] browsers];
}

+ (NSArray*) validBrowsers
{
    return [[Browsers sharedInstance] validBrowsers];
}

- (NSArray*) browsers
{
    if (![_browsers count]) { [self findBrowsers]; }
    return _browsers;
}

- (void) findBrowsersAsync
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self findBrowsers];
    });
}

- (void) findBrowsers
{
    NSLog(@"Find browsers");
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSArray *identifiers = [sharedWorkspace installedBrowserIdentifiers];
    NSString *defaultBrowser = [sharedWorkspace defaultBrowserIdentifier];
    NSMutableArray *allBrowsers = [[NSMutableArray alloc] initWithCapacity:identifiers.count];

    for (int i = 0; i < identifiers.count; i++) {
        NSString *browser = identifiers[i];

        if (!browser) {
            NSLog(@"Invalid application identifier: position %d of %@", i, identifiers);
            continue;
        }

        NSString *browserPath = [sharedWorkspace absolutePathForAppBundleWithIdentifier:browser];
        if (!browserPath) {
            NSLog(@"Can't find path of browser: %@", browser);
            continue;
        }

        NSString *browserName = [defaultFileManager displayNameAtPath:browserPath];
        if (!browserName) {
            NSLog(@"Can't find path of browser: %@", browser);
            continue;
        }

        BrowserItem *item = [[BrowserItem alloc] initWithApplicationId:browser name:browserName path:browserPath];
        item.blacklisted = [self isBlacklisted:browser];
        item.isDefault = [browser isEqualToString:defaultBrowser];
        [allBrowsers addObject:item];
    }

    _browsers = [allBrowsers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

}

- (NSArray*) validBrowsers
{
    return [self.browsers filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BrowserItem *item = evaluatedObject;
        return !item.blacklisted;
    }]];
}

- (BOOL) isBlacklisted:(NSString*) browserIdentifier
{
    if (!browserIdentifier) return NO;

    NSArray *prefsBlacklist = [[NSUserDefaults standardUserDefaults] valueForKey:PrefBlacklist];
    NSUInteger index = [prefsBlacklist indexOfObjectPassingTest:^BOOL(id blacklistedIdentifier, NSUInteger idx, BOOL *stop) {
        return [browserIdentifier rangeOfString:blacklistedIdentifier].location != NSNotFound;
    }];

    return index != NSNotFound;
}

- (void) blacklistABrowser:sender
{
    NSString *identifier = [sender representedObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefsBlacklist = [[defaults valueForKey:PrefBlacklist] mutableCopy];
    [prefsBlacklist addObject:identifier];
    [defaults setValue:prefsBlacklist forKey:PrefBlacklist];

    [self findBrowsersAsync];
}

- (void) removeFromBlacklist:sender
{
    NSString *identifier = [sender representedObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefsBlacklist = [[defaults valueForKey:PrefBlacklist] mutableCopy];

    NSUInteger index = [prefsBlacklist indexOfObjectPassingTest:^BOOL(id blacklistedIdentifier, NSUInteger idx, BOOL *stop) {
        return [identifier rangeOfString:blacklistedIdentifier].location != NSNotFound;
    }];

    if (index == NSNotFound) { return; }

    [prefsBlacklist removeObjectAtIndex:index];
    [defaults setValue:prefsBlacklist forKey:PrefBlacklist];

    [self findBrowsersAsync];
}

- (NSString*) defaultBrowserIdentifier
{
    return [[NSWorkspace sharedWorkspace] defaultBrowserIdentifier];
}

- (void) setDefaultBrowserIdentifier:(NSString *)defaultBrowserIdentifier
{
    [[NSWorkspace sharedWorkspace] setDefaultBrowserWithIdentifier:defaultBrowserIdentifier];
}

@end
