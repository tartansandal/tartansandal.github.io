---
layout: post
title:  "GitHub Pages with Fedora and Jekyll"
categories: github-pages jekyll fedora
comments: true
---

This is a sort of meta-post describing how I set up this blog, with some Fedora
Desktop specific advice.

I first stumbled on [GitHub Pages] and [Jekyll] while researching [Asciidoctor]
and was intrigued. It seemed to occupy a sweet spot in the world of technical
publishing:

* A very low bar of entry with free hosting via your existing GitHub account and
  automatic conversion of (the well known) GitHub Flavoured Markdown.

* Being built around Git, content could be developed, reviewed, and deployed just
  as you would normal 'code'. (No composing in clunky web editors or cut and
  paste into web forms).

* A flexible, low-friction development environment, with [Jekyll] and [Liquid]
  providing attractive and flexible layout and themes, plus plugins for extra
  features and few constraints for advanced users.

This looked like much more fun than the [Movable Type] based [blogs.perl.org]
I had previously used, and that rekindled my desire to write a technical
blog again.

## Learning about GitHub Pages

The starting point for this adventure was, well, a page that no longer exists.
To be honest, I first started looking at this four months ago, but I got
distracted by "life" for a while. By the time I had got back to it, things had
changed significantly. Fortunately, these changes were for the better.  The
[GitHub Pages] front page now gives you a nice video introduction and
interactive set up details, plus some links to various [Working with GitHub
Pages] guides.

I discovered very quickly that would have to choose a "site
type" before I could get much further.

> There are three types of GitHub Pages sites: project, user, and organisation.
> Project sites are connected to a specific project hosted on GitHub, such as
> a JavaScript library or a recipe collection. User and organisation sites are
> connected to a specific GitHub account.

This distinction is repeated constantly throughout the documentation, so once
I figured out which one I was using I could skip over a lot of irrelevant
instructions.  For example, any references to a `gh-pages` branch only apply to
"project" site types.

I was planning on building a site to host a professional blog, ostensibly for
gratuitous self-promotion. This was not going to be tied to any particular
project or organisation, so the "user" site type is definitely what I wanted.

The next step was to set up a "publishing source".  For my "user" site I simply
needed to

* Create a GitHub repository called "tartansandal.github.io"
* Browse to the "Settings" page and find the "GitHub Pages" section
* Select "master branch" from the "Source" drop-down menu

Now any content that I commit to the `master` branch of that repository would be
automatically published to <https://tartansandal.github.io>.  For example,
I could add a simple `index.html` file containing:

```html
<html>
  <body>
    <h1>Hello World</h1>
  </body>
</html>
```

Then browsing to <https://tartansandal.github.io> would display "Hello World" in
large bold text.

That was pretty easy, but it gets better. If I added a `_config.yml` file
containing:

```yaml
markdown: kramdown
```

GitHub would then automatically convert any Markdown files to appropriately
formatted HTML. I could replace the `index.html` file with `index.md` file
containing:

```markdown
# Hello World
```

and get the same effect. Very nice.

Now I just needed to learn how to use Jekyll to layout a technical blog.

[GitHub Pages]: https://pages.github.com
[Jekyll]: https://jekyllrb.com
[Asciidoctor]: https://asciidoctor.org
[Liquid]: https://shopify.github.io/liquid/
[Movable Type]: https://www.movabletype.org
[blogs.perl.org]:http://blogs.perl.org/users/kahlil_kal_hodgson/
[Working with GitHub Pages]: https://help.github.com/en/categories/working-with-github-pages

## Learning about Jekyll

GitHub pages uses Jekyll as its static site generator and has extensive set up
and usage [documentation][GitHub Pages with Jekyll].  After scanning that,
I decided on running through the official [Jekyll Docs], to get a better handle
on its requirements and capabilities.

One key point---somewhat obscured by the above guides---was that pushing content
to the `master` branch of my repository would cause the public website to be
updated (almost) immediately. If I wanted to (privately) review any new content,
major edits, or layout changes, I would have to install and run Jekyll locally.
This was something I was definitely going to want to do.

[GitHub Pages with Jekyll]: https://help.github.com/en/github/working-with-github-pages/setting-up-a-github-pages-site-with-jekyll
[Jekyll Docs]: https://jekyllrb.com/docs/

## Installing Jekyll on Fedora 31

Unfortunately the [GitHub Guide] and the [Jekyll Guide] did not strictly agree
on how to install Jekyll, and some of the advice relating to [Ruby], [RubyGems],
and [Bundler] did not seem appropriate for Fedora.

