#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class ZeroKitPreferencePaneManager;

@interface ZeroKitPreferencesWindowController : NSWindowController<NSToolbarDelegate> {
    ZeroKitPreferencePaneManager *myPreferencePaneManager;
    NSToolbar *myToolbar;
    NSMutableDictionary *myToolbarItems;
}

+ (ZeroKitPreferencesWindowController *)sharedController;

#pragma mark -

- (void)showPreferencesWindow: (id)sender;

- (void)hidePreferencesWindow: (id)sender;

#pragma mark -

- (void)togglePreferencesWindow: (id)sender;

#pragma mark -

- (void)loadPreferencePanes;

#pragma mark -

- (NSArray *)loadedPreferencePanes;

@end
