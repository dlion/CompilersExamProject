%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "symbol_tab.h"

void yyerror (char const *);

char 	*dataOggi, *dataPr,
	*coll1, *coll2, *numcoll,
	*isbn, *titolo, *autore,
	*nomeC, *cf;

int 	gg, mm, aaaa,
	nPag, countISBN=0, countCF=0;
struct 	tm 	dataNow = {0},
		dataPrestito = {0};

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
				if(strcmp(coll1, "LI") == 0 && strcmp(coll2, "BO") == 0) { yyerror("Non esiste il genere LI BO"); return -1; }
				dbL[hash(isbn)] = ins_lib(autore, titolo, isbn, nPag, coll1, coll2, numcoll);
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

				sscanf(dataPr, "%d/%d/%d",&dataPrestito.tm_mday,&dataPrestito.tm_mon,&dataPrestito.tm_year);
				dataNow.tm_year -= 1900; //Perché year è il numero dell'anno dal 1900 ad "ora"
				if(dataNow.tm_mday < 01 || dataNow.tm_mday > 31 || dataNow.tm_mon < 01 || dataNow.tm_mon > 12)
				{ yyerror("Formato data errato!"); return -1; }

				int hashCF = hash(cf);
				int hashL = hash(isbn);
				dbC[hash(cf)] = ins_cli(nomeC, cf, isbn, dataPr);
				libro *l = (libro*)malloc(sizeof(libro));
				l = dbL[hashL];
				l->data = strdup(dataPr);
				l->cliente = hashCF;
				dbL[hashL] = l;
			}	
			;

%%

int main()
{
	if(yyparse() == 0)
	{
		printf("Libri disponibili:\n");
		int i;
		for(i=0; i < HASHSIZE-1; i++)
		{
			if(dbL[i] != NULL)
			{
				if(dbL[i]->cliente == -1)
				{
					printf("%s - %s - %s %s %s\n", dbL[i]->titolo, dbL[i]->autore, dbL[i]->coll1, dbL[i]->coll2, dbL[i]->numcoll);
				}
			}
		}
		printf("\nPrestito scaduto:\n");
		int j;
		int trovato=0;
		for(i=0; i < HASHSIZE-1; i++)
		{
			if(dbC[i] != NULL)
			{
				for(j=0; j < HASHSIZE-1; j++)
				{
					if(dbL[j] != NULL)
					{
						if(dbL[j]->cliente == hash(dbC[i]->CF))
						{
							sscanf(dbL[j]->data, "%d/%d/%d",
								&dataPrestito.tm_mday,
								&dataPrestito.tm_mon,
								&dataPrestito.tm_year
							);
							dataPrestito.tm_year -= 1900;
							if(dataPrestito.tm_mday < 01 || dataPrestito.tm_mday > 31 ||
							    dataPrestito.tm_mon < 01 || dataPrestito.tm_mon > 12)
							{ yyerror("Formato data errato!"); return -1; }

							time_t tNow = mktime(&dataNow);
							time_t tPr = mktime(&dataPrestito);
							time_t tDiff = difftime(tNow, tPr);
							struct tm tmDiff = *gmtime(&tDiff);

							if(tmDiff.tm_yday > 60)
							{
								if(trovato == 0)
								{
									printf("%s : ", dbC[i]->CF);
									trovato = 1;
								}
								printf("%s %s, ", dbL[j]->data, dbL[j]->ISBN);
							}
						}
					}
				}
				trovato = 0;
			}
		}						

		printf("\nPagine lette:\n");
		for(i=0; i < HASHSIZE-1; i++)
		{
			int sommaP = 0;
			if(dbC[i] != NULL)
			{
				for(j=0; j < HASHSIZE-1; j++)
				{
					if(dbL[j] != NULL)
					{
						if(dbL[j]->cliente == hash(dbC[i]->CF))
						{
							sommaP += dbL[j]->num_pag;
						}
					}
				}
				printf("%s: %d\n", dbC[i]->nome, sommaP);
			}
		}						
							
	}
	return 0;
}

void yyerror (char const *s) {
	printf("Errore: %s\n", s);
}
