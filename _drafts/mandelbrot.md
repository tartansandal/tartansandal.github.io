---
usemathjax: true
---

# Exploring the Mandelbrot set with python

Prior art: [Visualizing the Mandelbrot Set Using Python (< 50 Lines)](https://medium.com/swlh/visualizing-the-mandelbrot-set-using-python-50-lines-f6aa5a05cf0f).

YouTube blogs

## Initial Concepts and Python support

Before diving into the Mandelbrot set we explore some initial concepts and
python support.

* complex numbers
* recursive functions (in math sense) -- its domain is its range
* generators
* orbits
* bounded regions

* [complex numbers](https://realpython.com/python-complex-numbers/)
* [generators](https://realpython.com/introduction-to-python-generators/)

definition of set
refresher on complex numbers? Nah, just point to wikipedia or 3b2b
orbits generators

```math
$$z_n = z_n*c$$
```

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

Draw a picture of bounded region

## Mandelbrot Set

Definition

> The set of all complex numbers \(c\), such that the orbit \(o\) of the recursive function \(z_n = {z_{n-1}}^2 + c\) is bounded.

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

Zoom in to show:
* repeated patterns
* branches
* weird structures
* less than a pixel width of first image

Links to other articles and YouTube.

Homework: Follow up by using the above to explore Julia sets?