Some research and experimentation was required to find the best path forward.

[GitHub Guide]: https://help.github.com/en/github/working-with-github-pages/testing-your-github-pages-site-locally-with-jekyll
[Jekyll Guide]: https://jekyllrb.com/docs/installation/other-linux/
[Ruby]: https://www.ruby-lang.org/en/
[RubyGems]: https://rubygems.org
[Bundler]: https://bundler.io

### Local RubyGems

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

This make the `gem` command "just work" without the user having to change their
environment, but it uses different paths to those suggested by the [Jekyll
Guide].

I'm running Fedora and already have some "user installed" ruby gems, so if
I blindly follow the [Jekyll Guide], those gems are going to break. Not good.

[`operating_system.rb`]: https://gist.github.com/tartansandal/f82322f7928b786432ab600804cae73e

### Using Bundler

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
just like Python's `vitualenv` or Node's `node_modules`. You can make this the
default behaviour with

```shell
bundle config set path "vendor/bundle"
```

One advantage of localising installations this way is that you don't end up
polluting your environment with executables from random dependencies. These
could shadow system executables and cause unexpected problems. This does cost
some disk space (gems are not shared between projects) and some time (duplicated
gem downloads), but for me, the effect was small.

[Dependency Hell]: https://en.wikipedia.org/wiki/Dependency_hell

### Different installation methods

The [Jekyll Guide] suggests installing some system dependencies with

```shell
sudo dnf install ruby ruby-devel @development-tools
```

Then installing both Bundler and Jekyll as a normal user with

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

So if we have [Bundler] installed and a `Gemfile` containing

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

The final wrinkle is the following very useful `jekyll` sub-command:

```shell
jekyll new PATH
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
    └── 2020-01-20-welcome-to-jekyll.markdown
```

Note that the `Gemfile` even contains (commented out) instructions for
`github-pages` gem. Using this requires having Jekyll installed first though.

The key take away from all this is that the version of Jekyll used by our
project can (and probably will) be different from the version installed using
the `gem` command.  If this is the case, then we could just install the versions
of Bundler and Jekyll that come with the Fedora distribution:

```shell
sudo dnf install rubygems-bundler rubygems-jekyll
```

This would automatically take care of any dependencies and we wouldn't have to
worry about managing updates. The Fedora versions are relatively modern and
(after reading the respective Changelogs) seem to be appropriately stable.

[`github-pages`]: https://github.com/github/pages-gem

## Bootstrapping GitHub Pages

At this point I felt I had done enough research and experimentation to formulate
a reasonable plan.

First, I cloned the GitHub Pages repository I set up earlier in [Learning about
GitHub Pages](#learning-about-github-pages):

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

Next, I configured bundler to always install gems into a local `vendor/bundle`
directory so any projects would be self-contained:

```shell
bundle config set path "vendor/bundle"
```

I used the path `vendor/bundle` here to be consistent with standard [bundle
deployments] and because, that path is ignored by default when Jekyll processes
files. Note: this was a global setting and would affect all future uses of the
`bundle` command.

[bundle deployments]: https://andre.arko.net/2011/06/11/deploying-with-bundler-notes/

I could now generate some basic scaffolding with

```shell
jekyll new .
```

The generated `Gemfile` contained a lot comments and Windows specific tweaks, so
I stripped that back to

```ruby
source "https://rubygems.org"
gem "github-pages", group: :jekyll_plugins
```

I could now safely install all the required gems with

```shell
bundle install
```

and verify that they were all installed under `vendor/bundle/ruby`.  I didn't
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

Now I was ready to start working through the [Jekyll Docs] and developing
content for my blog.

## Blogging with Jekyll

The [Jekyll Docs] walked me through the details of building a Jekyll based site
from scratch.  This was not strictly necessary, but gave me a bit more insight
into what was going on.

### Processing files

The basic operation of Jekyll is to recursively process all the files in the
project and place the results in the `_site/` directory:

* Files or directories beginning with a `.` and `_` are excluded from direct
  processing.  Additional exclusions, and exceptions to those exclusions, are
  defined in the project's `exclude`, `include`, and `keep_files` lists.

* HTML, Markdown, and SCCS files containing YAML [front matter] are processed
  using the [Liquid] templating engine. This provides additional markup for the
  interpolation of "objects", "tags", and "filters", as well as flow control
  constructs.

* If a `layout` name is set in a file's front matter, then the corresponding
  layout template is used to wrap the file's content during processing.

* The content of Markdown files are converted to HTML (using `kramdown`) and the
  suffix of the resulting file is changed to `.html`

* The content of SCCS files are converted to CSS (using `sassc`) and the suffix
  of the resulting file is changed to `.css`

* All other files and directories are copied over verbatim.

Many aspects of this process can be modified via the project's [jekyll
configuration] file `_config.yml`.

