---
id: 26
title: Automatic segmentation of microscopy images
date: 2013-11-05T03:14:48+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=26
permalink: /blog/2013/11/05/automatic-segmentation-of-microscopy-images/
categories:
  - Development
  - Science
tags:
  - biophysics
  - code
  - computing
  - machine learning
---
A few months back I was posed the problem of automatically segmenting <a href="http://en.wikipedia.org/wiki/Bright_field_microscopy" target="_blank">brightfield images</a> of bacteria such as this:

[<img class="size-full wp-image-583" alt="Brightfield image of a bacterial colony" src="/images/2013/10/bfcrops.png" width="319" height="349" srcset="/images/2013/10/bfcrops.png 319w, /images/2013/10/bfcrops-274x300.png 274w" sizes="(max-width: 319px) 85vw, 319px" />](/images/2013/10/bfcrops.png) 

I thought this was a really simple problem so I started applying some filters to the image and playing with [morphology](https://en.wikipedia.org/wiki/Mathematical_morphology) operations.
You can isolate dark spots in the image by applying a threshold to each pixel.
The resulting binary image can be modified by using the different morphological operators, and hopefully identifying each individual cell.
Turns out there is a reason people stopped using these methods in the 90s and the reason is they don't really work.
If the cells are close enough, there won't be a great enough difference in brightness to separate the two particles and they will remain stuck.

<!--more-->

So I used this technique to detect the background, instead of the cells.
By applying conservative settings, I can obtain an image where pixels which are definitely background are masked off.
In this hybrid image I can then try to detect areas with high probability of being inside a cell (called markers).
With user provided dimensions for an individual cell, I can break apart any marker too big to be part of only one cell using a combination of brightness and gradient information.
The [watershed](https://en.wikipedia.org/wiki/Watershed_(image_processing)) algorithm then expands these markers until they mark the whole cell.
All these operations are implemented in the excellent [openCV library](http://opencv.org/).

This heuristic works reasonably well, but in many experimental setups there are often defects which are not cells floating around in the image which are detected as cells by the above procedure.
Usually they fit inside the allowed dimensions for a cell but have strange shapes.
To mitigate this problem at the end of the heuristic I added a classification step, where the user can mark each individual marker as a cell or not.
By calculating the [image moments](https://en.wikipedia.org/wiki/Image_moment) for each marker I can create a feature vector quantifying its shape, which is fed into a support vector machine classifier.
I used [libsvm](http://www.csie.ntu.edu.tw/~cjlin/libsvm/) to implement this feature really quickly.
Because you can classify cells just by clicking on them, a user can create a massive training dataset in a few minutes, which results in a really good generalization capability.

You can download the [final software here](http://tmramalho.github.io/bigCellBrotherGUI/).
The GUI was implemented with qt which allows me to build it for all platforms.
For now it is available as a binary for mac and it also works flawlessly on linux (didn't provide a binary but should be easy to compile from source).
I'd like to make a windows version but honestly I have never developed on windows so I'd need to invest significant time in learning how to build for it.
And that time constitutes a high potential barrier for me to actually go do it, so it might take a while to get done.

While researching for this project I got into reading a lot in the field of computer vision.
It turned out to be a mix of wonder and frustration.
It appears most people use bayesian inference to do object detection, and they have developed quite sophisticated methods to perform such inference in spite of the computational burden of large images.
These methods appear quite good in theory, but in practice they are only as good as the features one feeds into them.
And choosing the right features appears to be more of an art than a science.
So for very specific scenarios where they fine tuned the feature detector you can get really good performance, but the method will not generalize at all.

One general idea in this direction would be segmentation based on a markov random field.
Each pixel would have a probability of being a cell or not based on a number of features such as the brightness, the gradient of the brightness and the texture of a patch of a certain size around it.
Additionally nearest neighbor interactions would make the labelling robust to noise.
However this approach does not directly tackle the issue of disconnecting the identified cells, because to do such a proper segmentation global features would have to be included in the feature set for each pixel.
Some features which the brain uses when segmenting these pictures are the shape/size of the cell a given pixel is part of or the continuity of the edges of a potential cell.
Distinct algorithms exist to process images and retrieve such global features, but it is not clear to me how to integrate them in the framework of a markov random field.
I thought about implementing this in the segmentation algorithm but I figured it would take me a few months to do so and this was supposed to be a quick project so I ended up doing the least interesting thing.

Another issue which I would like to tackle is lineage reconstruction.
For now this is done by simply looking at the previous frame and calculating which cell has the maximum overlap in area with the current and assigning it as the mother.
This approach has a number of issues, such as not accounting for the possibility of camera shift or cell death and migration (cell division is also not explicitly accounted for but is less of an issue).
For images with a steady camera and slowly moving/dividing cells this naive approach works nonetheless reasonably well.
If this is not the case a more global approach would be necessary.
This would involve the use of a filter to predict cell positions at the next time step and correct them accordingly, a <a href="http://en.wikipedia.org/wiki/Mean-shift" target="_blank">mean shift</a> type algorithm to detect if there was a global shift in the position, and a bookkeeping method to detect cell death/migration off screen.