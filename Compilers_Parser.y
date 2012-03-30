%{
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "link.h"
// better error reporting
#define YYERROR_VERBOSE

// bison requires that you supply this function
void yyerror(const char *msg)
{
      printf("ERROR(PARSER): %s\n", msg);
}
int paramList[100];
int paramCount=0;
int numberOfArguments = 0;
void addTypeToParams(int typeIndex){
        while(paramCount>0){
                paramCount--;
                addType(paramList[paramCount],typeIndex);        
        }
}

	extern FILE *yyin;
	extern FILE *yyout;
%}

%union{
      int id;
      int digit;
      int type;
      int identifier;
} 
%start program
%token PROGRAM PROCEDURE FUNCTION ID VAR TYPE FORWARD TBEGIN END
%token IF THEN ELSE WHILE DO FOR TO
%token ARRAY OF RECORD
%token INT OR MOD AND STRING NOT
%token PLUS MINUS RELOP MUL DIV
%token SEMICOLON DOT EQ COLEQ COMMA COLON RBRACEOPEN RBRACECLOSE SBRACEOPEN SBRACECLOSE DOUBLEDOT
%type <id> ID
%type <digit> INT;
%type <type>  type;
%type <identifier> identifierlist;
%type <identifier> variabledefinition;
%type <identifier> identifierlistmany;
%type <identifier> parameter;
%type <identifier> parameterlist;
%type <identifier> formalparameterlist;
%expect 1
%%
program : PROGRAM ID SEMICOLON typedefinitions variabledefinitions subprogramdeclerations compoundstatements DOT {fprintf(yyout,"Program\n");} ; 

typedefinitions : /* empty */
		  |TYPE typedefs {fprintf(yyout,"TYPE\n");};

typedefs : 	typedefinition 
	   | typedefinition typedefs;

typedefinition : ID EQ type SEMICOLON {fprintf(yyout,"TYPE-DEFINITION\n");if($1!=$3){addType($1,$3);}};


variabledefinitions : 	/* empty */
			|VAR variabledecs {fprintf(yyout,"VAR\n");};

variabledecs : variabledefinition
		| variabledefinition variabledecs;

variabledefinition : identifierlist COLON type SEMICOLON { fprintf(yyout,"VAR-DEFINITION\n");addType($1,$3);addTypeToParams($3);};

subprogramdeclerations : procedureorfunctiondecleration;

procedureorfunctiondecleration : /* empty */
				| procedureorfunction procedureorfunctiondecleration { fprintf(yyout,"SUB-PROGRAM-DECLERATION\n");};

procedureorfunction : proceduredecleration SEMICOLON
		      |functiondecleration SEMICOLON;

proceduredecleration : PROCEDURE ID RBRACEOPEN formalparameterlist RBRACECLOSE SEMICOLON blockorforward { fprintf(yyout,"PROCEDURE-DEFINITION\n");addFunctionParameter($2,$4);};

functiondecleration : FUNCTION ID RBRACEOPEN formalparameterlist RBRACECLOSE COLON resulttype SEMICOLON blockorforward { fprintf(yyout,"FUNCTION-DEFINITION\n");addFunctionParameter($2,$4);};

parameter : identifierlist COLON type { fprintf(yyout,"PARAMETER-DEFINITION\n");addType($1,$3);addTypeToParams($3);$$=numberOfArguments;numberOfArguments=0;};

parameterlist : parameter {$$=$1;}
		| parameter SEMICOLON parameterlist{$$=$1+$3;};

formalparameterlist : /* empty */ {$$=0;}
			| parameterlist {$$=$1};

resulttype : ID { fprintf(yyout,"RESULTYPE-DEFINITION\n");};

blockorforward : block { fprintf(yyout,"BLOCK\n");}
		| FORWARD { fprintf(yyout,"FOWARD\n");};

block: variabledefinitions compoundstatements { fprintf(yyout,"BLOCK-DEFINITION\n");};

compoundstatements : TBEGIN statementsequence END { fprintf(yyout,"COMPOUND-STATMENT-DEFINITION\n");};

statementsequence : statements { fprintf(yyout,"STATMENT-SEQUENCE-DEFINITION\n");};

statements : statement { fprintf(yyout,"SINGLE-STATEMENT\n");}
	     | statement SEMICOLON statements { fprintf(yyout,"MULTIPLE-STATEMENTS\n");}; 

statement : simplestatement { fprintf(yyout,"SIMPLE-STATMENT\n");}
	    | structuredstatement { fprintf(yyout,"STRUCTURED-STATMENT\n");};

simplestatement : /* empty*/
		 | assignmentorprocedure { fprintf(yyout,"SIMPLE-STATMENT-DEFINITION\n");};

