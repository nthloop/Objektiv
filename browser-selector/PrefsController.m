//
//  PrefsController.m
//  browser-selector
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "PrefsController.h"
#import "Constants.h"
#import "HotkeyManager.h"

@interface PrefsController ()
{
    @private
    NSUserDefaults *defaults;
    ZeroKitHotKey *lastHotkey;
    HotkeyManager *hotkeyManager;
}
@end

@implementation PrefsController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
        hotkeyManager = [HotkeyManager sharedInstance];
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self initUI];
}

#pragma mark - UI methods

- (void) showPreferences
{
    //[self initUI];

    [self.window makeKeyAndOrderFront:NSApp];
    [NSApp activateIgnoringOtherApps:YES];
}


- (void) initUI
{
    self.autoHideIcon.state = [defaults boolForKey:PrefAutoHideIcon] ? NSOnState : NSOffState;
    self.startAtLogin.state = [defaults boolForKey:PrefStartAtLogin] ? NSOnState : NSOffState;

    lastHotkey = [[ZeroKitHotKey alloc] initWithHotKeyCode:[defaults integerForKey:PrefHotkeyCode]
                                           hotKeyModifiers:[defaults integerForKey:PrefHotkeyModifiers]];


    self.hotkeyRecorder.hotKey = lastHotkey;
    self.hotkeyRecorder.hotKeyName = [lastHotkey hotKeyName];
    self.hotkeyRecorder.delegate = self;
}

#pragma mark - HotkeyRecorder
- (void)hotKeyRecorder:(ZeroKitHotKeyRecorder *)hotKeyRecorder didClearExistingHotKey:(ZeroKitHotKey *)hotKey
{
    NSLog(@"didClearExistingHotKey: %@", hotKey);
    [hotkeyManager clearHotkey:hotKey];
}
- (void)hotKeyRecorder:(ZeroKitHotKeyRecorder *)hotKeyRecorder didReceiveNewHotKey:(ZeroKitHotKey *)hotKey
{
    NSLog(@"didReceiveNewHotKey: %@", hotKey);
    [hotkeyManager clearHotkey:hotKey];

    [hotkeyManager registerHotkey: hotKey];
}


#pragma mark - IBActions

- (IBAction)toggleLoginItem: (id)sender
{
    NSLog(@"PrefsController :: toggleLoginItem");
    [defaults setBool:(self.startAtLogin.state == NSOnState) forKey:PrefStartAtLogin];
}

- (IBAction)toggleHideItem: (id)sender
{
    NSLog(@"PrefsController :: toggleHideItem");
    [defaults setBool:(self.autoHideIcon.state == NSOnState) forKey:PrefAutoHideIcon];
}


@end
