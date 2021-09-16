# Linting and fixing in Vim with Remark

The [`remark`](https://remark.js.org/) utility can be used to both highlight
style and formatting issues with your markdown and to automatically fix many of
them. Figuring out how to configure `remark` to work well with
[Vim](https://www.vim.org/) and [ALE](https://github.com/dense-analysis/ale) was
a bit challenging, so I thought I would share my setup and some tips.

First up, note that `remark` is a general framework for processing processing
Markdown and not just for converting it to HTML. It is built out of layered
components so that different parts can be used in different contexts. Some
relevant ones include.

* [`mdast`](https://github.com/syntax-tree/mdast): a specification for
  representing a variety of Markdown flavours in an Abstract Syntax Tree.

* [`mdast-util-from-markdown`](https://github.com/syntax-tree/mdast-util-from-markdown):
  a utility to parse Markdown to an AST.

* [`remark-parser`](https://github.com/remarkjs/remark/tree/main/packages/remark-parse):
  a parser that converts Markdown to an AST using the above.

* [`mdast-util-to-markdown`](https://github.com/syntax-tree/mdast-util-to-markdown):
  a utility to serialize `mdast` to Markdown.

* [`remark-stringify`](https://github.com/remarkjs/remark/tree/main/packages/remark-stringify):
  a serializer to convert an AST back into markdown using the above.

`remark-lint`: a library that examines an AST for issues based on plugins
`remark`: is a markdown processor powered by plugins and using the above
`unified`: a library for building configurable command-line interfaces
`remark-cli`: a command-line interface based on unified and remark

At various layers, support for additional markup and output (like footnotes,
directives, ToCs, GFM, MDX, etc) can be provided by extensions.

This can make understanding the setup and configuration a little confusing.

## Fixing Markdown

You can get an automatic "fixing" ability but simply installing
`remark-cli`:

```console
npm install -g remark-cli
``` 

To get the "fixing" to match your desired style, you just have to the formatting
otions.


to get all of the
above libraries installed plus a command-line utility called `remark`.  At this
stage you do not have any linting capabilities, but you do have a facility for
fixing many markdown formatting and style issues.  If you run `remark` command
on a markdown file, it will parse the content into an AST using
`mdast-util-from-markdown` and its then convert that AST back into text using
`mdast-util-to-markdown` and according to its default formatting options. The
output of this is probably going to be different from the input since the
stringification process is going to enforce a degree of consistency and the
default options may correspond to a different style of Markdown.

You can check out the available formatting options in the
[`mdast-util-to-markdown` documentation](https://github.com/syntax-tree/mdast-util-to-markdown#formatting-options).

## Linting Markdown

remark-lint-\*: (configurable) plugins focusing on individual issues

I thought I would share set up for this with Vim and ALE since.

I found this to be the case when I first installed.

ALE conveniently noticed this addition and automatically started highlighting errors in all my markdown files and my IDE was suddenly lit up like a Christmas tree.

remark framework

tuning remark

tuning to be general. leave target specific linting for pre-commit-hooks.

## Sidetracks

### Linting vs fixing

Asynchronous linting is good. Automatic fixing is better.

Having an IDE that highlights errors or warnings as you write can help to ensure that whatever you are writing or coding is coherent, provided the errors or warnings it reports are both relevant and correct. With Vim we can get access to excellent  asynchronous linting support via the [ALE](https://github.com/dense-analysis/ale) plugin which has integrations for a large number of 3rd party linting programs. Having your IDE constantly harass you about trivial errors can be distracting and fixing those errors immediately may be counter-productive

### Omitting references to micromark
