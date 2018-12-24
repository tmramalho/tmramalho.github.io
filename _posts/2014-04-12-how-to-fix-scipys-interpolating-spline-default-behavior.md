---
id: 768
title: 'How to fix scipys interpolating spline default behavior'
date: 2014-04-12T03:14:49+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=768
permalink: /blog/2014/04/12/how-to-fix-scipys-interpolating-spline-default-behavior/
dsq_thread_id:
  - "2638545206"
categories:
  - Development
tags:
  - data analysis
  - python
---
Scipy's <a href="http://docs.scipy.org/doc/scipy-0.13.0/reference/generated/scipy.interpolate.UnivariateSpline.html" target="_blank">UnivariateSpline</a> class is a super useful way to smooth time series, especially if you need an estimate of the derivative.
It is an implementation of an interpolating spline, which I've previously covered in <a title="An introduction to smoothing time series in python.
Part II: wiener filter and smoothing splines" href="/blog/2013/04/09/an-introduction-to-smoothing-time-series-in-python-part-ii-wiener-filter-and-smoothing-splines/" target="_blank">this blog post</a>.
Its big problem is that the default parameters suck.
Depending on the absolute value of your data, the spline produced by leaving the parameters at their default values can be overfit, underfit or just fine.
Below I visually reproduce the problem for two time series from an experiment with very different numerical values.

[<img class="size-large wp-image-772" alt="Two time series with different numerical values and their derivatives below" src="/images/2014/04/p_007-1024x744.png" width="604" height="438" srcset="/images/2014/04/p_007-1024x744.png 1024w, /images/2014/04/p_007-300x218.png 300w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 984px) 61vw, (max-width: 1362px) 45vw, 600px" />](/images/2014/04/p_007.png)

_Two time series with different numerical values and their derivatives below.
The first is overfit, the second underfit._

My usual solution was just to manually adjust the <span>$s$</span> parameter until the result looked good.
But this time I have hundreds of time series, so I have to do it right this time.
And doing it right requires actually understanding what's going on.
In the documentation, <span>$s$</span> is described as follows:

> Positive smoothing factor used to choose the number of knots.
Number of knots will be increased until the smoothing condition is satisfied:
>
> sum((w[i]*(y[i]-s(x[i])))**2,axis=0) <= s
>
> If None (default), s=len(w) which should be a good value if 1/w[i] is an estimate of the standard deviation of y[i].
If 0, spline will interpolate through all data points.

So the default value of <span>$s$</span> should be fine _if_ <span>$w^{-1}$</span> were an estimate of the standard deviation of <span>$y$</span>.
However, the default value for <span>$w$</span> is 1/len(y) which is clearly _not_ a decent estimate.
The solution then is to calculate a rough estimate of the standard deviation of <span>$y$</span> and pass the inverse of that as <span>$w$</span>.
My solution to that is to use a <a title="An introduction to smoothing time series in python.
Part I: filtering theory" href="/blog/2013/04/05/an-introduction-to-smoothing-time-series-in-python-part-i-filtering-theory/" target="_blank">gaussian kernel</a> to smooth the data and then calculate a smoothed variance as well.
Code below:

```python
def moving_average(self, series, sigma=3):
    b = gaussian(39, sigma)
    average = filters.convolve1d(series, b/b.sum())
    var = filters.convolve1d(np.power(series-average,2), b/b.sum())
    return average, var

_, var = moving_average(series)
sp = ip.UnivariateSpline(x, series, w=1/np.sqrt(var))
```

&nbsp;

[<img class="size-large wp-image-773" alt="Same timeseries with the variance estimate fix" src="/images/2014/04/p_007corr-1024x744.png" width="604" height="438" srcset="/images/2014/04/p_007corr-1024x744.png 1024w, /images/2014/04/p_007corr-300x218.png 300w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 984px) 61vw, (max-width: 1362px) 45vw, 600px" />](/images/2014/04/p_007corr.png)

Now, you may be thinking I only moved the parameter dependence around: before I had to fine tune <span>$s$</span> but now there is a free parameter _sigma_.
The difference is that a) the gaussian filter results are much more robust with respect to the choice of sigma;  b) we only need to provide an estimate of the standard deviation, so it's fine if the result coming out is not perfect; and c) it does not depend on the absolute value of the data.
In fact, for the above dataset I left sigma at its default value of 3 for all timeseries and all of them came out perfect.
So I'd consider this problem solved.

I understand why the scipy developers wouldn't use a method similar to mine to estimate <span>$w$</span> as default, after all it may not work for all types of data.
On the other hand, I think the documentation as it stands is confusing.
The user would expect that parameters which have a default value would work without fine tuning, instead what happens here is that if you leave <span>$w$</span> as the default you must change <span>$s$</span> and vice versa.
