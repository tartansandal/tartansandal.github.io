---
layout: post
categories: vim markdown remark
comments: true

title: "Linting and Fixing in Vim with Remark"
---

The [Remark][] utility can be used to highlight issues with your [Markdown][]
files and to automatically fix many of them.  Figuring out how to configure
[Remark][] to work well with [Vim][] and [ALE][] was a bit of a challenge, so
I thought I would share my setup plus some tips.

## TL;DR

```yaml
settings:
  rule: '-'
  fences: true
  listItemIndent: one

plugins:
  - remark-gfm

  - remark-preset-lint-recommended
  - remark-preset-lint-markdown-style-guide

  - - remark-lint-list-item-indent
    - space

  - - remark-lint-ordered-list-marker-value
    - ordered

  - remark-lint-strikethrough-marker
  - remark-lint-checkbox-content-indent

  - - remark-lint-checkbox-character-style
    - {checked: 'x', unchecked: ' '}

  - remark-lint-linebreak-style

  - - remark-lint-unordered-list-marker-style
    - '*'

  - - remark-lint-no-missing-blank-lines
    - exceptTightLists: true

  - - remark-lint-link-title-style
    - false

  - remark-lint-first-heading-level
  - remark-lint-no-heading-indent
  - remark-lint-no-heading-like-paragraph
  - remark-lint-no-duplicate-headings-in-section
  - remark-lint-no-paragraph-content-indent
```

## Linting vs Fixing

Not all Markdown is created equal. It is quite easy to create Markdown that is
either confusing in its raw form or which produces unexpected results when
converted to HTML.

We can try to address this problem by following a set of rules like the
[Markdown Style Guide][]. Moreover, there exist automated "linting" facilities
like [Remark][] that can warn us when we stray from these rules.

Some "linting" warnings identify inconsistencies or errors that don't require
any user decisions or input to resolve. For example, warnings about using the
incorrect bullet marker or consecutive newlines.  These warnings lend themselves
to automated "fixing", a process also supported by [Remark][].

In [Remark][], "linting" and "fixing" are two separate processes with separate
configurations.  Since I want to use both processes in [Vim][], I needed to find
complimentary, or at least non-conflicting, configurations.  In particular, I'll
need to ensure that:

1. The "fixing" routine only fixes the problems that I want it to fix. I don't
   want this routine to, say, backslash all the square brackets in my carefully
   laid out checkbox tasklist.

2. The "linting" routine highlights most (if not all) of the issues that are
   fixed by the "fixing" routine -- providing a preview of what the "fixing
   routine is going to change". I don't want the "fixing" routine to introduce
   unexpected changes.

3. The "fixing" routine does not (re)introduce Markdown that is just going
   trigger a "linting" warning. I don't want it to, say, convert all my
   unordered lists to use `-` if the "linting" routine is going to insists I use
   `*` characters.

## Where to start?

[Remark][] is a general framework for processing Markdown and not just
for converting it to HTML.  It is built out of layered components so that
different parts can be used in different contexts. Some relevant ones include:

* [`mdast`][mdast]: a specification for representing a various Markdown flavours
  in an Abstract Syntax Tree.

* [`mdast-util-from-markdown`][mdast-util-from-markdown]: a utility to parse
  Markdown to an AST.

* [`remark-parse`][remark-parse]: a parser and compiler that converts Markdown
  to an AST using the above.

* [`mdast-util-to-markdown`][mdast-util-to-markdown]: a utility to serialize
  `mdast` to Markdown.

* [`remark-stringify`][remark-stringify]: a serializer to convert an AST back
  into markdown using the above.

* [`remark-lint`][remark-lint]: a library that examines an AST for issues based
  on plugins.

* [`remark`][remark-package]: is a markdown processor powered by plugins and
  using all the above.

* [`unified-engine`][unified-engine]: a framework for processing files and
  configurations.

* [`unified-args`][unified-args]: a framework for building command-line tools.

* [`unified`][unified]: a framework for building text processing tools using the
  above.

* [`remark-cli`][remark-cli]: a command-line interface based on `unified` and
  `remark`

Support for additional markup and output (like footnotes, frontmatter,
directives, ToCs, GFM, MDX) is provided by various [plugins][remark-plugins].

