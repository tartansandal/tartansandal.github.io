---
layout: post
title:  "GitHub Pages with Fedora and Jekyll"
date:   2019-09-24 22:54:58 +1000
categories: jekyll fedora
comments: true
---

This is a sort of meta-post describing how I set up this blog, with some Fedora
Desktop specific advice.

I first stumbled on [GitHub Pages] and [Jekyll] while researching [Asciidoctor]
and was intrigued. It seemed to occupy a sweet spot in the world of technical
publishing:

* A very low bar of entry with free hosting via your existing GitHub account and
  automatic conversion of (the well known) GitHub Flavoured Markdown.

* Built around Git, so content could be developed, reviewed, and deployed just
  as you would 'code'. (No composing in clunky web editors or cut and paste into
  web forms).

* A flexible, low-friction development environment, with [Jekyll] and [Liquid]
  providing attractive and flexible layout and themes, plus plugins for extra
  features and few constraints for advanced users. You can even use your own
  domain name if you want to.

This looked like much more fun than the [Movable Type] based [blogs.perl.org]
I had previously used, and that rekindled my desire to write a technical
blog again.

## Learning about GitHub Pages

The starting point for this adventure was, well, a page that no longer exists.
To be honest, I first started looking at this four months ago, but I got
distracted by "life" for a while. By the time I had got back to it, things had
changed significantly. Fortunately, these changes where for the better.  The
[GitHub Pages] front page now gives you a nice video introduction and
interactive set up details, plus some links to various [Working with GitHub
Pages] guides.

I discovered very quickly that would have to choose a "site
type" before I could get much further.

> There are three types of GitHub Pages sites: project, user, and organization.
> Project sites are connected to a specific project hosted on GitHub, such as
> a JavaScript library or a recipe collection. User and organization sites are
> connected to a specific GitHub account.

This distinction is repeated constantly throughout the documentation, so once
I figured out which one I was using I could skip over a lot of irrelevant
instructions.  For example, any references to a `gh-pages` branch only apply to
"project" site types.

I was planning on building a site to host a professional blog, ostensibly for
gratuitous self-promotion. This is not going to be tied to any particular
project or organization, so the "user" site type is definitely what I want.

The next step was to set up a "publishing source".  For a "user" site I simply
needed to

* Create a GitHub repository called "tartansandal.github.io"
* Browse to the "Settings" page for that repository
* Under the "GitHub Pages" section, select "master branch" from the "Source"
  drop-down menu.

Any content that I commit to the `master` branch of that repository will be
automatically published to <https://tartansandal.github.io>. There was the
option of setting the domain name to one that I controlled, but that was more
complicated and something I could change later.

For example, I could
add a simple `index.html` file containing:

```html
<html>
  <body>
    <h1>Hello World</h1>
  </body>
</html>
```

Then browsing to <https://tartansandal.github.io> would display "Hello World" in
large bold text.

That was pretty easy, but it gets better. If I add a `_config.yml` file with:

```yaml
name: Just some notes...
markdown: kramdown
```

GitHub will then use Jekyll to automatic convert any Markdown files I add into
appropriately formatted HTML. So I could replace the `index.html` file with
`index.md` file containing

```markdown
# Hello World
```

to get the same effect. Very nice.

Now I just needed to learn how to use Jekyll to layout a technical blog.

[GitHub Pages]: https://pages.github.com
[Jekyll]: https://jekyllrb.com
[Asciidoctor]: https://asciidoctor.org
[Liquid]: https://shopify.github.io/liquid/
[Movable Type]: https://www.movabletype.org
[blogs.perl.org]:http://blogs.perl.org/users/kahlil_kal_hodgson/
[Working with GitHub Pages]: https://help.github.com/en/categories/working-with-github-pages

## Learning about Jekyll

GitHub pages uses Jekyll as its preferred static site generator and has
extensive set up and usage [documentation][GitHub Pages with Jekyll].  After
scanning that, I decided on running through the official [Jekyll Docs], in
order to get a better handle on its requirements and capabilities. This all
seemed quite reasonable.

One key point, somewhat obscured by the above guides, was that pushing any new
content to the `master` branch of my repository would trigger that content
being made public (almost) immediately. If I wanted to review my updates before
publishing, I would have to install and run Jekyll locally. This was something
I was definitely going to want to do for new content, major edits, and layout
changes.

[GitHub Pages with Jekyll]: https://help.github.com/en/github/working-with-github-pages/setting-up-a-github-pages-site-with-jekyll
[Jekyll Docs]: https://jekyllrb.com/docs/

## Installing and running Jekyll locally

There were a number of installation guides available, including a [GitHub Guide]
and a [Jekyll Guide].  Unfortunately these guides do not strictly agree, so some
research and experimentation was required to find the best path forward. There
were also some Fedora specific wrinkles with [Ruby], [RubyGems], and [Bundler]
that I needed to sort out.

