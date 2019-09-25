# tartansandal.github.io


This is the source for GitHub Page https://tartansandal.github.io.
"Leaking memory all over the place"

The starting point for this adventure was
https://help.github.com/en#github-pages-basics.

There are a lot of cross-links to other articles, both internal and external, and a lot
of repeated content, so it can seem a bit like falling through a rabbit hole without
end. Following the pages in the order listed, rather than following cross-links, gave me
a narrative I could follow without too much trouble. Scanning through the articles to
get a handle on some key concepts before digging deeper was definitely worthwhile.

## Choosing a site type

The two options are "User/Organization" and "Project".

The _User/Organization_ type are for _top level_ sites relating to that particular user
or organization, and there can only be one of these for each user or organisation.

The _Project_ type is for any _project level_ sites that a user or organization may
have. There can only be one of there for each _project_, though a user or organization
may have a number of projects.

This distinction is repeated constantly, so once I figured out which one I was using
I could skip over a lot of irrelevant instructions.

I'm building a site to host a professional blog, ostensibly for gratuitous
self-promotion, so the "User/Organization" type is definitely what I want.

## Configuring a "publishing source" for my GitHub pages

Now that I know what site type I'm using, I simply need to create a new git repo called
"tartansandal.github.io" with the understanding that the `master` branch of that repo
will be the one that is published.

## Learning about Jekyll

GitHub pages is pushing Jekyll as the preferred static site generator. 
https://help.github.com/en/articles/using-jekyll-as-a-static-site-generator-with-github-pages

So I started out running through the official tutorial.
https://jekyllrb.com/docs/step-by-step/01-setup/

A key part of that was running jekyll locally on my laptop, so I could see the results
of the site generation without having to push my master branch.

https://jekyllrb.com/docs/github-pages/

I was able to make everything work, but ran into some issues with using Bundle. I'm not
a Ruby programmer yet, but I fairly sure installing ruby gems globally is not the way to
go. Fortunately I stumbled on the fact that the official `gh-pages` gem site supports
running jekyll in a Docker container. 

## Installing Jekyll locally

We want to ensure maximum compatiblilty with GitHub Pages, so we are going to base
out setup of the GitHub supplied `pages-gem`.  We also want to keep our setup
isolated from the rest of our systems so we will use `Bundler` to manage
a _project-local_ copy of our versioned gems.

The fedora repositories supply a stable version 1.17.2 (less than 9 months old) so we
simply 

    sudo dnf install rubygem-bundler

In the process of running those tutorials I kinda stuffed up my local gem install. Not
a huge fan of that setup at the moment.

although there 

Using gh-pages Docker image.

## Choosing a Theme

I'm pretty happy with the minimal theme for the moment.  Though I have to wonder how
this is going to pan out if I start blogging more STEM stuff.

## Plus AsciiDoc extensions?

Need some kind of style/structure that I like. Steal from someone?
