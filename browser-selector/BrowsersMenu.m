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
    NSMenu *hiddenMenu = [[NSMenu alloc] init];

    NSLog(@"Browsers list: %@", browsers);

    for (int i = 0, count = 1; i < browsers.count; i++)
    {
        BrowserItem *browser = browsers[i];

        // Blacklisted browsers will be present in a hidden menu
        // that will only be made visible on pressing Option
        if (browser.blacklisted) {
            NSMenuItem *item = [self menuItemForBrowser:browser withHotkey:nil];

            item.offStateImage = [NSImage imageNamed:NSImageNameAddTemplate];
            item.toolTip = [NSString stringWithFormat:NSLocalizedString(@"Show %@", nil), browser.name];
            item.action = @selector(removeFromBlacklist:);

            [hiddenMenu addItem:item];
            continue;
        }

        NSMenuItem *item = [self menuItemForBrowser:browser withHotkey:[NSString stringWithFormat:@"%d", count]];
        item.action = @selector(selectABrowser:);
        item.state = browser.isDefault;

        [self addItem:item];

        // Create an alternate item used to blacklist the browser
        NSMenuItem *alternate = [item copy];

        alternate.keyEquivalentModifierMask = NSAlternateKeyMask;
        [alternate setAlternate:YES];
        alternate.state = NSMixedState;
        alternate.mixedStateImage = [NSImage imageNamed:NSImageNameRemoveTemplate];
        alternate.toolTip = [NSString stringWithFormat:NSLocalizedString(@"Hide %@", nil), browser.name];

        alternate.action = @selector(blacklistABrowser:);
        [self addItem:alternate];

        count++;
    }

    NSMenuItem *submenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Press ⌥ for more options", nil)
                                                     action:nil keyEquivalent:@""];
    [self addItem:submenu];

    NSMenuItem *submenuAlt = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Hidden Items", nil)
                                                        action:nil keyEquivalent:@""];
    submenuAlt.submenu = hiddenMenu;
    submenuAlt.keyEquivalentModifierMask = NSAlternateKeyMask;
    [submenuAlt setAlternate:YES];
    [self addItem:submenuAlt];

    [self addCommonItems];
}

# pragma mark - Internal methods

-(NSMenuItem*) menuItemForBrowser: (BrowserItem*) browser withHotkey:(NSString*) hotkey
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:browser.name
                                                  action:nil
                                           keyEquivalent:hotkey == nil ? @"" : hotkey];

    item.target = appDelegate;
    item.image = [ImageUtils menuIconForAppId:browser.identifier];
    item.state = NSOffState;
    item.representedObject = browser.identifier;

    return item;
}

-(void) addCommonItems
{
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
