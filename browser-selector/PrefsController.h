//
//  PrefsController.h
//  browser-selector
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefsController : NSWindowController

-(void) showPreferences;

@property (assign) IBOutlet NSButton *startAtLogin;
@property (assign) IBOutlet NSButton *autoHideIcon;

- (IBAction)toggleLoginItem: (id)sender;
- (IBAction)toggleHideItem: (id)sender;


@end
