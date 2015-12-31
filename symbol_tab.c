#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_tab.h"

/**
 * Calcola l'hash di una stringa
 */
unsigned int hash(char *s) {
	/* calcola il valore HASH di s;*/
	int h=0;
	for(;*s!='\0';s++)
	   h=(127*h+*s)%HASHSIZE;
	return h;
}

/**
 * Si calcola l'hash dal CF del cliente
 * Collega l'hashtable di indice hashC al cliente
 */
void collegaHashCliente(cliente *c)
{
	int hashC = hash(c->CF);
	dbC[hashC] = c;
}

/**
 * Si calcola l'hash dall'ISBN del libro
 * Collega l'hashtable di indice hashL al libro
 */
void collegaHashLibro(libro *l)
{
	int hashL = hash(l->ISBN);
	dbL[hashL] = l;
}

/**
 * Si calcola l'hash dall'ISBN
 * Trova il libro cercato tramite l'hashtable
 * Collega il libro al cliente che l'ha prenotato
 * Aggiunge la data della prenotazione
 * ritorna il riferimento al libro
 */
libro *collegaLibroCliente(char *isbn, char *data, cliente *c)
{
	libro *l = (libro*)malloc(sizeof(libro));
	int hashL = hash(isbn);
	l = dbL[hashL];
	l->tizio = c;
	l->data = strdup(data);
	return l;
}

/**
 * Si calcola gli hash del cliente e del libro
 * Trova il cliente dall'hashtable
 * Allarga l'array di libri presi dall'utente
 * Ci mette dentro l'hash del libro appena prenotato
 * Incrementa il numero di libri prenotati
 */
cliente *aggiungiHashLibro(char *isbn, char *cf)
{
	cliente *c = (cliente*)malloc(sizeof(cliente));
	int hashC = hash(cf);
	int hashL = hash(isbn);
	c = dbC[hashC];
	c->libri = (int*)realloc(c->libri, ((c->nLibri)+1) * sizeof(int));
	c->libri[c->nLibri] = hashL;
	(c->nLibri)++;
	return c;
}

/*
 * Creo un libro e lo metto alla fine della lista
 * Collego il libro all'hashtable
 * ritorno il riferimento alla lista
 */
libro *ins_lib(char *autore, char *titolo, char *isbn, int x, char *c1, char *c2, char *cn, libro *old)
{
	if(old == NULL)
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
		l->next = NULL;

		collegaHashLibro(l);

		return l;
	}
	else
	{
		old->next = ins_lib(autore, titolo, isbn, x, c1, c2, cn, old->next);
	}

	return old;
}


/**
 * Prendo l'hash del cliente
 * Se il cliente è già presente (trovato tramite hashtable) : Aggiungo il libro al suo array e collego il libro al cliente
 * Se il cliente non è presente : ne creo uno nuovo, lo collego all'hashtable, aggiungo il libro al suo array e collego il libro al cliente appena creato
 */
cliente *ins_cli(char *nome,char *CF, char *isbn, char *data, cliente *old)
{
	int hashC = hash(CF);
	if(dbC[hashC] == NULL)
	{
		if(old == NULL)
		{
			cliente *c = (cliente*)malloc(sizeof(cliente));
			c->nome    = strdup(nome);
			c->CF      = strdup(CF);
			c->libri = NULL;
			c->nLibri = 0;
			c->next = NULL;
			collegaHashCliente(c);
			dbC[hashC] = aggiungiHashLibro(isbn, CF);
			dbL[hash(isbn)] = collegaLibroCliente(isbn, data, c);
			return c;
		}
		else
		{
			old->next = ins_cli(nome, CF, isbn, data, old->next);
		}
	}
	else
	{
		dbC[hashC] = aggiungiHashLibro(isbn, CF);
		dbL[hash(isbn)] = collegaLibroCliente(isbn, data, dbC[hashC]);
	}

	return old;
}

