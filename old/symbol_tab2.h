/*
 * Massima grandezza dell'hashtable
 */
#define HASHSIZE 101


/*
 * Struttura dati del libro
 */
typedef struct l {
  char *autore,
       *titolo,
       *ISBN,
       *coll1,
       *coll2,
       *numcoll,
       *data;
  int num_pag,
      cliente;
}libro;

/*
 * Struttura dati del cliente
 */
typedef struct c {
  char *nome;
  char *CF;
}cliente;

/*
 * Database di utenti
 */
cliente *dbC[HASHSIZE];

/*
 * Database di libri
 */
libro *dbL[HASHSIZE];

/*
 * Genera l'hash
 */
unsigned int hash(char *s);

/*
 * Inserisce un libro all'interno dell'hashtable
 */
libro *ins_lib(char*,char*, char *, int, char*, char*, char*);

/*
 * Inserisce un cliente all'interno dell'hashtable
 */
cliente *ins_cli(char*, char*, char*, char*);
