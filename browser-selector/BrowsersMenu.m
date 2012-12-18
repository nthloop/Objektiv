//
//  BrowsersMenu.m
//  browser-selector
//
//  Created by Ankit Solanki on 18/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "BrowsersMenu.h"
#import "NSWorkspace+Utils.h"
#import "ImageUtils.h"
#import "AppDelegate.h"

@implementation BrowsersMenu {
    @private
    NSWorkspace *sharedWorkspace;
    AppDelegate *appDelegate;
}

-(id)init
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate*) [NSApplication sharedApplication].delegate;
        sharedWorkspace = [NSWorkspace sharedWorkspace];
        self.delegate = self;
        self.menuIsOpen = NO;
    }
    return self;
}

- (void) createMenu
{
    NSLog(@"Create Menu");
    [self removeAllItems];

    NSArray *browsers = [sharedWorkspace installedBrowserIdentifiers];
    NSString *defaultBrowser = [sharedWorkspace defaultBrowserIdentifier];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];

    NSLog(@"Browsers list: %@", browsers);

    for (int i = 0, count = 1; i < browsers.count; i++)
    {
        NSString *browser = browsers[i];

        if (!browser) {
            NSLog(@"Invalid application identifier: position %d of %@", i, browsers);
            continue;
        }

        if ([appDelegate isBlacklisted:browser]) { continue; }

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

        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:browserName
                                                      action:@selector(selectABrowser:)
                                               keyEquivalent:[NSString stringWithFormat:@"%d", count]];

        item.target = appDelegate;
        item.image = [ImageUtils menuIconForAppId:browser];
        item.representedObject = browser;
        item.state = [browser isEqualToString:defaultBrowser];

        [self addItem:item];
        count++;

    }

    [self addItem:[NSMenuItem separatorItem]];

    NSMenuItem *prefsItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Preferences", nil)
                                                       action:@selector(showPreferences)
                                                keyEquivalent:@","];
    prefsItem.target = appDelegate.prefsController;
    [self addItem:prefsItem];

    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"About", nil)
                                                       action:@selector(showAbout)
                                                keyEquivalent:@"a"];
    aboutItem.target = appDelegate;
    [self addItem:aboutItem];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit", nil)
                                                      action:@selector(doQuit)
                                               keyEquivalent:@"q"];
    quitItem.target = appDelegate;
    [self addItem:quitItem];
}

#pragma mark - NSMenuDelegate

-(void) menuDidClose:(NSMenu *) theMenu { self.menuIsOpen = NO; }

-(void) menuWillOpen:(NSMenu *) theMenu {
    self.menuIsOpen = YES;
    [self createMenu];
}

@end
