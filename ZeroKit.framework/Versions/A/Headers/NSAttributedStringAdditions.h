#import <Foundation/Foundation.h>

@interface NSAttributedString (NSAttributedStringAdditions)

+ (id)linkFromString: (NSString *)string withURL: (NSURL *)url font: (NSFont *)font;

@end
