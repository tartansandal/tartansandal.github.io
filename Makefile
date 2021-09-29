.PHONY: all serve build

all: serve 

export JEKYLL_VERSION=3.8
serve:
	docker run --rm -it \
		--volume="$$PWD:/srv/jekyll" \
		--volume="$$PWD/vendor/bundle:/usr/local/bundle" \
		--publish 4000:4000 \
		jekyll/jekyll:${JEKYLL_VERSION} \
		jekyll serve --drafts --livereload

build: 
	docker run --rm -it \
		--volume="$$PWD:/srv/jekyll" \
		--volume="$$PWD/vendor/bundle:/usr/local/bundle" \
		--publish 4000:4000 \
		jekyll/jekyll:${JEKYLL_VERSION} \
		jekyll build

