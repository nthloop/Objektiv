//
//  ImageUtils.m
//  Objektiv
//
//  Created by Ankit Solanki on 17/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//
// -------------------------------------------------
// This class uses a NSCache instance in order to cache icons
// of the installed browsers.
//

#import "ImageUtils.h"
#import "Constants.h"
#import <AppKit/AppKit.h>

@implementation ImageUtils
{
@private
    NSCache *cache;
}

# pragma mark initialization

+(ImageUtils*) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        cache = [[NSCache alloc] init];
    }
    return self;
}

# pragma mark static methods

+ (NSImage*) statusBarIconForAppId: (NSString*) applicationIdentifier
{
    // Use [self statusBarIconForAppId] if we want to revert to monochrome icons
    return [[self sharedInstance] menuIconForAppId:applicationIdentifier];
}

+ (NSImage*) menuIconForAppId: (NSString*) applicationIdentifier
{
    return [[self sharedInstance] menuIconForAppId:applicationIdentifier];
}

+ (NSImage*) fullSizeIconForAppId: (NSString*) applicationIdentifier
{
    NSImage *image = [[[self sharedInstance] iconForAppIdentifier:applicationIdentifier] copy];
    return image;
}

+ (NSImage*) fullSizeIconForAppId: (NSString*) applicationIdentifier withSize:(NSSize)size
{
    NSImage *image = [self fullSizeIconForAppId:applicationIdentifier];
    image.size = size;
    return image;
}

// Convert the B&W input image into the output tint
// Used to add the 'checkmark' on the selected browser's icon
+ (NSImage*) tintInputImage:(NSImage*)inputImage toColor:(NSColor*)outputColor
{
    CIColor *ciColor = [[CIColor alloc] initWithColor:outputColor];
    CIImage *ciColorImage = [CIImage imageWithColor:(CIColor*)ciColor];
    CIImage *ciInputImage = [self ciImageFromNSImate:inputImage];

    CIFilter *filter = [CIFilter filterWithName:@"CISourceInCompositing"];
    [filter setValue:ciColorImage forKey:@"inputImage"];
    [filter setValue:ciInputImage forKey:@"inputBackgroundImage"];

    CIImage *image = [filter valueForKey:@"outputImage"];
    NSImage *output = [self imageFromCIImage:image];

    return output;
}

# pragma mark instance methods

- (NSImage*) statusBarIconForAppId: (NSString*) applicationIdentifier
{
    NSString *key = [@"status:" stringByAppendingString:applicationIdentifier];
    NSImage *icon = [cache objectForKey:key];
    if (icon) return icon;
    
    icon = [ImageUtils resizeIcon:[ImageUtils destaurateIcon:
                                   [self iconForAppIdentifier:applicationIdentifier]]];
    [cache setObject:icon forKey:key];
    return icon;
}

- (NSImage*) menuIconForAppId: (NSString*) applicationIdentifier
{

    NSString *key = [@"menu:" stringByAppendingString:applicationIdentifier];
    NSImage *icon = [cache objectForKey:key];
    if (icon) return icon;

    icon = [ImageUtils resizeIcon:[self iconForAppIdentifier:applicationIdentifier]];
    [cache setObject:icon forKey:key];
    return icon;
}

# pragma mark internal utility methods

+ (NSImage*) resizeIcon: (NSImage*) icon
{
    icon = [icon copy];
    icon.scalesWhenResized = YES;
    icon.size = CGSizeMake(StatusBarIconSize, StatusBarIconSize);
    return icon;
}

- (NSImage*) iconForAppIdentifier: (NSString*) applicationIdentifier
{
    NSImage *icon = [cache objectForKey:applicationIdentifier];
    if (icon)
    {
        return icon;
    }
    
    NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:applicationIdentifier];
    icon = [[[NSWorkspace sharedWorkspace] iconForFile:path] copy];
    [cache setObject:icon forKey:applicationIdentifier];

    return icon;
}

+ (NSImage *) imageFromCIImage:(CIImage *)ciImage
{
    NSSize size = ciImage.extent.size;
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(size.width, size.height)];
    [image addRepresentation:[NSCIImageRep imageRepWithCIImage:ciImage]];
    return image;
}

+ (CIImage*) ciImageFromNSImate:(NSImage *)image
{
    NSSize size = [image size];
    [image lockFocus];
    NSRect imageRect = NSMakeRect(0, 0, size.width, size.height);
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect: imageRect];
    [image unlockFocus];
    return [[CIImage alloc] initWithBitmapImageRep:rep];
}

+ (NSImage*) destaurateIcon:(NSImage*)original
{
    NSImage *icon = [original copy];
    NSSize size = [icon size];

    [icon lockFocus];
    NSRect imageRect = NSMakeRect(0, 0, size.width, size.height);
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect: imageRect];
    [icon unlockFocus];

    CIImage *image = [[CIImage alloc] initWithBitmapImageRep:rep];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:image forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithInt:0] forKey:@"inputSaturation"];
    [filter setValue:[NSNumber numberWithInt:1] forKey:@"inputContrast"];

    return [self imageFromCIImage:[filter valueForKey:@"outputImage"]];
}


@end
