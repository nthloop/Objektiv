//
//  BrowserItem.m
//  browser-selector
//
//  Created by Ankit Solanki on 18/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "BrowserItem.h"

@implementation BrowserItem

- (BrowserItem*) initWithApplicationId: (NSString*)theId name: (NSString*)theName path: (NSString*) thePath
{
    self = [super init];
    if (self) {
        self.identifier = theId;
        self.name = theName;
        self.path = thePath;
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<BrowserItem id:%@ name:%@ blacklisted:%@>",
            self.identifier, self.name,
            self.blacklisted ? @"YES" : @"NO"];
}

@end
