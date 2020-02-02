---
title: An Email Validation Koan
---

I love this simple systems engineering problem. It encapsulates so may
lessons for the novice developer.

> Can you write a program to validate an email address?

* Simple sounding problem
* Technically "impossible"
* Requires a "business decision" to resolve
* Fantastic learning opportunity for novices

It is an extremely simple sounding problem, and obvious solutions jump quickly
to the mind of the budding programmer.

Many attempts at this have been tried. The problem has been "done to death" on
The Internet. There a some key engineering "realities" (discussed below) which
make a perfect solution impossible, so we are always forced to make the business
decisions:

> Which email addresses will we **accept**?

And conversely:

> Which email addresses will we **reject**?

These decisions are not necessarily distinct: they may overlap and the order in
which they are applied may be important.

Answers to these questions are not necessarily clear and optimal, or even
acceptable, answers will depend on your particular "business goals".

## A novices tail

1. Email addresses are just strings, and they seem to follow a common pattern,
   so regular expressions look like a good match (giggle) for the problem.
2. Scratching together an RE that matches everything in your address book is not
   too hard, but a couple of cases have you concerned -- what if that matches
   something that is invalid?
3. You head off to stackexchange -- surely someone has done this before -- only
   to find a
