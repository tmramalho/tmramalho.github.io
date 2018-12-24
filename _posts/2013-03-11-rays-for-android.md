---
id: 69
title: Rays for android
date: 2013-03-11T19:30:17+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=69
permalink: /blog/2013/03/11/rays-for-android/
categories:
  - Development
tags:
  - android
  - code
  - games
  - nonlinear systems
---
Another platform I had a go at porting the rays app for was android.
This was probably the least enjoyable port I've done, not because of the Java language but because there is essentially no decent library to do the kinds of 2D effects the app requires.

I researched a bit on the topic and there were three ways to go about doing this:

  * <span style="line-height: 14px;">Use android's own <a href="http://developer.android.com/training/graphics/opengl/index.html">openGL</a> implementation.</span>
  * Use the NDK to write <a href="http://developer.android.com/tools/sdk/ndk/index.html" target="_blank">native code</a> which draws directly to the framebuffer.
  * Use <a href="http://libgdx.badlogicgames.com/" target="_blank">libGDX</a>.

At the time (well over a year ago, before the fancy new android developers redesign) documentation for the first two options was absolutely incomprehensible.
Even now I find using the openGL implementation in android quite confusing, although it might be my fault as I never really learned low level openGL.
I now feel tempted to use the much improved NDK and do some low level pixel manipulation, but other projects take priority...

I ended up using libGDX.
It was also poorly documented (some random wiki pages + code comments) but the API made a lot more sense to me.
This is because it was in the vein of some 2D libraries for the NDS such as the venerable PAlib and uLibrary which I used extensively previously (in hindsight, it appears they were not the best libraries in terms of code quality and the simple <a href="http://devkitpro.org/wiki/PAlib" target="_blank">libNDS</a> would have been a much better choice).
The fact that you could instantly play the game on your computer natively without needing an emulator also helped.
Though I would recommend just plugging in your android device and debugging directly there, Android's debugger is truly excellent.

The library was chosen, the code was banged out, et voila! It lives! No antialiasing, no funky glow effects but it lives!

[<img class=" wp-image-117 " alt="Rays app running on Galaxy S2" src="/images/2013/02/Screenshot_2013-02-10-22-10-25.png" width="480" height="288" srcset="/images/2013/02/Screenshot_2013-02-10-22-10-25.png 800w, /images/2013/02/Screenshot_2013-02-10-22-10-25-300x180.png 300w, /images/2013/02/Screenshot_2013-02-10-22-10-25-624x374.png 624w" sizes="(max-width: 480px) 85vw, 480px" />](/images/2013/02/Screenshot_2013-02-10-22-10-25.png) 

One idea I had to make the app more interesting would be to synthesize some musical instrument, something like a violin, where each instrument would be represented by a ray, with the intensity of the sound proportional to its speed.
I could not find any satisfactory samples though, since they all come as single notes and I'd rather have some continuous sound produced.
It might be more interesting to use some sort of synthesis algorithm to produce an interesting sound and modulate its amplitude, frequency or harmonics with the rays.
How to go about it remains a mystery  There aren't too many synthesis libraries available for android that do what I want.
[Libpd](http://libpd.cc/) seems to be a decent option, now I just need to find the time to finish this project.

Since the application has only been tested on a handful of phones, I never did toss it on the play store.
[Get it here](/projects/raysandroid/gdxRaysAndroid.apk) if you want to play with it.
You'll have to allow installation of non market apps.