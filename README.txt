Project 2 :- Syntactic Parser.

Name:-Aditya Bhatia
NYU ID:- ab4239

How to run the code:-
The Code is run using flex and Bison tool.Using the following commands.
>flex Compilers_Lexical_Analyzer.lex
>bison Compilers_Parser.y -vd
>gcc Compilers_Parser.tab.c lex.yy.c -lfl -o parser
>./parser <program code file name> <output file name>

./parser code.pas rules.out

The output is buffered to an output file whose name is given as the second argument to the code.

The parsing instruction is written into the 2 argument file.

The symbol table is generated in the symtable.out file.
