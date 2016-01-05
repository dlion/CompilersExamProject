%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "symbol_tab.h"
int yylex();
void yyerror (char const *);

//Dichiaro le variabili
char 	*dataOggi, *dataPr,
	*coll1, *coll2, *numcoll,
	*isbn, *titolo, *autore,
	*nomeC, *cf;

int 	gg, mm, aaaa,
	nPag, primo=0;
struct 	tm 	dataNow = {0},
		dataPrestito = {0},
		tmDiff;
time_t tNow, tPr, tDiff;

//Inizializzo le liste dei libri e dei clienti
libro *listaL=NULL;
cliente *listaC=NULL;

%}

%union
{
    int intero;
    char *stringa;
}

%start Input
%left TESTO

%token SP1 SP2 SEP_SCRIT SEP_LIST FIN_LIST CAMPO_LIBRO
%token <stringa> TESTO ISBN COLL1 COLL2 CF DATA NUM_COLL
%token <intero> NUM_PAG


%%
Input: 			Sezione1 SP1 Sezione2 SP2 Sezione3
     			;

Sezione1:		DATA
			{
				//Salvo la data in cui viene processato il file e controllo che rispetti lo standard
				dataOggi=$1;
				sscanf(dataOggi, "%d/%d/%d",&dataNow.tm_mday,&dataNow.tm_mon,&dataNow.tm_year);
				dataNow.tm_year -= 1900; //Perché year è il numero dell'anno dal 1900 ad "ora"
				if(dataNow.tm_mday < 01 || dataNow.tm_mday > 31 || dataNow.tm_mon < 01 || dataNow.tm_mon > 12)
				{ yyerror("Formato data errato!"); return -1; }
			}
			;

Sezione2: 		Nome_autore ElencoLibri Sezione2
			| Nome_autore ElencoLibri
			;

Nome_autore: 		TESTO SEP_SCRIT  { free(autore); autore = $1; }
			;

ElencoLibri:  		StrutturaLibro SEP_LIST ElencoLibri
			| StrutturaLibro FIN_LIST
			;

StrutturaLibro: 	ISBN CAMPO_LIBRO TESTO CAMPO_LIBRO NUM_PAG CAMPO_LIBRO COLL1 COLL2 NUM_COLL
	      		{
				free(isbn); isbn=$1;
				free(titolo); titolo=$3;
				nPag=$5;
				free(coll1); coll1=$7;
				free(coll2); coll2=$8;
				free(numcoll); numcoll=$9;
				//Se ho le categorie LI e BO dà errore
				if(strcmp(coll1, "LI") == 0 && strcmp(coll2, "BO") == 0)
				{
					yyerror("Non esiste il genere LI BO");
				}
				//Creo un libro e lo aggiungo in coda alla lista
				listaL = ins_lib(autore, titolo, isbn, nPag, coll1, coll2, numcoll, listaL);
			}
			;

Sezione3: 		/* Empty */
			| InizioSezione3
			;

InizioSezione3:		Nome_cliente Elenco_prenotazioni InizioSezione3
			| Nome_cliente Elenco_prenotazioni
			;

Nome_cliente: 		TESTO CAMPO_LIBRO CF CAMPO_LIBRO
	    		{
				free(nomeC); nomeC = $1;
				free(cf); cf = $3;
			}
			;

Elenco_prenotazioni: 	Prenotazioni SEP_LIST Elenco_prenotazioni
			| Prenotazioni FIN_LIST
			;

Prenotazioni: 		DATA ISBN
	    		{
				free(dataPr); dataPr = $1;
				free(isbn); isbn = $2;
				//Prendo la data del prestito e controllo che rispetti lo standard
				sscanf(dataPr, "%d/%d/%d",&dataPrestito.tm_mday,&dataPrestito.tm_mon,&dataPrestito.tm_year);
				dataNow.tm_year -= 1900; //Perché year è il numero dell'anno dal 1900 ad "ora"
				if(dataNow.tm_mday < 01 || dataNow.tm_mday > 31 || dataNow.tm_mon < 01 || dataNow.tm_mon > 12)
				{ yyerror("Formato data errato!"); return -1; }
				//Creo un cliente e lo aggiungo in coda alla lista
				listaC = ins_cli(nomeC, cf, isbn, dataPr, listaC);
			}
			;

%%

int main()
{
	if(yyparse() == 0)
	{
		printf("Libri disponibili:\n");
		libro *i = (libro*)malloc(sizeof(libro));
		//Scorro la lista
		for(i=listaL; i != NULL; i=i->next)
		{
			//Se il libro non è associato a nessun utente questo è disponibile
			if(i->tizio == NULL)
			{
				printf("%s - %s - %s - %s - %s\n", i->titolo, i->autore, i->coll1, i->coll2, i->numcoll);
			}


		}
		free(i);

		printf("\nPrestiti scaduti:\n");
		cliente *j = (cliente*)malloc(sizeof(cliente));
		//Scorro la lista dei clienti
		for(j=listaC; j != NULL; j=j->next)
		{
			int k;
			//Scorro l'array dei libri presi dall'utente
			for(k=0; k < j->nLibri; k++)
			{
				int hashL = j->libri[k];
				sscanf(dbL[hashL]->data, "%d/%d/%d", &dataPrestito.tm_mday, &dataPrestito.tm_mon, &dataPrestito.tm_year);
				dataPrestito.tm_year -= 1900;
				//Ricontrollo che la data rispetti lo standard
				if(dataPrestito.tm_mday < 01 || dataPrestito.tm_mday > 31 ||dataPrestito.tm_mon < 01 || dataPrestito.tm_mon > 12)
				{
					yyerror("Formato data errato!");
					return -1;
				}

				tNow = mktime(&dataNow);
				tPr = mktime(&dataPrestito);
				tDiff = difftime(tNow, tPr);
				tmDiff = *gmtime(&tDiff);
				//Se la data è vecchia di 60 giorni da oggi mettilo in output
				if(tmDiff.tm_yday > 60)
				{
					//Così stampo solo una volta cliente associato
					if(primo == 0)
					{
						printf("%s : ", j->CF);
						primo = 1;
					}
					printf("%s %s", dbL[hashL]->data, dbL[hashL]->ISBN);
					//Così evito la virgola alla fine dell'array di libri associati all'utente
					if((k+1) < (j->nLibri-1)) printf(", ");
				}
			}
			putchar('\n');
			primo = 0;
		}
		free(j);

		printf("Pagine Lette :\n");
		j = (cliente*)malloc(sizeof(cliente));
		//Scorro la lista dei clienti
		for(j=listaC; j != NULL; j=j->next)
		{
			int k;
			int sommaP=0;
			//Scorro l'array di libri associati all'utente
			for(k=0; k < j->nLibri; k++)
			{
				int hashL = j->libri[k];
				//Sommo il numero di pagine di libri associati all'utente
				sommaP += dbL[hashL]->num_pag;
			}
			printf("%s: %d\n", j->nome, sommaP);
		}
		free(j);
	}
	return 0;
}

void yyerror (char const *s) {
	printf("Errore: %s\n", s);
}
