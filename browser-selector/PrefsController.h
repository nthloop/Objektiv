//
//  PrefsController.h
//  browser-selector
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ZeroKit/ZeroKit.h>

@interface PrefsController : NSWindowController<ZeroKitHotKeyRecorderDelegate>

-(void) showPreferences;

@property (assign) IBOutlet NSButton *startAtLogin;
@property (assign) IBOutlet NSButton *autoHideIcon;
@property (assign) IBOutlet ZeroKitHotKeyRecorder *hotkeyRecorder;


- (IBAction)toggleLoginItem: (id)sender;
- (IBAction)toggleHideItem: (id)sender;

- (void)hotKeyRecorder:(ZeroKitHotKeyRecorder *)hotKeyRecorder didClearExistingHotKey:(ZeroKitHotKey *)hotKey;
- (void)hotKeyRecorder:(ZeroKitHotKeyRecorder *)hotKeyRecorder didReceiveNewHotKey:(ZeroKitHotKey *)hotKey;

@end
