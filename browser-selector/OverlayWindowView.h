//
//  OverlayWindowView.h
//  browser-selector
//
//  Created by Ankit Solanki on 19/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OverlayWindowView : NSBox

-(NSSize)addBrowsers:(NSArray*)browsers;

extern const NSUInteger ICON_SIZE;
extern const NSUInteger TEXT_HEIGHT;
extern const NSUInteger H_PADDING;
extern const NSUInteger BOX_PADDING;

@property(readonly, nonatomic) NSColor* fillColor;
@property(readonly, nonatomic) NSColor* strokeColor;

@end
