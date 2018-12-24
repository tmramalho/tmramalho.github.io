---
id: 276
title: 'Preprint review: Parameter Space Compression Underlies Emergent Theories and Predictive Models'
date: 2013-05-25T21:56:42+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=276
permalink: /blog/2013/05/25/preprint-review-parameter-space-compression-underlies-emergent-theories-and-predictive-models/
categories:
  - Science
tags:
  - biophysics
  - complex dynamics
  - emergence
  - nonlinear systems
  - physics
---
So here's a preprint I found really interesting [<a href="http://arxiv.org/abs/1303.6738" target="_blank">arxiv:1303.6738</a>].
I'll try to give a quick overview of the story in my own words.

The main concept used in the paper is the [Fisher Information](http://en.wikipedia.org/wiki/Fisher_information), which is no more than a measure of the curvature in the space of probability distributions.
It is easy to intuitively understand what it is in the 1D case.
Suppose you have a probability distribution for some random variable <span>$x$</span> parametrized by <span>$\theta$</span>: <span>$P(x|\theta)$</span>.
If you change <span>$\theta$</span> by an infinitesimal amount, how will the probability distribution itself change? Will it be vastly different or almost the same? We can quantify that change by averaging the square of the relative changes of the probabilities of all the points: $$\mathcal{I}=E\left[\left(\frac{dP(x)}{d\theta}\frac{1}{P(x)}\right)^2\right]_x$$

Another way to look at it is as quantifying the 'resolution' with which we can detect the parameter <span>$\theta$</span>: when the FI is high, we can distinguish between 2 parameters with close values more easily than for low FI, which corresponds to a higher resolution in parameter space.
But why can I make this statement? After all the FI quantifies the difference between the probability distributions, not the parameters which specify them.
The reason the 'resolution' picture makes sense is thanks to the Cramér-Rao bound: $$var(\hat{\theta})=\frac{1}{\mathcal{I}}$$

To understand the bound we must make the following definitions: a hat over a parameter denotes the estimator of that parameter (an estimator is just a function that takes a set of realizations (or 'measurements') of the random variable we are looking at and spits out a number, which we hope will be close to the true value of the estimator) and the variance of an estimator is just the variance of the result of applying the estimator to many independent sets of measurements.
With that in mind, the statement is that the variance of an estimator of our parameter is bounded by the inverse of the FI (note: we assume the estimator to be '[unbiased](http://en.wikipedia.org/wiki/Bias_of_an_estimator)'). Because FI for a set of N independent samples scales as N, for a very large sample size the variance of the estimator tends to zero, meaning we always get the same, 'correct value', as we'd intuitively expect.

Now bear in mind this is a very mathematical construct, hence all the quotation marks.
The intuition I described above is only valid when the model is simple enough that we can afford to use the concept of unbiased estimators (which imply discarding all prior information we might have) and can assume that the underlying parameter is indeed a single number.
Im many interesting cases we cannot assume this, but rather that it is a random variable itself (either due to nature, or due to intermediate processes we neglect to add to our model).
[I digress](http://xkcd.com/1132/).
The FI stands on its own as a useful tool in a myriad of applications, often related to quantifying the 'resolution' of a system in the sense I tried to convey above.

In the paper we are looking at, the authors consider dynamic systems at a microscopic level with many degrees of freedom.
In these systems you can consider the attributes of each particle a parameter, and code the many possible state of the system at some point in time by a probability distribution, which of course depends on this very large set of parameters.
In this case the FI for any parameter is likely very small, as if you were to make a small change in one of these parameters the system would evolve in a very similar way leaving the probability distributions relatively unchanged, in the FI sense.
The interesting step is now to find the eigenvalues of the FI matrix.
This projects the parameters onto a new space where the directions correspond to some natural observables of the system.

Now, if we coarsen the system by allowing a long time to pass (i.e.
a diffusion process) or by looking at it from a macroscopic scale (i.e.
coarse graining an ising model) it turns out a few of these directions have a very large weight and the rest have comparatively low weight. The authors argue that these directions, when cast as observables, correspond to the macroscopic parameters of the system.
Going back to the picture of the FI as resolution, these few observables will be the ones which we will be able to easily distinguish, while all the others will get lost in the noise.
This is an appealing statement because it agrees with what we already know from statistical physics: we can accurately model systems at the macroscopic scale even if we have no hope to know what is going on at the microscopic level.
Now we can see this idea emerge naturally from probability theory.

Another point they make is that this procedure works for both diffusive type processes, where we attribute this scale separation due to the fact that fluctuations are only relevant at the micro scale but not at the macro; and for processes with phase transitions where fluctuations are relevant at all scales at the critical point (cf.
[renormalization group](http://en.wikipedia.org/wiki/Renormalization_group)).
Under this framework there is a single explanation for why universal behavior is so prevalent in physics which I think is pretty cool.