//
//  ImageUtils.m
//  browser-selector
//
//  Created by Ankit Solanki on 17/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//
// -------------------------------------------------
// This class uses a NSCache instance in order to cache icons
// of the installed browsers.
//

#import "ImageUtils.h"

@implementation ImageUtils
{
@private
    NSCache *cache;
}


static ImageUtils *_sharedInstance = nil;

# pragma mark initialization

+(ImageUtils*) sharedInstance
{
    if (!_sharedInstance)
    {
        _sharedInstance = [[ImageUtils alloc] init];
    }
    return _sharedInstance;
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
    return [[ImageUtils sharedInstance] statusBarIconForAppId:applicationIdentifier];
}

+ (NSImage*) menuIconForAppId: (NSString*) applicationIdentifier
{
    return [[ImageUtils sharedInstance] menuIconForAppId:applicationIdentifier];
}

+ (NSImage*) fullSizeIconForAppId: (NSString*) applicationIdentifier
{
    return [[ImageUtils sharedInstance] iconForAppIdentifier:applicationIdentifier];
}

# pragma mark instance methods

- (NSImage*) statusBarIconForAppId: (NSString*) applicationIdentifier
{
    NSString *key = [@"status:" stringByAppendingString:applicationIdentifier];
    NSImage *icon = [cache objectForKey:key];
    if (icon) return icon;
    
    icon = [self resizeIcon:[self destaurateIcon:[self iconForAppIdentifier:applicationIdentifier]]];
    [cache setObject:icon forKey:key];
    return icon;
}

- (NSImage*) menuIconForAppId: (NSString*) applicationIdentifier
{

    NSString *key = [@"menu:" stringByAppendingString:applicationIdentifier];
    NSImage *icon = [cache objectForKey:key];
    if (icon) return icon;

    icon = [self resizeIcon:[self iconForAppIdentifier:applicationIdentifier]];
    [cache setObject:icon forKey:key];
    return icon;
}

# pragma mark internal utility methods

- (NSImage*) resizeIcon: (NSImage*) icon
{
    icon = [icon copy];
    icon.scalesWhenResized = YES;
    icon.size = CGSizeMake(16, 16);
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

-(NSImage *) imageFromCIImage:(CIImage *)ciImage
{
    NSSize size = ciImage.extent.size;
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(size.width, size.height)];
    [image addRepresentation:[NSCIImageRep imageRepWithCIImage:ciImage]];
    return image;
}

- (NSImage*) destaurateIcon:(NSImage*)original
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
