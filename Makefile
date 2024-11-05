# Build HTML of Gora Phoenix main documentation from reStructuredText.

SHELL = /bin/bash # pick up executable paths properly
CONVERTER = rst2html5 --halt 3 --template=template.html

all: html/index.html svg

html/%.html: %.rst template.html
	$(CONVERTER) $*.rst > $@

svg:
	cp -u *.svg html/

clean:
	rm -f html/*.{html,svg}