[GitHub Guide]: https://help.github.com/en/github/working-with-github-pages/testing-your-github-pages-site-locally-with-jekyll
[Jekyll Guide]: https://jekyllrb.com/docs/installation/other-linux/
[Ruby]: https://www.ruby-lang.org/en/
[RubyGems]: https://rubygems.org
[Bundler]: https://bundler.io

### RubyGems

The [Jekyll Guide] suggests you first adjust your environment so that running
the `gem` command as a normal user operates on user files rather than the
default system files. In particular,

* Gems are installed under `~/.gems`
* Executable files are installed under `~/.gems/bin`.

This is probably appropriate for Ubuntu and many other Linux systems.

However, Fedora has modified RubyGems (see [`operating_system.rb`]) so that the
`gem` command automatically performs a "user install" if run by a normal user.
In particular,

* Gems are installed under `~/.gem/ruby`
* Executable files are installed under `~/bin`

Here, this make the `gem` command "just work" without the user having to change
their environment, but it uses different paths to those suggested by the [Jekyll
Guide].

I'm running Fedora and already have some "user installed" ruby gems, so if
I blindly follow the [Jekyll Guide], those gems are going to break.

[`operating_system.rb`]: https://gist.github.com/tartansandal/f82322f7928b786432ab600804cae73e

### Bundler

Managing local gem installations is a well known path to [Dependency Hell] and
one I'd rather avoid.

Both the [GitHub Guide] and the [Jekyll Guide] suggest using [Bundler] to manage
your sites dependencies.  [Bundler] allows you to safely install multiple,
potentially conflicting, versions of gems, by using a special command wrapper to
ensure that only the correct versions are used by your project.  In short:

* A `Gemfile` is used to specify the required gems and perhaps their minimal
  versions.

* The `bundle install` command installs those gems, plus any dependencies, whilst
  automatically recording the required versions in `Gemfile.lock`.

* The `bundle exec` command is used to run any programs under the version
  constraints specified in `Gemfile.lock`.

Unfortunately this does not work well with the Fedora modifications to RubyGems
mentioned above. We can get mutually compatible behaviour, however, by adding
the following to our bash configuration:

```bash
export GEM_HOME=$HOME/.gem/ruby
if [[ ! -e $HOME/.gem/ruby/bin ]]
then
    ln -s $HOME/bin $HOME/.gem/ruby/
fi
```

[Bundler] also has the option of installing gems inside your project directory,
just like Python's `vitualenv` or Node's `node_modules`:

```shell
bundle config set --local path vendor/bundle
bundle install
```

One advantage of localising the install is that you don't end up polluting your
environment with executables from random dependencies. These could shadow system
executables and cause unexpected problems. This does cost some disk space (gems
are not shared between projects) and some time (duplicated gem downloads), but
for me, the effect was small.

[Dependency Hell]: https://en.wikipedia.org/wiki/Dependency_hell

### Installation choices

The [Jekyll Guide] suggests installing some system dependencies:

```shell
sudo dnf install ruby ruby-devel @development-tools
```

Then installing both Bundler and Jekyll as a normal user:

```shell
gem install bundler jekyll
```

Using the configuration tweaks mentioned above, this is safe and
straight-forward.

On the other hand the [GitHub Guide] suggests using Bundler to install Jekyll in
order to ensure the version is compatible with the one used by GitHub. The
details of how exactly to do this are not explained though and, at this point,
the exposition starts to get a bit muddy.

The key to unravelling all this is that GitHub maintains and provides a special
[`github-pages`] gem:

> A simple Ruby Gem to bootstrap dependencies for setting up and maintaining
> a local Jekyll environment in sync with GitHub Pages

So if we have [Bundler] installed and a `Gemfile` containing:

```ruby
gem 'github-pages', group: :jekyll_plugins
```

We can install Jekyll and its dependencies at the correct versions with

```shell
bundle install
```

We can keep this in sync with the current GitHub Pages by regularly running

```shell
bundle update
```

And we can generate and serve our content locally with

```shell
bundle exec jekyll serve
```

The key point is that the version of Jekyll used by our project can (and
probably will) be different from the version installed using the `gem` command.
In this case we could just install and use the versions that come with the
Fedora distribution:

```shell
sudo dnf install rubygems-bundler rubygems-jekyll
```

This would automatically take care of any dependencies and we wouldn't have to
worry about managing updates. The Fedora versions are relatively modern and
(after reading the respective Changelogs) seem to be appropriately stable.

The final wrinkle is the following very useful `jekyll` sub-command:

```shell
jekyll new .
```

This generates a simple skeleton that can be used as a starting point for
your site:

```console
$ tree -a
.
├── 404.html
├── about.md
├── _config.yml
├── Gemfile
├── .gitignore
├── index.md
└── _posts
    └── 2020-01-16-welcome-to-jekyll.markdown
```

