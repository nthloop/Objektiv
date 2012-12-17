#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)

+ (NSString *)stringByGeneratingUUID;

#pragma mark -

- (BOOL)contains: (NSString *)string;

@end
