//
//  HotkeyManager.m
//  browser-selector
//
//  Created by Ankit Solanki on 05/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "HotkeyManager.h"
#import "Constants.h"

@implementation HotkeyManager {
    @private
    DDHotKeyCenter *hotkeyCenter;
    NSUserDefaults *defaults;

    enum {
        ZeroKitHotKeyAlternateCarbonKeyMask = 1 << 11,
        ZeroKitHotKeyCommandCarbonKeyMask   = 1 << 8,
        ZeroKitHotKeyControlCarbonKeyMask   = 1 << 12,
        ZeroKitHotKeyShiftCarbonKeyMask     = 1 << 9,
    };

}


static HotkeyManager *_sharedInstance = nil;

+(HotkeyManager*) sharedInstance
{
    if (!_sharedInstance)
    {
        _sharedInstance = [[HotkeyManager alloc] init];
    }
    return _sharedInstance;
}

-(id) init
{
    self = [super init];
    defaults = [NSUserDefaults standardUserDefaults];
    hotkeyCenter = [[DDHotKeyCenter alloc] init];
    return self;
}

-(void) registerHotkey:(ZeroKitHotKey*) hotkey
{
    [self registerHotkeyWithKeyCode:((unsigned short) hotkey.hotKeyCode)
                      modifierFlags:[self convertCarbonModifiersToCocoa:hotkey.hotKeyModifiers]];
}

-(void) registerHotkeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags
{
    NSLog(@"Registering hotkey: %d %ld", keyCode, flags);

    [defaults setInteger:keyCode forKey:PrefHotkeyCode];
    [defaults setInteger:flags forKey:PrefHotkeyModifiers];

    if ([defaults boolForKey:PrefAutoHideIcon])
    {
        [hotkeyCenter registerHotKeyWithKeyCode:keyCode
                                  modifierFlags:flags
                                         target:self
                                         action:@selector(hotkeyDidFire:)
                                         object:nil];
    }

    NSLog(@"New saved values: %ld %ld",
          [defaults integerForKey:PrefHotkeyCode],
          [defaults integerForKey:PrefHotkeyModifiers]);

}

-(void) clearHotkey
{
    [defaults setInteger:0 forKey:PrefHotkeyCode];
    [defaults setInteger:0 forKey:PrefHotkeyModifiers];
    NSLog(@"New saved values: %ld %ld",
          [defaults integerForKey:PrefHotkeyCode],
          [defaults integerForKey:PrefHotkeyModifiers]);

    [[hotkeyCenter registeredHotKeys] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        DDHotKey *hotkey = (DDHotKey*) obj;
        [hotkeyCenter unregisterHotKey:hotkey];
    }];
}

-(void) hotkeyDidFire: (NSEvent*)hotKeyEvent
{
    [[NSApplication sharedApplication].delegate performSelector:@selector(hotkeyTriggered)];
}

-(void) registerStoredHotkey
{
    NSInteger code = [defaults integerForKey:PrefHotkeyCode];
    NSInteger flags = [defaults integerForKey:PrefHotkeyModifiers];

    [self clearHotkey];

    if ([defaults boolForKey:PrefAutoHideIcon] && code != 0 && flags != 0)
    {
        [self registerHotkeyWithKeyCode:code modifierFlags:flags];
    }
}


- (NSInteger)convertCarbonModifiersToCocoa: (NSInteger)modifiers {
    NSInteger convertedModifiers = 0;

    if (modifiers & ZeroKitHotKeyControlCarbonKeyMask) {
        convertedModifiers |= NSControlKeyMask;
    }

    if (modifiers & ZeroKitHotKeyAlternateCarbonKeyMask) {
        convertedModifiers |= NSAlternateKeyMask;
    }

    if (modifiers & ZeroKitHotKeyShiftCarbonKeyMask) {
        convertedModifiers |= NSShiftKeyMask;
    }

    if (modifiers & ZeroKitHotKeyCommandCarbonKeyMask) {
        convertedModifiers |= NSCommandKeyMask;
    }

    return convertedModifiers;
}



@end
