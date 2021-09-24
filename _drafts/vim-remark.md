# Linting and fixing in Vim with Remark

The [Remark][] utility can be used to both highlight style and formatting
issues with your markdown and to automatically fix many of them. Figuring out
how to configure Remark to work well with [Vim][] and [ALE][] was a bit
challenging, so I thought I would share my setup and some tips.

First up, note that Remark is a general framework for processing Markdown and
not just for converting it to HTML. It is built out of layered components so
that different parts can be used in different contexts. Some relevant ones
include.

* [`micromark`][micromark]: the smallest commonmark-compliant markdown parser
  that exists.

* [`mdast`][mdast]: a specification for representing a various Markdown flavours
  in an Abstract Syntax Tree.

* [`mdast-util-from-markdown`][mdast-util-from-markdown]: a utility to parse
  Markdown to an AST.

* [`remark-parser`][remark-parser]: a parser that converts Markdown to an AST
  using the above.

* [`mdast-util-to-markdown`][mdast-util-to-markdown]: a utility to serialize
  `mdast` to Markdown.

* [`remark-stringify`][remark-stringify]: a serializer to convert an AST back
  into markdown using the above.

* [`remark-lint`][remark-lint]: a library that examines an AST for issues based
  on plugins

* [`remark`][remark-package]: is a markdown processor powered by plugins and
  using all the above.

* [`unified`][unified]: a framework for building text processing tools.

* [`remark-cli`][remark-cli]: a command-line interface based on `unified` and
  `remark`

At various layers, support for additional markup and output (like footnotes,
directives, ToCs, GFM, MDX, etc) can be provided by [remark plugins][].

This can make understanding the setup and configuration a little confusing --
with the documentation being spread across a number of packages and projects.

## Fixing Markdown

You can get an automatic "fixing" ability but simply installing `remark-cli`:

```console
npm install -g remark-cli
```

With that get all of the above libraries installed plus a command-line utility
called `remark`.

