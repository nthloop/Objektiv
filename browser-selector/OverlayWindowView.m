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

const NSUInteger ICON_SIZE = 72;
const NSUInteger TEXT_HEIGHT = 24;
const NSUInteger H_PADDING = 16;
const NSUInteger BOX_PADDING = 16;

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

// Draws the semi-transparent background for the overlay panel
- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:16 yRadius:16];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.7] set];
    [path fill];
}

- (void) buttonClicked:sender
{
    NSButton *button = sender;

    [self.window orderOut:nil];
    [self.window close];

    [appDelegate selectABrowser: button.cell];
}

// Adds buttons for browser icons in a 9-column wide grid.
// The first 9 will have hotkeys associated with them (numbers 1-9).
- (NSSize)addBrowsers:(NSArray*)browsers
{
    browsers = [browsers filteredArrayUsingPredicate:
                [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    BrowserItem *item = evaluatedObject;
                    return !item.blacklisted;
                }]];

    NSRect itemRect = NSMakeRect(BOX_PADDING, BOX_PADDING, ICON_SIZE + H_PADDING, ICON_SIZE + TEXT_HEIGHT);
    NSRect buttonRect = CGRectInset(itemRect, H_PADDING / 2, 0);
    NSUInteger width = itemRect.size.width, height = itemRect.size.height;

    NSUInteger maxRow = browsers.count / 9, maxColumn = browsers.count > 9 ? 9 : browsers.count;
    NSUInteger row = maxRow, column = 0;

    for (int i = 0; i < browsers.count; i++) {
        BrowserItem *browser = browsers[i];

        NSRect offset = CGRectOffset(buttonRect, width * column, height * row);

        NSButton *button = [self buttonForBrowser:browser
                                       atPosition:i
                                        withFrame:offset];
        [self addSubview:button];

        column++;
        if (column >= 9 && row > 0) {
            row--;
            column = 0;
        }
    }

    NSSize size = NSMakeSize(width * maxColumn + BOX_PADDING * 2, height * (maxRow + 1) + BOX_PADDING * 2);
    return size;
}

-(NSButton*)buttonForBrowser:(BrowserItem*)browser atPosition:(NSUInteger)position withFrame:(NSRect)frame
{
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    
    button.image = [self imageForBrowser:browser withBadge:position + 1];
    button.attributedTitle = [self titleForButton:browser.name inColor:[NSColor whiteColor]];
    button.target = self;
    button.focusRingType = NSFocusRingTypeNone;
    button.action = @selector(buttonClicked:);

    NSButtonCell *cell = button.cell;
    cell.imagePosition = NSImageAbove;

    [cell setBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.7]];
    [cell setBezeled:NO];
    [cell setBordered:NO];
    [cell setButtonType:NSMomentaryPushInButton];
    [cell setShowsStateBy:NSPushInCellMask];
    [cell setHighlightsBy:NSContentsCellMask];
    [cell setRepresentedObject:browser.identifier];

    return button;
}

-(NSImage*) imageForBrowser:(BrowserItem*)browser withBadge:(NSUInteger)position
{

    NSImage *image = [[ImageUtils fullSizeIconForAppId:browser.identifier
                                             withSize:NSMakeSize(ICON_SIZE, ICON_SIZE)] copy];
    if (position > 9) return image;

    NSString *badge = [NSString stringWithFormat:@"%ld", position];

    [image lockFocus];


    NSRect rect = NSMakeRect(0, 0, 20, 20);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:4 yRadius:4];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.75] set];
    [path fill];

    [badge drawInRect:CGRectInset(rect, 7, 2)
       withAttributes:@{NSForegroundColorAttributeName : [NSColor whiteColor]}];

    [image unlockFocus];
    return image;
}


-(NSAttributedString*) titleForButton:(NSString*) plainTitle inColor:(NSColor*) color
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle];

    NSRange range = NSMakeRange(0, title.length);
    [title addAttribute:NSForegroundColorAttributeName
                  value:color
                  range:range];
    [title addAttribute:NSFontAttributeName
                  value:[NSFont labelFontOfSize:[NSFont labelFontSize] + 2]
                  range:range];
    [title setAlignment:NSCenterTextAlignment range:range];
    [title fixAttributesInRange:range];

    return [self truncateString:title toWidth:ICON_SIZE];
}

- (NSAttributedString *)truncateString:(NSAttributedString*)attributedString toWidth:(NSUInteger)width
{
	NSAttributedString *result = attributedString;
	if (result.size.width > width)
	{
		NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:result];
		while ([newString size].width > width)
		{
			NSRange range = NSMakeRange(newString.length - 2, 2);
			[newString replaceCharactersInRange:range withString:@"…"];
		}
		result = newString;
	}
	return result;
}

@end
