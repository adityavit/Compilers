Project 4 :- Code Generation.

Name:-Aditya Bhatia
NYU ID:- ab4239

How to run the code:-
The Code is run using flex and Bison tool.Using the following commands.
>flex Compilers_Lexical_Analyzer.lex
>bison Compilers_Parser.y -vd
>gcc Compilers_Parser.tab.c lex.yy.c -lfl -o parser
>./parser <program code file name> <output file name>

Or the Make file is also added to help the compilation for that just
issue command
>make

./parser code.pas rules.out

The output is shown on the console.

The symbol table is generated in the symtable.out file.
