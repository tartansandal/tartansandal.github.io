#
# Makefile for development aliases
#

.PHONY: server versions

# launch a jekyll server to rebuild _site files
server:
	bundle exec jekyll server

# Lists the current gem dependency versions
versions:
	bundle exec github-pages versions

# update bundled gems
update:
	bundle update

## We don't need this for github.io domains
# health-check:
# 	bundle exec github-pages health-check
