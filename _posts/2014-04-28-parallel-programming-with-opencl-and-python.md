---
id: 778
title: Parallel programming with opencl and python
date: 2014-04-28T03:15:58+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=778
permalink: /blog/2014/04/28/parallel-programming-with-opencl-and-python/
dsq_thread_id:
  - "2642148372"
categories:
  - Development
tags:
  - code
  - computing
  - python
---
In the next few posts I'll cover my experiences with learning how to program efficient parallel programs on gpus using opencl.
Because the machine I got was a mac pro with the top of the line gpus (7 teraflops) I needed to use opencl, which is a bit complex and confusing at first glance.
It also requires a lot of boilerplate code which makes it really hard to just jump in and start experimenting.
I ultimately decided to use pyopencl, which allows us to do the boring boilerplate stuff in just a few lines of python and focus on the actual parallel programs (the kernels).

First, a few pointers on what I read. A great introduction to the abstract concepts of parallel programming is the udacity course <a href="https://www.udacity.com/course/cs344" target="_blank">Introduction to parallel programming.</a> They use C and CUDA to illustrate the concepts, which means you can't directly apply what you see there on a computer with a non nvidia gpu.
To learn the opencl api itself, I used the book <a href="http://www.amazon.com/OpenCL-Action-Accelerate-Graphics-Computation/dp/1617290173/" target="_blank">OpenCL in Action: How to Accelerate Graphics and Computation</a>.
As for pyopencl, the <a href="http://documen.tician.de/pyopencl/" target="_blank">documentation</a> is a great place to start.
You can also find all the python code I used in <a href="https://github.com/tmramalho/easy-pyopencl" target="_blank">github</a>.<!--more-->

I assume you know the basics of how gpus work and what they are useful for.
My intention is to 'translate' the existing tutorials into pyopencl, which lets you start running code much sooner than any C based framework.
Additionally, because we are using openCL, we can run our simple code on most computers.
To start with, let's look at how to access the data structures which contain information about the available openCL devices on our computer:

```python
import pyopencl as cl
plat = cl.get_platforms()
plat[0].get_devices()
```

In a given computer, you can have different implementations of OpenCL (i.e.
an amd driver,and an nvidia driver); these are known as platforms.
Usually you'll only have one platform in your computer.
A platform contains the devices it is responsible for, so by querying the platform data structure we can look at all the devices in our system.
The mac pro shows the following list of available devices:

```
[&lt;pyopencl.Device 'Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz' on 'Apple' at 0xffffffff&gt;, &lt;pyopencl.Device 'ATI Radeon HD - FirePro D700 Compute Engine' on 'Apple' at 0x1021c00&gt;, &lt;pyopencl.Device 'ATI Radeon HD - FirePro D700 Compute Engine' on 'Apple' at 0x2021c00&gt;]
```

To actually run something on these devices, we need to create a context to manage the queues of kernels which will be executed there.
So say I want to run something on my first gpu.
I'd create a context with:

```python
import pyopencl as cl
plat = cl.get_platforms()
devices = plat[0].get_devices()
ctx = cl.Context([devices[1]])
ctx.get_info(cl.context_info.DEVICES)
```

The final line queries the device associated with the context we just created:

```
[&lt;pyopencl.Device 'ATI Radeon HD - FirePro D700 Compute Engine' on 'Apple' at 0x1021c00&gt;]
```

<p class="p1">
  Why would we need to query the devices in a context if we put the devices there in the first place? One reason is that you can create a context without bothering to look up any platforms or devices beforehand.
Just run
</p>

```python
import pyopencl as cl
ctx = cl.create_some_context()
```

And you're done! When you run the script, a prompt will ask you for a specific device out of all possible devices, or you can set an environment variable to specify which one you want by default.
In the following, I'll always use this method to create a context, but if you want more control over which devices you choose, [this example](https://github.com/pyopencl/pyopencl/blob/master/examples/benchmark.py) is quite enlightening.

Now that we know how to access the devices, let's take a look at how to run code there.
I'll start with a simple parallel pattern, the map.
We are going to apply a function to each of the data points independently, which allows for maximal parallelism.
Here is the code:

```python
import pyopencl as cl
import numpy as np

a = np.arange(32).astype(np.float32)
res = np.empty_like(a)

ctx = cl.create_some_context()
queue = cl.CommandQueue(ctx)

mf = cl.mem_flags
a_buf = cl.Buffer(ctx, mf.READ_ONLY | mf.COPY_HOST_PTR, hostbuf=a)
dest_buf = cl.Buffer(ctx, mf.WRITE_ONLY, res.nbytes)

prg = cl.Program(ctx, """
    __kernel void sq(__global const float *a,
    __global float *c)
    {
      int gid = get_global_id(0);
      c[gid] = a[gid] * a[gid];
    }
    """).build()

prg.sq(queue, a.shape, None, a_buf, dest_buf)

cl.enqueue_copy(queue, res, dest_buf)

print a, res
```

In line 7 we create the context, as before.
Then, we create a queue in line 8, which is what schedules the kernels to run on the device.
Now let's skip a few lines and look at the actual opencl code, on lines 14-21.
You can see that the opencl code itself is in the c programming language, and is passed to the program object as a string.
In a real project we should write this code in a .cl file separate from the python project and have the code be read from there, but for these simple examples I'll leave the code as a string.
Once the program object is initialized with some code, we call its build method to compile it to a binary native to the gpu.

You can see from the kernel's signature that it expects to receive pointers to two memory locations.
These point to the gpu's main memory, and must be initialized before running the kernel.
That's what lines 10-12 are for: they let pyopencl know that two blocks of memory must be initialized on the gpu before the kernel is run, and if necessary, what values should be copied to that memory (the hostbuf parameter, which points to the source array on the host's main memory).
The memory is actually only allocated / copied when the kernel actually reaches the top of the queue, and before it runs.

We add the kernel to the queue in line 23, telling pyopencl which queue to add it to first; then how many instances of the kernel will be run (we want to spawn many instances to take advantage of the parallel nature of the gpu) and how they will be distributed (the None parameter, we'll cover this in a later post);  and finally the parameters which should be passed (the memory locations).
Finally in line 25 we copy the values from the memory at res back to an array in the host memory.
If we did this in C we would have needed 100+ lines of code by now so I'm really happy pyopencl exists.

Finally let's look at the kernel code itself, the actual opencl code and see what it does:

```c
__kernel void sq(__global const float *a, __global float *c)
{
    int gid = get_global_id(0);
    c[gid] = a[gid] * a[gid];
}
```

Each of the tiny processors on the GPU will run a copy of this code.
First we access each thread's unique global id.
This will allow the processor to identify which piece of memory it should work on.
Then, it loads the value from the a array and squares it, storing it in the correct position in the c array.
Simple! Next time we'll look at some more advanced operations we can perform on data.
