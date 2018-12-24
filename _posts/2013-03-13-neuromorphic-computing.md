---
id: 115
title: Neuromorphic computing
date: 2013-03-13T19:30:38+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=115
permalink: /blog/2013/03/13/neuromorphic-computing/
categories:
  - Science
tags:
  - ai
  - brain
  - complex systems
  - computing
---
Lately I've been giving some thought on quantitative measures for the brain's processing power.
Let us take the number of brain neurons as <span>$10^{11}$</span> and synapses as <span>$10^{14}$</span>, according to <a href="http://en.wikipedia.org/wiki/Neuron#Neurons_in_the_brain" target="_blank">wikipedia</a>.
I am going to assume a very simplified <a href="http://en.wikipedia.org/wiki/Biological_neuron_model" target="_blank">computational model</a> for a neuron:

$$y_i = \phi\left( \sum_j w_{ij} x_j \right)$$

With <span>$\phi$</span> an activation function such as a step function or a sigmoidal function.
So every time a neuron spikes, a computation is being performed.
From our previous numbers, the sum in the <span>$j$</span> has around <span>$10^3$</span> components on average, which means there are one thousand additions and one thousand multiplications performed per spike! Let's consider each of these a floating point operation on a computer.
Then we have 2000 flops (I will call flops the plural of a flop and flop/s flops per second, because the terminology is really confusing) per spike.
Let us assume an action potential (a spike) for a neuron lasting 1ms as an upper bound.
Then a neuron can spike up to 1000 times per second.
Thus we have <span>$1000*10^{11}*2000=2*10^{17}$</span> flop/s, or 200 petaflop/s.

That is only an order of magnitude higher than the fastest supercomputers at the <a href="http://www.top500.org/list/2012/11/" target="_blank">time of writing</a>.
It seems at least a first approximation to the brain would be achievable in realtime in the next few years correct? Not with the current architectures.
An obvious oversight such a simplistic calculation makes is the concurrency of the calculation.
The 2000 calculations for a given spike are performed simultaneously in a neuron, whereas a traditional von neumann architecture would need to do these calculations in steps: first perform all the multiplications, then sum all the results to a single value.
Even a massively parallel architecture would need one clock cycle for the multiplications, and 10 clock cycles to integrate all values (by summing them in pairs you need <span>$log_2 (1000)$</span> clock cycles).
The number of flop/s is the same, but you need to run your machine 11 times faster, which destroys power efficiency (you don't want your brain consuming megawatts of power).

An even greater problem is the memory bandwidth.
At each clock cycle, you need to move <span>$10^{11}$</span> numbers to your computational cores, compute their new values and move them back.
If each is a double we are in the order of 800GB/s each way just for the main operation (i.e.
not counting any temporary variables for the sum reduction above discussed), which does seem out of reach of current supercomputers, and also not very power efficient.

The brain is not affected by these problems since the memory is an integral part of the computational infrastructure.
In fact synaptic weights and connections are both the software and the memory of the brain's architecture.
Of course, the way information is encoded is not very well understood, and there are likely many mechanisms to do so.
The wikipedia page on neural coding is <a href="http://en.wikipedia.org/wiki/Neural_coding" target="_blank">quite interesting</a>.
In any case it is clear that synaptic weights are not enough to fully describe the brain's architecture, as [glial cells](http://www.cell.com/cell-stem-cell/abstract/S1934-5909(13)00007-6) might also play a role in memory formation and neuronal connectivity.
However, <a href="http://en.wikipedia.org/wiki/Spike-timing-dependent_plasticity" target="_blank">spike timing dependent plasticity</a> (STDP, associated with Hebb's rule) seems to be an adequate coarse grained description of how synapse weights are determined (at the time of writing).

With this in mind, <a href="http://en.wikipedia.org/wiki/Memristor" target="_blank">memristors</a> seem to be an appropriate functional equivalent to our coarse grained description of the brain.
In a memristor, resistance is proportional to the intensity of the current that flows through it.
Thus you can engineer a system where connections which are often used are reinforced.
By combining memristive units with transistors, it is in principle possible to create an integrate and fire unit similar to a neuron.
A device to emulate STDP could also be implemented.
The biggest hurdle seems to be connection density.
In a planar implementation, only 4 nearest neighbor connections can be implemented straightforwardly.
To reach an order of 1000 connections (not necessarily with nearest neighbors) per unit, 3D structures will need to be used.
At the current time however there are no promising techniques to enable the reliable construction of such structures.
I foresee that self assembly will play a large role in this field, again taking heavy inspiration from the way nature does things.

In spite of these hurdles, I am excited.
With progress in science getting harder each year, the only way to continue to discover nature's secrets will be to enhance our cognitive capabilities be it through biological or electrical engineering.