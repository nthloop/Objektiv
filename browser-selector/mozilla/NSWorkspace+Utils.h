/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import <AppKit/AppKit.h>

@interface NSWorkspace(CaminoDefaultBrowserAdditions)

- (NSArray*)installedBrowserIdentifiers;    // sort order not specified
- (NSString*)defaultBrowserIdentifier;
- (NSURL*)defaultBrowserURL;

- (NSArray*)installedFeedViewerIdentifiers;
- (NSString*)defaultFeedViewerIdentifier;
- (NSURL*)defaultFeedViewerURL;

- (void)setDefaultBrowserWithIdentifier:(NSString*)bundleID;
- (void)setDefaultFeedViewerWithIdentifier:(NSString*)bundleID;

- (NSURL*)urlOfApplicationWithIdentifier:(NSString*)bundleID;
- (NSString*)identifierForBundle:(NSURL*)inBundleURL;
- (NSString*)displayNameForFile:(NSURL*)inFileURL;

// OS feature checks
+ (NSString*)osVersionString;
+ (BOOL)isLeopardOrHigher;
+ (BOOL)isLionOrHigher;

@end
