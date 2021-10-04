.PHONY: all serve build update

all: serve 

# Use the latest version of Jekyll compatible with GitHub Pages
# https://pages.github.com/versions/
JEKYLL_VERSION=3.8

# Use the official docker image for that version
image  = jekyll/jekyll:${JEKYLL_VERSION}

# Bind the current dir to jekylls working dir
appdir = --volume="${PWD}:/srv/jekyll"

# Bind the local bundle dir to so it is cached between runs
cache  = --volume="${PWD}/vendor/bundle:/usr/local/bundle"

# Publish ports 4000 for HTTP and 35729 for livereload
publish= --publish 4000:4000 --publish 35729:35729

# Serve the static files for local development
serve:
	@docker run --rm -it ${appdir} ${cache} ${publish} ${image} \
		jekyll serve --drafts --watch --force-polling --livereload

# Build the static files
build: 
	@docker run --rm -it ${appdir} ${cache} ${image} \
		jekyll build

# Update the Gemfile.lock
update:
	@docker run --rm -it ${appdir} ${cache} ${image} \
		bundle update
