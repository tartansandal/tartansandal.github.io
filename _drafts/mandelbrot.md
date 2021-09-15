# Exploring the Complex Plane with Python and Generators

One of the joys of having ready access to modern computers and programming
frameworks is the ability to easily explore mathematical concepts that would
otherwise require a huge investment in time and resources. A classic example of
this is the ubiquitous Mandelbrot Set and its associated psychedelic images.
These images can be generated with surprisingling few lines of Python as
demonstrated by Blake Sanie in his blog [Visualizing the Mandelbrot Set Using
Python (< 50 Lines)][lt-50-lines].

Although it certainly is an odd image, but what is really going on here and,
more importantly, why should we care?

I was first introduced to the Mandelbrot many years ago at university, but
I confess that I never really understood it. More recently I stumbled on YouTube videos by

Last year I came a across a Numberphile vlog that explained it all alot better,
but just using a pen and some butchers paper.  In fact there are innumerable
blogs and youtube videos out there doing something similar.

This is pretty nice and relatively light introduction, but after reading the
[Wikipedia][] article, I felt that it might be glazing over some important
details.

There is of course the implmentation on the matplotlib website and Ned
Batcheldors Python modules.

code which show that it it does not take that much code to explore this.

I occurs that some of the "<50 lines" code could be simplified by taking
advantage of Python's complex numbers. This would allow us to add, multiply, and
measure the magnitude of those numbers without getting caught up in the
calculations.

> The set of all complex numbers (c), such that the orbit (o) of the
> recursive function (z_n = {z\_{n-1}}^2 + c) is bounded.

Domain and range

YouTube blogs

JupyterLab is a great tool for running adhoc experiments with python --
facillitating a discovery process that may lead to something more formal.:w

## Initial Concepts and Python support

Before diving into the Mandelbrot set we explore some initial concepts and
python support.

### complex numbers

* [complex numbers](https://realpython.com/python-complex-numbers/)

### recursive functions

(in math sense) -- its domain is its range

### orbits

### generators

* [generators](https://realpython.com/introduction-to-python-generators/)

Modelling orbits.

### Exploring a simple orbit

some pictures

math in jupyter notebooks?

```python
def orbit(c:complex):
  z = c
  while True
    yield z
    z = z*c

o = orbit(1)
[ next(o) for _ in range(10) ]

Predictable and boring. We get a single point.

o = orbit(-1)
[ next(o) for _ in range(10) ]

Predictable and only slightly less boring. We get an oscillation between points.

o = orbit(1j)
[ next(o) for _ in range(10) ]

Oh thats a little bit more interesting. We get an anticlockwise cycle.

o = orbit(-1j)
[ next(o) for _ in range(10) ]

Oh thats a little bit more interesting. We get an clockwise cycle.
What about ...

o = orbit(1+1j)
[ next(o) for _ in range(10) ]

What is going on here? Spirall outwards?

o = orbit(0.5+0.5j)
[ next(o) for _ in range(10) ]

A spiral inwards.
```

Draw a picture of orbit with \[seaborn].

Introduce concept of a bounded region.

```python
def bounded(o, p=500):
  for i in range(p):
    z = next(o)
    if abs(z) > 2:
      return i
  return p
```

Draw a picture of bounded region

## Mandelbrot Set

Definition

> The set of all complex numbers (c), such that the orbit (o) of the
> recursive function (z_n = {z\_{n-1}}^2 + c) is bounded.

```python
def orbit(c):
  z = c
  while True
    yield z
    z = z**2 + c

o = orbit(1+1j)
[ next(o) for _ in range(10) ]
```

Bounding lemma: if (|z_n| > 2) for any (n), then the orbit is unbounded.

Zoom out to show the circle around (|z| = 2)

What about (|z_n| < 2/3)?

Zoom in to show:

* repeated patterns
* branches
* weird structures
* less than a pixel width of first image

Links to other articles and YouTube.

Homework: Follow up by using the above to explore Julia sets?
Definition

--------------------------------------------------------------------------------

## Plan

* Introduction
  * Prior art: maths and python

  * Definition of the Mandelbrot Set
    * complex domain and range
    * recursive functions

  * Python and complex numbers -> coordinate pairs or Python's complex numbers

  * Python and generators

  * Recursive functions -> Python's generators

  * Using generators to express mandelbrot function

* Exploring a less complicated orbit
  * Why?
    * wanted to developing intuitions
    * confidence in our code
    * learn some interesting things
    * easier to prove things about
    * get a better understanding of what bounded means
    * a framework of behaviours to look out for
    * questions we should be asking about the boundary

  * define the recursive function

  * define the generator

  * define the arc function

* Exploring the Real line
  * The pieces
  * Behaviour summary

* Extending to the Imaginary numbers
  * Need a better way to visualize these arcs
  * Note that don't stray all over the complex plane
  * Cycles

## References

Visualizing the Mandelbrot Set Using Python (< 50 Lines)

[lt-50-lines]: https://medium.com/swlh/visualizing-the-mandelbrot-set-using-python-50-lines-f6aa5a05cf0f

[wikipedia]: https://en.wikipedia.org/wiki/Mandelbrot_set
