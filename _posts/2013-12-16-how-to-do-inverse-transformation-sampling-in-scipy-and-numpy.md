---
id: 614
title: How to do inverse transformation sampling in scipy and numpy
date: 2013-12-16T03:14:49+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=614
permalink: /blog/2013/12/16/how-to-do-inverse-transformation-sampling-in-scipy-and-numpy/
categories:
  - Development
  - Science
tags:
  - code
  - data analysis
  - python
  - stochastic calculus
---
Let's say you have some data which follows a certain probability distribution.
You can create a histogram and visualize the probability distribution, but now you want to sample from it.
How do you go about doing this with python?

[<img class="size-medium wp-image-629" alt="gaussian mixture" src="/images/2013/12/original-300x218.png" width="300" height="218" srcset="/images/2013/12/original-300x218.png 300w, /images/2013/12/original-1024x744.png 1024w, /images/2013/12/original.png 1100w" sizes="(max-width: 300px) 85vw, 300px" />](/images/2013/12/original.png)

The short answer:

```python
import numpy as np
import scipy.interpolate as interpolate

def inverse_transform_sampling(data, n_bins=40, n_samples=1000):
    hist, bin_edges = np.histogram(data, bins=n_bins, density=True)
    cum_values = np.zeros(bin_edges.shape)
    cum_values[1:] = np.cumsum(hist*np.diff(bin_edges))
    inv_cdf = interpolate.interp1d(cum_values, bin_edges)
    r = np.random.rand(n_samples)
    return inv_cdf(r)
```

The long answer:

You do [inverse transform sampling](en.wikipedia.org/wiki/Inverse_transform_sampling), which is just a method to rescale a uniform random variable to have the probability distribution we want.
The idea is that the [cumulative distribution function](https://en.wikipedia.org/wiki/Cumulative_distribution_function) for the histogram you have maps the random variable's space of possible values to the region [0,1].
If you invert it, you can sample uniform random numbers and transform them to your target distribution!

[<img class="size-large wp-image-628" alt="How the inverse CDF looks for the the above gaussian mixture" src="/images/2013/12/inverse-1024x744.png" width="604" height="438" srcset="/images/2013/12/inverse-1024x744.png 1024w, /images/2013/12/inverse-300x218.png 300w, /images/2013/12/inverse.png 1100w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 984px) 61vw, (max-width: 1362px) 45vw, 600px" />](/images/2013/12/inverse.png)

To implement this, we calculate the CDF for each bin in the histogram (red points above) and interpolate it using scipy's interpolate functions.
Then we just need to sample uniform random points and pass them through the inverse CDF! Here is how it looks:

[<img class="size-large wp-image-630" alt="New samples in red, original in blue" src="/images/2013/12/sampled-1024x744.png" width="604" height="438" srcset="/images/2013/12/sampled-1024x744.png 1024w, /images/2013/12/sampled-300x218.png 300w, /images/2013/12/sampled.png 1100w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 984px) 61vw, (max-width: 1362px) 45vw, 600px" />](/images/2013/12/sampled.png)

&nbsp;
