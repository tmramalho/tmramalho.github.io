---
layout: page
title: Projects
permalink: /projects/
---

## Rays
Rays is a visual generative art application. The user can draw beautiful patterns by guiding the small particles attached to the cursor with springs. I have used it as a toy model to test new frameworks or programming languages. Enjoy!

<a href="/images/2014/08/rays.png"><img class="aligncenter size-full wp-image-850" src="/images/2014/08/rays.png" alt="rays" width="897" height="584" srcset="/images/2014/08/rays.png 897w, /images/2014/08/rays-300x195.png 300w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 1362px) 62vw, 840px" /></a>

<span class="projectDate" style="color: #6f6f6f;">Jul 2008</span>

#### Links

* [Rays in processing]({% post_url 2013-02-03-porting-the-rays-app-to-processing-js %})
* [Processing](assets/projects/raysprocessing/)
* [Android]({% post_url 2013-03-11-rays-for-android %})
* [APK](assets/projects/raysandroid/gdxRaysAndroid.apk)
* [Nintendo DS](assets/projects/raysnds/rays.nds)

## Nematic

This was a monte carlo simulation of a nematic fluid in 3d I did while I was in my bachelor. It was my first contact with statistical physics, which I ended up pursuing. It was also my first time doing serious scientific C, which was a lot of fun.

<a href="/images/2014/08/rods3d.png"><img class="aligncenter size-large wp-image-852" src="/images/2014/08/rods3d-1024x686.png" alt="rods3d" width="604" height="404" srcset="/images/2014/08/rods3d-1024x686.png 1024w, /images/2014/08/rods3d-300x201.png 300w, /images/2014/08/rods3d.png 1200w" sizes="(max-width: 604px) 85vw, 604px" /></a>


<span class="projectDate" style="color: #6f6f6f;">Apr 2009</span>

#### Links

* [Code on github](https://github.com/tmramalho/rods)

## Minesweeper

We decided to create a simple game to test homebrew development for the nintendo DS. You needed to use some libraries built by the community and because homebrew is not exactly sanctioned by Nintendo the ARM toolchain worked in mysterious ways, the compilation process seemed to be some mix between black magic and art. That led to extreme excitement when you actually got something to move on the screen!

Minesweeper was a fun project and it is probably still the application I use the most on my nintendo DS in spite of the great commercial games I have. The combination of touchscreen + buttons lets you, well, sweep the minefield really quickly and you really are only limited by your brain.

<a href="/images/2014/08/mines.png"><img class="aligncenter size-large wp-image-845" src="/images/2014/08/mines-682x1024.png" alt="mines" width="604" height="906" srcset="/images/2014/08/mines-682x1024.png 682w, /images/2014/08/mines-200x300.png 200w, /images/2014/08/mines.png 1024w" sizes="(max-width: 604px) 85vw, 604px" /></a>

With: <a style="color: #2980b9;" href="https://twitter.com/miguelndmiranda">Miguel Miranda</a>

<span class="projectDate" style="color: #6f6f6f;">Jul 2007</span>

#### Links

* [Nintendo DS](https://github.com/tmramalho/ndsMines/blob/master/mines.nds)

## Fluids
This java project was a lot of fun and required me to learn a lot about a field I was not very familiar with: computational fluid dynamics. Even though realtime CFD is a quite different beast from research level algorithms, the basics are essentially the same. This code is based on Jos Stam&#8217;s stable fluids with an attempt to add compressible fluid flow (to have explosions and such). Controls are documented in the source.

[<img class="aligncenter size-full wp-image-843" src="/images/2014/08/fluids.png" alt="fluids" width="500" height="500" srcset="/images/2014/08/fluids.png 500w, /images/2014/08/fluids-150x150.png 150w, /images/2014/08/fluids-300x300.png 300w" sizes="(max-width: 500px) 85vw, 500px" />](/images/2014/08/fluids.png)

<span class="projectDate" style="color: #6f6f6f;">Aug 2011</span>

#### Links

* [Fluid code](https://github.com/tmramalho/FluidProc)

## Falling Sand

Falling sand games have always fascinated me. They&#8217;re kind of a sandbox game (no pun intended), kind of a physics simulation. From a rigorous point of view they&#8217;re actually just cellular automaton simulations. But these are really complicated cellular automata.
I tried to create my own version, basing the rules off of <a style="color: #2980b9;" href="https://github.com/nornagon/World-of-Sand-DS">worldofsandDS</a> and letting the sand particles be influenced by wind (simulated via stam&#8217;s stable fluids)

[<img class="aligncenter size-large wp-image-854" src="/images/2014/08/sand-838x1024.png" alt="sand" width="604" height="738" srcset="/images/2014/08/sand-838x1024.png 838w, /images/2014/08/sand-245x300.png 245w, /images/2014/08/sand.png 900w" sizes="(max-width: 604px) 85vw, 604px" />](/images/2014/08/sand.png)

<span class="projectDate" style="color: #6f6f6f;">Nov 2011</span>

#### Links

* [Java code on github](https://github.com/tmramalho/sandbox)

## Cell Tracking
This software is used to open microscopy timelapse images of bacteria and identify each one automatically. This is useful for experiments which try to understand how bacteria react to different environments and how they process information. Its code name is BigCellBrother for the time being, you can probably guess why.

The GUI is developed with <a style="color: #2980b9;" href="http://qt-project.org/" target="_blank">QT</a> and the backend computer vision algorithms are from <a style="color: #2980b9;" href="http://opencv.org/" target="_blank">opencv</a>. There is also a support vector machine implementation for cell classification using <a style="color: #2980b9;" href="http://www.csie.ntu.edu.tw/~cjlin/libsvm/" target="_blank">libsvm</a>.<figure id="attachment_841" style="width: 604px" class="wp-caption aligncenter">

[<img class="size-large wp-image-841" src="/images/2014/08/bcb-1024x671.png" alt="Screenshot of segmentation process" width="604" height="395" srcset="/images/2014/08/bcb-1024x671.png 1024w, /images/2014/08/bcb-300x196.png 300w, /images/2014/08/bcb.png 1332w" sizes="(max-width: 604px) 85vw, 604px" />](/images/2014/08/bcb.png)

_Screenshot of segmentation process_

<span class="projectDate" style="color: #6f6f6f;">Jan 2013</span>

#### Links

* [Project page](http://tmramalho.github.io/bigCellBrotherGUI/)
* [Github](https://github.com/tmramalho/bigCellBrotherGUI)
* [Blog]({% post_url 2013-11-05-automatic-segmentation-of-microscopy-images %})