assignmentorprocedure : assignmentstatement { fprintf(yyout,"ASSIGNMENT-STATMENT-DEFINITION\n");}
			| procedurestatement { fprintf(yyout,"PROCEDURE-STATMENT-DEFINITION\n");};

assignmentstatement : variable COLEQ expression { fprintf(yyout,"ASSIGNMENT-STATMENT\n");};

procedurestatement : ID RBRACEOPEN actualparameterlist RBRACECLOSE { fprintf(yyout,"PRCEDURE-STATMENT\n");};

structuredstatement : compoundstatements { fprintf(yyout,"COMPOUND-STATMENTS\n");}
		     | ifelsestatement { fprintf(yyout,"IF-ELSE-STATMENTS\n");}
		     | whiledostatement { fprintf(yyout,"WHILE-STATMENTS\n");}
		     | forstatement { fprintf(yyout,"FOR-STATMENTS\n");};

ifelsestatement : IF expression THEN statement ELSE statement { fprintf(yyout,"IF-THEN-ELSE-STATMENT\n");}
		  |IF expression THEN statement { fprintf(yyout,"IF-THEN-STATMENT\n");};

whiledostatement : WHILE expression DO statement { fprintf(yyout,"DO-WHILE-STATMENT\n");};

forstatement : FOR ID COLEQ expression TO expression DO statement { fprintf(yyout,"FOR-STATMENT\n");};

type : ID { $$=$1;fprintf(yyout,"TYPE-DEFINATION\n");}
       | arraytype {fprintf(yyout,"TYPE-ARRAY-DEFINITION\n");}
       | recordtype {fprintf(yyout,"TYPE-RECORD-DEFINITION\n");};

arraytype : ARRAY SBRACEOPEN constant DOUBLEDOT constant SBRACECLOSE OF type { fprintf(yyout,"ARRAY-TYPE-DEFINATION\n");};

recordtype : RECORD fieldlist END { fprintf(yyout,"RECORD-TYPE-DEFINATION\n");};

fieldlist : formalparameterlist { fprintf(yyout,"FIELDLIST-DEFINATION\n");};

sign :	PLUS { fprintf(yyout,"PLUS\n");}
	|MINUS { fprintf(yyout,"MINUS\n");};
 
constant : sign INT { fprintf(yyout,"SIGNED-INT\n");}
	   |INT { fprintf(yyout,"UNSIGNED-INT\n");};

expression : simpleexpression relationalexpression { fprintf(yyout,"EXPRESSION\n");};

relationoperator : RELOP { fprintf(yyout,"RELATIONAL-OPERATOR\n");};

relationalexpression : /*empty*/
		       | relationoperator simpleexpression { fprintf(yyout,"RELATIONAL-EXPRESSION\n");};	

simpleexpression : sign term addoperatorterms { fprintf(yyout,"SIGNED-SIMPLE-EXPRESSION\n");}
		    | term addoperatorterms { fprintf(yyout,"UNSIGNED-SIMPLE-EXPRESSION\n");};

addoperatorterm : addoperator term { fprintf(yyout,"ADDOPERATOR-TERM\n");};

addoperatorterms : /* empty */
	           | addoperatorterm addoperatorterms;
 
addoperator : PLUS { fprintf(yyout,"ADDOPERATOR-PLUS\n");}
		| MINUS { fprintf(yyout,"ADDOPERATOR-MINUS\n");}
		| OR { fprintf(yyout,"ADDOPERATOR-OR\n");};

muloperator : MUL { fprintf(yyout,"MULOPERATOR-MUL\n");}
		| DIV { fprintf(yyout,"MULOPERATOR-DIV\n");}
		| MOD { fprintf(yyout,"MULOPERATOR-MOD\n");}
		| AND { fprintf(yyout,"MULOPERATOR-AND\n");};

term : factor muloperatorfactors { fprintf(yyout,"TERM\n");};

muloperatorfactors : /*empty*/
		     |muloperator factor;

factor : INT { fprintf(yyout,"FACTOR-INT\n");}
	|STRING { fprintf(yyout,"FACTOR-STRING\n");}
	|variable { fprintf(yyout,"FACTOR-VARIABLE\n");}
	|functionreference { fprintf(yyout,"FACTOR-FUNC-REF\n");}
	|NOT factor { fprintf(yyout,"NOT-FACTOR\n");}
	|RBRACEOPEN expression RBRACECLOSE { fprintf(yyout,"FACTOR-EXPRESSION\n");};

functionreference : ID RBRACEOPEN actualparameterlist RBRACECLOSE { fprintf(yyout,"FUNCT-REF-DEFINITION\n");};

