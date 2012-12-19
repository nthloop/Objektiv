//
//  OverlayWindowView.m
//  browser-selector
//
//  Created by Ankit Solanki on 19/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "OverlayWindowView.h"
#import "BrowserItem.h"
#import "AppDelegate.h"
#import "ImageUtils.h"

@implementation OverlayWindowView {
    AppDelegate *appDelegate;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [[NSApplication sharedApplication] delegate];
        self.title = @"";
        [self setBorderType:NSNoBorder];
        [self setContentViewMargins:NSMakeSize(0, 0)];
        [self setBoxType:NSBoxCustom];
        [self setBorderColor:[NSColor clearColor]];
        [self setFillColor:[NSColor clearColor]];
        [self setAutoresizesSubviews:NO];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"Size: %f %f, Position: %f %f", dirtyRect.size.width, dirtyRect.size.height, dirtyRect.origin.x, dirtyRect.origin.y);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:10.0 yRadius:10.0];
    [[NSColor blackColor] set];
    [path fill];
}

- (void) buttonClicked:sender
{
    NSButton *button = sender;

    [self.window orderOut:nil];
    [self.window close];

    [appDelegate selectABrowser: button.cell];
}

- (NSSize)addBrowsers:(NSArray*)browsers
{
    int count = 0;

    NSRect iconRect = NSMakeRect(0, 36, 128, 128);
    NSRect textRect = NSMakeRect(0,  0, 128,  36);

    for (int i = 0; i < browsers.count; i++) {
        BrowserItem *browser = browsers[i];

        if (browser.blacklisted) { continue; }

        NSButton *button = [self buttonForBrowser:browser withFrame:CGRectOffset(iconRect, count * 128, 0)];
        [self addSubview:button];

        NSTextView *textView = [self textViewForBrowser:browser withFrame:CGRectOffset(textRect, count * 128, 0)];
        [self addSubview:textView];

        count++;
    }

    NSSize size = NSMakeSize(128 * count + 6, 128 + 42);
    return size;
}

-(NSButton*)buttonForBrowser:(BrowserItem*)browser withFrame:(NSRect)frame
{
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    button.image = [ImageUtils fullSizeIconForAppId:browser.identifier];

    button.target = self;
    button.action = @selector(buttonClicked:);

    NSButtonCell *cell = button.cell;
    [cell setBezeled:NO];
    [cell setBordered:NO];
    [cell setRepresentedObject:browser.identifier];

    return button;
}


-(NSTextView*)textViewForBrowser:(BrowserItem*)browser withFrame:(NSRect)frame
{
    NSTextView *textView = [[NSTextView alloc] initWithFrame:frame];

    [textView changeColor:[NSColor whiteColor]];
    [textView setDrawsBackground:NO];
    [textView setFont:[NSFont labelFontOfSize:[NSFont labelFontSize] + 4]];
    [textView setAlignment:NSCenterTextAlignment];
    [textView setSelectable:NO];
    [textView setEditable:NO];

    [textView setString:browser.name];
    return textView;
}

@end
