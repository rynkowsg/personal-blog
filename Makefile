HUGO := hugo
DESTDIR := public

# All input files
FILES=$(shell find content layouts static themes -type f)

.PHONY: clean
clean:
	-rm -rf public

build: clean $(FILES) config.yaml
	$(HUGO) --gc --log --destination=$(DESTDIR)

build-minified: clean $(FILES) config.yaml
	$(HUGO) --gc --log --minify --destination=$(DESTDIR)

.PHONY: server
server:
	$(HUGO) serve -D

.PHONY: deploy
deploy: clean build-minified
	-aws s3 sync $(DESTDIR) s3://rynkowski.pl
