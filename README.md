Objektiv
========================================

<span style="float: left">![Objektiv Logo][logo]</span> Objektiv is a
utility that lets you switch your default browser easily. You might find
it useful if you're a web designer or use multiple browsers in your
workflow.

**[Download Objektiv now][download]!**

Features
----------------------------------------

 - A status-bar icon for quick access
 - An optional global hotkey triggers an overlay window for even quicker
   switching
 - Pressing ALT (⌥) in the status menu lets you blacklist browsers that
   are incorrectly detected

![Screenshot of the Objektiv overlay window](https://raw.github.com/nthloop/Objektiv/master/Objektiv/en.lproj/objektiv-overlay.png)

Building & Running
----------------------------------------

Objektiv requires [CocoaPods][] in order to be built.

After cloning this repository, run:

    $ pod install

in order to grab dependencies. Also, make sure that you open
`Objektiv.xcworkspace`, not `Objektiv.xcodeproj`.

Copyright & About
----------------------------------------

We built Objektiv to scratch an itch we at [nth loop][] were facing, and
to also learn all about developing Mac Apps. It's ridiculously
over-engineered for such a simple utility.

Copyright 2012, [nth loop][]. Objektiv is available under the MIT
License.

Credits
----------------------------------------

  - [ZeroKit][] by eczarny (MIT Licensed, portions of source used)
  - [MASShortcut][] by Vadim Shpakovski (BSD Licensed)
  - [CDEvents][] by Aron Cedercrantz (MIT Licensed)
  - [NSWorkspace+Utils][1] from Mozilla's Camino project (MPL)

  [logo]:        https://raw.github.com/nthloop/Objektiv/master/Objektiv/Objektiv.iconset/icon_128x128.png
  [download]:    http://nthloop.com/objektiv/objektiv-latest.zip
  [nth loop]:    http://nthloop.com
  [CocoaPods]:   http://cocoapods.org/
  [ZeroKit]:     https://github.com/eczarny/zerokit
  [MASShortcut]: https://github.com/shpakovski/MASShortcut
  [CDEvents]:    http://aron.cedercrantz.com/CDEvents/
  [1]:           http://hg.mozilla.org/camino/file/6d654a6d1cf4/src/extensions/NSWorkspace%2BUtils.h
