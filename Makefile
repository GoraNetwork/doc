# Build HTML of Gora Phoenix main documentation from reStructuredText.

SHELL = /bin/bash # pick up executable paths properly
CONVERTER = rst2html5 --halt 3 --template=template.html \
                      --stylesheet-inline main.css 

all: html/index.html svg

html/index.html: *.rst main.css template.html
	$(CONVERTER) index.rst > $@

svg:
	cp -u *.svg html/

clean:
	rm -f html/*.{html,svg}