all:
	pdflatex cliq && bibtex cliq && pdflatex cliq && pdflatex cliq
