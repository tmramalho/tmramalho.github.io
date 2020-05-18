---
id: 824
title: 'Parallel programming with opencl and python: parallel scan'
date: 2014-06-23T03:14:59+00:00
author: Tiago Ramalho
layout: post
visual: /images/2014/06/bl2.png
guid: http://www.nehalemlabs.net/prototype/?p=824
permalink: /blog/2014/06/23/parallel-programming-with-opencl-and-python-parallel-scan/
dsq_thread_id:
  - "2787790790"
categories:
  - Development
tags:
  - code
  - gpu
  - python
---
This post will continue the subject of how to implement common algorithms in a parallel processor, which I started to discuss [here](/blog/2014/05/25/parallel-programming-with-opencl-and-python-parallel-reduce/ "Parallel programming with opencl and python: parallel reduce").
Today we come to the second pattern, the <a href="https://en.wikipedia.org/wiki/Prefix_sum" target="_blank">scan</a>.
An example is the cumulative sum, where you iterate over an array and calculate the sum of all elements up to the current one.
Like reduce, the algorithm we'll talk about is not exclusive for the sum operation, but for any binary associative operation (the max is another common example).
There are two ways to do a parallel scan:  the hills steele scan, which needs <span>$\log n$</span> steps; and the blelloch scan, requiring <span>$2 \log n$</span> steps.
The blelloch scan is useful if you have more data than processors, because it only needs to do <span>$\mathcal{O}(n)$</span> operations (this quantity is also referred to as the work efficiency); while the hillis steele scan needs <span>$\mathcal{O}(n \log n)$</span> operations.
So let's look at how to implement both of them with opencl kernels.

<!--more-->

#### Hillis Steele

This is the simplest scan to implement, and is also quite simple to understand.
It is worthwhile noting that this is an inclusive scan, meaning the first element of the output array o is described as a function of the input array a as follows: $$o_i = \sum_{j=0}^i a_j$$

Naturally, you could replace the summation with any appropriate operator.
Rather than describing the algorithm with words, I think a picture will make it much clearer than I could:

[<img class="size-full wp-image-828" src="/images/2014/06/hs1.png" alt="Visualization of the hillis steele inclusive scan." width="872" height="432" srcset="/images/2014/06/hs1.png 872w, /images/2014/06/hs1-300x148.png 300w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 1362px) 62vw, 840px" />](/images/2014/06/hs1.png)

_Visualization of the hillis steele inclusive scan.
Credit: <a href="http://developer.download.nvidia.com/compute/cuda/1.1-Beta/x86_website/projects/scan/doc/scan.pdf" target="_blank">nvidia</a>._

As you can see, the key is to add the value of your neighbor <span>$2^d$</span> positions to your left to yourself, or just do nothing if such neighbor does not exist.
This is quite simple to translate to an OpenCL kernel:

```c
#define SWAP(a,b) {__local float *tmp=a;a=b;b=tmp;}
__kernel void scan(__global float *a,
                   __global float *r,
                   __local float *b,
                   __local float *c)
{
    uint gid = get_global_id(0);
    uint lid = get_local_id(0);
    uint gs = get_local_size(0);

    c[lid] = b[lid] = a[gid];
    barrier(CLK_LOCAL_MEM_FENCE);

    for(uint s = 1; s &lt; gs; s &lt;&lt;= 1) {
        if(lid &gt; (s-1)) {
            c[lid] = b[lid]+b[lid-s];
        } else {
            c[lid] = b[lid];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
        SWAP(b,c);
    }
    r[gid] = b[lid];
}
```

The for loop variable s represents the neighbor distance: it is multiplied by two every loop until we reach N neighbors.
Note the use of the SWAP macro: it swaps the b and c pointers which will always denote the current step (c) and the previous step (b) without needing to copy memory.

#### Blelloch

The Blelloch scan is an exclusive scan, which means the sum is computed up to the current element but excluding it.
In practice it means the result is the same as the inclusive scan, but shifted by one position to the right: $$o_i = \sum_{j=0}^{i-1} a_j,o_0=0$$

The idea of the algorithm is to avoid repeating summations of the same numbers.
As an example, if you look at the picture above you can see that to calculate <span>$o_5$</span> we need to add together <span>${x_5, x_4, x_2+x_3, x_1+x_0}$</span>.
That means we are essentially repeating the calculation of <span>$o_3$</span> for nothing.
So to avoid this we'd need to come up with a non overlapping set of partial sums that each calculation could reuse.
That's what this algorithm does!

As before, the algorithm is better explained with a picture or two:

[<img class="size-full wp-image-826" src="/images/2014/06/bl1.png" alt="The up sweep portion of the Blelloch scan." width="887" height="451" srcset="/images/2014/06/bl1.png 887w, /images/2014/06/bl1-300x152.png 300w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 1362px) 62vw, 840px" />](/images/2014/06/bl1.png)

_The up sweep portion of the Blelloch scan.
Here the partial sums are calculated.
Credit: <a href="http://developer.download.nvidia.com/compute/cuda/1.1-Beta/x86_website/projects/scan/doc/scan.pdf" target="_blank">nvidia</a>._

[<img class="size-full wp-image-827" src="/images/2014/06/bl2.png" alt="The down sweep portion of the Blelloch scan." width="888" height="562" srcset="/images/2014/06/bl2.png 888w, /images/2014/06/bl2-300x189.png 300w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 1362px) 62vw, 840px" />](/images/2014/06/bl2.png)

_The down sweep portion of the Blelloch scan.
Here the partial sums are used to calculate the final answer._

You can see how the up sweep part consists of calculating partial sums, and the down sweep combines them in such a way that we end up with the correct results in the correct memory positions.
Let's see how to do this in OpenCL:

```c
__kernel void scan(__global float *a,
                   __global float *r,
                   __local float *b,
                   uint n_items)
{
    uint gid = get_global_id(0);
    uint lid = get_local_id(0);
    uint dp = 1;

    b[2*lid] = a[2*gid];
    b[2*lid+1] = a[2*gid+1];

    for(uint s = n_items&gt;&gt;1; s &gt; 0; s &gt;&gt;= 1) {
        barrier(CLK_LOCAL_MEM_FENCE);
        if(lid &lt; s) {
            uint i = dp*(2*lid+1)-1;
            uint j = dp*(2*lid+2)-1;
            b[j] += b[i];
        }

        dp &lt;&lt;= 1;
    }

    if(lid == 0) b[n_items - 1] = 0;

    for(uint s = 1; s &lt; n_items; s &lt;&lt;= 1) {
        dp &gt;&gt;= 1;
        barrier(CLK_LOCAL_MEM_FENCE);

        if(lid &lt; s) {
            uint i = dp*(2*lid+1)-1;
            uint j = dp*(2*lid+2)-1;

            float t = b[j];
            b[j] += b[i];
            b[i] = t;
        }
    }

    barrier(CLK_LOCAL_MEM_FENCE);

    r[2*gid] = b[2*lid];
    r[2*gid+1] = b[2*lid+1];
}
```

It took me a little while to wrap my head around both steps of the algorithm, but the end code is pretty similar to the Hillis Steele.
There are two loops instead of one, and the indexing is a bit tricky, but I think that comparing the code to the picture it should be straightforward.
You can also find a cuda version in the nvidia <a href="http://developer.download.nvidia.com/compute/cuda/1.1-Beta/x86_website/projects/scan/doc/scan.pdf" target="_blank">paper</a> where I took the pictures from.
