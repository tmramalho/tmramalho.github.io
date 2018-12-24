---
id: 717
title: Simple pattern formation with cellular automata
date: 2014-02-11T03:14:13+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=717
permalink: /blog/2014/02/11/simple-pattern-formation-with-cellular-automata/
categories:
  - Science
tags:
  - biophysics
  - complex dynamics
  - complex systems
  - emergence
  - nonlinear systems
  - physics
  - web
---
A cellular automaton is a dynamical system where space, time and dynamic variable are all discrete.
The system is thus composed of a lattice of cells (discrete space), each described by a state (discrete dynamic variable) which evolve into the next time step (discrete time) according to a dynamic rule.

<div>
$$
x_i^{t+1} = f(x_i^t, \Omega_i^t, \xi)
$$
</div>

This rule generally depends on the state of the target cell <span>$x_i^t$</span>, the state of its neighbors <span>$\Omega_i^t$</span>, and a number of auxiliary external variables <span>$\xi$</span>.
Since all these inputs are discrete, we can enumerate them and then define the dynamic rule by a transition table.
The transition table maps each possible input to the next state for the cell.
As an example consider the elementary 1D cellular automaton.
In this case the neighborhood consists of only the 2 nearest neighbors <span>$\Omega_i^t = \{x_{i-1}^t, x_{i+1}^t\}$</span> and no external variables.

In general, there are two types of neighborhoods, commonly classified as Moore or Von Neumann.
A Moore neighborhood of radius <span>$r$</span> corresponds to all cells within a hypercube of size <span>$r$</span> centered at the current cell.
In 2D we can write it as <span>$\Omega_{ij}^t = \{x^t_{kl}:|i-k|\leq r \wedge |j-l|\leq r\}\setminus x^t_{ij}$</span>.
The Von Neumann neighborhood is more restrictive: only cells within a manhattan distance of <span>$r$</span> belong to the neighborhood.
In 2D we write <span>$\Omega_{ij}^t = \{x^t_{kl}:|i-l|+|j-k| \leq r\}\setminus x^t_{ij}$</span>.

Finally it is worth elucidating the concept of totalistic automata.
In high dimensional spaces, the number of possible configurations of the neighborhood <span>$\Omega$</span> can be quite large.
As a simplification, we may consider instead as an input to the transition table the sum of all neighbors in a specific state <span>$N_k = \sum_{x \in \Omega}\delta(x = k)$</span>.
If there are only 2 states, we need only consider <span>$N_1$</span>, since <span>$N_0 = r - N_1$</span>.
For an arbitrary number <span>$m$</span> of states, we will obviously need to consider <span>$m-1$</span> such inputs to fully characterize the neighborhood.
Even then, each input <span>$N_k$</span> can take <span>$r+1$</span> different values, which might be too much.
In such cases we may consider only the case when <span>$N_k$</span> is above some threshold.
Then we can define as an input the boolean variable

<div>
$$
P_{k,T}=\begin{cases}

1& \text{if}\; N_k \geq T,\\

0& \text{if}\; N_k < T.

\end{cases}
$$
</div>

In the simulation you can find [here](/projects/discretemorpho/zo1d.html), I considered a cellular automaton with the following properties: number of states <span>$m=2$</span>; moore neighborhood with radius <span>$r=1$</span>; lattice size <span>$L_x \times L_y$</span>; and 3 inputs for the transition table:

  * Current state <span>$x_{ij}^t$</span>
  * Neighborhood state <span>$P_{1,T}$</span> with <span>$T$</span> unspecified
  * One external input <span>$\xi$</span>

  <div>
  $$

    \xi_{ij}=\begin{cases}

    1& \text{if}\; i \geq L_x/2,\\

    0& \text{if}\; i < L_x/2.

    \end{cases}

    $$
  </div>
  * Initial condition <span>$x_{ij} = 0 \; \forall_{ij}$</span>

For these conditions a deterministic simulation of these conditions yields only a few steady states: homogeneous 1 or 0, half the lattice 1 and the other 0, and oscillation between a combination of the previous.

One possibility would be to add noise to the cellular automaton in order to provide more interesting dynamics.
There are two ways to add noise to a cellular automaton:

The most straightforward way is to perform the following procedure at each time step:

  * Apply the deterministic dynamics to the whole lattice
  * For each lattice site <span>$ij$</span>, invert the state <span>$x_{ij}$</span> with probability <span>$p$</span>

This procedure only works of course for <span>$m=2$</span>.
In the case of more states there is no obvious way to generalize the procedure and we need to use a proper monte carlo method to get the dynamics.

A second way is to implement a probabilistic cellular automaton.
In this case the transition table is generalized to a markov matrix: each input is now mapped not to a specific state but rather to a set of probabilities for a transition to each state (<span>$m$</span> probabilities).
Naturally for each input these sum to one.
In this case we have <span>$m$</span> times more parameters than before.
