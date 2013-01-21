Objektiv
========================================

Objektiv is a small utility for your Mac that allows you to quickly
switch your default browser. It's mainly designed to help webdevs who
need to run a lot of different browsers while testing.

We built Objektiv to scratch an itch we at [nth loop][] were facing, and
to also learn all about Mac App development. It was built over the
course of a few months, on-and-off whenever we had time. It's
ridiculously over-engineered for such a simple utility; here are some of
the features at a glance:

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

  - [ZeroKit][] by eczarny (MIT Licensed, portions of source used)
  - [MASShortcut][] by Vadim Shpakovski (BSD Licensed)
  - [CDEvents][] by Aron Cedercrantz (MIT Licensed)
  - [NSWorkspace+Utils][1] from Mozilla's Camino project (MPL)

Copyright & About
----------------------------------------

Copyright 2012, [nth loop][]. Objektiv is available under the
MIT License.

  [nth loop]:    http://nthloop.com
  [CocoaPods]:   http://cocoapods.org/
  [ZeroKit]:     https://github.com/eczarny/zerokit
  [MASShortcut]: https://github.com/shpakovski/MASShortcut
  [CDEvents]:    http://aron.cedercrantz.com/CDEvents/
  [1]:           http://hg.mozilla.org/camino/file/6d654a6d1cf4/src/extensions/NSWorkspace%2BUtils.h
