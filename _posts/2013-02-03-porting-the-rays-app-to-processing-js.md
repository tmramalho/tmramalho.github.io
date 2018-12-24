---
id: 88
title: Porting the rays app to processing.js
date: 2013-02-03T19:40:29+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=88
permalink: /blog/2013/02/03/porting-the-rays-app-to-processing-js/
categories:
  - Development
tags:
  - code
---
Over the past few years I have been on a quest to port my old flash web toys to an open platform.
Javascript in conjunction with the HTML canvas element seemed to provide a good alternative.
So I tried to port one of my favorite toys, the rays app, to <a href="http://processingjs.org/" target="_blank">processing.js</a>. <a href="/projects/raysprocessing/" target="_blank">This is the result</a>.

I have mixed feelings about the experience.
On the one hand, it was extremely easy to develop for, as it would be expected from javascript + processing.
Since I had already implemented rays as a java applet with the original processing library, porting to javascript was mainly just changing static to dynamic typing and adjusting some function calls.
I did not manage to get keyboard shortcuts to work, even though they work perfectly in the java version.
This might be some quirk in javascript I am not aware of.

The major issue is, as I was afraid, not enough performance to implement a ‘glow effect’ as I did in <a href="http://www.nehalemlabs.net/labs/images/portfolio/wave.swf" target="_blank">flash</a> (press tab to access the options).
The idea in flash was to only draw the ‘dirty’ part of the image to an offscreen buffer, then draw it to the main framebuffer, then blur the offscreen buffer and blend it again into the main framebuffer.
Then clear the offscreen buffer and start again.
Perhaps it is easier to illustrate this with the corresponding actionscript.

```as
private function drawLines():void {
	myCanvas.graphics.lineStyle(0.1,rayA.color,rayA.alphaMult);
	myCanvas.graphics.moveTo(rayA.oldx,rayA.oldy);
	myCanvas.graphics.curveTo(rayA.x-t*rayA.vx,rayA.y-t*rayA.vy,rayA.x,rayA.y);
}

private function drawToScreen() {
	myBitmapData.draw(myCanvas,null,null,blendModeStr,null);
	if(glowPass) {
		myCanvas.filters = [blur];
		myBitmapData.draw(myCanvas,null,null,blurStr,null);
		myCanvas.filters = [];
	}
	myCanvas.graphics.clear();
}
```

Here the drawLines() function draws directly to the offscreen buffer, while drawToScreen() handles copying the buffer twice to the screen.
(This code was written almost 5 years ago, makes me feel old). In processing.js the only option which runs at a fast enough speed is a simple direct draw to the main framebuffer.
I reproduce here the main loop for the curious.

```js
for(var i = 0; i&lt; curP; i++) {
	//setup
	var xpn = xp[i];
	var ypn = yp[i];
	var xvn = vx[i];
	var yvn = vy[i];
	var xan = ax[i];
	var yan = ay[i];
	var k = ks[i];

	//velocity verlet
	var xpn1 = xpn + xvn * dt + 0.5 * xan * dt * dt;
	var ypn1 = ypn + yvn * dt + 0.5 * yan * dt * dt;
	var dx = mx - xp[i];
	var dy = my - yp[i];
	var cx = 0; //nonlinearity
	var cy = 0; //nonlinearity
	var den = 1/(2 + b * dt);
	var xvn1 = ((xan + dx * k + cx) * dt + 2 * xvn) * den;
	var yvn1 = ((yan + dy * k + cy) * dt + 2 * yvn) * den;
	var xan1 = (2 * k * dx + 2 * cx - xan * b * dt - 2 * b * xvn) * den;
	var yan1 = (2 * k * dy + 2 * cy - yan * b * dt - 2 * b * yvn) * den;

	processing.stroke(col[i]);
	processing.bezier(xpn, ypn, xpn+dt*xvn, ypn+dt*yvn,
						xpn1-dt*xvn1, ypn1-dt*yvn1, xpn1, ypn1);

	//store
	xp[i] = xpn1;
	yp[i] = ypn1;
	vx[i] = xvn1;
	vy[i] = yvn1;
	ax[i] = xan1;
	ay[i] = yan1;
}
```

The only interesting thing to comment about this code is how I used the bezier curve to extract a bit more precision out of each time step.
Normally I could just draw a line from the past to the present.
Here instead I draw a bezier curve where the control points are given by euler steps into the future or past, respectively.
This essentially produces an interpolation which uses the first derivative at each endpoint, meaning we get a higher order integration of the path and can use a much bigger time step to integrate the paths.

[<img class="size-full wp-image-99" alt="bezier" src="/images/2013/02/bezier.png" width="400" height="250" srcset="/images/2013/02/bezier.png 400w, /images/2013/02/bezier-300x187.png 300w" sizes="(max-width: 400px) 85vw, 400px" />](/images/2013/02/bezier.png)
