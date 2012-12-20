//
//  OverlayWindow.m
//  browser-selector
//
//  Created by Ankit Solanki on 17/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "OverlayWindow.h"
#import "NSWorkspace+Utils.h"
#import "ImageUtils.h"
#import "AppDelegate.h"
#import "BrowserItem.h"
#import "OverlayWindowView.h"

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
    browsers = appDelegate.browsers;

    OverlayWindowView *contentView = [[OverlayWindowView alloc] init];
    [self setContentView:contentView];
    NSSize contentSize = [contentView addBrowsers:browsers];
    [self setContentSize:contentSize];

    [self center];
    [contentView setNeedsUpdateConstraints:YES];
    [contentView setNeedsDisplay:YES];
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

    if (theEvent.keyCode >= kVK_ANSI_1 && theEvent.keyCode <= kVK_ANSI_9)
    {
        NSUInteger offset = theEvent.keyCode - kVK_ANSI_1;
        if (offset < browsers.count)
        {
            BrowserItem *item = browsers[offset];
            [appDelegate selectABrowser:item.identifier];
            [self orderOut:nil];
        }
    }
}

@end
