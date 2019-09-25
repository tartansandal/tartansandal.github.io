# TODO

1. About page
    * Open Source
    * Fedora Linux Desktop
    * record of some of my deep dive
        * blog incorages me to dive deeper and 
    * maths, technology, programming, music theory,  

1. My VIM setup

1. dotfiles

1. Blog on Makefile for project command aliases
    * Makefiles can be complex, but a simple usage can be powerful
    * simple targets as aliases for more complex project-specific commands
    * uniform targets across projects
        * build
        * test
        * smoke-test
        * clean
        * run
        * watch
        * server
        * update
        * deploy
    * sanity for working on multiple projects
        * different frameworks, languages
            * perl
            * python
            * go
            * node
    * documents your projects development process
    * long docker run commands
        * docker run --rm -i -t -v .:/opt/app  -v --network ... --name
          username/image:version

    * `export` to set and propagate environment variables

        export VIRTUAL_ENV := ./venv
        export PATH := ./venv/bin:$(PATH)

    * mark aliases with .PHONY
    * figuring out details, getting it right, then forget about it
    * bash completion
    * executable documentation

1. Blog about local user installs

    * ~/bin
    * ~/.local
    * ~/.config

    GEM madness
