//
//  BrowserItem.m
//  Objektiv
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
    return [NSString stringWithFormat:@"<BrowserItem id:%@ name:%@ hidden:%@>",
            self.identifier, self.name,
            self.hidden ? @"YES" : @"NO"];
}

@end
