---
title: Github Pages on Fedora Revisited
---

After all the messy fussing around with Jekyll and Ruby required to get this
blog to work, an upgrade to Fedora 34 broke everything by including ruby-3 in
its base. Right! Enough of this rubbish!  I should have dockerized things from
the start: containers avoid this issue entirely. Fortunately others have already
had the same idea:

* https://github.com/Starefossen/docker-github-pages
* https://github.com/envygeeks/jekyll-docker#readme
