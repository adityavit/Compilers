# Makefile for Compiers Project.
# Name : Aditya Bhatia
# Builds the parser for the project.

CC = gcc
FLEX = flex
CFLAG = -lfl
LEX_FILE = Compilers_Lexical_Analyzer.lex
YACC_FILE = Compilers_Parser.y
OUT_FILE = parser
BISON = bison

all : parser

parser: lex.yy.c Compilers_Parser.tab.c
	${CC} lex.yy.c Compilers_Parser.tab.c ${CFLAG} -o ${OUT_FILE}

lex.yy.c: ${LEX_FILE}
	${FLEX} ${LEX_FILE}
Compilers_Parser.tab.c : ${YACC_FILE}
			${BISON} ${YACC_FILE} -vd

