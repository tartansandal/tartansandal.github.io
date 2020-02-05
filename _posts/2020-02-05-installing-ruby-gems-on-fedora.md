---
layout: post
title: Installing Ruby "gems" as a normal user on Fedora
categories: fedora ruby
comments: true
---

There are some unexpected and problematic wrinkles around installing user local
Ruby "gems" on Fedora and setting `GEM_HOME` appropriately.

Setting up local user installation is not normally something Fedora users have
to worry about, since the distribution has tweaked the [RubyGems] package so the
`gem` command automatically performs a local user install when run by a normal
user.  In particular,

* Gems are installed under `~/.gem/ruby`
* Executable files are installed under `~/bin`

See [`operating_system.rb`] for all the gory details.

Ostensibly, this is to make the `gem` command "just work" without the user
having to change their environment.  This is all well and good until it breaks
something.

If you don't know about this automatic behaviour, you may have already installed
some user local gems without realizing it.  For example, you might run

```bash
gem install asciidoctor
```

to install a local version of [Asciidoctor].  You won't get a `sudo` prompt or
permission errors, and the new `asciidoctor` program will be in your path and
"just work".

You could even do something "crazy" like this:

``` bash
gem install bundler
```

[Bundler] is a popular approach to managing collections of potentially
conflicting versions of Ruby "gems".

Why is this "crazy?

The newly installed `bundle` command is not affected by Fedoras tweaking of the
`gem` command. For example, if you try to use [Bundler] to install [Jekyll]
with

``` bash
echo "source 'https://rubygems.org'" > Gemfile
echo "gem 'jekyll'" >> Gemfile
bundle install
```

you get write permission errors on the `/usr/bin` and `/usr/share/gems`
directory, since Bundler is trying to perform a system installation.

This is unexpected.

A typical web search will yield an extremely common piece of advice for setting
up local user installs. Simply put the following in your `~/.bashrc` file:

``` bash
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
```

If you do this, and run either the `gem` or `bundler` command as a normal user,
then

* Gems will be installed under `~/gem/ruby`
* Executable files will be installed under `~/gem/bin`

This is probably appropriate for Ubuntu and many other Linux systems, but the
paths are wrong for the default Fedora.  If we don't correct that, then `bunder`
and `gem` are going to install to different locations.

We could (blindly) follow the above advice to get bundler to work. If we then run

``` bash
gem install jekyll
```

a second version of [Jekyll] is installed under `~/.gem/ruby`, but the `jekyll`
command still uses the original one under `~/gems`.  This is unexpected.
Similar confusion arises with the `gem uninstall` command.


Initially this is fine, but becomes problematic as the versions of the
dependencies diverge, and can take a while to sort out, especially if you are
installing many user local gems over a long time.

To get mutually compatible behaviour on Fedora, simply add the following to your
bash configuration:

``` bash
# Install Ruby Gems to the default Fedora locations
export GEM_HOME=$HOME/.gem/ruby
if [[ ! -e $HOME/.gem/ruby/bin ]]
then
    ln -s $HOME/bin $HOME/.gem/ruby/
fi
```

Your `~/.bash_profile` is probably a more sensible place to put this, rather than
`.bashrc`, since the former only gets sourced once on login, whereas the latter
gets sourced for every sub-shell.

[`operating_system.rb`]: https://gist.github.com/tartansandal/f82322f7928b786432ab600804cae73e#file-operating_system-rb-L95
[RubyGems]: https://rubygems.org
[Bundler]: https://bundler.io
[Asciidoctor]: https://asciidoctor.org
[Jekyll]: https://jekyllrb.com
