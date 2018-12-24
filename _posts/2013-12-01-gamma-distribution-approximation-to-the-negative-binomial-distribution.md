---
id: 592
title: Gamma distribution approximation to the negative binomial distribution
date: 2013-12-01T03:14:27+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=592
permalink: /blog/2013/12/01/gamma-distribution-approximation-to-the-negative-binomial-distribution/
categories:
  - Science
tags:
  - data analysis
  - stochastic calculus
---
In a recent data analysis project I was fitting a negative binomial distribution to some data when I realized that the gamma distribution was an equally good fit.
And with equally good I mean the MLE fits were numerically indistinguishable.
This intrigued me.
In the internet I could find only a cryptic sentence on [wikipedia](https://en.wikipedia.org/wiki/Gamma_distribution) saying the negative binomial is a discrete analog to the gamma and a [paper](http://www.jstor.org/stable/3215032) talking about bounds on how closely the negative binomial approximates the gamma, but nobody really explains _why_ this is the case.
So here is a quick physicist's derivation of the limit for large k.

<!--more-->

First let's define the distributions: the negative binomial is defined as 
<div>$$P(k)=\frac{\Gamma(k+r)}{k!\,\Gamma(r)} (1-p)^rp^k$$</div>
 with parameters <span>$r,p$</span>; and the gamma distribution is defined as 
<div>$$P(x)=\frac{\beta^{\alpha}}{\Gamma(\alpha)}x^{\alpha-1} e^{-\beta x}$$</div>
 with parameters <span>$\alpha, \beta$</span>.

We assume <span>$p\rightarrow 1$</span>, therefore <span>$\langle k \rangle = \frac{pr}{1-p} \rightarrow \infty$</span>; which means that the values of <span>$k$</span> for which <span>$P(k)$</span> is non negligible will be very high.

[<img class="size-full wp-image-610" alt="p going to one" src="/images/2013/11/nb.gif" width="800" height="582" />](/images/2013/11/nb.gif) 

Let's start with the expression for the negative binomial and make the following replacement 
<div>$$\alpha=r, \beta=1-p$$</div>
 (I actually derived this ansatz from the numerical fits).
We get the following expression: 
<div>$$P(k)=\frac{\beta^{\alpha}}{\Gamma(\alpha)} \frac{\Gamma(k+\alpha)}{k!} (1-\beta)^k$$</div>


Let's do stirling on both the denominator and numerator of the second term.


<div>$$P(k)=\frac{\beta^{\alpha}}{\Gamma(\alpha)} \frac{(k+\alpha-1)^{k+\alpha-1} e^k}{e^{k+\alpha-1} k^k} (1-\beta)^k$$</div>


Let's split the term <span>$(k+\alpha-1)^{k+\alpha-1} = (k+\alpha-1)^k(k+\alpha-1)^{\alpha-1}$</span>.
We can simplify the first term as <span>$(k+\alpha-1)^k = k^k\left(1+\frac{\alpha-1}{k}\right)^k$</span>.
The second term is approximately <span>$k^{\alpha-1}$</span> because <span>$k>>\alpha-1$</span>.
Now the <span>$e^k$</span> and <span>$k^k$</span> cancel out and we get:


<div>$$P(k)=\frac{\beta^{\alpha}}{\Gamma(\alpha)} \frac{k^{\alpha-1} }{e^{\alpha-1}} \left(1+\frac{\alpha-1}{k}\right)^k (1-\beta)^k$$</div>


Now, remember that 
<div>$$\lim_{n\rightarrow \infty} \left(1+\frac{x}{n}\right)^n = e^{x}$$</div>


We can use this on the two last terms of the expression to obtain <span>$e^{\alpha-1}e^{-\beta k}$</span>, which yields the gamma expression we were looking for.