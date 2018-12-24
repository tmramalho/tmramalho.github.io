---
id: 27
title: 'An introduction to smoothing time series in python.
Part IV: Particle Filter'
date: 2013-07-16T20:35:41+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=27
permalink: /blog/2013/07/16/an-introduction-to-smoothing-time-series-in-python-part-iv-particle-filter/
categories:
  - Science
tags:
  - bayesian
  - code
  - information theory
  - stochastic calculus
---
Last time we started talking about state space models with the [Kalman Filter](/blog/2013/06/25/an-introduction-to-smoothing-time-series-in-python-part-iii-kalman-filter/ "An introduction to smoothing time series in python.
Part III: Kalman Filter").
Our aim has been to find a smoothed trajectory for some given noisy observed data.
In the case of state space models, we incorporate a model for the underlying physical system to calculate a likelihood for each trajectory and select the optimal one.
When it comes to implementing this idea, we run into the problem of how to represent the probability distributions for the state of the system: it would be unfeasible to calculate the probability for every single point in phase space at all times.
The Kalman filter solves this by approximating the target probability density function (abbreviated pdf) with a Gaussian, which has only two parameters.
This approximation works surprisingly well but it might not be optimal for cases where the underlying pdf is multimodal.

Today we will be looking at another idea to implement state space models - the <a href="http://en.wikipedia.org/wiki/Particle_filter" target="_blank">particle filter</a>.
Our goal is still to find the maximum of the posterior distribution <span>$P(x|y,\theta)$</span>, given by bayes' formula:
<div>$$P(x|y,\theta)\propto P(y | x, \theta)P(x|\theta)P(\theta)$$</div>
 Now the idea is to approximate this distribution by randomly drawing points from it.
Because we will only look at one time step at a time, the sequence of points we sample will be a markov chain; and because the method relies on random sampling we call it a markov chain monte carlo (MCMC) method.<!--more-->

Formally, consider the expectation of a function f at some time point:
<div>$$\int dx\; f(x) p(x|y)$$</div>
 We can approximate this integral by sampling a bunch of points according to <span>$p(x|y)$</span> and then approximating the integral with the sum <span>$\sum_{j}f(x^j)$</span>.
Note that when f is a delta function we are sampling the pdf itself.
If we sample infinite points, the result will be exact; we hope we can get away with a smaller number than that. The problem is that often we don't know how to sample from p, so we have to be clever.

The standard way to be clever is by using <a href="http://en.wikipedia.org/wiki/Importance_sampling" target="_blank">importance sampling</a>.
Instead of sampling directly from <span>$p$</span> we sample from an easier distribution to work with: <span>$q$</span>, the proposal.
We put it in by using a great trick: multiplying by one (<span>$1=\frac{q}{q}$</span>)
<div>$$\int dx\; f(x) \frac{p(x|y)}{q(x|y)}q(x|y)\simeq\sum_{j}f(x^j)w(x^j)$$</div>
 where w is the ratio between p and q. If we pick a nice q, the sampled points will be highly informative and we won't need to sample quite so many points to describe the posterior distribution well.
Designing a nice proposal distribution is almost an art form (or black magic?).

Let's do this one step at a time: for each time slice, we want to sample from <span>$P(x_i|y_{0:i})$</span>.
All we know is the distribution in the past and the new data <span>$y_i$</span>.
Because this is a markov chain, the current value only depends on the previous value; and we know how to move from the one time point into the future: we use the chapman-kolmogorov relation
<div>$$P(x_i|y_{0:i})=\int dx_{i-1}\;P(x_i|x_{i-1}, y_{0:i})P(x_{i-1}|y_{0:i})$$</div>
 At this point it will be helpful to again multiply stuff by one.
The first pdf will be the target of our sampling so we multiply and divide by <span>$q(x_i|x_{i-1}, y_{0:i})$</span>.
We handle the second pdf by multiplying and dividing by something we should know, <span>$P(x_{i-1}|y_{0:i-1})$</span>.
So the whole thing now looks like
<div>$$P(x_i|y_{0:i})=\int dx_{i-1}\;\frac{P(x_i|x_{i-1}, y_{0:i})}{q(x_i|x_{i-1}, y_{0:i})}\frac{P(x_{i-1}|y_{0:i})}{P(x_{i-1}|y_{0:i-1})}P(x_{i-1}|y_{0:i-1})q(x_i|x_{i-1}, y_{0:i})$$</div>


Almost there! Now we use the fact that we are representing both the current time and the previous time with particles.
We can use a delta function to represent the function itself with the particle set
<div>$$\sum_n\delta(x^n)P(x^n_i|y_{0:i})$$</div>
 And recognize that the integral over <span>$x_{i-1}$</span> is an expectation over the pdf of the previous time, which is also represented by particles.
It then becomes
<div>$$P(x^n_i|y_{0:i})=\sum_j \frac{P(x^n_i|x^j_{i-1}, y_{0:i})}{q(x^n_i|x^j_{i-1}, y_{0:i})}\frac{P(x^j_{i-1}|y_{0:i})}{P(x^j_{i-1}|y_{0:i-1})}q(x^n_i|x^j_{i-1}, y_{0:i}) \; w(x^j_{i-1})$$</div>


That's a lot of particles! Now there is an obvious simplification: because in the computer we only evolve one particle at a time, there will be only one <span>$x^j_{i-1}$</span> that resulted in a given <span>$x^n_{i}$</span>.
Thus the inner sum is approximated as being over only one particle which makes the sum go away.

<div>$$\sum_n\delta(x^n)\frac{P(x^n_i|x^n_{i-1}, y_{0:i})}{q(x^n_i|x^n_{i-1}, y_{0:i})}\frac{P(x^n_{i-1}|y_{0:i})}{P(x^n_{i-1}|y_{0:i-1})}w(x^n_{i-1}) \; q(x^n_i|x^n_{i-1}, y_{0:i})$$</div>


So we can <span style="line-height: 14px;">sample according to <span>$q(x_i|x_{i-1}, y_{0:i})$</span> and </span><span style="line-height: 1.714285714; font-size: 1rem;">the weights will be given by what remains.
We can rewrite the weights as
<div>$$w\propto w(x^n_{i-1})\frac{P(y_i|x_i)P(x_i|x_{i-1},y_{0:i-i})}{q(x_i|x_{i-1}, y_{0:i})}$$</div>
 </span><span style="line-height: 1.714285714; font-size: 1rem;">(we can ignore the normalization because we can renormalize them at the end).
We still need to use black magic to determine the sampling distribution <span>$q(x_i|x_{i-1}, y_{0:i})$</span>, but often we cheat and use <span>$P(x_{i-1}|y_{0:i-i})$</span>, which makes the weights <span>$w\propto  w(x^n_{i-1})P(y_i|x_i)$</span>.</span>

One problem is that samples tend to accumulate in regions in phase space with large probability.
It might happen that after some time steps we have only one particle with weight approximately 1 and all others 0.
To fix this we can, at each time step, resample the particle set according to the current probability distribution, which then resets all the weights: <span>$w(x^n) = 1/N$</span>.
Hopefully these particles will be better at exploring the phase space.

Let's try this algorithm on the nonlinear problem which stumped the Kalman filter.
As before, we use as transition function <span>$p(x_i|x_{i-1})$</span> the integral of the differential equations for the van der pol oscillator.
You can find the python code on <a href="https://github.com/tmramalho/smallParticleFilter" target="_blank">github</a>.

The result is more a testament to how amazing an approximation the Kalman Filter is than anything else: the particle filter manages an mse of 0.108 vs.
the Kalman filter's 0.123 when the nonlinearity parameter is set to 4.
I guess my experiments are probably too easy for these advanced methods.
You can visualize the particles evolving along time in the following plot:

[<img class="size-large wp-image-437" alt="Visualization of particle set evolution for a single nonlinear van der pol oscillator.
I dispersed the points for each time step a little around t to make the distribution easy to see, but there are only 10 measurements total (corresponding to each of the clusters).
Notice the nice quenching in position space due to the dynamics all converging to that point in phase space." src="/images/2013/07/dists-864x1024.png" width="625" height="740" srcset="/images/2013/07/dists-864x1024.png 864w, /images/2013/07/dists-253x300.png 253w, /images/2013/07/dists-624x738.png 624w, /images/2013/07/dists.png 1055w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 984px) 61vw, (max-width: 1362px) 45vw, 600px" />](/images/2013/07/dists.png)

_Visualization of particle set evolution for a single nonlinear van der pol oscillator.
I dispersed the points for each time step a little around t to make the distribution easy to see, but there are only 10 measurements total (corresponding to each of the clusters).
Notice the nice quenching in position space due to the dynamics all converging to that point in phase space.
The particles are also colored by weight but you can barely see the points with significantly higher weights among all the samples.
1000 particles total._

A caveat for these methods is that we must know the underlying parameters for the physical system if they are to work well.
In many situations, there is a way to estimate them, but in others we actually need the smoothed result to estimate the parameters, such as in systems biology.
In a future post I will talk about the challenges of parameter inference for state space models.
