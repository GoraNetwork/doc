# Build HTML of Gora Phoenix main documentation from reStructuredText.

CONVERTER = rst2html5 --halt 3 --template=template.html

all: html/main.html svg

html/%.html: %.rst template.html
	$(CONVERTER) $*.rst > $@

svg:
	cp -u *.svg html/

clean:
	rm -f html/*.{html,svg}