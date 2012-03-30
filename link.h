#include "stdio.h"
#include "stdlib.h"

extern void* malloc();
extern struct lexemes{
	char *lexeme;
        int isType;
        int funtionParams;
        struct lexemes* typeNode;	
	struct lexemes* next;
        int isFunction;
}lexemes;

struct lexemes* createNode(char * lex,int lexSize);
void declareType(int typeIndex);
void addType(int idIndex, int typeIndex);
int fetchIndex(char *lex,int yyleng);
void printSymbolTable();
void addFunctionParameter(int idIndex,int);
