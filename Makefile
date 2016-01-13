all: biblio

biblio: biblio.tab.c lex.yy.c
	gcc symbol_tab.c biblio.tab.c lex.yy.c -o biblio
biblio.tab.c: biblio.y
	bison -d biblio.y
lex.yy.c: biblio.fl
	flex biblio.fl
clean:
	rm biblio.tab.c lex.yy.c biblio