For [ALE][] integration with [Vim][], I needed a command line interface, so the
last package in the above stack was what I wanted.

```console
npm install -g remark-cli
```

This gave me a `remark` command, installed in a user-global context, which
I could use on arbitrary Markdown files.

Unfortunately, the documentation for [Remark][] is spread across all of the
above packages and I found that understanding the application and its plugins,
plus all the relevant settings and configuration options, required tracking
through a lot of cross-references.

## Fixing Markdown

Out of the box, the `remark` command gives us an automatic fixing utility.
When you run it on a Markdown file, it will parse the content into an AST using
[`remark-parse`][remark-parse], then serializes that AST back into text using
[`remark-stringify`][remark-stringify]. The result is usually a more strictly
formatted version of the original Markdown, with things like bullet characters
and block spacing being applied consistently.

Various details of this "reformatting" can be controlled by settings passed to
the serializer (see [`mdast-util-to-markdown`][mdast-util-to-markdown] for
details).  The defaults for most settings are reasonable and avoid many
issues. Of particular note are the following settings which minimize ambiguity
and seem to give stable behaviour:

```yaml
bullet: '*'
bulletOrdered: '.'
emphasis: '*'
strong: '*'
fence: '`'
quote: '"'
```

The only ones I ended up changing from the default where:

```yaml
rule: '-'
fences: true
listItemIndent: one
```

Using `-` instead of `*` for a rule marker helps avoid a couple of edge cases
where the intent is ambiguous.  Always using fences for code blocks, and
a single space after bullets, enforces a consistency that matches well with the
available linting rules.

This formatting can also be influenced by [plugins][remark-plugins] which extend
the parser and compiler.  

Since I often use Markdown tables (an extension to [Commonmark][] provided by
[Github Flavoured Markdown][gfm]), I added the [`remark-gfm`][remark-gfm] plugin
so that the fixing routine will ensure my table columns are nicely padded and
aligned.  I also get support for checkboxes (which I occasionally use) and
strike-through markers (which I seldom use). There are some options to this
module, but the defaults seem to work well.  

As you will see below, there are corresponding linting rules that highlight
issues with the GFM extensions.  These rules have to be loaded *after* the
plugin since they require the content to be appropriately parsed before it can
be interpreted by the linting routines. 

## Linting Markdown

At this stage, despite having a `remark-lint` module installed, I did not have
any linting capabilities. This is because `remark-lint` passes off all the
actual linting to configurable plugins that target specific errors or
warnings. These must be installed and loaded before any linting can occur.

There are currently 67 [official rule][remark-lint rules] plugins covering
common issues.  In addition, [Remark][] provides 3 preset "meta" packages that load and configure commonly used combinations:

* [`remark-preset-lint-consistent`][remark-preset-lint-consistent]: rules that
  enforce consistency

* [`remark-preset-lint-recommended`][remark-preset-lint-recommended]: rules that
  prevent mistakes or stuff that fails across vendors.

* [`remark-preset-lint-markdown-style-guide`][remark-preset-lint-markdown-style-guide]:
  rules that enforce the [Markdown Style Guide][]

The table below shows some of the relationships between the different rules and
presets.  I've omitted the `remark-lint-` prefix and used the following
key to keep the table compact.

* **MSG**: Rules provided by the Markdown Style Guide preset
* **Con**: Rules provided by the Consistent preset
* **Rec**: Rules provided by the Recommended preset
* **GFM**: Rules that require the Github Flavoured Markdown plugin
* **Fix**: Rules that are "fixed" by the serializer

| Plugin                                                                               | MSG | Con | Rec | GFM | Fix |
| ------------------------------------------------------------------------------------ | --- | --- | --- | --- | --- |
| [`definition-case`][remark-lint-definition-case]                                     | X   |     |     |     |     |
| [`fenced-code-flag`][remark-lint-fenced-code-flag]                                   | X   |     |     |     |     |
| [`file-extension`][remark-lint-file-extension]                                       | X   |     |     |     |     |
| [`final-definition`][remark-lint-final-definition]                                   | X   |     |     |     |     |
| [`maximum-heading-length`][remark-lint-maximum-heading-length]                       | X   |     |     |     |     |
| [`maximum-line-length`][remark-lint-maximum-line-length]                             | X   |     |     |     |     |
| [`no-duplicate-headings`][remark-lint-no-duplicate-headings]                         | X   |     |     |     |     |
| [`no-emphasis-as-heading`][remark-lint-no-emphasis-as-heading]                       | X   |     |     |     |     |
| [`no-file-name-articles`][remark-lint-no-file-name-articles]                         | X   |     |     |     |     |
| [`no-file-name-consecutive-dashes`][remark-lint-no-file-name-consecutive-dashes]     | X   |     |     |     |     |
| [`no-file-name-irregular-characters`][remark-lint-no-file-name-irregular-characters] | X   |     |     |     |     |
| [`no-file-name-mixed-case`][remark-lint-no-file-name-mixed-case]                     | X   |     |     |     |     |
| [`no-file-name-outer-dashes`][remark-lint-no-file-name-outer-dashes]                 | X   |     |     |     |     |
| [`no-heading-punctuation`][remark-lint-no-heading-punctuation]                       | X   |     |     |     |     |
| [`no-multiple-toplevel-headings`][remark-lint-no-multiple-toplevel-headings]         | X   |     |     |     |     |
| [`no-shell-dollars`][remark-lint-no-shell-dollars]                                   | X   |     |     |     |     |
| [`definition-spacing`][remark-lint-definition-spacing]                               | X   |     |     |     | X   |
| [`list-item-spacing`][remark-lint-list-item-spacing]                                 | X   |     |     |     | X   |
| [`no-consecutive-blank-lines`][remark-lint-no-consecutive-blank-lines]               | X   |     |     |     | X   |
| [`ordered-list-marker-value`][remark-lint-ordered-list-marker-value]                 | X   |     |     |     | X   |
| [`no-table-indentation`][remark-lint-no-table-indentation]                           | X   |     |     | X   | X   |
| [`table-pipes`][remark-lint-table-pipes]                                             | X   |     |     | X   | X   |
| [`table-pipe-alignment`][remark-lint-table-pipe-alignment]                           | X   |     |     | X   | X   |
| [`table-cell-padding`][remark-lint-table-cell-padding]                               | X   | X   |     | X   | X   |
| [`blockquote-indentation`][remark-lint-blockquote-indentation]                       | X   | X   |     |     | X   |
| [`emphasis-marker`][remark-lint-emphasis-marker]                                     | X   | X   |     |     | X   |
| [`fenced-code-marker`][remark-lint-fenced-code-marker]                               | X   | X   |     |     | X   |
| [`code-block-style`][remark-lint-code-block-style]                                   | X   | X   |     |     | X   |
| [`heading-style`][remark-lint-heading-style]                                         | X   | X   |     |     | X   |
| [`link-title-style`][remark-lint-link-title-style]                                   | X   | X   |     |     | X+  |
| [`list-item-content-indent`][remark-lint-list-item-content-indent]                   | X   | X   |     |     | X   |
| [`rule-style`][remark-lint-rule-style]                                               | X   | X   |     |     | X   |
| [`strong-marker`][remark-lint-strong-marker]                                         | X   | X   |     |     | X   |
| [`ordered-list-marker-style`][remark-lint-ordered-list-marker-style]                 | X   | X   | X   |     | X   |
| [`hard-break-spaces`][remark-lint-hard-break-spaces]                                 | X   |     | X   |     | X   |
| [`list-item-indent`][remark-lint-list-item-indent]                                   | X   |     | X   |     | X   |
| [`no-auto-link-without-protocol`][remark-lint-no-auto-link-without-protocol]         | X   |     | X   |     | X   |
| [`no-blockquote-without-marker`][remark-lint-no-blockquote-without-marker]           | X   |     | X   |     | X   |
| [`no-literal-urls`][remark-lint-no-literal-urls]                                     | X   |     | X   |     | X   |
| [`no-shortcut-reference-image`][remark-lint-no-shortcut-reference-image]             | X   |     | X   |     | X   |
| [`no-shortcut-reference-link`][remark-lint-no-shortcut-reference-link]               | X   |     | X   |     | X   |
| [`list-item-bullet-indent`][remark-lint-list-item-bullet-indent]                     |     |     | X   |     | X   |
| [`final-newline`][remark-lint-final-newline]                                         |     |     | X   |     | X   |
| [`no-heading-content-indent`][remark-lint-no-heading-content-indent]                 |     |     | X   |     | X   |
| [`no-undefined-references`][remark-lint-no-undefined-references]                     |     |     | X   |     |     |
| [`no-unused-definitions`][remark-lint-no-unused-definitions]                         |     |     | X   |     |     |
| [`no-duplicate-definitions`][remark-lint-no-duplicate-definitions]                   |     |     | X   |     |     |
| [`no-inline-padding`][remark-lint-no-inline-padding]                                 |     |     | X   |     |     |
| [`heading-increment`][remark-lint-heading-increment]                                 | X   |     |     |     |     |
| [`checkbox-character-style`][remark-lint-checkbox-character-style]                   |     | X   |     | X   | X   |
| [`checkbox-content-indent`][remark-lint-checkbox-content-indent]                     |     |     |     | X   | X   |
| [`strikethrough-marker`][remark-lint-strikethrough-marker]                           |     |     |     | X   | X   |
| [`unordered-list-marker-style`][remark-lint-unordered-list-marker-style]             |     |     |     |     | X   |
| [`linebreak-style`][remark-lint-linebreak-style]                                     |     |     |     |     | X   |
| [`no-missing-blank-lines`][remark-lint-no-missing-blank-lines]                       |     |     |     |     | X   |
| [`first-heading-level`][remark-lint-first-heading-level]                             |     |     |     |     |     |
| [`no-duplicate-defined-urls`][remark-lint-no-duplicate-defined-urls]                 |     |     |     |     |     |
| [`no-duplicate-headings-in-section`][remark-lint-no-duplicate-headings-in-section]   |     |     |     |     |     |
| [`no-empty-url`][remark-lint-no-empty-url]                                           |     |     |     |     |     |
| [`no-heading-indent`][remark-lint-no-heading-indent]                                 |     |     |     |     |     |
| [`no-heading-like-paragraph`][remark-lint-no-heading-like-paragraph]                 |     |     |     |     |     |
| [`no-html`][remark-lint-no-html]                                                     |     |     |     |     |     |
| [`no-paragraph-content-indent`][remark-lint-no-paragraph-content-indent]             |     |     |     |     |     |
| [`no-reference-like-url`][remark-lint-no-reference-like-url]                         |     |     |     |     |     |
| [`no-tabs`][remark-lint-no-tabs]                                                     |     |     |     |     |     |
| [`no-unneeded-full-reference-image`][remark-lint-no-unneeded-full-reference-image]   |     |     |     |     |     |
| [`no-unneeded-full-reference-link`][remark-lint-no-unneeded-full-reference-link]     |     |     |     |     |     |

You can see from the above table that many of issues raised by these linting
rules can be automatically resolved by the serializer.  Noting the overlap of
the MSG and Recommended presets with the rules that are automatically fixed by
the serializer, I realized I could get a reasonably compact rule set by
including those two presets, the GFM plugin, and just six extra rules.  This also
included some rules that could not be fixed by the serializer,  but they all
seemed to be sensible enough and I had no problems including them.

Fortunately the default linting rule settings, the MSG preset overrides, and the
default serializer settings, were fairly complimentary, and there were only
a couple of instances where I had to override settings to get the desired
behaviour.  The following is a trimmed down version of the configuration that
I use.  The [full version][my-remarkrc] includes detailed comments on all the
official rules as a quick reference in case I need to tweak anything.

```yaml
settings:
  rule: '-'
  fences: true
  listItemIndent: one

