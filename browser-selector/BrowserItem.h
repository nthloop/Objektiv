//
//  BrowserItem.h
//  browser-selector
//
//  Created by Ankit Solanki on 18/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrowserItem : NSObject

@property NSString *identifier;
@property NSString *name;
@property NSString *path;
@property BOOL blacklisted;
@property BOOL isDefault;

- (BrowserItem*) initWithApplicationId: (NSString*)theId name: (NSString*)theName path: (NSString*) thePath;

@end
