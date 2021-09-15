# Linting and fixing in Vim with Remark

Asynchronous linting is good. Automatic fixing is better.

Having an IDE that highlights errors or warnings as you write can help to ensure that whatever you are writing or coding is coherent, provided the errors or warnings it reports are both relevant and correct. With Vim we can get access to excellent  asynchronous linting support via the [ALE](https://github.com/dense-analysis/ale) plugin which has integrations for a large number of 3rd party linting programs. Having your IDE constantly harass you about trivial errors can be distracting and fixing those errors immediately may be counter-productive.

I found this to be the case when I first installed [`remark-lint`](https://github.com/markdownlint/markdownlint). ALE conveniently noticed this addition and automatically started highlighting errors in all my markdown files and my IDE was suddenly lit up like a Christmas tree.


remark framework

tuning remark

tuning to be general. leave target specific linting for pre-commit-hooks.