plugins:
  - remark-gfm

  - remark-preset-lint-recommended
  - remark-preset-lint-markdown-style-guide

  - - remark-lint-list-item-indent
    - space

  - - remark-lint-ordered-list-marker-value
    - ordered

  - remark-lint-strikethrough-marker
  - remark-lint-checkbox-content-indent

  - - remark-lint-checkbox-character-style
    - {checked: 'x', unchecked: ' '}

  - remark-lint-linebreak-style

  - - remark-lint-unordered-list-marker-style
    - '*'

  - - remark-lint-no-missing-blank-lines
    - exceptTightLists: true
```

In the above, I override the preset rule settings by loading the associated rule
with the desired settings *after* the preset has been loaded.

Unfortunately there was one rule that I could not configure to consistently
match the serializer output:
[`link-title-style`][remark-lint-link-title-style]. Since this was loaded via
the MSG preset, I ended up suppressing this rule by explicitly setting it to
`false`.

```yaml
  - - remark-lint-link-title-style
    - false
```

What about the rest of the rules?

Getting headings and sections wrong while I'm writing is going to upset my
composition, and fixing them could require significant rework, so I like to keep
these under control at by adding the following rules:

```yaml
  - remark-lint-first-heading-level
  - remark-lint-no-heading-indent
  - remark-lint-no-heading-like-paragraph
  - remark-lint-no-duplicate-headings-in-section
  - remark-lint-no-paragraph-content-indent
