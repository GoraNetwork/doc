# Build HTML of Gora Phoenix main documentation from reStructuredText.

CONVERTER = rst2html5.py

all: html/main.html svg

html/%.html: %.rst
	$(CONVERTER) $*.rst > $@

svg:
	cp -u *.svg html/

clean:
	rm -f html/*.{html,svg}