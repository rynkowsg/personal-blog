HUGO := hugo
DESTDIR := public

# All input files
FILES=$(shell find content layouts static themes -type f)

.PHONY: clean
clean:
	-rm -rf public
	-./scripts/remove-info-shortcodes.sh

.PHONY: generate-info
generate-info:
	./scripts/generate-info-shortcodes.sh

build: clean generate-info $(FILES) config.yaml
	$(HUGO) --gc --log --destination=$(DESTDIR)

build-minified: clean generate-info $(FILES) config.yaml
	$(HUGO) --gc --log --minify --destination=$(DESTDIR)

.PHONY: server
server: clean generate-info
	$(HUGO) serve -D

.PHONY: deploy
deploy: clean build-minified
	-aws s3 sync "$(DESTDIR)/en" s3://rynkowski.uk
	-aws s3 sync "$(DESTDIR)/pl" s3://rynkowski.pl
