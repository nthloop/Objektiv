//
//  AppDelegate.h
//  browser-selector
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PrefsController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

-(void) hotkeyTriggered;
- (BOOL) isBlacklisted:(NSString*) browserIdentifier;

@property PrefsController* prefsController;

@end
