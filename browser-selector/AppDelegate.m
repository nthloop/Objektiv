//
//  AppDelegate.m
//  browser-selector
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "AppDelegate.h"
#import "PrefsController.h"
#import "HotkeyManager.h"
#import "NSWorkspace+Utils.h"
#import "Constants.h"
#import <ZeroKit/ZeroKitUtilities.h>

@interface AppDelegate()
{
    @private

    PrefsController *prefsController;
    NSStatusItem *statusBarIcon;
    NSMenu *browserMenu;
    NSUserDefaults *defaults;
    NSWorkspace *sharedWorkspace;
    Boolean menuIsOpen;
    HotkeyManager *hotkeyManager;
    NSArray *blacklist;
}
@end

@implementation AppDelegate

{} // TODO Figure out why the first pragma mark requires this empty block to show up

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"applicationDidFinishLaunching");

    prefsController = [[PrefsController alloc] initWithWindowNibName:@"PrefsController"];
    sharedWorkspace = [NSWorkspace sharedWorkspace];
    blacklist = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                         pathForResource:@"Blacklist"
                                                         ofType:@"plist"]];
    menuIsOpen = NO;

    browserMenu = [[NSMenu alloc] init];
    [browserMenu setDelegate:self];

    hotkeyManager = [HotkeyManager sharedInstance];

    NSLog(@"Setting defaults");
    [ZeroKitUtilities registerDefaultsForBundle:[NSBundle mainBundle]];
    defaults = [NSUserDefaults standardUserDefaults];

    [defaults addObserver:self
               forKeyPath:PrefAutoHideIcon
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [defaults addObserver:self
               forKeyPath:PrefStartAtLogin
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    if ([defaults boolForKey:PrefAutoHideIcon]) [hotkeyManager registerStoredHotkey];
    [self showAndHideIcon:nil];

    NSLog(@"Initial debug data");
    NSArray *browsers = [sharedWorkspace installedBrowserIdentifiers];
    NSLog(@"Browser: %@", browsers);
    NSLog(@"Default browser: %@", [sharedWorkspace defaultBrowserIdentifier]);

    NSLog(@"applicationDidFinishLaunching :: finish");
}

- (BOOL)applicationShouldHandleReopen: (NSApplication *)application hasVisibleWindows: (BOOL)visibleWindows
{
    [self showAndHideIcon:nil];
    return YES;
}

#pragma mark - NSMenuDelegate

-(void) menuDidClose:(NSMenu *) theMenu { menuIsOpen = NO; }

-(void) menuWillOpen:(NSMenu *) theMenu {
    menuIsOpen = YES;
    [self createMenu];
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{

    if ([keyPath isEqualToString:PrefAutoHideIcon])
    {
        if ([change valueForKey:@"new"])
        {
            [hotkeyManager registerStoredHotkey];
        } else
        {
            [hotkeyManager clearHotkey];
        }

        [self showAndHideIcon:nil];
    }
    else if ([keyPath isEqualToString:PrefStartAtLogin])
    {
        [self toggleLoginItem];
    }
}

#pragma mark - "Business" Logic

- (void) selectABrowser:sender
{
    NSString *newDefaultBrowser = [sender representedObject];
    NSMenuItem *menuItem = sender;
    NSMenu *menu = menuItem.menu;

    [menu.itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setState:NSOffState];
    }];
    menuItem.state = NSOnState;

    NSLog(@"Selecting a browser: %@", newDefaultBrowser);
    [sharedWorkspace setDefaultBrowserWithIdentifier:newDefaultBrowser];
    statusBarIcon.image = [self resizedIconForPath:newDefaultBrowser];

    [self showNotification:newDefaultBrowser];
}

- (void) toggleLoginItem
{
    if ([defaults boolForKey:PrefStartAtLogin])
    {
        [ZeroKitUtilities enableLoginItemForBundle:[NSBundle mainBundle]];
    }
    else
    {
        [ZeroKitUtilities disableLoginItemForBundle:[NSBundle mainBundle]];
    }
}

