---
id: 21
title: Information processing systems post-mortem
date: 2013-01-25T13:47:34+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=21
permalink: /blog/2013/01/25/information-processing-systems-post-mortem/
categories:
  - Science
tags:
  - ai
  - bayesian
  - biology
  - complex systems
  - emergence
  - information theory
  - machine learning
---
[Slides from the talk](/images/2013/01/main.pdf)

Yesterday I gave an informal talk about information processing systems and lessons learned from the fields of AI and biology.
This was a mix of introductory information theory and some philosophical ramblings.

While creating this talk I took the time to review several concepts from machine learning and AI. In <a href="http://www.amazon.com/Probability-Theory-Science-T-Jaynes/dp/0521592712" target="_blank">Jaynes'</a> book about probability theory, bayesian inference is presented as a completely general system for logic under uncertainty. The gist of the argument is that an inference system which obeys certain internal consistency requirements must use probability theory as a formal framework. A hypothetical information processing system should obey such consistency requirements when assigning levels of plausibility to all pieces of information, which means its workings should be built upon probability theory. As a bonus, all the theory is developed, so we need only apply it!

To implement such a system we make a connection with biology. I started by arguing that an organism which wants to maximise its long term population growth must be efficient at decoding environmental inputs and responding to them. Thus if we define long term viability of an organism implementing a given information processing system as a finess function, we can obtain good implementations of our system by maximising such a function.

<!--more-->

This argument depends on two observations: first, the growth rate of a population depends on whether the action the organisms take is the appropriate for the environment they are on; second, the long term population levels are proportional to the logarithm of the growth rate. In a well known paper on bacterial heterogeneity in the face of <a href="http://www.sciencemag.org/content/309/5743/2075.abstract" target="_blank">uncertain environments</a> it was shown that the long term growth rate for a population of bacteria in the face of an uncertain environment has the same functional form as the expected (monetary) return in the case of betting in an uncertain event with some odds (<a href="http://en.wikipedia.org/wiki/Gambling_and_information_theory" target="_blank">Kelly criterion</a>). This expression critically depends on how much you know about the environment. Concretely, assign a probability <span>$p_i$</span> to each different state the environment can be in, and a probability <span>$q_j$</span> to each of the different actions you can take. Let there also be a problem specific constant <span>$A$</span>. The return on the investment <span>$q$</span> you make is
<div>$$A[\log(n)-k(q,p)-H(p)]$$</div>
 with <span>$k(q,p)=\sum_i q_i \log \frac{q_i}{p_i}$</span> the <a href="http://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence" target="_blank">Kullback Leibler divergence</a> and <span>$H(p)=\sum_i p_i \log p_i$</span> the <a href="http://en.wikipedia.org/wiki/Entropy_(information_theory)" target="_blank">Shannon entropy</a>.

This suggests that maximizing your return can be accomplished by choosing your actions according to the same probability distribution as that for the states of the environment (<span>$p=q$</span>, which sets the KL divergence part to <span>$0$</span>), at which point only the entropy of the environment comes into play. This being the case, and if all organisms play this strategy, then the one which can best decode inputs about the environment it is in (effectively reducing the entropy of distribution <span>$p$</span>, which in the limit would be a delta function at a single state) will have an advantage.

Given a well defined objective function which measures the fitness of each organism, we now need an optimization scheme which finds its maximum. Nature has solved this problem with a (biased) random walk through parameter space (natural selection): mutation and genetic recombination providing variations in the parameters (encoded in DNA) and survival of the fittest keeping only the local maxima. <a href="http://en.wikipedia.org/wiki/Differential_evolution" target="_blank">Differential evolution</a> is an optimization heuristic inspired by this process which I have used with success in various projects (i.e. <a href="https://github.com/tmramalho/inferProfiles" target="_blank">MLE estimation of interpolating splines</a>). In the framework of artificial information processing systems, it could be used in a parallel scenario, where each machine runs an implementation of our 'intelligence model' with different parameters and the worse performers get updated with different parameters.

Finally I touched upon the topic of how such systems might look like, implementation wise. As truly intelligent systems, they will need to integrate a vast number of inputs and transform them into a conversely vast number of outputs. A system using a brute force application of bayesian inference would be extremely energy inefficient, as we can safely assume that most variables are only correlated in pairs, or relatively small groups. Thus we would like the inference process to be aware of this sparseness in the problem. This is where probabilistic <a href="http://en.wikipedia.org/wiki/Graphical_model" target="_blank">graphical models</a> come in. They appear to be an elegant way to describe the constraints of most real life problems, and I discussed the two most used ones in particular:

  * <span style="line-height: 14px;">Bayesian networks encode a causality structure and they seem to reproduce the causal network structure we find in gene regulatory networks. Indeed, they have been used with success in the reverse engineering of gene interactions from microarray experiments. In fact in most engineering problems where there is a significant causal dependency between variables they appear to be quite useful.</span>
  * Markov random fields, on the other hand, are undirected models, and are thus appropriate for processing inputs where there are massive amounts of data coming in simultaneously. The most interesting feature is that well characterized local interactions between variables give rise to global behaviors in the final density function. This emergent behavior allows these networks to perform very high level functions such as global feature extraction while still being sparse and thus energy/computationally efficient. A biological equivalent of these would be the visual cortex, where data is fed into neurons linked in a network which reflects the previously learned correlation structure of natural images. In the case of the brain it is not clear however whether a simple MRF model would be enough, since there is a neural a hierarchy of sorts, where each layer feeds its inputs into the next and thus the network as a whole might also encode causal relationships (eg. motion detection).

The slides contain more references to papers both in biology and machine learning and hitchhikers guide to the galaxy jokes. I also plan to do a post on the image segmentation problem I mention as an introduction in the talk.

&nbsp;
