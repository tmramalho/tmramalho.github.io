---
id: 616
title: Pinch to zoom in libgdx
date: 2014-02-15T03:14:36+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=616
permalink: /blog/2014/02/15/pinch-to-zoom-in-libgdx/
categories:
  - Development
tags:
  - android
  - code
---
So I was a bit confused how to reproduce the multitouch gesture you often see in mobile gallery apps using libgdx.
The idea is to zoom and recenter the viewport such that the points where your fingers are anchored are always the same (in game coordinates).
Assuming you don't need to rotate, here is the code I came up with:

```java
public class MyGestures implements GestureListener {

	/* more stuff....
*/
	@Override
	public boolean pinch(Vector2 initialPointer1, Vector2 initialPointer2,
			Vector2 pointer1, Vector2 pointer2) {
		//grab all the positions
		touchPos.set(initialPointer1.x, initialPointer1.y, 0);
		camera.unproject(touchPos);
		float x1n = touchPos.x;
		float y1n = touchPos.y;
		touchPos.set(initialPointer2.x, initialPointer2.y, 0);
		camera.unproject(touchPos);
		float x2n = touchPos.x;
		float y2n = touchPos.y;
		touchPos.set(pointer1.x, pointer1.y, 0);
		camera.unproject(touchPos);
		float x1p = touchPos.x;
		float y1p = touchPos.y;
		touchPos.set(pointer2.x, pointer2.y, 0);
		camera.unproject(touchPos);
		float x2p = touchPos.x;
		float y2p = touchPos.y;

		float dx1 = x1n - x2n;
		float dy1 = y1n - y2n;
		float initialDistance = (float) Math.sqrt(dx1*dx1+dy1*dy1);
		float dx2 = x1p - x2p;
		float dy2 = y1p - y2p;
		float distance = (float) Math.sqrt(dx2*dx2+dy2*dy2);

		if(zooming == false) {
			zooming = true;
			cx = (_x1 + _x2)/2;
			cy = (_y1 + _y2)/2;
			px = camera.position.x;
			py = camera.position.y;
			initZoom = camera.zoom;
		} else {
			float nextZoom = (initialDistance/distance)*scale;
			/* do some ifs here to check if nextZoom is too zoomed in or out*/
			camera.zoom = nextZoom;
			camera.update();

			Vector3 pos = new Vector3((pointer1.x + pointer2.x)/2, (pointer1.y + pointer2.y)/2, 0f);
			camera.unproject(pos);
			dx = cx - pos.x;
			dy = cy - pos.y;
			/* do some ifs here to check if we are in bounds*/
			camera.translate(dx, dy);
			camera.update();
		}
		return false;
	}
}
```

Of course, you shouldn't put all this stuff into this method: each logical piece of code should be in its own method (and in [minesweeper](/blog/2013/12/11/minesweeper-on-android/ "A lovely new minesweeper on android I made") most of it is actually on another object, since I like to have only code relating to gesture handling on the gesture handler object)
