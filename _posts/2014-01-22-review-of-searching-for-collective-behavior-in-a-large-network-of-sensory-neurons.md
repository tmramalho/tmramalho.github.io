---
id: 662
title: 'Review of Searching for Collective Behavior in a Large Network of Sensory Neurons'
date: 2014-01-22T03:14:52+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=662
permalink: /blog/2014/01/22/review-of-searching-for-collective-behavior-in-a-large-network-of-sensory-neurons/
categories:
  - Science
tags:
  - bayesian
  - biology
  - brain
  - data analysis
  - information theory
  - networks
  - physics
---
[Last time](/blog/2014/01/15/maximum-entropy-a-primer-and-some-recent-applications/ "Maximum entropy: a primer and some recent applications") I reviewed the principle of maximum entropy.
Today I am looking at a [paper](http://www.ploscompbiol.org/article/info%3Adoi%2F10.1371%2Fjournal.pcbi.1003408) which uses it to create a simplified probabilistic representation of neural dynamics.
The idea is to measure the spike trains of each neuron individually (in this case there are around 100 neurons from a salamander retina being measured) and simultaneously.
In this way, all correlations in the network are preserved, which allows the construction of a probability distribution describing some features of the network.

Naturally, a probability distribution describing the full network dynamics would need a model of the whole network dynamics, which is not what the authors are aiming at here.
Instead, they wish to just capture the correct statistics of the network states.
What are the network states? Imagine you bin time into small windows.
In each window, each neuron will be spiking or not.
Then, for each time point you will have a binary word with 100 bits, where each a 1 corresponds to a spike and a -1 to silence.
This is a network state, which we will represent by <span>$\boldsymbol{\sigma}$</span>.

So, the goal is to get <span>$P(\boldsymbol{\sigma})$</span>.
It would be more interesting to have something like <span>$P(\boldsymbol{\sigma}_{t+1}|\boldsymbol{\sigma}_t)$</span> (subscript denoting time) but we don't always get what we want, now do we? It is a much harder problem to get this conditional probability, so we'll have to settle for the overall probability of each state.
According to maximum entropy, this distribution will be given by
<div>$$P(\boldsymbol{\sigma})=\frac{1}{Z}\exp\left(-\sum_i \lambda_i f_i(\boldsymbol{\sigma})\right)$$</div>
<!--more-->

So now it is necessary to define which expectation values will be constrained.
The authors have decided to constrain the following:

  1.
The mean.
The function is <span>$f_i=\sigma_i$</span>, with one <span>$i$</span> for each dimension, and thus there will be a term <span>$-\sum_i h_i \sigma_i$</span> in the exponential (the <span>$\lambda$</span> was renamed to <span>$h$</span> due to [thermodynamical reasons](http://www.frontiersin.org/Journal/10.3389/neuro.10.022.2009/abstract), as the first two terms in this model are equivalent to the [ising model](https://en.wikipedia.org/wiki/Ising_model)).
  2.
Pairwise correlations.
This is equivalent to the second order moment, with <span>$f_{ij}=\sigma_i\sigma_j$</span>.
The term added to the exponential will be <span>$-1/2\sum_{i,j}J_{ij}\sigma_i\sigma_j$</span>, again with the lagrange multipliers renamed.
  3.
The proportion of spiking neurons vs.
silent ones.
To define this, the authors propose a distribution <span>$P(K)=\sum_{\boldsymbol{\sigma}}\, P(\boldsymbol{\sigma})\,\delta(\sum_i \sigma_i, 2K-N)$</span> (because K spins will cancel out K other spins, you're left with <span>$N-2K$</span> spins).
This distribution is fixed by its N moments, which reduce to
<div>$$\langle K^k\rangle=\sum_{\boldsymbol{\sigma}} \left(\sum_i \sigma_i\right)^k P(\boldsymbol{\sigma})$$</div>
 once you kill the delta.
It is now clear that the max entropy function will be <span>$f_k=\left(\sum_i \sigma_i\right)^k$</span> corresponding to a term
<div>$$-\sum_k^n \lambda_k \left(\sum_i \sigma_i\right)^k$$</div>
 in the exponential (no renaming convention here).
I am a bit suspicious of this term here since the different powers of <span>$\sum_i \sigma_i$</span> are not really independent quantities, which might mean that the model is being overfit.
I would be interested in seeing a comparison between this term and a simpler one, with just a single term (<span>$k=1$</span>) considered.

So their probability distribution looks like 
<div>$$P(\boldsymbol{\sigma})\propto\exp\left(-\sum_i h_i \sigma_i-1/2\sum_{i,j}J_{ij}\sigma_i\sigma_j-\sum_k^n \lambda_k \left(\sum_i \sigma_i\right)^k\right)$$</div>
 which is kind of the ising model with the addition of that last term.
The crucial step is now to find <span>${\mathbf{h}, \mathbf{J},\boldsymbol{\lambda}}$</span> such that the expectations of the distribution match the ones calculated from the data.
So one can run an optimization algorithm which will change the values of those parameters until the expectations for the distribution match (or are close enough to) the experimental ones.

But <span>$P(\boldsymbol{\sigma})$</span> as defined has no analytic expression for the desired expectation values,  so they must be calculated numerically.
The authors use [MCMC](https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo) to calculate them, because of the high dimensionality of the problem.
Of course, this is super computationally expensive, so they use a [little trick](http://prl.aps.org/abstract/PRL/v61/i23/p2635_1) to make it go faster.
The idea is that if you only change the parameters slightly, the distribution will also only change slightly, and therefore the MCMC samples can be reused.
Consider a max ent distribution with a vector of parameters <span>$\lambda$</span>.
You can rewrite the expectation value of a function g as

<div>
\begin{aligned}\langle g\rangle_{\lambda'}&=\sum_{\boldsymbol{\sigma}} g(\boldsymbol{\sigma}) P_{\lambda'}(\boldsymbol{\sigma})\\&=\sum_{\boldsymbol{\sigma}} g(\boldsymbol{\sigma}) \frac{P_{\lambda'}(\boldsymbol{\sigma})}{P_{\lambda}(\boldsymbol{\sigma})}P_{\lambda}(\boldsymbol{\sigma})\\&=\sum_{\boldsymbol{\sigma}}  g(\boldsymbol{\sigma}) \frac{Z_{\lambda}}{Z_{\lambda'}} \exp\left(-(\lambda'-\lambda).f(\boldsymbol{\sigma})\right) P_{\lambda}(\boldsymbol{\sigma})\\&=\frac{Z_{\lambda}}{Z_{\lambda'}}  \left\langle g \exp\left(-(\lambda'-\lambda).f\right) \right\rangle_{\lambda}\\&=\frac{\left\langle g \exp\left(-(\lambda'-\lambda).f\right) \right\rangle_{\lambda}}{\left\langle \exp\left(-(\lambda'-\lambda).f\right) \right\rangle_{\lambda}} \end{aligned}
</div>

So if you have the samples for the parameter set <span>$\lambda$</span> you can estimate the value for the parameter set <span>$\lambda'$</span> with little error (indeed, the above formula is exact, any error comes from the fact that we have finite samples from MC).
After you moved too far away from the distribution, your samples will probably not do a very good job of approximating the distribution, so the authors propose resampling after a given number of evaluations (but they don't mention how they chose the max number of evaluations, this is something that probably could use a bit more discussion).
Okay, so now they just plug this in their favorite (derivative-free) optimizer and they're golden.

They then go on to discuss the results, where they show that this procedure produces a pretty good fit to the data with apparently low overfitting.
I'd invite you to read the full paper, which has a lot of discussion on the actual neuroscience and information theory.
