---
id: 686
title: The link between thermodynamics and inference
date: 2014-01-29T03:14:43+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=686
permalink: /blog/2014/01/29/the-link-between-thermodynamics-and-inference/
categories:
  - Science
tags:
  - bayesian
  - information theory
  - physics
  - stochastic calculus
---
In recent blog posts I talked a bit about how many aspects of maximum entropy were analogous to methods in statistical physics.
In this short post, I'll summarize the most interesting similarities.
In bayesian inference, we are usually interested in the posterior distribution of some parameters <span>$\theta$</span> given the data d.
This posterior can be written as a [boltzmann distribution](https://en.wikipedia.org/wiki/Boltzmann_distribution):
<div>$$P(\theta|d)=\frac{P(\theta,d)}{P(d)}=\left.\frac{e^{-\beta H(\theta,d)}}{Z}\right|_{\beta=1}$$</div>
 with <span>$H(\theta,d) = -\log P(\theta,d)/\beta$</span> and <span>$Z=\int d\theta\;e^{-\beta H(\theta,d)}$</span>.
I'll note that we are working with units such that <span>$k_B=1$</span> and thus <span>$\beta=1/T$</span>.

The energy is just the expectation value of the hamiltonian H (note that the expectation is taken with respect to <span>$P(\theta|d)$</span>):
<div>$$E = \langle H \rangle = -\frac{\partial \log Z}{\partial \beta}$$</div>


And the entropy is equal to
<div>$$S=-\int d\theta\;P(\theta|d)\log P(\theta|d)=\beta\langle H \rangle - \log Z$$</div>


We can also define the free energy, which is
<div>$$F=E\, - \frac{S}{\beta}=-\frac{\log Z}{\beta}$$</div>


A cool way to approximate Z if we can't calculate it analytically (we usually can't calculate it numerically for high dimensional problems because the integrals take a very long time to calculate) is to use laplace's [approximation](http://en.wikipedia.org/wiki/Laplace%27s_method): 
<div>$$Z=\int d\theta\;e^{-\beta H(\theta,d)}\simeq\sqrt{\frac{2\pi}{\beta|H'(\theta^*)|}}e^{-\beta H(\theta^*)}$$</div>
 where <span>$|H'(\theta^*)|$</span> is the determinant of the hessian of the hamiltonian (say that 3 times real fast) and <span>$\theta^*$</span> is such that <span>$H(\theta^*)=\min H(\theta)$</span> (minimum because of the minus sign).
Needless to say this approximation works best for small temperature (<span>$\beta\rightarrow\infty$</span>) which might not be close to the correct value at <span>$\beta=1$</span>.
<span>$\theta^*$</span> is known as the [maximum a posteriori](http://en.wikipedia.org/wiki/Maximum_a_posteriori_estimation) (MAP) estimate.
Expectation values can also be approximated in a similar way:
<div>$$\langle f(\theta) \rangle = \int d\theta \; f(\theta) P(\theta|d) \simeq\sqrt{\frac{2\pi}{\beta|H'(\theta^*)|}} f(\theta^*)P(\theta^*|d)$$</div>


So the MAP estimate is defined as <span>$\text{argmax}_{\theta} P(\theta|d)$</span>.
The result won't change if we take the log of the posterior, which leads to a form similar to the entropy:

<div>
\begin{align}\theta_{\text{MAP}}&=\text{argmax}_{\theta} (-\beta H - \log Z)\\&=\text{argmax}_{\theta} (-2\beta H + S)\end{align}
</div>

Funny, huh? For infinite temperature (<span>$\beta=0$</span>) the parameters reflect total lack of knowledge: the entropy is maximized.
As we lower the temperature, the energy term contributes more, reflecting the information provided by the data, until at temperature zero we would only care about the data contribution and ignore the entropy term.

(This is also the basic idea for the [simulated annealing](https://en.wikipedia.org/wiki/Simulated_annealing) optimization algorithm, where in that case the objective function plays the role of the energy and the algorithm walks around phase space randomly, with jump size proportional to the temperature.
The annealing schedule progressively lowers the temperature, restricting the random walk to regions of high objective function value, until it freezes at some point.)

Another cool connection is the fact that the heat capacity is given by
<div>$$C(\beta)=\beta^2\langle (\Delta H)^2 \rangle=\beta^2\langle (H-\langle H \rangle)^2 \rangle=\beta^2\frac{\partial^2 \log Z}{\partial \beta^2}$$</div>


In the paper I looked at [last time](/blog/2014/01/22/review-of-searching-for-collective-behavior-in-a-large-network-of-sensory-neurons/ "Review of ‘Searching for Collective Behavior in a Large Network of Sensory Neurons’"), the authors used this fact to estimate the entropy: they calculated <span>$\langle (\Delta H)^2 \rangle$</span> by [MCMC](https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo) for various betas and used the relation $$S = \, \int_{1}^{\infty} d\beta\; \frac{1}{\beta} C(\beta)$$
