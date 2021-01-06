HUGO := hugo
DESTDIR := public

# All input files
FILES=$(shell find content layouts static themes -type f)

.PHONY: clean
clean:
	-rm -rf public
	@make remove-info

.PHONY: generate-info
generate-info: remove-info
	-./scripts/generate-info-shortcodes.sh

.PHONY: remove-info
remove-info:
	-./scripts/remove-info-shortcodes.sh

build: clean generate-info $(FILES) config.yaml
	$(HUGO) --gc --log --destination=$(DESTDIR)

build-minified: clean generate-info $(FILES) config.yaml
	$(HUGO) --gc --log --minify --destination=$(DESTDIR)

.PHONY: server
server: generate-info
	@# rerun generate-info if detected
	-fswatch -o scripts/ | xargs -n1 -I{} make generate-info &
	$(HUGO) serve -D

.PHONY: deploy
deploy: clean build-minified
	-aws s3 sync "$(DESTDIR)/en" s3://rynkowski.uk
	-aws s3 sync "$(DESTDIR)/pl" s3://rynkowski.pl
