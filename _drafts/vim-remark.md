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

* [`micromark`](https://github.com/micromark/micromark): the smallest commonmark-compliant markdown parser that exists.

* [`mdast-util-from-markdown`](https://github.com/syntax-tree/mdast-util-from-markdown):
  a utility to parse Markdown to an AST.

* [`remark-parser`](https://github.com/remarkjs/remark/tree/main/packages/remark-parse):
  a parser that converts Markdown to an AST using the above.

* [`mdast-util-to-markdown`](https://github.com/syntax-tree/mdast-util-to-markdown):
  a utility to serialize `mdast` to Markdown.

* [`remark-stringify`](https://github.com/remarkjs/remark/tree/main/packages/remark-stringify):
  a serializer to convert an AST back into markdown using the above.

* [`remark-lint`](): a library that examines an AST for issues based on plugins

* [`remark`](): is a markdown processor powered by plugins and using all the above.

* [`unified`](): a library for building configurable command-line interfaces

* [`remark-cli`](): a command-line interface based on `unified` and `remark`

At various layers, support for additional markup and output (like footnotes,
directives, ToCs, GFM, MDX, etc) can be provided by [plugins](https://github.com/remarkjs/remark/blob/main/doc/plugins.md#plugins).

This can make understanding the setup and configuration a little confusing.

## Fixing Markdown

You can get an automatic "fixing" ability but simply installing `remark-cli`:

```console
npm install -g remark-cli
```

With that get all of the above libraries installed plus a command-line utility called `remark`.

When you run this `remark` command on a markdown file, it will parse the content
into an AST using `mdast-util-from-markdown` and its then convert that AST back
into text using `mdast-util-to-markdown` and according to its default formatting
options.  To get this "fixing" to match your desired style, you just have to the
formatting otions.

You can check out the available formatting options in the
[`mdast-util-to-markdown` documentation](https://github.com/syntax-tree/mdast-util-to-markdown#formatting-options) and my settings in the Configuration section below.

## Linting Markdown

At this stage, despite having a `remark-lint` module installed, you do not have
any linting capabilities. This is because `remark-lint` passes off all the
actual linting to configurable plugins that target specific errors or
warnings. These must be installed and loaded before any linting can occur.

There are a set of 67 [official plugins](https://github.com/remarkjs/remark-lint/blob/main/doc/rules.md#list-of-rules) covering common rules, plus 3 preset packages that load commonly used
combinations of of the official plugins:

* `remark-preset-lint-consistent`: rules that enforce consistency
* `remark-preset-lint-recommended`: rules that prevent mistakes or stuff that fails across vendors.
* `remark-preset-lint-markdown-style-guide`: rules that enforce the markdown style guide

|                                                   |  C  |  R  | MSG |
|---------------------------------------------------|-----|-----|-----|
| [`remark-lint-blockquote-indentation`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-blockquote-indentation)              |  X  |     |  X  |
| [`remark-lint-checkbox-character-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-checkbox-character-style)            |  X  |     |     |
| [`remark-lint-code-block-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-code-block-style)                    |  X  |     |  X  |
| [`remark-lint-definition-case`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-definition-case)                     |     |     |  X  |
| [`remark-lint-definition-spacing`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-definition-spacing)                  |     |     |  X  |
| [`remark-lint-emphasis-marker`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-emphasis-marker)                     |  X  |     |  X  |
| [`remark-lint-fenced-code-flag`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-fenced-code-flag)                    |     |     |  X  |
| [`remark-lint-fenced-code-marker`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-fenced-code-marker)                  |  X  |     |  X  |
| [`remark-lint-file-extension`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-file-extension)                      |     |     |  X  |
| [`remark-lint-final-definition`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-final-definition)                    |     |     |  X  |
| [`remark-lint-final-newline`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-final-newline)                       |     |  X  |     |
| [`remark-lint-hard-break-spaces`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-hard-break-spaces)                   |     |  X  |  X  |
| [`remark-lint-heading-increment`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-heading-increment)                   |     |     |  X  |
| [`remark-lint-heading-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-heading-style)                       |  X  |     |  X  |
| [`remark-lint-link-title-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-link-title-style)                    |  X  |     |  X  |
| [`remark-lint-list-item-indent`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-indent)                    |     |  X  |  X  |
| [`remark-lint-list-item-bullet-indent`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-bullet-indent)             |     |  X  |     |
| [`remark-lint-list-item-content-indent`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-content-indent)            |  X  |     |  X  |
| [`remark-lint-list-item-spacing`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-list-item-spacing)                   |     |     |  X  |
| [`remark-lint-maximum-line-length`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-maximum-line-length)                 |     |     |  X  |
| [`remark-lint-maximum-heading-length`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-maximum-heading-length)              |     |     |  X  |
| [`remark-lint-no-auto-link-without-protocol`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-auto-link-without-protocol)       |     |  X  |  X  |
| [`remark-lint-no-blockquote-without-marker`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-blockquote-without-marker)        |     |  X  |  X  |
| [`remark-lint-no-consecutive-blank-lines`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-consecutive-blank-lines)          |     |     |  X  |
| [`remark-lint-no-duplicate-definitions`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-definitions)            |     |  X  |     |
| [`remark-lint-no-duplicate-headings`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-headings)               |     |     |  X  |
| [`remark-lint-no-emphasis-as-heading`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-emphasis-as-heading)              |     |     |  X  |
| [`remark-lint-no-file-name-articles`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-articles)               |     |     |  X  |
| [`remark-lint-no-file-name-consecutive-dashes`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-consecutive-dashes)     |     |     |  X  |
| [`remark-lint-no-file-name-irregular-characters`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-irregular-characters)   |     |     |  X  |
| [`remark-lint-no-file-name-mixed-case`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-mixed-case)             |     |     |  X  |
| [`remark-lint-no-file-name-outer-dashes`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-file-name-outer-dashes)           |     |     |  X  |
| [`remark-lint-no-heading-content-indent`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-content-indent)           |     |  X  |     |
| [`remark-lint-no-heading-punctuation`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-punctuation)              |     |     |  X  |
| [`remark-lint-no-inline-padding`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-inline-padding)                   |     |  X  |     |
| [`remark-lint-no-literal-urls`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-literal-urls)                     |     |  X  |  X  |
| [`remark-lint-no-multiple-toplevel-headings`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-multiple-toplevel-headings)       |     |     |  X  |
| [`remark-lint-no-shell-dollars`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-shell-dollars)                    |     |     |  X  |
| [`remark-lint-no-shortcut-reference-image`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-shortcut-reference-image)         |     |  X  |  X  |
| [`remark-lint-no-shortcut-reference-link`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-shortcut-reference-link)          |     |  X  |  X  |
| [`remark-lint-no-table-indentation`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-table-indentation)                |     |     |  X  |
| [`remark-lint-no-undefined-references`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-undefined-references)             |     |  X  |     |
| [`remark-lint-no-unused-definitions`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-unused-definitions)               |     |  X  |     |
| [`remark-lint-ordered-list-marker-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-ordered-list-marker-style)           |  X  |  X  |  X  |
| [`remark-lint-ordered-list-marker-value`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-ordered-list-marker-value)           |     |     |  X  |
| [`remark-lint-rule-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-rule-style)                          |  X  |     |  X  |
| [`remark-lint-strong-marker`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-strong-marker)                       |  X  |     |  X  |
| [`remark-lint-table-cell-padding`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-table-cell-padding)                  |  X  |     |  X  |
| [`remark-lint-table-pipe-alignment`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-table-pipe-alignment)                |     |     |  X  |
| [`remark-lint-table-pipes`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-table-pipes)                         |     |     |  X  |
| [`remark-lint-checkbox-content-indent`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-checkbox-content-indent)             |     |     |     |
| [`remark-lint-first-heading-level`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-first-heading-level)                 |     |     |     |
| [`remark-lint-linebreak-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-linebreak-style)                     |     |     |     |
| [`remark-lint-no-duplicate-defined-urls`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-defined-urls)           |     |     |     |
| [`remark-lint-no-duplicate-headings-in-section`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-duplicate-headings-in-section)    |     |     |     |
| [`remark-lint-no-empty-url`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-empty-url)                        |     |     |     |
| [`remark-lint-no-heading-indent`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-indent)                   |     |     |     |
| [`remark-lint-no-heading-like-paragraph`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-heading-like-paragraph)           |     |     |     |
| [`remark-lint-no-html`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-html)                             |     |     |     |
| [`remark-lint-no-missing-blank-lines`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-missing-blank-lines)              |     |     |     |
| [`remark-lint-no-paragraph-content-indent`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-paragraph-content-indent)         |     |     |     |
| [`remark-lint-no-reference-like-url`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-reference-like-url)               |     |     |     |
| [`remark-lint-no-tabs`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-tabs)                             |     |     |     |
| [`remark-lint-strikethrough-marker`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-strikethrough-marker)                |     |     |     |
| [`remark-lint-no-unneeded-full-reference-image`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-unneeded-full-reference-image)    |     |     |     |
| [`remark-lint-no-unneeded-full-reference-link`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-no-unneeded-full-reference-link)     |     |     |     |
| [`remark-lint-unordered-list-marker-style`](https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-unordered-list-marker-style)         |     |     |     |

MSG includes all but 1 from C and 7 from R

Plus a growing list of [external rules](https://github.com/remarkjs/remark-lint#list-of-external-rules)

remark-lint-\*: (configurable) plugins focusing on individual issues

I thought I would share set up for this with Vim and ALE since.

I found this to be the case when I first installed.

tuning remark

tuning to be general. leave target specific linting for pre-commit-hooks.

## Configuration

Handled by `unified`
.remarkrc.yaml

## Integrating with Vim via ALE

## Sidetracks

### Linting vs fixing

Asynchronous linting is good. Automatic fixing is better.

Having an IDE that highlights errors or warnings as you write can help to ensure that whatever you are writing or coding is coherent, provided the errors or warnings it reports are both relevant and correct. With Vim we can get access to excellent  asynchronous linting support via the [ALE](https://github.com/dense-analysis/ale) plugin which has integrations for a large number of 3rd party linting programs. Having your IDE constantly harass you about trivial errors can be distracting and fixing those errors immediately may be counter-productive

### Omitting references to micromark
