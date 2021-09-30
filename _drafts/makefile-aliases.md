---
title: Makefiles for project-level command aliases
---

Blog on using Makefile for project command aliases

* Makefiles can be complex, but a simple usage can be powerful

    <https://www.gnu.org/software/make/manual/html_node/>

* Real Makefiles are somthing else

* simple targets as aliases for more complex project-specific commands

* sanity for working on multiple projects
  * different frameworks, languages
    * perl
    * python
    * go
    * node

* development process: bash (tab) completion
* executable documentation

* uniform targets across projects
    * setup
        typically run once after `git clone`
    * build
    * test
    * run
    * clean

* less common targets
    * all -> points to build
    * check
    * smoke
    * watch
    * server
    * update
    * install
    * deploy
    * debug?

* but you can have anything
    * these are just aliases
    * keep it simple

* documents your projects development process
    This is developer documentation, not end user

* long docker run commands
    * docker run --rm -i -t -v .:/opt/app  -v --network ... --name
      username/image:version

* `export` to set and propagate environment variables

    export VIRTUAL_ENV := ./venv
    export PATH := ./venv/bin:$(PATH)

* mark aliases with .PHONY
* figuring out details, getting it right, then forget about it

Meta programming:
<http://make.mad-scientist.net/constructed-macro-names/>

<https://suva.sh/posts/well-documented-makefiles/>
