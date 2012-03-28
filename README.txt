Project 1 :- Compilers Lexical Analyzer.

Name:-Aditya Bhatia
NYU ID:- ab4239

How to run the code:-
The Code is run using flex tool.Using the following commands.
>flex Compilers_Lexical_Analyzer.lex
>gcc lex.yy.c -lfl
>./a.out <program code file name> <output file name>

The output is buffered to an output file whose name is given as the second argument to the code.

The tokens are generated as follows.
token name : token value
Keywords:-

KEYWORD: lexeme

Identifiers:-

ID: <index to the symbol table> lexeme

Numbers:-

NUM: <index to the symbol table> lexeme

Relational operators:-

RELOP: lexeme

Symbols:-

SYMBOLS: lexeme

Comments:-

No tokens

Symbol table is printed at the end of the file.

lexeme: index in the symbol table.
