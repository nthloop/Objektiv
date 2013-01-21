/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "NSWorkspace+Utils.h"

@implementation NSWorkspace(CaminoDefaultBrowserAdditions)

- (NSArray*)installedBrowserIdentifiers
{
  NSArray* apps = [(NSArray*)LSCopyAllHandlersForURLScheme(CFSTR("https")) autorelease];

  // add the default if it isn't there
  NSString* defaultHandler = [self defaultBrowserIdentifier];
  if (defaultHandler && ([apps indexOfObject:defaultHandler] == NSNotFound))
    apps = [apps arrayByAddingObject:defaultHandler];

  return apps;
}

- (NSArray*)installedFeedViewerIdentifiers
{
  NSArray* apps = [(NSArray*)LSCopyAllHandlersForURLScheme(CFSTR("feed")) autorelease];

  // add the default if it isn't there
  NSString* defaultHandler = [self defaultFeedViewerIdentifier];
  if (defaultHandler && ([apps indexOfObject:defaultHandler] == NSNotFound))
    apps = [apps arrayByAddingObject:defaultHandler];

  return apps;
}

- (NSString*)defaultBrowserIdentifier
{
  NSString* defaultBundleId = [(NSString*)LSCopyDefaultHandlerForURLScheme(CFSTR("http")) autorelease];
  // Sometimes LaunchServices likes to pretend there's no default browser.
  // If that happens, we'll assume it's probably Safari.
  if (!defaultBundleId)
    defaultBundleId = @"com.apple.safari";
  return defaultBundleId;
}

- (NSString*)defaultFeedViewerIdentifier
{
  return [(NSString*)LSCopyDefaultHandlerForURLScheme(CFSTR("feed")) autorelease];
}

- (NSURL*)defaultBrowserURL
{
  NSString* defaultBundleId = [self defaultBrowserIdentifier];
  if (defaultBundleId)
    return [self urlOfApplicationWithIdentifier:defaultBundleId];
  return nil;
}

- (NSURL*)defaultFeedViewerURL
{
  NSString* defaultBundleId = [self defaultFeedViewerIdentifier];
  if (defaultBundleId)
    return [self urlOfApplicationWithIdentifier:defaultBundleId];
  return nil;
}

- (void)setDefaultBrowserWithIdentifier:(NSString*)bundleID
{
  LSSetDefaultHandlerForURLScheme(CFSTR("http"), (CFStringRef)bundleID);
  LSSetDefaultHandlerForURLScheme(CFSTR("https"), (CFStringRef)bundleID);
  LSSetDefaultRoleHandlerForContentType(kUTTypeHTML, kLSRolesViewer, (CFStringRef)bundleID);
  LSSetDefaultRoleHandlerForContentType(kUTTypeURL, kLSRolesViewer, (CFStringRef)bundleID);
}

- (void)setDefaultFeedViewerWithIdentifier:(NSString*)bundleID
{
  LSSetDefaultHandlerForURLScheme(CFSTR("feed"), (CFStringRef)bundleID);
}

- (NSURL*)urlOfApplicationWithIdentifier:(NSString*)bundleID
{
  if (!bundleID)
    return nil;
  NSURL* appURL = nil;
  if (LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)bundleID, NULL, NULL, (CFURLRef*)&appURL) == noErr)
    return [appURL autorelease];

  return nil;
}

- (NSString*)identifierForBundle:(NSURL*)inBundleURL
{
  if (!inBundleURL) return nil;

  NSBundle* tmpBundle = [NSBundle bundleWithPath:[[inBundleURL path] stringByStandardizingPath]];
  if (tmpBundle)
  {
    NSString* tmpBundleID = [tmpBundle bundleIdentifier];
    if (tmpBundleID && ([tmpBundleID length] > 0)) {
      return tmpBundleID;
    }
  }
  return nil;
}

- (NSString*)displayNameForFile:(NSURL*)inFileURL
{
  NSString *name;
  LSCopyDisplayNameForURL((CFURLRef)inFileURL, (CFStringRef *)&name);
  return [name autorelease];
}

//
// +osVersionString
//
// Returns the system version string from
// /System/Library/CoreServices/SystemVersion.plist
// (as recommended by Apple).
//
+ (NSString*)osVersionString
{
  NSDictionary* versionInfo = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
  return [versionInfo objectForKey:@"ProductVersion"];
}

//
// +systemVersion
//
// Returns the host's OS version as returned by the 'sysv' gestalt selector,
// 10.x.y = 0x000010xy
//
+ (long)systemVersion
{
  static long sSystemVersion = 0;
  if (!sSystemVersion)
    Gestalt(gestaltSystemVersion, &sSystemVersion);
  return sSystemVersion;
}

//
// +isLeopardOrHigher
//
// returns YES if we're on 10.5 or better
//
+ (BOOL)isLeopardOrHigher
{
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4
  return YES;
#else
  return [self systemVersion] >= 0x1050;
#endif
}

//
// +isLionOrHigher
//
// returns YES if we're on 10.7 or better
//
+ (BOOL)isLionOrHigher
{
  return [self systemVersion] >= 0x1070;
}

@end
