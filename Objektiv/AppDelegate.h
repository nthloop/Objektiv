//
//  AppDelegate.h
//  Objektiv
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PrefsController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

- (void) hotkeyTriggered;
- (void) selectABrowser:sender;
- (void) updateStatusBarIcon;

@property PrefsController* prefsController;

@end
