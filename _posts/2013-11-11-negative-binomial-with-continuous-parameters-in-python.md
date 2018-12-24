---
id: 590
title: Negative binomial with continuous parameters in python
date: 2013-11-11T03:14:09+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=590
permalink: /blog/2013/11/11/negative-binomial-with-continuous-parameters-in-python/
categories:
  - Development
  - Science
tags:
  - data analysis
  - python
---
So scipy doesn't support a [negative binomial](https://en.wikipedia.org/wiki/Negative_binomial_distribution) for a continuous r parameter.
The expression for its pdf is <span>$P(k)=\frac{\Gamma(k+r)}{k!\,\Gamma(r)} (1-p)^rp^k$</span>.
I coded a small class which computes the pdf and is also able to find MLE estimates for p and k given some data.
It relies on the [mpmath](https://github.com/fredrik-johansson/mpmath/) arbitrary precision library since the gamma function values can get quite large and overflow a double.
It might be useful to someone so here's the code below.

```python
import scipy.special as special
import scipy.optimize as optimize
import numpy as np
import mpmath

class negBin(object):
	def __init__(self, p = 0.1, r = 10):
		nbin_mpmath = lambda k, p, r: mpmath.gamma(k + r)/(mpmath.gamma(k+1)*mpmath.gamma(r))*np.power(1-p, r)*np.power(p, k)
		self.nbin = np.frompyfunc(nbin_mpmath, 3, 1)
		self.p = p
		self.r = r

	def mleFun(self, par, data, sm):
		'''
		Objective function for MLE estimate according to
		https://en.wikipedia.org/wiki/Negative_binomial_distribution#Maximum_likelihood_estimation

		Keywords:
		data -- the points to be fit
		sm -- \sum data / len(data)
		'''
		p = par[0]
		r = par[1]
		n = len(data)
		f0 = sm/(r+sm)-p
		f1 = np.sum(special.psi(data+r)) - n*special.psi(r) + n*np.log(r/(r+sm))
		return np.array([f0, f1])

	def fit(self, data, p = None, r = None):
		if p is None or r is None:
			av = np.average(data)
			va = np.var(data)
			r = (av*av)/(va-av)
			p = (va-av)/(va)
		sm = np.sum(data)/len(data)
		x = optimize.fsolve(self.mleFun, np.array([p, r]), args=(data, sm))
		self.p = x[0]
		self.r = x[1]

	def pdf(self, k):
		return self.nbin(k, self.p, self.r).astype('float64')
```

&nbsp;
