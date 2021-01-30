cheshire-yeomanry-handbook.pdf: $(wildcard *.bib) $(wildcard *.tex) $(wildcard **/*.tex) $(wildcard **/*.pdf)
	latexmk -pdf cheshire-yeomanry-handbook.tex

clean:
	latexmk -C
	rm -f cheshire-yeomanry-handbook.bbl