Note that the `Gemfile` even contains (commented out) instructions for
`github-pages` gem.

At this point I felt I had done enough research and experimentation to
formulate a plan.

[`github-pages`]: https://github.com/github/pages-gem

## Bootstrapping GitHub Pages on Fedora 31

First, I cloned the GitHub Pages repository I set up earlier:

```shell
git clone git@github.com:tartansandal/tartansandal.github.io.git
cd tartansandal.github.io
```

Next, I installed the Fedora packages with

```shell
sudo dnf install rubygem-bundler rubygem-jekyll
```

This gave me access to reasonably up-to-date versions of the `bundle` and
`jekyll` commands.

I could now generate some basic scaffolding:

```console
$ jekyll new .
```

The generated `Gemfile` contained a lot comments and Windows specific tweaks, so
I stripped that back to

```ruby
source "https://rubygems.org"
gem "github-pages", group: :jekyll_plugins
```

Next, I configured bundler to install gems into a local `vendor/bundle`
directory so the whole project was self-contained:

```shell
bundle config set --local path vendor/bundle
```

I used the path `vendor/bundle` here to be consistent with standard [bundle
deployments] and because, as we will see later, that path is ignored by default
when Jekyll processes files. I also used the `--local` option so that a local
configuration file (`.bundle/config`) is used and could be tracked by git.

[bundle deployments]: https://andre.arko.net/2011/06/11/deploying-with-bundler-notes/

I could now safely install all the required gems with

```shell
bundle install
```

and could see that were all installed under `vendor/bundle/ruby`.  I didn't
want those files tracked by Git, so I added an appropriate line to the
`.gitignore` file.

Generating and serving the default content was straight-forward:

```shell
bundle exec jekyll serve
```

And I could ensure development environment was in sync with GitHub Pages by
running:

```shell
bundle update
```

Finally, I made a `Makefile` so I could start up my environment by just running
`make`:

```make
# Development aliases
.PHONY: all serve update

# Ensure gems have been updated before launching the server
all: update serve

# Update bundled gems to sync with GitHub Pages
update:
	bundle update

# Launch a jekyll server to rebuild and serve _site files
serve:
	bundle exec jekyll serve
```

Now I was ready to start working through the [Jekyll Docs] and developing
content for my blog.

## Blogging with Jekyll

* Theme's
* `_` directories

  ```text
  _layout
  _includes
  _sass
  _posts
  ```

* shadowing
* `index.md`
* `_site`

* `_drafts`

<https://jekyllrb.com/docs/posts/#drafts>

```shell
bundle exec jekyll serve --drafts
```

trigger browser reload on any changes with the `--livereload` option

## Wrapping things up

It was simple enough to edit the `_config.yml` file to change the blog title,
description, and various user details.  I was pretty happy with the default
`minima` theme, but some minor [customization][customizing minima] was in order:

* Changing the date format to Australian standard with

  ```yaml
  minima:
    date_format: "%-d %B %Y"
  ```

* Enabling display of post "excerpts" in the main listing with

  ```yaml
  show_excerpts: true
  ```

* Setting up a Disqus account:

  ```yaml
  discus:
    shortname: tartansandal
  ```

* Using <https://realfavicongenerator.net/> to build my own favicons.

Updating the `about.md` content initially got out of hand, but I eventually
decided to cut it back to something simple.

Finally, I wrote this story and used it to replace the introductory
'welcome-to-jekyll' post.

Now it was time to deploy.

[customizing minima]: https://github.com/jekyll/minima#customizing-templates

## Deployment

Enabling GH pages
Create a Repository

I had been using git to track the development of this project and had merged all
my changes into the `master` branch. In order to deploy all I had to do was not
attach it to the `tartansandal.github.io` repository, and push my changes.

```shell
git add remote origin git@github.com:tartansandal/tartansandal.github.io.git
git push --force
```

## Conclusions

The quality of these guides has improved greatly. My only
criticism is that, while the main contents page suggests a reasonable narrative,
the individual articles lack the navigation links to make that narrative easy to
follow.
I have to keep going back to the contents page to make sure you
haven't missed anything. Internal links point to very similar looking pages.

## Guides

Some useful guides I found a long the way.

* Jonathan McGlone's excellent [Creating and Hosting a Personal Site on GitHub](
  http://jmcglone.com/guides/github-pages/)

* Ben Balter's oppinionated [Jekyll style guide](
  https://ben.balter.com/jekyll-style-guide/)

* Sylvain Durand's very straight-forward [Using GitHub to serve Jekyll](
  https://www.sylvaindurand.org/using-github-to-serve-jekyll/). This was the
  closest to the approach that I eventually ended up using.

* Jekyll's hard to find [Jekyll GitHub Pages](
  https://jekyllrb.com/docs/github-pages/)
