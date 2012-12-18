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
#import "BrowserItem.h"

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

    NSArray *browsers = [appDelegate browsers];
    NSString *defaultBrowser = [sharedWorkspace defaultBrowserIdentifier];

    NSLog(@"Browsers list: %@", browsers);

    for (int i = 0, count = 1; i < browsers.count; i++)
    {
        BrowserItem *browser = browsers[i];

        if (browser.blacklisted) { continue; }
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:browser.name
                                                      action:@selector(selectABrowser:)
                                               keyEquivalent:[NSString stringWithFormat:@"%d", count]];

        item.target = appDelegate;
        item.image = [ImageUtils menuIconForAppId:browser.identifier];
        item.representedObject = browser.identifier;
        item.state = [browser.identifier isEqualToString:defaultBrowser];

        [self addItem:item];

        // Create an alternate item used to blacklist the browser
        NSMenuItem *alternate = [item copy];
        alternate.keyEquivalentModifierMask = NSAlternateKeyMask;
        [alternate setAlternate:YES];
        alternate.action = @selector(blacklistABrowser:);

        [self addItem:alternate];

        count++;
    }

    NSMenuItem *submenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Blacklisted", nil)
                                                     action:@selector(showAbout) keyEquivalent:@""];
    submenu.view = [[NSView alloc] init];
    [self addItem:submenu];

    NSMenuItem *submenuAlt = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Blacklisted", nil)
                                                        action:@selector(showAbout) keyEquivalent:@""];
    submenuAlt.submenu = [[NSMenu alloc] init];
    submenuAlt.keyEquivalentModifierMask = NSAlternateKeyMask;
    [submenuAlt setAlternate:YES];

    for (int i = 0; i < browsers.count; i++)
    {
        BrowserItem *browser = browsers[i];

        if (!browser.blacklisted) { continue; }
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:browser.name
                                                      action:@selector(removeFromBlacklist:)
                                               keyEquivalent:@""];

        item.target = appDelegate;
        item.image = [ImageUtils menuIconForAppId:browser.identifier];
        item.representedObject = browser.identifier;

        [submenuAlt.submenu addItem:item];
    }
    [self addItem:submenuAlt];


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
