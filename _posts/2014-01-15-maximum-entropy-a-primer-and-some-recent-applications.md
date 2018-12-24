---
id: 638
title: 'Maximum entropy: a primer and some recent applications'
date: 2014-01-15T03:14:36+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=638
permalink: /blog/2014/01/15/maximum-entropy-a-primer-and-some-recent-applications/
categories:
  - Science
tags:
  - bayesian
  - information theory
  - physics
  - stochastic calculus
---
I'll let [Caticha](http://arxiv.org/abs/0808.0012) summarize the principle of maximum entropy:

> Among all possible probability distributions that agree with whatever we know select that particular distribution that reflects maximum ignorance about everything else.
Since ignorance is measured by entropy, the method is mathematically implemented by selecting the distribution that maximizes entropy subject to the constraints imposed by the available information.

It appears to have been introduced by Jaynes in 57, and has seen a resurgence in the past decade with people taking bayesian inference more seriously.
(As an aside, Jayne's posthumously published [book](http://www.amazon.com/Probability-Theory-The-Logic-Science/dp/0521592712) is well worth a read, in spite of some cringeworthy rants peppered throughout.) I won't dwell too much on the philosophy as the two previously mentioned sources have already gone into great detail to justify the method.

Usually we consider constraints which are linear in the probabilities, namely we constrain the probability distribution to have specific expectation values.
Consider that we know the expectation values of a certain set of functions <span>$f^k$</span>.
Then, <span>$p(x)$</span> should be such that 
<div>$$\langle f^k \rangle = \int dx \; p(x) f^k(x)$$</div>
 for all k.
Let's omit the notation <span>$(x)$</span> for simplicity.
Then, we can use variational calculus to find p which minimizes the functional 
<div>$$S[p]\; - \alpha \int dx\; p\; - \sum_k \lambda_k \langle f^k \rangle$$</div>
 The constraint with <span>$\alpha$</span> is the normalization condition and <span>$S$</span> is the [shannon entropy](https://en.wikipedia.org/wiki/Shannon_entropy).

The solution to this is 
<div>$$p = \frac{1}{Z}\exp\left(-\sum_k\lambda_k f^k \right) $$</div>
 with 
<div>$$Z=\int dx \; \exp \left(-\sum_k\lambda_k f^k \right)$$</div>
 the partition function (which is just the normalization constant).
Now, we can find the remaining [multipliers](http://en.wikipedia.org/wiki/Lagrange_multiplier) by solving the system of equations 
<div>$$-\frac{\partial \log Z}{\partial \lambda_k} = \langle f^k \rangle$$</div>
 I'll let you confirm that if we fix the mean and variance we get a gaussian distribution.
Go on, I'll wait.

<!--more-->

## Power law distributions with maxent

I read a [recent paper](http://www.pnas.org/content/110/51/20380.abstract) on PNAS which shows how to use this formalism to derive an intuition on why distributions with power law tails are so ubiquitous.
It is not very well written, but I think I successfully deduced what the authors meant.
Suppose you have a system with a given number of particles, where you 'pay' a fixed price for each particle to join.
If you consider the first one to already be there, the total paid cost is <span>$f(k)=(k-1)\mu$</span>, with mu the chemical potential (now we are talking about discrete states, now the k indexes each state, or rather the number of particles in the cluster).

By bundling every constant into a <span>$\mu^{\circ}$</span> factor, its not necessary to specify the actual value of the expectation and determine the lagrange multiplier: whatever it is, the distribution will look like <span>$p_k=\frac{\exp(-\mu^{\circ} k)}{Z}$</span> with this arbitrary <span>$\mu'$</span> factor (remember Z is just a normalization constant).
This is an exponential distribution, which means events far away from the mean are comparatively very rare.
The authors now propose to look at economies of scale - what if it gets cheaper to add a new particle as the cluster grows? Then, the cost is <span>$k_0\mu/(k+k_0)$</span>, which is a hill type function and where <span>$k_0$</span> describes how much the cost is spread out with each additional particle.
So the function f becomes <span>$f(k)=\sum_{j=1}^{k-1} k_0\mu/(j+k_0)$</span> .
Then you repeat the calculation and you get 
<div>$$p_k=\frac{\exp(-\mu^{\circ} k_0 \Psi(k+k_0))}{Z}$$</div>


Here, <span>$\Psi$</span> is the [digamma function](http://en.wikipedia.org/wiki/Digamma_function) and it's just a fancy way of hiding the sum you saw in the function <span>$f$</span> (when you do that, you also get a constant term which then cancels out).
You can expand it for large <span>$k$</span> and get <span>$\Psi \sim \log(k+k_0-1/2)$</span>.
Then the probability distribution is <span>$p_k \sim \left(k+k_0-1/2\right)^{-\mu^{\circ} k_0}$</span>.
Cool.
The authors tested this by fitting <span>$\mu^{\circ}$</span> and <span>$k_0$</span> to various datasets with power law distributions, which doesn't really show much more since we already know they are power laws, and the expression they fit is a power law.
The main message here is that you can get a power law from the maximum entropy principle, which suggests a sort of universality among systems brought about by this kind of cost amortization.

In the next post, I'll talk about a more complicated application of the maximum entropy principle to neural codes.