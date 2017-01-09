//
//  AppDelegate.m
//  Objektiv
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserItem.h"
#import "Browsers.h"
#import "Constants.h"
#import "PrefsController.h"
#import "ImageUtils.h"
#import "BrowsersMenu.h"
#import "OverlayWindow.h"
#import "ZeroKitUtilities.h"
#import <MASShortcut/Shortcut.h>
#import "PFMoveApplication.h"
#import <CDEvents.h>
#import <Sparkle/Sparkle.h>

@interface AppDelegate()
{
    @private
    NSStatusItem *statusBarIcon;
    BrowsersMenu *browserMenu;
    NSUserDefaults *defaults;
    NSWorkspace *sharedWorkspace;
    OverlayWindow *overlayWindow;
    CDEvents *cdEvents;
    NSString *_defaultBrowser;
}
@end

@implementation AppDelegate

{} // TODO Figure out why the first pragma mark requires this empty block to show up

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self
            andSelector:@selector(getUrl:withReplyEvent:)
          forEventClass:kInternetEventClass
             andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    PFMoveToApplicationsFolderIfNecessary();

    NSLog(@"applicationDidFinishLaunching");

//    [[SUUpdater sharedUpdater] checkForUpdatesInBackground];

    self.prefsController = [[PrefsController alloc] initWithWindowNibName:@"PrefsController"];
    sharedWorkspace = [NSWorkspace sharedWorkspace];

    browserMenu = [[BrowsersMenu alloc] init];

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
    
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:PrefHotkey toAction:^{
        [self hotkeyTriggered];
     }];
    
    [[Browsers sharedInstance] findBrowsers];
    [self showAndHideIcon:nil];

    overlayWindow = [[OverlayWindow alloc] init];

    [self watchApplicationsFolder];

    NSLog(@"applicationDidFinishLaunching :: finish");
}

- (void)watchApplicationsFolder
{
    // Watch the /Applications & ~/Applications directories for a change
    NSArray *urls = @[
        [NSURL URLWithString:@"/Applications"],
        [NSURL URLWithString:[NSHomeDirectoryForUser(NSUserName()) stringByAppendingString:@"/Applications"]]
    ];

    cdEvents = [[CDEvents alloc] initWithURLs:urls block:^(CDEvents *watcher, CDEvent *event) {
        [[Browsers sharedInstance] findBrowsersAsync];
    }];
    cdEvents.ignoreEventsFromSubDirectories = YES;
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
        [self showAndHideIcon:nil];
    }
    if ([keyPath isEqualToString:PrefStartAtLogin])
    {
        [self toggleLoginItem];
    }
}

#pragma mark - "Business" Logic

- (NSArray*) browsers
{
    return [Browsers browsers];
}

- (void) selectABrowser:sender
{
    NSString *newDefaultBrowser = [sender respondsToSelector:@selector(representedObject)]
        ? [sender representedObject]
        :sender;

    NSLog(@"Selecting a browser: %@", newDefaultBrowser);
    [Browsers sharedInstance].defaultBrowserIdentifier = newDefaultBrowser;
    [self performSelector:@selector(updateStatusBarIcon) withObject:nil afterDelay:0.1];
    
    if ([defaults boolForKey:PrefShowNotifications])
    {
        [self showNotification:newDefaultBrowser];
    }
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

#pragma mark - UI


- (void) hotkeyTriggered
{
    NSLog(@"@Hotkey triggered");
    if (overlayWindow.isVisible) {
        [overlayWindow close];
        return;
    }
    [overlayWindow makeKeyAndOrderFront:NSApp];
    [self showAndHideIcon:nil];
}

- (void) createStatusBarIcon
{
    NSLog(@"createStatusBarIcon");
    if (statusBarIcon != nil) return;
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];

    statusBarIcon = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusBarIcon.toolTip = AppDescription;
    [self updateStatusBarIcon];
    statusBarIcon.highlightMode = YES;

    statusBarIcon.menu = browserMenu;
}

- (void) updateStatusBarIcon;
{
    NSString *identifier = [Browsers sharedInstance].defaultBrowserIdentifier;
    statusBarIcon.image = [ImageUtils statusBarIconForAppId:identifier];

    if ([identifier isEqualToString:_defaultBrowser]) return;
    _defaultBrowser = identifier;
    [[Browsers sharedInstance] findBrowsersAsync];
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
    NSUserNotificationCenter* center = [NSUserNotificationCenter defaultUserNotificationCenter];
    center.delegate = self;
    [center deliverNotification:notification];
}

- (void)getUrl:(NSAppleEventDescriptor *)event
withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    // Get the URL
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject]
                        stringValue];
    NSArray *urls = [NSArray arrayWithObject:[NSURL URLWithString:urlStr]];
    
    int options = NSWorkspaceLaunchAsync;

    [[NSWorkspace sharedWorkspace] openURLs: urls
                    withAppBundleIdentifier: [[Browsers sharedInstance] defaultBrowserIdentifier]
                                    options: options
             additionalEventParamDescriptor: nil
                          launchIdentifiers: nil];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
