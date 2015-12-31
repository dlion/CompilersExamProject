#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_tab.h"

unsigned int hash(char *s) {
	/* calcola il valore HASH di s;*/
	int h=0;
	for(;*s!='\0';s++)
	   h=(127*h+*s)%HASHSIZE;
	return h;
}

libro *ins_lib(char *autore, char *titolo, char *isbn, int x, char *c1, char *c2, char *cn)
{
	libro *l   = (libro *)malloc(sizeof(libro));
	l->autore  = strdup(autore);
	l->titolo  = strdup(titolo);
	l->ISBN    = strdup(isbn);
	l->num_pag = x;
    	l->coll1    = strdup(c1);
    	l->coll2    = strdup(c2);
	l->numcoll  = strdup(cn);
    	l->data    = NULL;
	l->cliente = -1;
	return l;
}

cliente *ins_cli(char *nome,char *CF, char *isbn, char *data)
{
	cliente *c = (cliente*)malloc(sizeof(cliente));
	c->nome    = strdup(nome);
	c->CF      = strdup(CF);
	return c;
}
