//
//  OverlayWindow.m
//  browser-selector
//
//  Created by Ankit Solanki on 17/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "OverlayWindow.h"
#import "ImageUtils.h"
#import "AppDelegate.h"
#import "BrowserItem.h"
#import "Browsers.h"
#import "OverlayWindowView.h"
#import <Carbon/Carbon.h>

@implementation OverlayWindow {

    @private
    AppDelegate *appDelegate;
    NSArray *browsers;
}

-(id)init
{
    NSLog(@"Initializing OverlayWindow");
    self = [super initWithContentRect:CGRectZero
                            styleMask:NSBorderlessWindowMask | NSNonactivatingPanelMask
                              backing:NSBackingStoreBuffered
                                defer:NO];

    self.delegate = self;
    if (self) {
        appDelegate = [NSApplication sharedApplication].delegate;
        [self setLevel:NSFloatingWindowLevel];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setFloatingPanel:YES];
        [self setMovable:NO];
        [self setOpaque:NO];
    }

    return self;
}

-(BOOL)canBecomeKeyWindow { return YES; }


-(void)awakeFromNib
{
}

-(void)windowDidBecomeKey:(NSNotification *)notification
{
    NSLog(@"became key");
    browsers = [Browsers validBrowsers];

    OverlayWindowView *contentView = [[OverlayWindowView alloc] init];
    [self setContentView:contentView];
    NSSize contentSize = [contentView addBrowsers:browsers];
    [self setContentSize:contentSize];

    [self center];

    self.alphaValue = 0;

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [self.animator setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

-(void)windowDidResignKey:(NSNotification *)notification
{
    browsers = nil;
    [self setContentView:nil];
    [self orderOut:nil];
    [self close];
}

-(void)keyDown:(NSEvent *)theEvent
{
    if (theEvent.keyCode == kVK_Escape)
    {
        [self orderOut:nil];
        [self close];
    }
    else
    {
        [super keyDown:theEvent];
    }
}

@end
