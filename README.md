# Gora documentation

Customer-facing documentation for Gora. Document text sources files are in
reStructuredText format. Diagrams are in OpenOffice ODG format and must be
manually exported to SVG for inclusion after updates. To produce HTML, make sure
that `rst2html5` from https://rst2html5.readthedocs.io is installed (note that
it is different from `rst2html5.py` provided by `docutils` package), then run
`make`. Output will be placed in `html` directory. See `Makefile` for default
options and paths. The output is unstyled, consumers are expected to use their
own CSS stylesheets.