- (BOOL) isBlacklisted:(NSString*) browserIdentifier
{
    if (!blacklist.count || !browserIdentifier) return NO;

    NSInteger index = [blacklist indexOfObjectPassingTest:^BOOL(id blacklistedIdentifier, NSUInteger idx, BOOL *stop) {
        NSRange range = [browserIdentifier rangeOfString:blacklistedIdentifier];
        return range.location != NSNotFound;
    }];

    return  index != NSNotFound;
}

#pragma mark - UI

- (void) hotkeyTriggered
{
    NSLog(@"@Hotkey triggered");
    [self showAndHideIcon:nil];
}

- (void) createStatusBarIcon
{
    NSLog(@"createStatusBarIcon");
    if (statusBarIcon != nil) return;
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSString *defaultBrowser = [sharedWorkspace defaultBrowserIdentifier];

    statusBarIcon = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusBarIcon.toolTip = AppDescription;
    statusBarIcon.image = [self resizedIconForPath:defaultBrowser];

    statusBarIcon.menu = browserMenu;
}

- (void) destroyStatusBarIcon
{
    NSLog(@"destroyStatusBarIcon");
    if (![defaults boolForKey:PrefAutoHideIcon])
    {
        return;
    }
    if (menuIsOpen)
    {
        [self performSelector:@selector(destroyStatusBarIcon) withObject:nil afterDelay:10];
    }
    else
    {
        [[statusBarIcon statusBar] removeStatusItem:statusBarIcon];
        statusBarIcon = nil;
    }
}

- (void) showAndHideIcon:(NSEvent*)hotKeyEvent
{
    NSLog(@"showAndHideIcon");
    [self createStatusBarIcon];
    if ([defaults boolForKey:PrefAutoHideIcon])
    {
        [self performSelector:@selector(destroyStatusBarIcon) withObject:nil afterDelay:10];
    }
}

- (void) createMenu
{
    NSLog(@"Create Menu");
    [browserMenu removeAllItems];

    NSArray *browsers = [sharedWorkspace installedBrowserIdentifiers];
    NSString *defaultBrowser = [sharedWorkspace defaultBrowserIdentifier];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];

    NSLog(@"Browsers list: %@", browsers);

    for (int i = 0; i < browsers.count; i++)
    {
        NSString *browser = browsers[i];

        if ([self isBlacklisted:browser]) { continue; }

        NSString *browserPath = [sharedWorkspace absolutePathForAppBundleWithIdentifier:browser];
        if (!browserPath) continue;

        NSString *browserName = [defaultFileManager displayNameAtPath:browserPath];
        if (!browserName) continue;

        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:browserName
                                                      action:@selector(selectABrowser:)
                                               keyEquivalent:@""];

        item.image = [self resizedIconForPath:browser];
        item.representedObject = browser;
        item.state = [browser isEqualToString:defaultBrowser];

        [browserMenu addItem:item];
    }

    [browserMenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *prefsItem = [[NSMenuItem alloc] initWithTitle:@"Preferences"
                                                       action:@selector(showPreferences)
                                                keyEquivalent:@","];
    prefsItem.target = prefsController;
    [browserMenu addItem:prefsItem];

    [browserMenu addItem:[[NSMenuItem alloc]
                          initWithTitle:@"About"
                                 action:@selector(showAbout)
                          keyEquivalent:@"a"]];


    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(doQuit) keyEquivalent:@"q"];
    [browserMenu addItem:quitItem];
}

- (void) showAbout
{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
}

- (void) doQuit
{
    [NSApp terminate:nil];
}

#pragma mark - Utilities

- (NSImage*) resizedIconForPath:(NSString*)browserIdentifier
{
    NSString *path = [sharedWorkspace absolutePathForAppBundleWithIdentifier:browserIdentifier];
    NSImage *icon = [[sharedWorkspace iconForFile:path] copy];
    icon.scalesWhenResized = YES;
    icon.size = CGSizeMake(16, 16);
    return icon;
}

- (void) showNotification:(NSString *)browserIdentifier
{
    NSString *browserPath = [sharedWorkspace absolutePathForAppBundleWithIdentifier:browserIdentifier];
    NSString *browserName = [[NSFileManager defaultManager] displayNameAtPath:browserPath];

    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [NSString stringWithFormat:NotificationTitle, browserName];
    notification.informativeText = [NSString stringWithFormat:NotificationText, browserName, AppName];

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}


@end
