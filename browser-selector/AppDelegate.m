//
//  AppDelegate.m
//  browser-selector
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserItem.h"
#import "Constants.h"
#import "PrefsController.h"
#import "HotkeyManager.h"
#import "NSWorkspace+Utils.h"
#import "ImageUtils.h"
#import "BrowsersMenu.h"
#import "OverlayWindow.h"
#import <ZeroKit/ZeroKitUtilities.h>

@interface AppDelegate()
{
    @private
    NSStatusItem *statusBarIcon;
    BrowsersMenu *browserMenu;
    NSUserDefaults *defaults;
    NSWorkspace *sharedWorkspace;
    HotkeyManager *hotkeyManager;
    NSArray *blacklist;
    OverlayWindow *overlayWindow;
}
@end

@implementation AppDelegate

{} // TODO Figure out why the first pragma mark requires this empty block to show up

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"applicationDidFinishLaunching");

    self.prefsController = [[PrefsController alloc] initWithWindowNibName:@"PrefsController"];
    sharedWorkspace = [NSWorkspace sharedWorkspace];
    blacklist = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                         pathForResource:@"Blacklist"
                                                         ofType:@"plist"]];

    browserMenu = [[BrowsersMenu alloc] init];

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

    overlayWindow = [[OverlayWindow alloc] init];

    NSLog(@"applicationDidFinishLaunching :: finish");
}

- (BOOL)applicationShouldHandleReopen: (NSApplication *)application hasVisibleWindows: (BOOL)visibleWindows
{
    [self showAndHideIcon:nil];
    return YES;
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

- (NSArray*) browsers
{
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    NSArray *identifiers = [sharedWorkspace installedBrowserIdentifiers];
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
        [allBrowsers addObject:item];
    }

    return [allBrowsers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

- (void) selectABrowser:sender
{
    NSString *newDefaultBrowser = [sender respondsToSelector:@selector(representedObject)]
        ? [sender representedObject]
        :sender;
    
//    NSMenuItem *menuItem = sender;
//    NSMenu *menu = menuItem.menu;
//
//    [menu.itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [obj setState:NSOffState];
//    }];
//    menuItem.state = NSOnState;

    NSLog(@"Selecting a browser: %@", newDefaultBrowser);
    [sharedWorkspace setDefaultBrowserWithIdentifier:newDefaultBrowser];
    statusBarIcon.image = [ImageUtils statusBarIconForAppId:newDefaultBrowser];

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
    if (!browserIdentifier) return NO;

    NSArray *prefsBlacklist = [defaults valueForKey:PrefBlacklist];
    NSUInteger index = [prefsBlacklist indexOfObjectPassingTest:^BOOL(id blacklistedIdentifier, NSUInteger idx, BOOL *stop) {
        return [browserIdentifier rangeOfString:blacklistedIdentifier].location != NSNotFound;
    }];

    return index != NSNotFound;
}

- (void) blacklistABrowser:sender
{
    NSString *identifier = [sender representedObject];
    NSMutableArray *prefsBlacklist = [[defaults valueForKey:PrefBlacklist] mutableCopy];
    [prefsBlacklist addObject:identifier];
    [defaults setValue:prefsBlacklist forKey:PrefBlacklist];
}

- (void) removeFromBlacklist:sender
{
    NSString *identifier = [sender representedObject];
    NSMutableArray *prefsBlacklist = [[defaults valueForKey:PrefBlacklist] mutableCopy];

    NSUInteger index = [prefsBlacklist indexOfObjectPassingTest:^BOOL(id blacklistedIdentifier, NSUInteger idx, BOOL *stop) {
        return [identifier rangeOfString:blacklistedIdentifier].location != NSNotFound;
    }];

    if (index == NSNotFound) { return; }

    [prefsBlacklist removeObjectAtIndex:index];
    [defaults setValue:prefsBlacklist forKey:PrefBlacklist];
}

#pragma mark - UI

- (void) hotkeyTriggered
{
    NSLog(@"@Hotkey triggered");
    [overlayWindow makeKeyAndOrderFront:NSApp];
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
    statusBarIcon.image = [ImageUtils statusBarIconForAppId:defaultBrowser];
    statusBarIcon.highlightMode = YES;

    statusBarIcon.menu = browserMenu;
}

- (void) destroyStatusBarIcon
{
    NSLog(@"destroyStatusBarIcon");
    if (![defaults boolForKey:PrefAutoHideIcon])
    {
        return;
    }
    if (browserMenu.menuIsOpen)
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

- (void) showAbout
{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
}

- (void) doQuit
{
    [NSApp terminate:nil];
}

#pragma mark - Utilities

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
