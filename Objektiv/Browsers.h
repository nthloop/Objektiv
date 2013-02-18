//
//  Browsers.h
//  Objektiv
//
//  Created by Ankit Solanki on 19/01/13.
//  Copyright (c) 2013 nth loop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrowserItem.h"

@interface Browsers : NSObject

+ (Browsers*)sharedInstance;
+ (NSArray*) browsers;
+ (NSArray*) validBrowsers;

@property(readonly) NSArray* browsers;
@property(readonly) NSArray* validBrowsers;
@property NSString* defaultBrowserIdentifier;

- (BOOL) isHidden:(NSString*) browserIdentifier;
- (void) hideABrowser:sender;
- (void) unhideABrowser:sender;

- (void) findBrowsersAsync;
- (void) findBrowsers;

@end