```

While all of the rules have some benefit, loading too many can slow down the
linting routine while you are editing, so I relegated any additional rules to
post-commit and CI hooks.

To use the rules mentioned above I had to install a few packages:

```bash
npm install -g                                   \
    remark-gfm                                   \
    remark-preset-lint-recommended               \
    remark-preset-lint-markdown-style-guide      \
    remark-lint-list-item-indent                 \
    remark-lint-ordered-list-marker-value        \
    remark-lint-strikethrough-marker             \
    remark-lint-checkbox-content-indent          \
    remark-lint-checkbox-character-style         \
    remark-lint-linebreak-style                  \
    remark-lint-unordered-list-marker-style      \
    remark-lint-no-missing-blank-lines           \
    remark-lint-link-title-style                 \
    remark-lint-first-heading-level              \
    remark-lint-no-heading-indent                \
    remark-lint-no-heading-like-paragraph        \
    remark-lint-no-duplicate-headings-in-section \
    remark-lint-no-paragraph-content-indent
```

## Configuration

Configuration for `remark` is handled by [`unified-engine`][unified-engine]
framework. This supports configuration files in multiple formats and a search up
the file-system hierarchy. The current directory is searched for a file named
either

* `.remarkrc` (JSON), or
* `.remarkrc.js` (JS), or
* `.remarkrc.yml` (YAML).

If a matching file is not found, the parent directory is searched, and so on.
With this setup, you can have optional project level configurations and
a catch-all configuration in, say, your home directory.  Note that if a lower
level configuration file is found, the search stops and any higher level
configuration files are ignored, so there is no convenient merging of
configurations.

The documentation suggests there is a "configuration cascade" and that settings
may be extended or overridden, but unfortunately, it does not include any
details.  After some experiments and some code diving, it seems this cascade
does not work for many of the linting rules and so its not very useful for us.

## Integrating with Vim via ALE

If you install `remark-cli`, [ALE][] will automatically detect it and start
linting accordingly. If you run `:ALEInfo`, you will see "remark_lint" in the
list of "Available Linters". 

> There is some term juggling going on here. [ALE][] refers to both the "fixer"
> and the "linter" as "remark-lint" (possibly for historical reasons). But note
> that the `g:ale_markdown_remark_lint_executable` variable is set to
> `remark`, so "remark-lint" is the one that we want, and it will use the right
> command.

You can configure [ALE][] to use `remark-lint` as a "fixer" via a global
setting, but I prefer do this via a buffer local setting in
`~/.vim/ftplugin/markdown.vim`:

```viml
let b:ale_fixers=['remark-lint']
```

I also explicitly limit [ALE][] to using `remark-lint` because I don't
want other installed "linters" being picked up and confusing my set up.

```viml
let b:ale_linters=['remark-lint']
```

Finally, I have `ALEFix` bound to `\f` as part of my global `.vimrc` so fixing my
buffer is only two key strokes away:

```viml
nmap <silent> <leader>f <Plug>(ale_fix)
```

### Local overrides

If you are working on a project that uses `remark` as part of its testing/CI
chain, [ALE][] will usually detect this and use the corresponding configuration.
This may not work well if the linting process takes too long, so you may want to
tweak the "live" linting to omit some plugins.

If you use [localvimrc][] files, you could override a plugin with:

```viml
let b:ale_markdown_remark_lint_options = '-u remark-lint-no-html=false'
```

Or you could force the use of the global executable and configuration with

```viml
let b:ale_markdown_remark_lint_use_global = 1
let b:ale_markdown_remark_lint_options = '-r ~/.remarkrc'
```

At the time of writing, very few of the linting plugins support passing in
settings via the command line (PRs pending). Until that is fixed, the only way
to alter the settings for an existing rule is to use an edited copy of the whole
configuration file.

### No Tabs

One of the potential linting rules, [`no-tabs`][remark-lint-no-tabs], warns
about using raw tab characters. With [Vim][] I avoid needing to use this rule
by adding the following lines to my `~/.vim/ftplugin/markdown.vim` file:

```viml
setlocal tabstop=2
setlocal shiftwidth=2
setlocal shiftround       " Indent/outdent to nearest tabstop
setlocal expandtab        " Convert all tabs typed to spaces
```

This makes it pretty difficult to accidentally enter a tab character unless
I explicitly want to (say, for a Makefile snippet).

### Long lines

One issue that often arises is whether or not to wrap long lines. The Markdown
Style Guide suggests doing this at 80 chars, but some markdown processors (like
GitLab) interpret these as hard-breaks rather than re-flowing the text as
expected (the specification says you need 2 spaces or a backslash at the end of
a line for a hard-break).

I avoid this issue (and many arguments with other developers) by disabling the
[`maximum-line-length`][remark-lint-maximum-line-length] plugin in my
`remarkrc.yml` with

```yaml
  - - remark-lint-maximum-line-length
    - false
