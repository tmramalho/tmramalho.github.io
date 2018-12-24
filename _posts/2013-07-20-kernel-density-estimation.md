---
id: 447
title: Kernel density estimation
date: 2013-07-20T15:06:49+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=447
permalink: /blog/2013/07/20/kernel-density-estimation/
categories:
  - Science
tags:
  - bayesian
  - information theory
  - machine learning
  - stochastic calculus
---
Sometimes you need to estimate a probability distribution from a set of discrete points.
You could build a histogram of the measurements, but that provides little information about the regions in phase space with no measurements (it is very likely you won't have enough points to span the whole phase space).
So the data set must be smoothed, as we did with [time series](/blog/2013/04/05/an-introduction-to-smoothing-time-series-in-python-part-i-filtering-theory/ "An introduction to smoothing time series in python.
Part I: filtering theory").
As in that case, we can describe the smoothing by a convolution with a kernel.
In this case, the formula is very simple $$f(x)=\frac{1}{N}\sum_i^N K(x-x_i)$$

The choice of K is an art, but the standard choice is the gaussian kernel as we've seen before.
Let's try this out on some simulated data

```
d = MixtureDistribution[{1, 2}, {NormalDistribution[-3, 1/2],
    NormalDistribution[4, 5/3]}];
Plot[Evaluate[PDF[d, x]], {x, -6, 8}, Filling -&gt; Axis]
```

&nbsp;

[<img class="size-full wp-image-451" alt="Gaussian mixture we will sample from" src="/images/2013/07/kdedist.png" width="360" height="231" srcset="/images/2013/07/kdedist.png 360w, /images/2013/07/kdedist-300x192.png 300w" sizes="(max-width: 360px) 85vw, 360px" />](/images/2013/07/kdedist.png)

And now let's apply KDE to some sampled data.

```
ns = 100;
dat = RandomVariate[d, ns];
\[Sigma] = 1;
c[x_] := Sum[
   Exp[-(dat[[i]] - x)^2/(2*\[Sigma])]/(Sqrt[2 \[Pi] \[Sigma]]), {i,
    ns}];
Show[Histogram[dat, 30, "ProbabilityDensity"],
 Plot[c[x]/ns, {x, -6, 8}]]
```

&nbsp;

[<img class="size-full wp-image-448" alt="100 samples, sigma 1" src="/images/2013/07/kde100.png" width="360" height="223" srcset="/images/2013/07/kde100.png 360w, /images/2013/07/kde100-300x185.png 300w" sizes="(max-width: 360px) 85vw, 360px" />](/images/2013/07/kde100.png) [<img class="size-full wp-image-449" alt="1000 samples, sigma 1" src="/images/2013/07/kde1000.png" width="360" height="223" srcset="/images/2013/07/kde1000.png 360w, /images/2013/07/kde1000-300x185.png 300w" sizes="(max-width: 360px) 85vw, 360px" />](/images/2013/07/kde1000.png)

The choice of standard deviation makes a big difference in the final result.
For low amounts of data we want a reasonably high sigma, to smoothen out the large variations in the data.
But if we have a lot of points, a lower sigma will more faithfully represent the original distribution:

[<img class="size-full wp-image-450" alt="1000 samples, sigma 0.1" src="/images/2013/07/kde1000-0.1.png" width="360" height="223" srcset="/images/2013/07/kde1000-0.1.png 360w, /images/2013/07/kde1000-0.1-300x185.png 300w" sizes="(max-width: 360px) 85vw, 360px" />](/images/2013/07/kde1000-0.1.png)

&nbsp;

&nbsp;
