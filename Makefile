# Development aliases
.PHONY: all serve update

# Ensure gems have been updated before launching the server
all: update serve

# Launch a jekyll server to rebuild _site files
serve:
	bundle exec jekyll serve

# Update bundled gems to sync with GitHub Pages
update:
	bundle update

# Lists the current gem dependency versions
# versions:
# 	bundle exec github-pages versions
#
## We don't need this for github.io domains
# health-check:
# 	bundle exec github-pages health-check
