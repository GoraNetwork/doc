# Build HTML of Gora Phoenix main documentation from reStructuredText.

SHELL = /bin/bash # pick up executable paths properly
CONVERTER = rst2html5 --halt 3 --strip-comments --template=template.html \
                      --stylesheet-inline

all: html/index.html html/github_home.html svg png

html/index.html: *.rst main.css template.html
	$(CONVERTER) main.css index.rst > $@

html/github_home.html: github_home.rst github_home.css template.html
	$(CONVERTER) github_home.css github_home.rst > $@

svg:
	cp -u *.svg html/
png:
	cp -u *.png html/

clean:
	rm -f html/*.{html,svg,png}