Files under directories beginning with `_` provide additional "data" for use
during processing.  For example,

* `_include/` provides content fragments that can included in other files.

* `_layout/` provides layout templates (which make extensive use of content
  fragments).

* `_sass/` provides style definitions for converting SCCS files.

These three `_` directories, plus an additional `assets` directory, form the
project's "theme".

Themes generally make heavy use of [Jekyll Variables] via [Liquid] markup. For
example:

* the `site` variable for site wide information configurations settings.
* the `page` variable for page specific information and variables set in
  a page's front matter.
* the `content` variable for the rendered content being wrapped by a layout.

While themes can be defined locally, they are more often packaged and imported
as gems.  In this case, files from the theme gem are (right) merged with files
from the project, before the combined set of files are processed.  This allows
you to selectively override parts of a theme adding files with the same relative
path to your project--the project files shadow the gem files.  This helps to
keep your project uncluttered and makes it very easy to use sophisticated 3rd
party themes.  If the theme has been published on [RubyGems], then you can
simply add it to your `Gemfile`, set the corresponding theme name in
`_config.yml`, then all those files in that gem will become part of your next
build.

[Jekyll Variables]: https://jekyllrb.com/docs/variables/

### The default theme

The default gem-based theme used by Jekyll is "minima":

```console
$ tree vendor/bundle/ruby/2.6.0/gems/minima-2.5.1/
vendor/bundle/ruby/2.6.0/gems/minima-2.5.1/
├── assets
│   ├── main.scss
│   └── minima-social-icons.svg
├── _includes
│   ├── disqus_comments.html
│   ├── footer.html
│   ├── google-analytics.html
│   ├── header.html
│   ├── head.html
│   ├── icon-github.html
│   ├── icon-github.svg
│   ├── icon-twitter.html
│   ├── icon-twitter.svg
│   └── social.html
├── _layouts
│   ├── default.html
│   ├── home.html
│   ├── page.html
│   └── post.html
├── LICENSE.txt
├── README.md
└── _sass
    ├── minima
    │   ├── _base.scss
    │   ├── _layout.scss
    │   └── _syntax-highlighting.scss
    └── minima.scss
```

These are merged with the scaffolding files generated by the `jekyll new`
command:

```console
$ tree
.
├── 404.html
├── about.md
├── _config.yml
├── Gemfile
├── index.md
└── _posts
    └── 2020-01-20-welcome-to-jekyll.markdown
```

The combined set of files are processed as follows:

* `assets/main.scss` is compiled using the "minima" style defined in the themes
  `_sass` directory. This produces `_site/assets/main.css` and that file is
  referenced in the `head.html` fragment.

* `404.html` uses the "default" layout (which includes the `head.html`,
  `header.html` and `footer.html` fragments) to produce a well-formed HTML page
  at `_site/404.html`

* All the other layouts inherit the "default" layout to produce a consistent
  well-formed HTML pages.

* All Markdown files are compiled into well-formed HTML fragments before being
  wrapped in their respective layouts.

* `about.md` uses the "page" layout and sets the `permalink` property. The
  latter changes the destination file to `_site/about/index.html` so it can be
  linked to with the path `/about/`.

* `index.md` uses the "home" layout and the content of the `_post` directory
  (via a `site.posts` object) to form a listing of links to posts. This
  produces `_site/index.html`.

* `2020-01-20-welcome-to-jekyll.markdown` uses the "post" layout and variables
  set in the front matter (via the `page` object) to produce
  `/_site/jekyll/update/2020/01/20/welcome-to-jekyll.html`.

This can be personalised by setting the configuration variables `title`,
`author`, `email`, `description`, and `github_username`, and by replacing the
content of the `about.md` file.

The result is a simple, attractive, and functional blogging site--all from
simple `jekyll new` command.

### Posts and drafts

While [Jekyll] is great for generating many types of static sites, the default
theme and scaffolding are focused on producing blogs. This was what I was
really after.

The section above introduced the `_posts` data directory which is handled
specially. Files in this directory have a special naming convention:

```text
YEAR-MONTH-DAY-title.MARKUP
```

The `YEAR-MONTH-DAY` prefix corresponds to the intended publication date.  Posts
are sorted by this date and allows for authoring posts with a planned future
publication date.

