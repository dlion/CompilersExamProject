/*
 * Valore da usare per generare l'hash e grandezza massima hashtable
 */
#define HASHSIZE 101

/*
 * Struttura dati del cliente
 */
typedef struct c {
  char *nome,
       *CF;
  //Array di hash di libri
  int *libri;
  //Numero di libri associati al cliente
  int nLibri;

  struct c *next;
}cliente;

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
  int num_pag;
  struct l *next;
  //Punta al cliente che l'ha preso in prestito
  cliente *tizio;
}libro;

/*
 * HashTable di libri
 */
libro *dbL[HASHSIZE];

/*
 * Hashtable di clienti
 */
cliente *dbC[HASHSIZE];

/*
 * Genera l'hash
 */
unsigned int hash(char *s);

/**
 * Collega l'hashtable dei clienti con i vari clienti
 */
void collegaHashCliente(cliente*);

/**
 * Collega l'hashtable dei libri con i vari libri
 */
void collegaHashLibro(libro*);

/**
 * Collega un libro ad un cliente
 */
libro *collegaLibroCliente(char*, char*, cliente*);

/**
 * Inserisce l'hash di un libro associato ad un utente all'interno dell'array dei libri associati dell'utente
 */
cliente *aggiungiHashLibro(char*, char*);

/*
 * Inserisce un libro all'interno della lista
 */
libro *ins_lib(char*,char*, char *, int, char*, char*, char*, libro*);

/*
 * Inserisce un cliente all'interno della lista
 */
cliente *ins_cli(char*, char*, char*, char*, cliente*);