```

and adding the following settings to my `~/.vim/ftplugin/markdown.vim`:

```viml
setlocal linebreak        " Wrap long lines at word boundaries
setlocal formatoptions-=t " Dont auto-wrap text using textwidth
setlocal columns=80       " Constrain window width to trigger soft wrap
" ^ increase this if you use number or error columns
```

This gives me reasonable soft-wrapping behaviour and makes editing Markdown
files with very long lines bearable.

## Conclusion

Once I worked out all the wrinkles, I found [Remark][] to a valuable addition to
my linting setup with [Vim][]. It has certainly has been catching many errors while writing this blog. 

Having the live feedback has helped to train me away from using bad Markdown and to avoid creating structures that were not going to work in the long-run.

Having an automated fixing routine has meant I could temporarily ignore linting
warnings, since I knew I could easily fix them in bulk later.  A great example
of this is fixing the padding for large GFM tables. 

Knowing that linting was always there has meant I could, say, ignore tracking
down a reference until I was sure I was going to keep the sentence that
contained it.  I could use the linting warnings as a kind of automatic TODO list
of issues I needed to fix up at some point.

Anyway, I hope you have found this useful. Please feel free to leave any
comments or corrections below.

<!-- References -->

[commonmark]: https://commonmark.org

[gfm]: https://github.github.com/gfm/

[markdown style guide]: https://cirosantilli.com/markdown-style-guide/

[markdown]: https://en.wikipedia.org/wiki/Markdown

[my-remarkrc]: https://github.com/tartansandal/dotfiles/blob/master/remarkrc.yml

[localvimrc]: https://github.com/embear/vim-localvimrc

[vim]: https://www.vim.org/

[ale]: https://github.com/dense-analysis/ale

[remark-lint rules]: https://github.com/remarkjs/remark-lint/blob/main/doc/rules.md#list-of-rules

[remark]: https://remark.js.org/

[mdast]: https://github.com/syntax-tree/mdast

[mdast-util-from-markdown]: https://github.com/syntax-tree/mdast-util-from-markdown

[mdast-util-to-markdown]: https://github.com/syntax-tree/mdast-util-to-markdown

[remark-parse]: https://github.com/remarkjs/remark/tree/main/packages/remark-parse

[remark-stringify]: https://github.com/remarkjs/remark/tree/main/packages/remark-stringify

[remark-lint]: https://github.com/remarkjs/remark-lint

[remark-package]: https://github.com/remarkjs/remark/tree/main/packages/remark

[remark-plugins]: https://github.com/remarkjs/awesome-remark#plugins

[remark-gfm]: https://github.com/remarkjs/remark-gfm

[unified]: https://github.com/unifiedjs/unified

[unified-args]: https://github.com/unifiedjs/unified-args

[unified-engine]: https://github.com/unifiedjs/unified-engine

[remark-cli]: https://github.com/remarkjs/remark/tree/main/packages/remark-cli

[remark-preset-lint-consistent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-preset-lint-consistent

[remark-preset-lint-recommended]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-preset-lint-recommended

[remark-preset-lint-markdown-style-guide]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-preset-lint-markdown-style-guide

[remark-lint-blockquote-indentation]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-blockquote-indentation

[remark-lint-checkbox-character-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-checkbox-character-style

[remark-lint-checkbox-content-indent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-checkbox-content-indent

[remark-lint-code-block-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-code-block-style

[remark-lint-definition-case]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-definition-case

[remark-lint-definition-spacing]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-definition-spacing

[remark-lint-emphasis-marker]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-emphasis-marker

[remark-lint-fenced-code-flag]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-fenced-code-flag

[remark-lint-fenced-code-marker]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-fenced-code-marker

[remark-lint-file-extension]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-file-extension

[remark-lint-final-definition]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-final-definition

[remark-lint-final-newline]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-final-newline

[remark-lint-first-heading-level]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-first-heading-level

[remark-lint-hard-break-spaces]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-hard-break-spaces

[remark-lint-heading-increment]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-heading-increment

[remark-lint-heading-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-heading-style

[remark-lint-linebreak-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-linebreak-style

[remark-lint-link-title-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-link-title-style

[remark-lint-list-item-bullet-indent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-bullet-indent

[remark-lint-list-item-content-indent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-content-indent

[remark-lint-list-item-indent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-indent

[remark-lint-list-item-spacing]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-spacing

[remark-lint-maximum-heading-length]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-maximum-heading-length

[remark-lint-maximum-line-length]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-maximum-line-length

[remark-lint-no-auto-link-without-protocol]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-auto-link-without-protocol

[remark-lint-no-blockquote-without-marker]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-blockquote-without-marker

[remark-lint-no-consecutive-blank-lines]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-consecutive-blank-lines

[remark-lint-no-duplicate-defined-urls]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-defined-urls

[remark-lint-no-duplicate-definitions]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-definitions

[remark-lint-no-duplicate-headings-in-section]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-headings-in-section

[remark-lint-no-duplicate-headings]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-headings

[remark-lint-no-emphasis-as-heading]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-emphasis-as-heading

[remark-lint-no-empty-url]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-empty-url

[remark-lint-no-file-name-articles]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-articles

[remark-lint-no-file-name-consecutive-dashes]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-consecutive-dashes

[remark-lint-no-file-name-irregular-characters]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-irregular-characters

[remark-lint-no-file-name-mixed-case]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-mixed-case

[remark-lint-no-file-name-outer-dashes]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-outer-dashes

[remark-lint-no-heading-content-indent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-content-indent

[remark-lint-no-heading-indent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-indent

[remark-lint-no-heading-like-paragraph]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-like-paragraph

[remark-lint-no-heading-punctuation]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-punctuation

[remark-lint-no-html]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-html

[remark-lint-no-inline-padding]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-inline-padding

[remark-lint-no-literal-urls]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-literal-urls

[remark-lint-no-missing-blank-lines]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-missing-blank-lines

[remark-lint-no-multiple-toplevel-headings]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-multiple-toplevel-headings

[remark-lint-no-paragraph-content-indent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-paragraph-content-indent

[remark-lint-no-reference-like-url]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-reference-like-url

[remark-lint-no-shell-dollars]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-shell-dollars

[remark-lint-no-shortcut-reference-image]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-shortcut-reference-image

[remark-lint-no-shortcut-reference-link]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-shortcut-reference-link

[remark-lint-no-table-indentation]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-table-indentation

[remark-lint-no-tabs]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-tabs

[remark-lint-no-undefined-references]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-undefined-references

[remark-lint-no-unneeded-full-reference-image]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-unneeded-full-reference-image

[remark-lint-no-unneeded-full-reference-link]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-unneeded-full-reference-link

[remark-lint-no-unused-definitions]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-unused-definitions

[remark-lint-ordered-list-marker-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-ordered-list-marker-style

[remark-lint-ordered-list-marker-value]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-ordered-list-marker-value

[remark-lint-rule-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-rule-style

[remark-lint-strikethrough-marker]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-strikethrough-marker

[remark-lint-strong-marker]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-strong-marker

[remark-lint-table-cell-padding]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-table-cell-padding

[remark-lint-table-pipe-alignment]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-table-pipe-alignment

[remark-lint-table-pipes]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-table-pipes

[remark-lint-unordered-list-marker-style]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-unordered-list-marker-style
