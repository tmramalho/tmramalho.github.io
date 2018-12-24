---
id: 252
title: Modeling excitable media with cellular automata
date: 2013-04-17T17:44:43+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=252
permalink: /blog/2013/04/17/modeling-excitable-media-with-cellular-automata/
categories:
  - Science
tags:
  - biophysics
  - complex dynamics
  - complex systems
  - nonlinear systems
---
While researching for my seminar I came across a class of cellular automata which models spiral waves in <a href="http://en.wikipedia.org/wiki/Excitable_medium" target="_blank">excitable media</a>.
Because these models are so simple I had some fun implementing them in processing.
Processing is great because you can use the javascript version to embed the visualization in a webpage directly and everyone can play with it.
Here are some of the models I played around with:

  * <a style="line-height: 1.714285714; font-size: 1rem;" href="/projects/spiralwaves/Spiral.html">Spiral</a><span style="line-height: 1.714285714; font-size: 1rem;">, a model developed by Gerhard and Schuster to simulate a chemical reaction.</span>
  * [CCA](/projects/spiralwaves/CCA.html), a simple [cyclic cellular automaton](http://en.wikipedia.org/wiki/Cyclic_cellular_automaton).
  * [StochCCA](/projects/spiralwaves/StochCCA.html), where I added stochasticity to the previous model.
This is useful to assign more weight to the 4 neighbors of the [Von Neumann neighborhood](http://en.wikipedia.org/wiki/Von_Neumann_neighborhood) than to the remaining 4 which complete the [Moore neighborhood](http://en.wikipedia.org/wiki/Moore_neighborhood).
This appears to make space 'more isotropic' and makes the waves actually circular.