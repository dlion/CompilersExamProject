# CompilersExamProject
Compilers exam project

## Requirements
* bison
* flex
* gcc

## Compile
```
flex biblio.fl
bison -d biblio.y
gcc lex.yy.c symbol_tab.c biblio.tab.c -o biblio
```

## Usage
```
./biblio < prova1.txt
./biblio < prova2.txt
...
```

## Output prova1
```
Libri disponibili:
"steppa" - "Hesse Herman" - LS - SO - 127 C

Prestiti scaduti:
BNNSFN90A01G999A : 12/04/2015 88-17-83457-X, 20/09/2015 88-14-24B43-2

Pagine Lette :
"Stefano Benni": 782
"Giovanni Leto": 419
```

## Authors
* Domenico Luciani
* Andrea Pergola
* Daniela Conti

## License
MIT
