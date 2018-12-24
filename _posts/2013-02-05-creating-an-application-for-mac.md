---
id: 106
title: Creating an application for mac
date: 2013-02-05T12:40:57+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=106
permalink: /blog/2013/02/05/creating-an-application-for-mac/
categories:
  - Development
tags:
  - code
  - mac
---
I developed my cell segmentation project <a href="https://github.com/tmramalho/bigCellBrother" target="_blank">bigcellbrother</a> on linux but it seems all the experimental collaborators use macs.
So now that I have something which kind of half works I decided it was time to compile the application for the mac and create a distributable bundle.
I used the lovely <a href="http://www.macports.org/" target="_blank">macports</a> to install all the dependencies I used to create the project (essentially openCV and its dependencies).

The first step was to compile the core part of the application to a shared library, as I'd done on linux.
This is easier said than done.
Supposedly you only need to add a -dynamiclib flag to the compilation command, but since I am compiling on Snow Leopard there are compiler/architecture issues cropping up at seemingly every step.
Apple doesn't want you to develop with C++, this much is clear. Then I compiled the QT <a href="https://github.com/tmramalho/bigCellBrotherGUI" target="_blank">GUI part</a> of the application with qt creator and automagically it created an application bundle with my app.
That was the easy bit.

Of course, all the shared libraries the app requires are scattered everywhere throughout the drive.
If only I could put them all in the application bundle.
<a href="http://doc.qt.digia.com/qq/qq09-mac-deployment.html" target="_blank">This tutorial</a> was helpful, essentially the idea is to toss all dependencies into a Frameworks folder inside the app bundle.
You can use **otool -L** to check which libraries are being called and then **install_name_tool** to change the paths of the libraries.
Of course the shared libraries themselves have dependencies.
So this would be a few hours' worth of trouble if not for <a href="http://macdylibbundler.sourceforge.net/" target="_blank">macdylbbundler</a> which does this stuff automatically.
yay! To bundle the Qt frameworks there's another program called _macdeployqt_ which takes care of everything and comes with Qt.

**Update**: some libraries don't have enough space to change the dependencies' path and dylibbundler fails to compile.
If you run across this, you'll need to apply a [patch](https://trac.macports.org/ticket/29838) to macports and reinstall the affected libraries compiling from source: _sudo port -v -s install libawesome_.