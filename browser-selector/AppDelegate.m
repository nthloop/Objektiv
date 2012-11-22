//
//  AppDelegate.m
//  browser-selector
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "AppDelegate.h"
#import "NSWorkspace+Utils.h"
#import "Constants.h"
#import "DDHotKeyCenter.h"

NSStatusItem *statusBarIcon;
NSMenu *browserMenu;
NSUserDefaults *defaults;
DDHotKeyCenter *hotkeyCenter;
NSWorkspace *sharedWorkspace;
Boolean menuIsOpen = NO;

@interface AppDelegate()

-(void) createStatusBarIcon;
- (NSImage*) resizedIconForPath:(NSString*)path;
- (void) selectABrowser:sender;
@end

@implementation AppDelegate


- (void) createStatusBarIcon
{
    if (statusBarIcon != nil) return;
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSString *defaultBrowser = [sharedWorkspace defaultBrowserIdentifier];

    statusBarIcon = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusBarIcon.toolTip = AppDescription;
    statusBarIcon.image = [self resizedIconForPath:defaultBrowser];

    statusBarIcon.menu = browserMenu;
}

- (NSImage*) resizedIconForPath:(NSString*)browserIdentifier
{
    NSString *path = [sharedWorkspace absolutePathForAppBundleWithIdentifier:browserIdentifier];
    NSImage *icon = [[sharedWorkspace iconForFile:path] copy];
    icon.scalesWhenResized = YES;
    icon.size = CGSizeMake(16, 16);
    return icon;
}

- (void) destroyStatusBarIcon
{
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
    [self createStatusBarIcon];
    if ([defaults boolForKey:PrefAutoHideIcon])
    {
        [self performSelector:@selector(destroyStatusBarIcon) withObject:nil afterDelay:10];
    }
}

- (void) selectABrowser:sender 
{
    NSString *newDefaultBrowser = [sender representedObject];
    NSMenuItem *menuItem = sender;
    NSMenu *menu = menuItem.menu;

    NSLog(@"Deselecting all other menu items");
    for (NSMenuItem *item in menu.itemArray)
    {
        item.state = NSOffState;
    }
    menuItem.state = NSOnState;

    NSLog(@"Selecting a browser: %@", newDefaultBrowser);
    [sharedWorkspace setDefaultBrowserWithIdentifier:newDefaultBrowser];
    statusBarIcon.image = [self resizedIconForPath:newDefaultBrowser];

    [self showNotification:newDefaultBrowser];
}

- (void) createMenu
{
    browserMenu = [[NSMenu alloc] init];
    
    [browserMenu setDelegate:self];
    
    NSArray *browsers = [sharedWorkspace installedBrowserIdentifiers];
    NSString *defaultBrowser = [sharedWorkspace defaultBrowserIdentifier];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    
    for (int i = 0; i < browsers.count; i++)
    {
        NSString *browser = browsers[i];
        NSString *browserPath = [sharedWorkspace absolutePathForAppBundleWithIdentifier:browser];
        NSString *browserName = [defaultFileManager displayNameAtPath:browserPath];

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
    [browserMenu addItem:prefsItem];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(doQuit) keyEquivalent:@"q"];
    [browserMenu addItem:quitItem];
}

- (void) doQuit
{
    [NSApp terminate:nil];
}

- (void) showPreferences
{
    [[self window] makeKeyAndOrderFront:NSApp];
    [NSApp activateIgnoringOtherApps:YES];
}

-(void) menuDidClose:(NSMenu *) theMenu { menuIsOpen = NO;  }
-(void) menuWillOpen:(NSMenu *) theMenu { menuIsOpen = YES; }

- (void) showNotification:(NSString *)browserIdentifier
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Hello, World!";
    notification.informativeText = @"A notification";

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.window.title = AppName;
    
    sharedWorkspace = [NSWorkspace sharedWorkspace];
    
    [self createMenu];
    
    hotkeyCenter = [[DDHotKeyCenter alloc] init];
    [hotkeyCenter registerHotKeyWithKeyCode:0x0B
                              modifierFlags:(NSAlternateKeyMask | NSCommandKeyMask)
                                     target:self
                                     action:@selector(showAndHideIcon:)
                                     object:nil];

    defaults = [NSUserDefaults standardUserDefaults];

    [defaults addObserver:self
               forKeyPath:PrefAutoHideIcon
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [defaults addObserver:self
               forKeyPath:PrefStartAtLogin
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    NSString *dictPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:dictPath]];


    [self updateUI];

    [self showAndHideIcon:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{

    if ([keyPath isEqualToString:PrefAutoHideIcon])
    {
        [self showAndHideIcon:nil];
    }

    NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
}

- (void) updateUI
{
    self.autoHideIcon.state = [defaults boolForKey:PrefAutoHideIcon] ? NSOnState : NSOffState;
    self.startAtLogin.state = [defaults boolForKey:PrefStartAtLogin] ? NSOnState : NSOffState;
}

- (IBAction)toggleLoginItem: (id)sender
{
    [defaults setBool:(self.startAtLogin.state == NSOnState) forKey:PrefAutoHideIcon];
}

- (IBAction)toggleHideItem: (id)sender
{
    BOOL autoHide = self.autoHideIcon.state == NSOnState;
    [defaults setBool:autoHide forKey:PrefAutoHideIcon];
}


- (BOOL)applicationShouldHandleReopen: (NSApplication *)application hasVisibleWindows: (BOOL)visibleWindows
{
    [self showAndHideIcon:nil];
    return YES;
}


@end
