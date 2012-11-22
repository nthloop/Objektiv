//
//  AppDelegate.h
//  browser-selector
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSButton *startAtLogin;
@property (assign) IBOutlet NSButton *autoHideIcon;

- (IBAction)toggleLoginItem: (id)sender;
- (IBAction)toggleHideItem: (id)sender;

@end
