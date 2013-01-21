Objektiv
========================================

Objektiv is a small utility for your Mac that allows you to quickly
switch your default browser. It's mainly designed to help webdevs who
need to run a lot of different browsers while testing.

We built Objektiv to scratch an itch we were facing, and to also learn
all about Mac App development. It's ridiculously over-engineered for
such a simple utility; here are some of the features at a glance:

 - A status-bar icon to quickly toggle your default browser
 - An optional global hotkey that will trigger an overlay window
 - Alternate items (⌥) in the status icon menu will let you blacklist
   browsers that are incorrectly detected.
 - And many other details!

Building & Running
----------------------------------------

Objektiv requires [CocoaPods][] in order to be built.

After cloning this repository, run:

    $ pod install

in order to grab dependencies. Also, make sure that you open
`Objektiv.xcworkspace`, not `Objektiv.xcodeproj`.

Credits
----------------------------------------

  a. ZeroKit by eczarny (MIT Licensed)
  b. MASShortcut by Vadim Shpakovski
  c. NSWorkspace+Utils from Mozilla's Camino project (Mozilla Public
      License)

Copyright & About
----------------------------------------

Copyright 2012, [nth loop][]. Objektiv is available under the
MIT License.

  [nth loop]: http://nthloop.com
  [CocoaPods]: http://cocoapods.org/