variable : ID { fprintf(yyout,"VARIABLE\n");}
	   |ID componentselection { fprintf(yyout,"VARIABLE-COMPONENT-SELECTION\n");};

variableselection : DOT variable { fprintf(yyout,"VARIABLE-SELECTION\n");};

componentselection  : variableselection
			|selectioncomponent;

selectioncomponent : SBRACEOPEN expression SBRACECLOSE componentselection { fprintf(yyout,"SELECTION COMPOENENT\n");};

actualparameterlist : /*empty*/ { fprintf(yyout,"ACTUAL-PARAMETER-LIST-EMPTY\n");}
			| expression expressionsmany { fprintf(yyout,"ACTUAL-PARAMETER-LIST\n");};
 
expressionsmany : /* empty*/
			| COMMA expression expressionsmany;
identifierlist : ID identifierlistmany { fprintf(yyout,"IDENTIFIER-LIST\n");$$=$1;numberOfArguments=$2+1;};

identifierlistmany : /*empty*/ {$$=0;}
		      | COMMA ID identifierlistmany { fprintf(yyout,"IDENTIFIER-LIST-MANY\n");paramList[paramCount]=$2;paramCount++;$$=$3+1;};

%%
//extern yydebug;
//extern errors;

	/*Creates a new Node in the linked list*/
struct lexemes* first = NULL;
struct lexemes* createNode(char * lex,int lexSize){

	struct lexemes* temp = (struct lexemes *) malloc(sizeof(struct lexemes));
	char * templexeme = (char *) malloc(lexSize +1);
	strcpy(templexeme,lex);
	temp->lexeme = templexeme;
        temp->typeNode = NULL;
	temp->next = NULL;
        temp->isType=0;
        temp->funtionParams=0;
        temp->isFunction =0;
	return temp;
}

void addFunctionParameter(int idIndex,int numberOfParams){
        struct lexemes* temp = first;
        int i=0;
        while(i<idIndex-1){
            temp = temp->next;
            i++;        
        }
        temp->funtionParams = numberOfParams;
        temp->isFunction = 1;   
}

void declareType(int typeIndex){
        struct lexemes* temp = first;
        int i = 0;
        while(i<typeIndex-1){
                temp = temp->next;
                i++;        
        }
        temp->isType = 1;
        temp->typeNode = NULL;
        return;
}
void addType(int idIndex, int typeIndex){
        struct lexemes* idNode = first;
        struct lexemes* typeNode = first;
        int i = 0;
        while(i< idIndex-1){
                idNode = idNode->next;
                i++;        
        }
        i=0;
        while(i<typeIndex-1){
                typeNode = typeNode->next;
                i++;                        
        }
        idNode->typeNode = typeNode;
        return;

}
	/*Fetches the index for the lexeme in the symbol table.*/
int fetchIndex(char *lex,int yyleng){
	struct lexemes* temp;
	int symbol_index;
	if(first == NULL){
		first = createNode(lex,yyleng);
		return 1;
	}else{
		temp = first;
		symbol_index  = 0;
		struct lexemes* lastNode;
		while(temp != NULL){
			if(strcmp(temp->lexeme,lex) == 0){
				return symbol_index + 1;
			}else{
				if(temp->next == NULL){
					lastNode = temp;	
				}
				temp = temp->next;
				symbol_index += 1;
			}
		}
		lastNode->next = createNode(lex,yyleng);
		return symbol_index+1;
		
	}
}
	/* Prints the symbol table linked list */
void printSymbolTable(){
        FILE* printFile = fopen("symtable.out","w");
        fprintf(printFile,"****************************Symbol Table**************************\n");
	fprintf(printFile,"Index\t:\tlexeme\t\t:\tType\t:\tFunction Param Number\n");
	struct lexemes* temp = first;
	int symbol_index = 0;
	while(temp != NULL){
		fprintf(printFile,"%d\t:\t%s\t",++symbol_index,temp->lexeme);
                if(temp->typeNode != NULL){
                 fprintf(printFile,"\t:\t%s",temp->typeNode->lexeme);
                }
                if(temp->isFunction == 1){
                    fprintf(printFile,"\t:\t\t:\t%d",temp->funtionParams);                    
                }
                fprintf(printFile,"\n");
		temp = temp->next;
	}
        fclose(printFile);
}
main( int argc,char* argv[])
{
	if(argc==3){
  	yyin = fopen(argv[1],"r");
	yyout = fopen(argv[2],"w");
	}else{
		printf("Improper Arguments \n 1.Input file name \n 2. Output file name\n");
	exit(-1);
	}
//	yydebug = 1;
//	errors = 0;
        yyparse();
        printSymbolTable();
}
