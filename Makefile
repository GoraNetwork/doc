# Build HTML of Phoenix main documentation from reStructuredText.

SHELL = /bin/bash # pick up executable paths properly
CONVERTER = rst2html5 --halt 3 --strip-comments --template=template.html \
                      --stylesheet-inline

all: docs/index.html docs/github_home.html svg png

docs/index.html: *.rst main.css template.html
	$(CONVERTER) main.css index.rst > $@

docs/github_home.html: github_home.rst github_home.css template.html
	$(CONVERTER) github_home.css github_home.rst > $@

svg:
	cp -u *.svg docs/
png:
	cp -u *.png docs/

clean:
	rm -f docs/*.{html,svg,png}