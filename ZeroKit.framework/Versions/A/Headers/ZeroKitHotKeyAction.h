#import <Foundation/Foundation.h>

@interface ZeroKitHotKeyAction : NSObject {
    id myTarget;
    SEL mySelector;
}

- (id)initWithTarget: (id)target selector: (SEL)selector;

#pragma mark -

+ (ZeroKitHotKeyAction *)hotKeyActionFromTarget: (id)target selector: (SEL)selector;

#pragma mark -

- (void)trigger;

@end
