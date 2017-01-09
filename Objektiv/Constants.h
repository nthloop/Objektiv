//
//  Constants.h
//  Objektiv
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#include <Foundation/Foundation.h>

#define AppName @"Objektiv"
#define AppDescription @"Objektiv is a simple menu-bar app that allows you to quickly toggle your default browser";

#define PrefStartAtLogin @"BrowserSelectorStartAtLogin"
#define PrefAutoHideIcon @"BrowserSelectorAutoHideIcon"
#define PrefShowNotifications @"ShowNotifications"

#define PrefSelectedBrowser @"BrowserSelected"

#define PrefHotkey @"BrowserSelectorHotkey"

#define PrefBlacklist @"BrowserSelectorBlacklist"

#define NotificationTitle NSLocalizedString(@"%@ selected", @"Title of the notification")
#define NotificationText NSLocalizedString(@"You selected %@ as your default browser using %@.", @"Notification text")

#define StatusBarIconSize 16

// Via https://gist.github.com/1057420
// a nice macro to define singletons properly
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \
