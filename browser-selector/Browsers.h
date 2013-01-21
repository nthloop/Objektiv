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

- (BOOL) isBlacklisted:(NSString*) browserIdentifier;
- (void) blacklistABrowser:sender;
- (void) removeFromBlacklist:sender;

- (void) findBrowsersAsync;
- (void) findBrowsers;

@end