The `title` is going to be
a [slugified](https://en.wikipedia.org/wiki/Clean_URL#Slug) version of the post's
title which we set in the pages front matter.

I'm plan to be primarily use Markdown for my posts, so I'll use the `md` suffix
for `MARKUP`. However, I may write some posts in [Asciidoctor] and manually
convert them to HTML, so the `html` suffix is also a possibility.

Individual post files require some minimal front matter:

```yaml
---
layout: posts
title: "Welcome to Jekyll!"
categories: jekyll update
---
```

The `categories` setting allows us to group related posts.  In particular it
changes the path part of the post's URL, for example, in the above the path is
changed to `/jekyll/update/2020/01/20/welcome-to-jekyll.html`.  This can be
useful for SEO, but does can make linking between posts more complicated. The
trick is to use the `post_url` tag to generate the correct path:

```liquid
{% raw %}{% post_url 2020-01-20-welcome-to-jekyll %}{% endraw %}
```

What about drafts?

Most of my posts are going to take a while to polish and I expect
be working on more than one post at a time. In this case I can use a `_drafts/`
directory to store draft posts. Drafts are not visible in production and are
only shown locally if you pass the `--drafts` option:

```shell
bundle exec jekyll serve --drafts
```

The naming convention is simpler as well:

```text
title.MARKUP
```

The `post.date` is automatically set to when the file was last changed on the
file. Once I'm happy with the post, I can move it to and appropriately named
file under `_posts`.

[kramdown]: https://kramdown.gettalong.org
[front matter]: https://jekyllrb.com/docs/step-by-step/03-front-matter/
[jekyll configuration]: https://jekyllrb.com/docs/configuration/
[jekyll posts]: https://jekyllrb.com/docs/posts/
[jekyll drafts]: https://jekyllrb.com/docs/posts/#drafts

## Wrapping things up

I was pretty happy with the default `minima` theme and it was simple enough to
edit the `_config.yml` file to change the blog title, description, and various
user details. I also made some minor [customizations][customizing minima]:

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

I had already been using git to track the development of this project and had
merged all my changes into the `master` branch. All I had to do was attach the
project to the `tartansandal.github.io` repository and push my changes:

```shell
git add remote origin git@github.com:tartansandal/tartansandal.github.io.git
git push --force
```

[customizing minima]: https://github.com/jekyll/minima#customizing-templates

## Conclusions

Setting up this blog has been fun and relatively easy.  I managed to achieve
really good results with minimum effort. There were some Fedora specific
wrinkles with setting up Jekyll, but I managed to find appropriate tweaks to the
Quick-start instructions:

```console
~ $ sudo dnf install rubygem-bundler rubygem-jekyll
~ $ bundle config set path vendor/bundle
~ $ jekyll new my-awesome-site
~ $ cd my-awsome-site
~/my-awsome-site $ bundle install
~/my-awsome-site $ bundle exec jekyll serve
# => Now browse to http://localhost:4000
```

The principle [GitHub Pages] documentation had improved significantly, but there
are still some issues.  The main contents page suggested a reasonable narrative,
but the individual articles lacked the navigation links to make that narrative
easy to follow.  There were many internal links pointing to very similar looking
pages and I had to keep going back to the contents page to make sure I hadn't
missed anything.  This may all be due to an accumulation of features over time
(GitHub Pages is not new) and I found some of the older guides are more
straight-forward.

The [Jekyll] documentation was especially good--very simple and direct--although
some of the more useful pages were a little hard to track down.

I hope you have found this post useful. Any mistakes or omission are my own.
Feel free to let me know about them in the comments.

## Guides

Some other useful guides I found a long the way:

* Jonathan McGlone's excellent [Creating and Hosting a Personal Site on GitHub](
  http://jmcglone.com/guides/github-pages/)

* Ben Balter's opinionated [Jekyll style guide](
  https://ben.balter.com/jekyll-style-guide/)

* Sylvain Durand's very straight-forward [Using GitHub to serve Jekyll](
  https://www.sylvaindurand.org/using-github-to-serve-jekyll/). This was the
  closest to the approach that I eventually ended up using.

* Jekyll's hard to find [Jekyll GitHub Pages](
  https://jekyllrb.com/docs/github-pages/).

* Tomasz Gałajs [How to schedule posts with Jekyll](
  https://shot511.github.io/2018-12-03-how-to-schedule-posts-with-jekyll/)

* Fizer Khan's [Working with upcoming posts in Jekyll](
  http://www.fizerkhan.com/blog/posts/Working-with-upcoming-posts-in-Jekyll.html)