When you run this `remark` command on a markdown file, it will parse the content
into an AST using `mdast-util-from-markdown` (via `remark-parse`) and then
convert that AST back into text using `mdast-util-to-markdown` (via
`remark-stringify`).  To get this "fixing" routine to match your desired style,
you just have to the formatting otions.  You can check out the available
formatting options in the [`mdast-util-to-markdown`
documentation](https://github.com/syntax-tree/mdast-util-to-markdown#formatting-options),

> Which, if any, settings should I change?

You will want to ensure your "fixing" settings don't conflict with your
preferred "linting" rules. You want stable round-trips: you don't want your
"fixing" routine to alter the markdown so that a "linting" error is triggered,
especially if you have just fixed that error manually.

The defaults for most settings are resonable and using them in this particular
combination avoids many issues. Of particular note are the following settings
which minimize ambiguity and seem to give stable round-trips:

```yaml
# Marker defaults
bullet: '*'
bulletOrdered: '.'
emphasis: '*'
strong: '*'
fence: '`'
quote: '"'
...
```

The only ones I change are:

```yaml
# Use a different rule marker for contrast
rule: '-'

# Always use fences for code blocks to match Markdown Style Guide (MSG)
fences: true

# Indent the content of list items with the size of the bullet plus one space
listItemIndent: one
```

Using '-' instead of '\*' for a rule marker helps avoid a couple of edge cases
where the intent is ambiguous.  Always using fences for code blocks, and
a single space after bullets, enforces a consistency that can help to avoid
unnecessary round-trips.

If you want support for GFM tables and checkbox lists, you will want to add the
`remark-gfm` plugin.  This has to be loaded before any associated "linting"
plugins since they require the content to be appropriately parsed before it can
be linted. There are some options to this module, but the defaults seem to work
well.

## Linting Markdown

At this stage, despite having a `remark-lint` module installed, you do not have
any linting capabilities. This is because `remark-lint` passes off all the
actual linting to configurable plugins that target specific errors or
warnings. These must be installed and loaded before any linting can occur.

There are currently 67 [official rule][remark-lint rules] plugins covering common
issues.

> Which rules should I use?

Remark provides 3 preset "meta" packages that load and configure commonly used
combinations:

* [`remark-preset-lint-consistent`][remark-preset-lint-consistent] (C): rules that enforce consistency

* [`remark-preset-lint-recommended`][remark-preset-lint-recommended] (R): rules that prevent mistakes or stuff
  that fails across vendors.

* [`remark-preset-lint-markdown-style-guide`][remark-preset-lint-markdown-style-guide] (MSG): rules that enforce the
  markdown style guide

The table below shows some of the relationships between the different rules and
presets.  I've ommited the `remark-lint-` rule prefix and used the following
key to keep the table compact.

* MSG: provided by the Markdown Style Guide preset
* C: provided by the Consistent preset
* R: provided by the Recommended preset
* GFM: requires the Github Flavoured Markdown plugin (`remark-gfm`)
* F: The "fixer" (`remark-stringify`) automatically resolves this issue

| Plugin                                                                               | MSG | C | R | GFM | F  | My Fixer Setting    | My Linter Setting              |
| ------------------------------------------------------------------------------------ | --- | - | - | --- | -- | ------------------- | ------------------------------ |
| [`definition-case`][remark-lint-definition-case]                                     | X   |   |   |     |    |                     |                                |
| [`fenced-code-flag`][remark-lint-fenced-code-flag]                                   | X   |   |   |     |    |                     |                                |
| [`file-extension`][remark-lint-file-extension]                                       | X   |   |   |     |    |                     |                                |
| [`final-definition`][remark-lint-final-definition]                                   | X   |   |   |     |    |                     |                                |
| [`maximum-heading-length`][remark-lint-maximum-heading-length]                       | X   |   |   |     |    |                     |                                |
| [`maximum-line-length`][remark-lint-maximum-line-length]                             | X   |   |   |     |    |                     |                                |
| [`no-duplicate-headings`][remark-lint-no-duplicate-headings]                         | X   |   |   |     |    |                     |                                |
| [`no-emphasis-as-heading`][remark-lint-no-emphasis-as-heading]                       | X   |   |   |     |    |                     |                                |
| [`no-file-name-articles`][remark-lint-no-file-name-articles]                         | X   |   |   |     |    |                     |                                |
| [`no-file-name-consecutive-dashes`][remark-lint-no-file-name-consecutive-dashes]     | X   |   |   |     |    |                     |                                |
| [`no-file-name-irregular-characters`][remark-lint-no-file-name-irregular-characters] | X   |   |   |     |    |                     |                                |
| [`no-file-name-mixed-case`][remark-lint-no-file-name-mixed-case]                     | X   |   |   |     |    |                     |                                |
| [`no-file-name-outer-dashes`][remark-lint-no-file-name-outer-dashes]                 | X   |   |   |     |    |                     |                                |
| [`no-heading-punctuation`][remark-lint-no-heading-punctuation]                       | X   |   |   |     |    |                     |                                |
| [`no-multiple-toplevel-headings`][remark-lint-no-multiple-toplevel-headings]         | X   |   |   |     |    |                     |                                |
| [`no-shell-dollars`][remark-lint-no-shell-dollars]                                   | X   |   |   |     |    |                     |                                |
| [`definition-spacing`][remark-lint-definition-spacing]                               | X   |   |   |     | X  |                     |                                |
| [`list-item-spacing`][remark-lint-list-item-spacing]                                 | X   |   |   |     | X  |                     |                                |
| [`no-consecutive-blank-lines`][remark-lint-no-consecutive-blank-lines]               | X   |   |   |     | X  |                     |                                |
| [`ordered-list-marker-value`][remark-lint-ordered-list-marker-value]                 | X   |   |   |     | X  |                     | ordered                        |
| [`no-table-indentation`][remark-lint-no-table-indentation]                           | X   |   |   | X   | X  |                     |                                |
| [`table-pipes`][remark-lint-table-pipes]                                             | X   |   |   | X   | X  |                     |                                |
| [`table-pipe-alignment`][remark-lint-table-pipe-alignment]                           | X   |   |   | X   | X  |                     |                                |
| [`table-cell-padding`][remark-lint-table-cell-padding]                               | X   | X |   | X   | X  |                     |                                |
| [`blockquote-indentation`][remark-lint-blockquote-indentation]                       | X   | X |   |     | X  |                     |                                |
| [`emphasis-marker`][remark-lint-emphasis-marker]                                     | X   | X |   |     | X  |                     |                                |
| [`fenced-code-marker`][remark-lint-fenced-code-marker]                               | X   | X |   |     | X  |                     |                                |
| [`code-block-style`][remark-lint-code-block-style]                                   | X   | X |   |     | X  | fences: true        |                                |
| [`heading-style`][remark-lint-heading-style]                                         | X   | X |   |     | X  |                     |                                |
| [`link-title-style`][remark-lint-link-title-style]                                   | X   | X |   |     | X+ |                     | **false**                      |
| [`list-item-content-indent`][remark-lint-list-item-content-indent]                   | X   | X |   |     | X  |                     |                                |
| [`rule-style`][remark-lint-rule-style]                                               | X   | X |   |     | X  | rule: '-'           |                                |
| [`strong-marker`][remark-lint-strong-marker]                                         | X   | X |   |     | X  |                     |                                |
| [`ordered-list-marker-style`][remark-lint-ordered-list-marker-style]                 | X   | X | X |     | X  |                     |                                |
| [`hard-break-spaces`][remark-lint-hard-break-spaces]                                 | X   |   | X |     | X  |                     |                                |
| [`list-item-indent`][remark-lint-list-item-indent]                                   | X   |   | X |     | X  | listItemIndent: one | space                          |
| [`no-auto-link-without-protocol`][remark-lint-no-auto-link-without-protocol]         | X   |   | X |     | X  |                     |                                |
| [`no-blockquote-without-marker`][remark-lint-no-blockquote-without-marker]           | X   |   | X |     | X  |                     |                                |
| [`no-literal-urls`][remark-lint-no-literal-urls]                                     | X   |   | X |     | X  |                     |                                |
| [`no-shortcut-reference-image`][remark-lint-no-shortcut-reference-image]             | X   |   | X |     | X  |                     |                                |
| [`no-shortcut-reference-link`][remark-lint-no-shortcut-reference-link]               | X   |   | X |     | X  |                     |                                |
| [`list-item-bullet-indent`][remark-lint-list-item-bullet-indent]                     |     |   | X |     | X  |                     |                                |
| [`final-newline`][remark-lint-final-newline]                                         |     |   | X |     | X  |                     |                                |
| [`no-heading-content-indent`][remark-lint-no-heading-content-indent]                 |     |   | X |     | X  |                     |                                |
| [`no-undefined-references`][remark-lint-no-undefined-references]                     |     |   | X |     |    |                     |                                |
| [`no-unused-definitions`][remark-lint-no-unused-definitions]                         |     |   | X |     |    |                     |                                |
| [`no-duplicate-definitions`][remark-lint-no-duplicate-definitions]                   |     |   | X |     |    |                     |                                |
| [`no-inline-padding`][remark-lint-no-inline-padding]                                 |     |   | X |     |    |                     |                                |
| [`heading-increment`][remark-lint-heading-increment]                                 | X   |   |   |     |    |                     |                                |
| [`checkbox-character-style`][remark-lint-checkbox-character-style]                   |     | X |   | X   | X  |                     | {checked: 'x', unchecked: ' '} |
| [`checkbox-content-indent`][remark-lint-checkbox-content-indent]                     |     |   |   | X   | X  |                     |                                |
| [`strikethrough-marker`][remark-lint-strikethrough-marker]                           |     |   |   | X   | X  |                     |                                |
| [`unordered-list-marker-style`][remark-lint-unordered-list-marker-style]             |     |   |   |     | X  |                     | '\*'                           |
| [`linebreak-style`][remark-lint-linebreak-style]                                     |     |   |   |     | X  |                     |                                |
| [`no-missing-blank-lines`][remark-lint-no-missing-blank-lines]                       |     |   |   |     | X  |                     | exceptTightLists: true         |
| [`first-heading-level`][remark-lint-first-heading-level]                             |     |   |   |     |    |                     |                                |
| [`no-duplicate-defined-urls`][remark-lint-no-duplicate-defined-urls]                 |     |   |   |     |    |                     |                                |
| [`no-duplicate-headings-in-section`][remark-lint-no-duplicate-headings-in-section]   |     |   |   |     |    |                     |                                |
| [`no-empty-url`][remark-lint-no-empty-url]                                           |     |   |   |     |    |                     |                                |
| [`no-heading-indent`][remark-lint-no-heading-indent]                                 |     |   |   |     |    |                     |                                |
| [`no-heading-like-paragraph`][remark-lint-no-heading-like-paragraph]                 |     |   |   |     |    |                     |                                |
| [`no-html`][remark-lint-no-html]                                                     |     |   |   |     |    |                     |                                |
| [`no-paragraph-content-indent`][remark-lint-no-paragraph-content-indent]             |     |   |   |     |    |                     |                                |
| [`no-reference-like-url`][remark-lint-no-reference-like-url]                         |     |   |   |     |    |                     |                                |
| [`no-tabs`][remark-lint-no-tabs]                                                     |     |   |   |     |    |                     |                                |
| [`no-unneeded-full-reference-image`][remark-lint-no-unneeded-full-reference-image]   |     |   |   |     |    |                     |                                |
| [`no-unneeded-full-reference-link`][remark-lint-no-unneeded-full-reference-link]     |     |   |   |     |    |                     |                                |

Many of issues highlighted by these rules can be automatically resolved by the
serializer and I was able to find complementary "fixer" and "linter" settings.
Mostly these corresponded to the default [`remark-stringify`][remark-stringify]
settings and
[`remark-preset-lint-markdown-style-guide`][remark-preset-lint-markdown-style-guide]
settings, but there were a couple of instances where I had to compromise to get
consistent round-trip behaviour.

This gives us a baseline of the minimum set of linting rules that we need and
the correspunding settings. If we note the overlap of the MSG and Recommended
presets with the rules that are automatically fixed by the serializer, we can
get a reasonably compact configuration by including those presets, the GFM
plugin, and just 3 extra rules.

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

In the above we override preset configurations by loading the associated rule
and setting the non-default value.

Unfortunately there was one rule that I could not be configured to consistently
match the serializer output: `link-title-style`. Since this could be loaded via
a preset, I ended up suppressng this rule by explicitly setting it to `false`.

```yaml
  - - remark-lint-link-title-style
    - false 
```

> What about the rest of the rules?

Getting headings and sections wrong is going to upset my composition and fixing
them could require significant rework, so I like to keep these under control at
by adding the following rules:

```yaml
  - remark-lint-first-heading-level
  - remark-lint-no-heading-indent
  - remark-lint-no-heading-like-paragraph
  - remark-lint-no-duplicate-headings-in-section
  - remark-lint-no-paragraph-content-indent
```

While all of the rules have some benefit, loading too many can slow down the
"linting" routine while you are editing.  Rather than running all the rules in
your editor, it may be more efficient to set up a linting routine in your
project's Pre-Commit hook or CI configuration, and relegating the slow or rarely
triggered rules to that routine.

```yaml
  - remark-lint-no-tabs
  - remark-lint-no-html
  - remark-lint-no-empty-url
  - remark-lint-no-duplicate-defined-urls
  - remark-lint-no-inline-padding
  - remark-lint-no-reference-like-url
```

There are some MSG and Recomended rules that could be omitted if you have
something like that set up. For example, the rules from MSG that check the file
name and extension:

```yaml
  - remark-lint-file-extension
  - remark-lint-no-file-name-articles
  - remark-lint-no-file-name-consecutive-dashes
  - remark-lint-no-file-name-irregular-characters
  - remark-lint-no-file-name-mixed-case
  - remark-lint-no-file-name-outer-dashes
```

And rules that check for missing, unused, or duplicate definitions:

```yaml
  - remark-lint-no-inline-padding
  - remark-lint-no-duplicate-definitions
  - remark-lint-no-undefined-references
  - remark-lint-no-unused-definitions
```

Though testing does not show a huge effect on performance.

## Configuration

It is fairly easy to make small errors in the configuration files that cause
Remark to bail. The symptom is often an unusual error on the very first line of
the of the file. If you see this, check `:ALEInfo` to see what the error is.

tuning remark
tuning to be general. leave target specific linting for pre-commit-hooks.

Handled by `unified`
.remarkrc.yaml

## Integrating with Vim via ALE

--------------------------------------------------------------------------------

## Sidetracks

### Linting vs fixing

Asynchronous linting is good. Automatic fixing is better.

Having an IDE that highlights errors or warnings as you write can help to ensure
that whatever you are writing or coding is coherent, provided the errors or
warnings it reports are both relevant and correct. With Vim we can get access to
excellent  asynchronous linting support via the
[ALE](https://github.com/dense-analysis/ale) plugin which has integrations for
a large number of 3rd party linting programs. Having your IDE constantly harass
you about trivial errors can be distracting and fixing those errors immediately
may be counter-productive

### Preset overlaps

As you can see, the Consistency rules are almost a subset of the Markdown Style
Guide rules (except for linter settings), with the
[`checkbox-character-style`][remark-lint-checkbox-character-style] rule being
the only exception. The real differences between the two presets is that the
Consistency preset only insists that the markdown uses a *consistent* style
(e.g. the same markers and indentation are used throughout), whereas the
Markdown Style Guide preset insists that a *specific* style is used. Since our
"fixer" routine is going to impose a specific style, we probably want to use
similar rules.

Conversley, the Consistency and Recommended rules are almost disjoint, with the
[`ordered-list-marker-style`][remark-lint-ordered-list-marker-style] rule being
the only exception.

--------------------------------------------------------------------------------

## References

[vim]: https://www.vim.org/

[ale]: https://github.com/dense-analysis/ale

[remark plugins]: https://github.com/remarkjs/remark/blob/main/doc/plugins.md#plugins

[remark-lint rules]: https://github.com/remarkjs/remark-lint/blob/main/doc/rules.md#list-of-rules

[remark]: https://remark.js.org/

[micromark]: https://github.com/micromark/micromark

[mdast]: https://github.com/syntax-tree/mdast

[mdast-util-from-markdown]: https://github.com/syntax-tree/mdast-util-from-markdown

[remark-parser]: https://github.com/remarkjs/remark/tree/main/packages/remark-parse

[mdast-util-to-markdown]: https://github.com/syntax-tree/mdast-util-to-markdown

[remark-stringify]: https://github.com/remarkjs/remark/tree/main/packages/remark-stringify

[remark-lint]: https://github.com/remarkjs/remark-lint

[remark-package]: https://github.com/remarkjs/remark/tree/main/packages/remark

[unified]: https://github.com/unifiedjs/unified

[remark-preset-lint-consistent]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-preset-lint-consistent

[remark-preset-lint-recommended]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-preset-lint-recommended

[remark-preset-lint-markdown-style-guide]: https://github.com/remarkjs/remark-lint/tree/main/packages/remark-preset-lint-markdown-style-guide

[remark-cli]: https://github.com/remarkjs/remark/tree/main/packages/remark-cli

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
