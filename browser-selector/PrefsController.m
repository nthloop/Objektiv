//
//  PrefsController.m
//  browser-selector
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "PrefsController.h"
#import "Constants.h"

@interface PrefsController ()
{
    @private
    NSUserDefaults *defaults;
}
@end

@implementation PrefsController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
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

    ZeroKitHotKey *hotkey = [[ZeroKitHotKey alloc]
                             initWithHotKeyCode:0x0B hotKeyModifiers:(NSAlternateKeyMask | NSCommandKeyMask)];

    NSLog(@"Setting up hotkey recorder: %@", self.hotkeyRecorder);
    self.hotkeyRecorder.hotKey = hotkey;
    self.hotkeyRecorder.hotKeyName = [hotkey hotKeyName];
    self.hotkeyRecorder.delegate = self;
    
    NSLog(@"initUI called");
    NSLog(@"Outlets: %@, %@", self.autoHideIcon, self.startAtLogin);
}

#pragma mark - HotkeyRecorder
- (void)hotKeyRecorder:(ZeroKitHotKeyRecorder *)hotKeyRecorder didClearExistingHotKey:(ZeroKitHotKey *)hotKey
{
    NSLog(@"didClearExistingHotKey: %@", hotKey);
}
- (void)hotKeyRecorder:(ZeroKitHotKeyRecorder *)hotKeyRecorder didReceiveNewHotKey:(ZeroKitHotKey *)hotKey
{
    NSLog(@"didReceiveNewHotKey: %@", hotKey);
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
