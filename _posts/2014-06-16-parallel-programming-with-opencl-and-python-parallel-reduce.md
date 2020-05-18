---
id: 810
title: 'Parallel programming with opencl and python: parallel reduce'
date: 2014-06-16T03:14:57+00:00
author: Tiago Ramalho
layout: post
visual: /images/2014/06/reduction.png
guid: http://www.nehalemlabs.net/prototype/?p=810
permalink: /blog/2014/06/16/parallel-programming-with-opencl-and-python-parallel-reduce/
dsq_thread_id:
  - "2768324544"
categories:
  - Development
tags:
  - code
  - gpu
  - python
---
Once you know how to use python to run opencl kernels on your device (read [Part I](/blog/2014/04/28/parallel-programming-with-opencl-and-python/ "Parallel programming with opencl and python") and [Part II](/blog/2014/05/25/parallel-programming-with-opencl-and-python-vectors-and-concurrency/ "Parallel programming with opencl and python: vectors and concurrency") of this series) you need to start thinking about the programming patterns you will use.
While many tasks are inherently parallel (like calculating the value of a function for N different values) and you can just straightforwardly run N copies on your processors, most interesting tasks involve dependencies in the data.
For instance if you want to simply sum N numbers in the simplest possible way, the thread doing the summing needs to know about all N numbers, so you can only run one thread, leaving most of your cores unused.
So what we need to come up with are clever ways to decompose the problem into individual parts which can be run in parallel, and then combine them all in the end.

<!--more-->

This is the strong point of [Intro to Parallel Programming](https://www.udacity.com/course/cs344), available free.
If you really want to learn about this topic in depth you should watch the whole course.
Here I will only show how I implemented some of the algorithms discussed there in OpenCL (the course is in CUDA).
I'll discuss three algorithms: reduce, scan and histogram.
They show how you can use some properties of mathematical operators to decompose a long operation into a series of many small, independent operations.

Reduce is the simplest of the three.
Let's say you have to sum N numbers.
On a serial computer, you'd create a temporary variable and add the value of each number to it in turn.
It appears there is not much to parallelize here.
The key is that addition is a binary associative operator.
That means that <span>$a + b + c + d = (a+b) + (c+d)$</span>.
So if I have two cores I can add the first two numbers on one, the last two on the other, and then sum those two intermediate results.
You can convince yourself that we only need <span>$\mathcal{O}(\log N)$</span> steps if we have enough parallel processing units; as opposed to <span>$\mathcal{O}(N)$</span> steps in the serial case.
A reduction kernel in OpenCL is straightforward, assuming N is smaller than the number of cores in a single compute unit:

```c
__kernel void reduce(__global float *a,
                     __global float *r,
                     __local float *b)
{
    uint gid = get_global_id(0);
    uint wid = get_group_id(0);
    uint lid = get_local_id(0);
    uint gs = get_local_size(0);

    b[lid] = a[gid];
    barrier(CLK_LOCAL_MEM_FENCE);

    for(uint s = gs/2; s &gt; 0; s &gt;&gt;= 1) {
        if(lid &lt; s) {
          b[lid] += b[lid+s];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if(lid == 0) r[wid] = b[lid];
}
```

Full code <a href="https://github.com/tmramalho/easy-pyopencl/blob/master/008_localreduce.py" target="_blank">here</a>.
First we copy the numbers into shared memory.
To make sure we always access memory in a contiguous fashion, we then take the first N/2 numbers and add to them the other N/2, so now we have N/2 numbers to add up.
Then we take half of those and add the next half, until there is only one number remaining.
That's the one we copy back to main memory.

[<img class="size-large wp-image-818" src="/images/2014/06/reduction-1024x598.png" alt="Reduction stages." width="604" height="352" srcset="/images/2014/06/reduction-1024x598.png 1024w, /images/2014/06/reduction-300x175.png 300w, /images/2014/06/reduction.png 1454w" sizes="(max-width: 709px) 85vw, (max-width: 909px) 67vw, (max-width: 984px) 61vw, (max-width: 1362px) 45vw, 600px" />](/images/2014/06/reduction.png)

_Reduction stages.
Image from <a href="http://developer.download.nvidia.com/assets/cuda/files/reduction.pdf" target="_blank">nvidia slides</a>._


If we have N bigger than the number of cores in a single unit, we need to call the kernel multiple times.
Each core will compute its final answer, and then we run reduce again on that array of answers until we have our final number.
In the python code I <a href="https://github.com/tmramalho/easy-pyopencl/blob/master/008_localreduce.py" target="_blank">linked</a> to, you can see how we enqueue the kernel twice, but with fewer threads the second time:

```python
'''run kernels the first time for all N numbers, this will result
in N/n_threads numbers left to sum'''
evt = prg.reduce(queue, (N,), (n_threads,), a_buf, r_buf, loc_buf)
evt.wait()
print evt.profile.end - evt.profile.start

'''because I'd set N=n_threads*n_threads, there are n_threads numbers
left to sum, we sum those here, leaving 1 number'''
evt = prg.reduce(queue, (n_threads,), (n_threads,), r_buf, o_buf, loc_buf)
evt.wait()
print evt.profile.end - evt.profile.start

'''copy the scalar back to host memory'''
cl.enqueue_copy(queue, o, o_buf)
```
