//
//  HotkeyManager.h
//  browser-selector
//
//  Created by Ankit Solanki on 05/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZeroKit/ZeroKit.h>
#import "DDHotKeyCenter.h"

@interface HotkeyManager : NSObject

+(HotkeyManager*) sharedInstance;

-(void) registerHotkeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;
-(void) registerHotkey:(ZeroKitHotKey*) hotkey;

-(void) clearHotkeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;
-(void) clearHotkey:(ZeroKitHotKey*) hotkey;

-(void) hotkeyDidFire: (NSEvent*)hotKeyEvent;

@end
