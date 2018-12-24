---
id: 362
title: How to import structured matlab data into python with scipy
date: 2013-11-01T03:14:53+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=362
permalink: /blog/2013/11/01/how-to-import-structured-matlab-data-into-python-with-scipy/
categories:
  - Development
  - Science
tags:
  - code
  - data analysis
  - physics
  - python
---
So a few days ago I received this really nice data set from an experimental group in matlab format which contains a list of structs with some properties, some of which are structs themselves. I usually just open it in matlab using my university's license and export the data as a .csv , but in this case with the structs there was no direct way to export the data and preserve all the associated structure.
Luckily scipy has a method to import .mat files into python, appropriately called [loadmat](http://docs.scipy.org/doc/scipy/reference/generated/scipy.io.loadmat.html).

In the case of a struct array the resulting file is kind of confusing to navigate.
You'd expect to access each record with data[i], where data is the struct list.
For some reason I cannot hope to understand you need to iterate over data in the following way: data[0,i].

Each record is loaded as a numpy [structured array](http://docs.scipy.org/doc/numpy/user/basics.rec.html), which allow you to access the data by its original property names.
That's great, but what I don't understand is why some data gets nested inside multiple one dimensional arrays which you need to navigate out of.
An example: I needed to access a 2d array of floats which was a property of a property of a struct (...).
You'd expect to access it as record\['property'\]\['subproperty'\].
But actually you have to dig it out of record\['property'\]\['subproperty'\]\[0\]\[0\].
I'm not sure if this is due to the way .mat files are structured or scipy's behavior.
This is relatively easy to figure out using the interactive shell, although it makes for some ugly code to parse the whole file.

The best way to map the structure would be to create an array of dicts in python with the corresponding properties.
However I wanted to have the data in numpy format which led to a slightly awkward design decision: I create a table where each row contains the (unique) value of the properties in the child structs and the corresponding values for the properties in the parent structs. This means that the properties in the parent structs are duplicated across all rows corresponding to their children.
With this I traded off memory space for being able to directly access all values for a single property without traversing some complicated structure.
I believe this was a reasonable tradeoff.

What about selecting subsets of data based on the parent properties? To solve this problem, I actually converted the massive numpy table into a [pandas](http://pandas.pydata.org/) dataframe.
Pandas is extremely useful when your data fits the 'spreadsheet' paradigm (i.e.
each column corresponds to a different kind of data type), and its advanced [selection](http://pandas.pydata.org/pandas-docs/stable/indexing.html) operations allow you to do SQL-like queries on the data (yes, you can even do [joins](http://pandas.pydata.org/pandas-docs/stable/merging.html#database-style-dataframe-joining-merging)!), which is what I have been using to do advanced selections.