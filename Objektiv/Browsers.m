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

    // This internal blacklist of browsers is always hidden
    NSArray *internalBlacklist;
}

+ (Browsers*)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

-(id)init
{
    self = [super init];

    internalBlacklist = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                pathForResource:@"Blacklist"
                                                         ofType:@"plist"]];
    return self;
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

    identifiers = [identifiers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id browserId, NSDictionary *bindings) {
        return ![self doesString:browserId matchPatternsInArray:internalBlacklist];
    }]];

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
        item.hidden = [self isHidden:browser];
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
        return !item.hidden;
    }]];
}

- (BOOL) doesString: (NSString*) targetString matchPatternsInArray:(NSArray*) array
{
    NSUInteger index = [array indexOfObjectPassingTest:^BOOL(id currentPattern, NSUInteger idx, BOOL *stop) {
        return [targetString rangeOfString:currentPattern].location != NSNotFound;
    }];

    return index != NSNotFound;
}

- (BOOL) isHidden:(NSString*) browserIdentifier
{
    if (!browserIdentifier) return NO;

    NSArray *prefsHidden = [[NSUserDefaults standardUserDefaults] valueForKey:PrefBlacklist];
    return [self doesString:browserIdentifier matchPatternsInArray:prefsHidden];
}

- (void) hideABrowser:sender
{
    NSString *identifier = [sender representedObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefsHidden = [[defaults valueForKey:PrefBlacklist] mutableCopy];
    [prefsHidden addObject:identifier];
    [defaults setValue:prefsHidden forKey:PrefBlacklist];

    [self findBrowsersAsync];
}

- (void) unhideABrowser:sender
{
    NSString *identifier = [sender representedObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefsHidden = [[defaults valueForKey:PrefBlacklist] mutableCopy];

    NSUInteger index = [prefsHidden indexOfObjectPassingTest:^BOOL(id hiddenIdentifer, NSUInteger idx, BOOL *stop) {
        return [identifier rangeOfString:hiddenIdentifer].location != NSNotFound;
    }];

    if (index == NSNotFound) { return; }

    [prefsHidden removeObjectAtIndex:index];
    [defaults setValue:prefsHidden forKey:PrefBlacklist];

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
