---
usemathjax: true
---

# Exploring the Mandelbrot Set with Python complex numbers and generators

The Mandelbrot Set is one of those ubiquitous psychodelic images that crops up
when comes to trying to demonstrate to the general public that mathematics can
actually be interesting, or at least incredibly strange. Phrases like "fractal
dimensions" and "infinitely self-similar" presented with lots of handwaving and
invariably extract the requisite "Oooh's" and "Ahhh's" of appreciation from the
audience. It certainly is an odd image, but what is really going on here and,
more importantly, why should we care?


I first came across

I recently discovered a blog about 
Prior art: [Visualizing the Mandelbrot Set Using Python (< 50
Lines)](https://medium.com/swlh/visualizing-the-mandelbrot-set-using-python-50-lines-f6aa5a05cf0f).

This is pretty nice and sufficiently light introduction.

Definition

> The set of all complex numbers \(c\), such that the orbit \(o\) of the
> recursive function \(z_n = {z_{n-1}}^2 + c\) is bounded.

YouTube blogs

## Initial Concepts and Python support

Before diving into the Mandelbrot set we explore some initial concepts and
python support.

### complex numbers

* [complex numbers](https://realpython.com/python-complex-numbers/)

### recursive functions (in math sense) -- its domain is its range

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

Draw a picture of orbit with [seaborn].

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

> The set of all complex numbers \(c\), such that the orbit \(o\) of the
> recursive function \(z_n = {z_{n-1}}^2 + c\) is bounded.

```python
def orbit(c):
  z = c
  while True
    yield z
    z = z**2 + c 

o = orbit(1+1j)
[ next(o) for _ in range(10) ]
```

Bounding lemma: if \(|z_n| > 2\) for any \(n\), then the orbit is unbounded.

Zoom out to show the circle around \(|z| = 2\)

What about \(|z_n| < 2/3\)?

Zoom in to show:
* repeated patterns
* branches
* weird structures
* less than a pixel width of first image

Links to other articles and YouTube.

Homework: Follow up by using the above to explore Julia sets?


## Plan

* Introduction
  * Prior art: maths and python
  * Definition of the Mandelbrot Set
    * complex domain and range
    * recursive functions
  * Python and complex numbers -> coordinate pairs or Python's complex numbers
  * Python and generators
  * Recursive functions -> Python's generators
  * Using  

* Exploring a less complicated orbit
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
* 
