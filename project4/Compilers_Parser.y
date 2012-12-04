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
int tempVarCount =0;
int labelCount =0;
char* operatorStack[100];
int operatorStackHead =-1;

int labelQueue[100];
int queueStartIndex = 0;
int queueEndIndex = -1;
int labelStack[100];
int labelStackHead = -1;

void addTypeToParams(int typeIndex){
        while(paramCount>0){
                paramCount--;
                declareVar(paramList[paramCount],typeIndex);        
        }
}

void pushOperatorStack(char* operator){
        operatorStackHead++;
        char* temp = malloc(sizeof(char)*strlen(operator)+1);
        strcpy(temp,operator);
        operatorStack[operatorStackHead] = temp;
}

char* popOperatorStack(){
        char* temp = operatorStack[operatorStackHead];
        operatorStackHead--;
        return temp;
}

void enqueueLabel(int labelIndex){
        queueEndIndex++;
        labelQueue[queueEndIndex] = labelIndex;
}

int dequeueLabel(){
        int returnVal = -1;
        if(queueStartIndex <= queueEndIndex){
                returnVal = labelQueue[queueStartIndex];
                queueStartIndex++;     
        }

        return returnVal;
}
void pushLabelToStack(int labelIndex){
  labelStackHead++;
  labelStack[labelStackHead] = labelIndex;
}

int popLabelStack(){
  int temp = labelStack[labelStackHead];
  labelStackHead--;
  return temp;
}

	extern FILE *yyin;
	extern FILE *yyout;
%}

%union{
      int id;
      int digit;
      int type;
      int identifier;
      int string;
      char* token;
      char* relop;
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
%type <type>  arraytype;
%type <string> STRING;
%type <identifier> identifierlist;
%type <identifier> variabledefinition;
%type <identifier> identifierlistmany;
%type <identifier> parameter;
%type <identifier> parameterlist;
%type <identifier> formalparameterlist;
%type <identifier> variable;
%type <identifier> resulttype;
%type <identifier> factor;
%type <identifier> assignmentstatement;
%type <identifier> expression;
%type <identifier> relationalexpression;
%type <identifier> simpleexpression;
%type <identifier> addoperatorterm;
%type <identifier> addoperatorterms;
%type <identifier> term;
%type <identifier> muloperatorfactors;
%type <identifier> functionreference;
%type <identifier> expressionsmany;
%type <identifier> componentsel;
%type <identifier> componentselection;
%type <identifier> selectioncomponent
%type <token> addoperator;
%type <token> muloperator
%type <token> sign
%type <relop> relationoperator
%type <relop> RELOP
%type <relop> EQ
%expect 1
%%
program : PROGRAM ID{fprintf(yyout,"Creating a table\n");addSymbolTable($2);} SEMICOLON typedefinitions variabledefinitions subprogramdeclerations{addQRecord();addLabelToCurrentQR($2);printQRRecord();} compoundstatements DOT {fprintf(yyout,"Program\n");} ; 

typedefinitions : /* empty */
		  |TYPE typedefs {fprintf(yyout,"TYPE\n");};

typedefs : 	typedefinition 
	   | typedefinition typedefs;

typedefinition : ID EQ type SEMICOLON {fprintf(yyout,"TYPE-DEFINITION\n");if($1!=$3){addType($1,$3);}};


variabledefinitions : 	/* empty */
			|VAR variabledecs {fprintf(yyout,"VAR\n");};

variabledecs : variabledefinition
		| variabledefinition variabledecs;

variabledefinition : identifierlist COLON type SEMICOLON { fprintf(yyout,"VAR-DEFINITION\n");declareVar($1,$3);addTypeToParams($3);fprintf(yyout,"Var-definition-%d\n",$3);};

subprogramdeclerations : procedureorfunctiondecleration;

procedureorfunctiondecleration : /* empty */
				| procedureorfunction procedureorfunctiondecleration { fprintf(yyout,"SUB-PROGRAM-DECLERATION\n");};

procedureorfunction : proceduredecleration SEMICOLON
		      |functiondecleration SEMICOLON;

proceduredecleration : PROCEDURE ID  {fprintf(yyout,"Creating a table\n");addSymbolTable($2);addQRecord();addLabelToCurrentQR($2);printQRRecord();} RBRACEOPEN formalparameterlist RBRACECLOSE SEMICOLON blockorforward { fprintf(yyout,"PROCEDURE-DEFINITION\n");addFunctionParameter($2,$5);printTable();deleteSymbolTable();addQRecord();addOperatorToCurrentQR(RET_VAL);printQRRecord();};

functiondecleration : FUNCTION ID {fprintf(yyout,"Creating a table\n");addSymbolTable($2);addQRecord();addLabelToCurrentQR($2);printQRRecord();} RBRACEOPEN formalparameterlist RBRACECLOSE COLON resulttype { declareVar($2,$8); }SEMICOLON blockorforward { fprintf(yyout,"FUNCTION-DEFINITION\n");addFunctionParameter($2,$5);printTable();deleteSymbolTable();declareVar($2,$8);addQRecord();addOperatorToCurrentQR(FUN_RET);addArg2ToCurrentQR($2);printQRRecord();};

parameter : identifierlist COLON type { fprintf(yyout,"PARAMETER-DEFINITION\n");declareVar($1,$3);addTypeToParams($3);$$=numberOfArguments;numberOfArguments=0;};

parameterlist : parameter {$$=$1;}
		| parameter SEMICOLON parameterlist{$$=$1+$3;};

formalparameterlist : /* empty */ {$$=0;}
			| parameterlist {$$=$1};

resulttype : ID { fprintf(yyout,"RESULTYPE-DEFINITION\n");$$ = $1};

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

assignmentstatement : variable COLEQ expression { addResultToCurrentQR($1);printQRRecord();fprintf(yyout,"ASSIGNMENT-STATMENT\n");};

procedurestatement : ID RBRACEOPEN actualparameterlist RBRACECLOSE { fprintf(yyout,"PRCEDURE-STATMENT\n");};

structuredstatement : compoundstatements { fprintf(yyout,"COMPOUND-STATMENTS\n");}
		     | ifelsestatement { fprintf(yyout,"IF-ELSE-STATMENTS\n");}
		     | whiledostatement { fprintf(yyout,"WHILE-STATMENTS\n");}
		     | forstatement { fprintf(yyout,"FOR-STATMENTS\n");};

ifelsestatement : IF expression {addQRecord(); addOperatorToCurrentQR(IF_VAL); addArg2ToCurrentQR($2);int label = getNewLabel();enqueueLabel(label);addGotoLabelToCurrentQR(label);printQRRecord();addQRecord();label = getNewLabel();enqueueLabel(label);addGotoLabelToCurrentQR(label);printQRRecord();} THEN {int label = dequeueLabel(label);addQRecord();addLabelToCurrentQR(label);printQRRecord(); } statement { addQRecord(); int label = getNewLabel();enqueueLabel(label);addGotoLabelToCurrentQR(label);printQRRecord(); } elsestatement {addQRecord(); int label = dequeueLabel();addLabelToCurrentQR(label); printQRRecord(); fprintf(yyout,"IF-THEN-STATMENT\n");};

elsestatement : /*empty*/ {addQRecord(); int label = dequeueLabel();addLabelToCurrentQR(label); printQRRecord();}
                | ELSE {addQRecord(); int label = dequeueLabel();addLabelToCurrentQR(label); printQRRecord();} statement { fprintf(yyout,"IF-THEN-ELSE-STATMENT\n");}

whiledostatement : WHILE  {addQRecord(); int label = getNewLabel();pushLabelToStack(label);addLabelToCurrentQR(label); printQRRecord();} expression DO statement {addQRecord(); addOperatorToCurrentQR(IF_VAL); addArg2ToCurrentQR($3); int label = popLabelStack(); addGotoLabelToCurrentQR(label);printQRRecord(); fprintf(yyout,"DO-WHILE-STATMENT\n");};

forstatement : FOR ID COLEQ expression TO expression DO {addQRecord(); addResultToCurrentQR($2); addArg1ToCurrentQR($4);printQRRecord(); addQRecord(); int label = getNewLabel();int temp = getNewTempVar(); addOperatorToCurrentQR(LESS_THAN); addArg1ToCurrentQR($2); addResultToCurrentQR(temp); addArg2ToCurrentQR($6); addQRecord(); addOperatorToCurrentQR(IF_VAL); addArg2ToCurrentQR(temp); int afterLabel = getNewLabel(); pushLabelToStack(afterLabel);addGotoLabelToCurrentQR(label); pushLabelToStack(label);addQRecord(); addGotoLabelToCurrentQR(afterLabel);addQRecord();addLabelToCurrentQR(label); printQRRecord();addQRecord(); addResultToCurrentQR($2);addArg1ToCurrentQR($2); addOperatorToCurrentQR(PLUS_SIGN); addArg2ToCurrentQR(ONE_POS); printQRRecord();} statement {addQRecord(); int temp = getNewTempVar(); addResultToCurrentQR(temp);addArg1ToCurrentQR($2); addOperatorToCurrentQR(LESS_THAN);addArg2ToCurrentQR($6);printQRRecord(); addQRecord(); addOperatorToCurrentQR(IF_VAL); addArg2ToCurrentQR(temp); int label = popLabelStack(); addGotoLabelToCurrentQR(label); printQRRecord();addQRecord();int afterLabel = popLabelStack();addLabelToCurrentQR(afterLabel); fprintf(yyout,"FOR-STATMENT\n");};

type : ID { $$=$1;fprintf(yyout,"TYPE-DEFINATION\n");}
       | arraytype {$$=$1;fprintf(yyout,"TYPE-ARRAY-DEFINITION\n");}
       | recordtype {fprintf(yyout,"TYPE-RECORD-DEFINITION\n");};

arraytype : ARRAY SBRACEOPEN constant DOUBLEDOT constant SBRACECLOSE
 OF type { $$=$8;fprintf(yyout,"ARRAY-TYPE-DEFINATION\n");};

recordtype : RECORD fieldlist END { fprintf(yyout,"RECORD-TYPE-DEFINATION\n");};

fieldlist : formalparameterlist { fprintf(yyout,"FIELDLIST-DEFINATION\n");};

sign :	PLUS { $$ = PLUS_SIGN;fprintf(yyout,"PLUS\n");}
	|MINUS { $$ = MINUS_SIGN;fprintf(yyout,"MINUS\n");};
 
constant : sign INT { fprintf(yyout,"SIGNED-INT\n");}
	   |INT { fprintf(yyout,"UNSIGNED-INT\n");};

expression : simpleexpression relationalexpression { $$ = $1;if($2>0){ addArg1ToCurrentQR($1);int temp = getNewTempVar();$$=temp; addResultToCurrentQR(temp);printQRRecord(); }fprintf(yyout,"EXPRESSION\n");};

relationoperator : RELOP {  char* relop = malloc(sizeof(char)*strlen($1)+1); strcpy(relop,$1); $$ = relop; fprintf(yyout,"RELATIONAL-OPERATOR\n");}
		   |EQ { char* relop = malloc(sizeof(char)*strlen($1)+1); strcpy(relop,$1); $$ = relop; fprintf(yyout,"EQUAL-OPERATOR\n");}

relationalexpression : /*empty*/ {$$ = -2}
		       | relationoperator simpleexpression { $$ = $2;addQRecord(); addArg2ToCurrentQR($2);addOperatorToCurrentQR($1); fprintf(yyout,"RELATIONAL-EXPRESSION\n");};	

simpleexpression : sign term addoperatorterms { addQRecord();addSignToCurrentQR($1); $$=$2;addArg1ToCurrentQR($2);if($3>0){int temp = getNewTempVar();$$=temp; addResultToCurrentQR(temp);addArg2ToCurrentQR($3); char* operator =popOperatorStack();addOperatorToCurrentQR(operator);free(operator);}fprintf(yyout,"SIGNED-SIMPLE-EXPRESSION\n");}

		    | term addoperatorterms { addQRecord(); addArg1ToCurrentQR($1);$$=$1;if($2>0){ int temp = getNewTempVar(); $$=temp; addResultToCurrentQR(temp);addArg2ToCurrentQR($2); char* operator =popOperatorStack();addOperatorToCurrentQR(operator);free(operator);}printQRRecord();fprintf(yyout,"UNSIGNED-SIMPLE-EXPRESSION\n")};

addoperatorterm : addoperator{pushOperatorStack($1);} term { $$ = $3;fprintf(yyout,"ADDOPERATOR-TERM\n");};

addoperatorterms : /* empty */ {$$ = -2;}
	           | addoperatorterm addoperatorterms {if($2>0){ addQRecord(); int temp = getNewTempVar(); addArg1ToCurrentQR($1);addArg2ToCurrentQR($2);  addResultToCurrentQR(temp);$$ =temp;char* operator =popOperatorStack();addOperatorToCurrentQR(operator);free(operator);printQRRecord();} };
 
addoperator : PLUS { $$ = PLUS_SIGN; fprintf(yyout,"ADDOPERATOR-PLUS\n");}
		| MINUS { $$ = MINUS_SIGN; fprintf(yyout,"ADDOPERATOR-MINUS\n");}
		| OR { $$ = OR_SIGN; fprintf(yyout,"ADDOPERATOR-OR\n");};

muloperator : MUL { $$ = MUL_SIGN;fprintf(yyout,"MULOPERATOR-MUL\n");}
		| DIV { $$ = DIV_SIGN; fprintf(yyout,"MULOPERATOR-DIV\n");}
		| MOD { $$ = MOD_SIGN; fprintf(yyout,"MULOPERATOR-MOD\n");}
		| AND { $$ = AND_SIGN; fprintf(yyout,"MULOPERATOR-AND\n");};

term : factor muloperatorfactors { if($2>0){ addQRecord(); int temp = getNewTempVar(); addArg1ToCurrentQR($1);addArg2ToCurrentQR($2);  addResultToCurrentQR(temp);char* operator =popOperatorStack();addOperatorToCurrentQR(operator);free(operator);printQRRecord();$$ = temp;}else{ $$=$1;}fprintf(yyout,"TERM\n");};

muloperatorfactors : /*empty*/ {$$ = -2;} 
		     |muloperator {pushOperatorStack($1);}factor{$$=$3};

factor : INT { fprintf(yyout,"FACTOR-INT\n");$$ = $1;}
	|STRING { fprintf(yyout,"FACTOR-STRING\n");$$ = $1;}
	|variable { $$=$1;fprintf(yyout,"FACTOR-VARIABLE\n");}
	|functionreference {addQRecord(); int temp = getNewTempVar();addResultToCurrentQR(temp);addOperatorToCurrentQR(FUN_CALL); addArg2ToCurrentQR($1); $$=temp;printQRRecord(); fprintf(yyout,"FACTOR-FUNC-REF\n");}
	|NOT factor { $$=$2;fprintf(yyout,"NOT-FACTOR\n");}
	|RBRACEOPEN expression RBRACECLOSE { $$=$2;fprintf(yyout,"FACTOR-EXPRESSION\n");};

functionreference : ID RBRACEOPEN actualparameterlist RBRACECLOSE { $$=$1;fprintf(yyout,"FUNCT-REF-DEFINITION\n");};

variable : ID componentselection { $$=$1; if($2>0){ int temp = getNewTempVar(); addArg1ToCurrentQR($1); addArg2ToCurrentQR($2); addResultToCurrentQR(temp); $$=temp; printQRRecord();}printSymbolSearchError($1); fprintf(yyout,"VARIABLE-COMPONENT-SELECTION\n");};

componentselection : /*empty*/ {$$ =-2;}
                      | componentsel { $$ = $1;fprintf(yyout,"COMPONENT-SELECTION\n");};

componentsel  :         DOT ID componentselection { addQRecord(); addOperatorToCurrentQR(RECORD_VAL); $$ = $2;}
			|selectioncomponent {addQRecord(); addOperatorToCurrentQR(ARR_VAL); $$=$1;};

selectioncomponent : SBRACEOPEN expression SBRACECLOSE componentselection { $$ = $2; fprintf(yyout,"SELECTION COMPOENENT\n");};

actualparameterlist : /*empty*/ { fprintf(yyout,"ACTUAL-PARAMETER-LIST-EMPTY\n");}
			| expression { addQRecord(); addOperatorToCurrentQR(PARAM_VAL); addArg2ToCurrentQR($1); printQRRecord();} expressionsmany  { if($3>0){addQRecord(); addOperatorToCurrentQR(PARAM_VAL); addArg2ToCurrentQR($3); printQRRecord(); } fprintf(yyout,"ACTUAL-PARAMETER-LIST\n");};
 
expressionsmany : /* empty*/ {$$ = -2;}
			| COMMA expression expressionsmany { $$ =$2;};
identifierlist : ID identifierlistmany { fprintf(yyout,"IDENTIFIER-LIST\n");$$=$1;numberOfArguments=$2+1;};

identifierlistmany : /*empty*/ {$$=0;}
		      | COMMA ID identifierlistmany { fprintf(yyout,"IDENTIFIER-LIST-MANY\n");paramList[paramCount]=$2;paramCount++;$$=$3+1;};

%%
//extern yydebug;
//extern errors;

struct lexemes* first = NULL;
struct symbolTable* table = NULL;
struct symbolTable* currentTable = NULL;
struct quadruple* quadruples = NULL;
struct quadruple* currentQuadRuple = NULL;

/* ------- Functions for Part4 of Project ----- */

struct quadruple* createQuadruple(){
	struct quadruple* tempQuadruple = malloc(sizeof(struct quadruple));
	tempQuadruple->op = NULL;
	tempQuadruple->sign = NULL;
	tempQuadruple->arg1 = NULL;
	tempQuadruple->arg2 = NULL;
	tempQuadruple->subArg1 = NULL;
	tempQuadruple->subArg2 = NULL;
	tempQuadruple->result = NULL;
	tempQuadruple->subResult = NULL;
	tempQuadruple->label = NULL;
	tempQuadruple->gotoLabel = NULL;
	tempQuadruple->nextRecord = NULL;
	tempQuadruple->previousRecord = NULL;
	return tempQuadruple;
}

void addQRecord(){
	if(quadruples == NULL){
		quadruples = createQuadruple();
		currentQuadRuple = quadruples;
	}else{
		struct quadruple* tempQR;
		tempQR = createQuadruple();
		currentQuadRuple->nextRecord = tempQR;
		tempQR->previousRecord = currentQuadRuple;
		currentQuadRuple = tempQR;
	}    
}

void addLabelToCurrentQR(int index){
        if(index>0)
	currentQuadRuple->label = fetchLexemeNode(index);
}

void addArg1ToCurrentQR(int index){
        if(index>0)
	currentQuadRuple->arg1 = fetchLexemeNode(index);
}

void addArg2ToCurrentQR(int index){
        if(index>0){
	currentQuadRuple->arg2 = fetchLexemeNode(index);
        }
}

void addSubArg1ToCurrentQR(int index,char* type){
        if(index>0){
        struct component* comp = malloc(sizeof(struct component));
        comp->variable = fetchLexemeNode(index);
        char* typeVal = malloc(sizeof(char)*strlen(type)+1);
        strcpy(typeVal,type);
        comp->type = typeVal;
        comp->nextComponent = NULL;
	currentQuadRuple->subArg1 = comp;
        }
}

void addSubArg2ToCurrentQR(int index,char* type){
        if(index>0){
        struct component* comp = malloc(sizeof(struct component));
        comp->variable = fetchLexemeNode(index);
        char* typeVal = malloc(sizeof(char)*strlen(type)+1);
        strcpy(typeVal,type);
        comp->type = typeVal;
        comp->nextComponent = NULL;
	currentQuadRuple->subArg2 = comp;
        }
}

void addResultToCurrentQR(int index){
        if(index>0)
	currentQuadRuple->result = fetchLexemeNode(index);
}

void addSubResultToCurrentQR(int index,char* type){
        if(index>0){
        struct component* comp = malloc(sizeof(struct component));
        comp->variable = fetchLexemeNode(index);
        char* typeVal = malloc(sizeof(char)*strlen(type)+1);
        strcpy(typeVal,type);
        comp->type = typeVal;
        comp->nextComponent = NULL;
	currentQuadRuple->subResult = comp;
        }
}

void addOperatorToCurrentQR(char* operator){
	char* tempString = malloc(sizeof(char)*strlen(operator)+1);
	strcpy(tempString,operator);
	currentQuadRuple->op = tempString;
}
void addSignToCurrentQR(char* operator){
	char* tempString = malloc(sizeof(char)*strlen(operator)+1);
	strcpy(tempString,operator);
	currentQuadRuple->sign = tempString;
}
void addGotoLabelToCurrentQR(int index){
        if(index>0)
	currentQuadRuple->gotoLabel = fetchLexemeNode(index);
}
void printQRRecord(){
        return;
	struct quadruple* temp = currentQuadRuple;
	if(temp->label != NULL){
		printf("%s:",temp->label->lexeme);
	}
	if(temp->result != NULL){
		printf("%s := ",temp->result->lexeme);
	}
        if(temp->sign != NULL){
		printf(" %s ",temp->sign);
	}
	if(temp->arg1 != NULL){
		printf("%s",temp->arg1->lexeme);
	}
	if(temp->op != NULL){
                if(strcmp(temp->op,ARR_VAL) !=0 && strcmp(temp->op,RECORD_VAL) !=0){
		printf(" %s ",temp->op);
                }
	}
	if(temp->arg2 != NULL){
              if(temp->op != NULL){
                 if(strcmp(temp->op,ARR_VAL) ==0){
		        printf("[%s]",temp->arg2->lexeme);
                }else if(strcmp(temp->op,RECORD_VAL) ==0){
                      printf(".%s",temp->arg2->lexeme);                   
                }else{
                      printf("%s",temp->arg2->lexeme);   
                     }
              }else{
                    printf("%s",temp->arg2->lexeme);     
                }
        
	}
        if(temp->gotoLabel != NULL){
		printf(" goto %s",temp->gotoLabel->lexeme);
	}
        printf("\n");
}

void printSingleQRRecord(struct quadruple* temp1){
	struct quadruple* temp = temp1;
	if(temp->label != NULL){
		printf("%s:",temp->label->lexeme);
	}
	if(temp->result != NULL){
		printf("%s := ",temp->result->lexeme);
	}
        if(temp->sign != NULL){
		printf(" %s ",temp->sign);
	}
	if(temp->arg1 != NULL){
                if(temp->result != NULL){
		printf("%s",temp->arg1->lexeme);
                }
	}
	if(temp->op != NULL){
                if(strcmp(temp->op,ARR_VAL) !=0 && strcmp(temp->op,RECORD_VAL) !=0){
		printf(" %s ",temp->op);
                }
	}
	if(temp->arg2 != NULL){
              if(temp->op != NULL){
                 if(strcmp(temp->op,ARR_VAL) ==0){
		        printf("[%s]",temp->arg2->lexeme);
                }else if(strcmp(temp->op,RECORD_VAL) ==0){
                      printf(".%s",temp->arg2->lexeme);                   
                }else{
                      printf("%s",temp->arg2->lexeme);   
                     }
              }else{
                    printf("%s",temp->arg2->lexeme);     
                }
        
	}
        if(temp->gotoLabel != NULL){
		printf(" goto %s",temp->gotoLabel->lexeme);
	}
        printf("\n");
}


void printQuadruple(){
        struct quadruple* temp = quadruples;
        while(temp!=NULL){
               printSingleQRRecord(temp);
                temp = temp->nextRecord;
        }
}


int getNewLabel(){
	char* prefix = malloc(sizeof(char)*10);
	prefix[0] = 'L';
	generateNewLabel(prefix);
	return fetchIndex(prefix,strlen(prefix));
	free(prefix);
}
int getNewTempVar(){
	char* prefix = malloc(sizeof(char)*10);;
	prefix[0] = '_';
	prefix[1] = 't';
	generateNewTemp(prefix);
	return fetchIndex(prefix,strlen(prefix));
	free(prefix);
}

/*
 * Generates a new Temp Variable.
 */
void generateNewTemp(char* buffer){
	char intBuffer[5];
	sprintf(intBuffer,"%d",tempVarCount);
	tempVarCount++;
	strcat(buffer,intBuffer);
}
/*
 * Generates a New Label.
 */
void generateNewLabel(char* buffer){
	char intBuffer[5];
        sprintf(intBuffer,"%d",labelCount);
        labelCount++;
        strcat(buffer,intBuffer);
}

/* ------ Functions for Part3 of Project ----- */
struct symbolTable* createSymbolTable(){
	struct symbolTable* temp = (struct symbolTable*)malloc(sizeof(struct symbolTable));
	temp->symbols = NULL;
	temp->next = NULL;
	temp->prev = NULL;
	return temp;
}

void addSymbolTable(int tableNameIndex){
	struct symbolTable *tempTable;
	struct lexemes* lexemeTemp = first;
	int i =0;
	while(i<tableNameIndex-1){
		lexemeTemp = lexemeTemp->next;
		i++;
	}
	if(table == NULL){
		table = createSymbolTable();
		table->tableName = lexemeTemp->lexeme;
		currentTable = table;
	}else{
		tempTable = createSymbolTable();
		tempTable->prev = currentTable;
		currentTable->next = tempTable;
		currentTable = tempTable;
		currentTable->tableName = lexemeTemp->lexeme;
	}
}

void deleteSymbolTable(){
	struct symbolTable *tempTable;
	tempTable = currentTable;
	currentTable = tempTable->prev;
	free(tempTable);
	currentTable->next = NULL;
}

/*
 * Searches the current Symbol table.
 * Returns 1 if found else 0 if not found. 
 */

struct element*  searchSymbolTable(int lexemeIndex){
	struct symbolTable *tempTable = currentTable;
	struct lexemes* tempLexeme= first;
	struct element* tempElement;
	int i=0;
	struct element* elementFound = NULL;
	while(i<lexemeIndex-1){
		tempLexeme = tempLexeme->next;
		i++;
	}
	while(tempTable!=NULL){
		tempElement = tempTable->symbols;
		elementFound = NULL;
		while(tempElement != NULL){
			if(tempElement->lexemeNode == tempLexeme){
			//	printf("Identifier %s defined in scope\n",tempLexeme->lexeme);
				elementFound = tempElement;
				break;
			}
			tempElement = tempElement->nextElement;
		}
		if(elementFound != NULL){
			break;
		}
		tempTable = tempTable->prev;
	}
	//if(elementFound == 0){
	//	printf("Error :: Identifier %s not defined\n",tempLexeme->lexeme);
	//}
	return elementFound; 	
}
struct element* searchSymbolInCurrentScope(int lexeme){
	struct symbolTable *tempTable = currentTable;
	struct lexemes* tempLexeme = fetchLexemeNode(lexeme);
	struct element* tempElement;

	tempElement = tempTable->symbols;
	while(tempElement != NULL){
		if(tempElement->lexemeNode == tempLexeme){
			return tempElement;
		}
		tempElement = tempElement->nextElement;
	}
	return NULL;
}
/**
 * Print Search result of the identifier in the current Scope.
 */
void printSymbolSearchError(int lexemeIndex){
	if(NULL == searchSymbolTable(lexemeIndex)){
		printf("Error :: %s has not been declared\n",fetchLexemeNode(lexemeIndex)->lexeme);
	}
}

/**
 * Checktype of two lexemes.
 * If the type matches it returns 1.
 * else it returns 0.
 */

int checkType(int lValueIndex,int typeIndex){
	if(NULL != searchSymbolTable(lValueIndex)){
  		if(searchSymbolTable(lValueIndex)->typeNode == fetchLexemeNode(typeIndex)){
  			return 1;
		}
	}
	return 0;
}

/*
 * Prints the type Error Check for lvalue and rvalue.
 */

void printCheckTypeError(int lValueIndex,int typeIndex){
//	printf("typeIndex=%d\n",typeIndex);
	if(0 < typeIndex){
		if(checkType(lValueIndex,typeIndex) == 0){
			printf("Error:: Assignment of %s and cannot be made to %s\n",fetchLexemeNode(lValueIndex)->lexeme,fetchLexemeNode(typeIndex)->lexeme);
		}
	}else{
		printf("Error:: Assignment of lvalue=%s with undefined value\n",fetchLexemeNode(lValueIndex)->lexeme);
	}
}

/*
 * Does the type check for the for the lside and rside besides the operator.
 */
int printCheckTypeResult(int lside,int rside){
//	printf("lside=%d,rside=%d\n",lside,rside);
	if(lside == rside){
	 return lside;
	}else{
           if(lside == -2){
		return rside;
		}else if(rside == -2){
		 return lside;
		}
	}
	return -1;
}
/**
 * Adds the symbol table to the currentSymbol Table.
 * If already declared in the scope errors out and returns.
 */
void addSymbol(int lexemeIndex,int typeIndex){
	//printf("adding symbol %d of type %d\n",lexemeIndex,typeIndex);
	struct element* temp;
	struct element* lastNode;
	if(NULL != searchSymbolInCurrentScope(lexemeIndex)){
		printf("Error:: Multiple decleration of the identifier %s\n",fetchLexemeNode(lexemeIndex)->lexeme);
		return;
	}
	temp = currentTable->symbols;
	if(currentTable->symbols == NULL){
		currentTable->symbols = createSymbol(lexemeIndex,typeIndex);
	}else{
		while(temp != NULL){
			if(temp->nextElement == NULL){
				lastNode = temp;
			}
			temp = temp->nextElement;
		}
		lastNode->nextElement = createSymbol(lexemeIndex,typeIndex);
	}
}
/*
 * Creates a memory allocation for the symbol.
 */
struct element* createSymbol(int lexemeIndex, int typeIndex){
	struct element* tempElem = (struct element*) malloc(sizeof(struct element));
	struct lexemes* temp = first;
	struct lexemes* type = NULL;
	int i=0;
	while(i<lexemeIndex-1){
	temp = temp->next;
	i++;
	}
	tempElem->lexemeNode = temp;
	temp = first;
	i=0;
	while(i<typeIndex-1){
		temp=temp->next;
		i++;
	}
	type = temp;
	while(temp->typeNode != NULL){
		temp = temp->typeNode;	
	}
	if(0 < temp->isType){
		tempElem->typeNode = temp;
	}else{
		tempElem->typeNode = type;
		printf("Error:Type %s not defined but used\n",type->lexeme); 
	}
	tempElem->nextElement = NULL;
	return tempElem;
}

/**
 * Prints the current Symbol Table.
 */
void printTable(){
	struct symbolTable* temp = currentTable;
	struct element* tempElem;
        FILE* printFile = fopen("symtable.out","a");
	while(temp!= NULL){
	fprintf(printFile,"****************************Symbol Table %s **************************\n",temp->tableName);
		tempElem = temp->symbols;
		while(tempElem != NULL){
			fprintf(printFile,"lexeme = %s\t",tempElem->lexemeNode->lexeme);
			fprintf(printFile,"type = %s\n",tempElem->typeNode->lexeme);
			tempElem = tempElem->nextElement;
		}
		temp= temp->next;
	}
	fclose(printFile);
}

/**
 * Fetches the Lexeme Node based on the lexemeIndex.
 */

struct lexemes* fetchLexemeNode(int lexemeIndex){
	struct lexemes* tempLexeme = first;
	int i=0;
	while(i<lexemeIndex-1){
		tempLexeme = tempLexeme->next;
		i++;
	}
	return tempLexeme;
}

/*
 * Returns the typeNode index for the identifier
 */
int getTypeIndex(int lexemeIndex){
	struct element* elementNode = searchSymbolTable(lexemeIndex);
	if(elementNode != NULL){
		return fetchIndex(elementNode->typeNode->lexeme,strlen(elementNode->typeNode->lexeme));	
	}else{
	 	///addingprintf("Error:: Symbol %s Not declared in scope \n",fetchLexemeNode(lexemeIndex)->lexeme);
	}
	return -1;
}
	/*Creates a new Node in the linked list*/
struct lexemes* createNode(char * lex,int lexSize,int isType){

	struct lexemes* temp = (struct lexemes *) malloc(sizeof(struct lexemes));
	char * templexeme = (char *) malloc(lexSize +1);
	strcpy(templexeme,lex);
	temp->lexeme = templexeme;
        temp->typeNode = NULL;
	temp->next = NULL;
	temp->isType=isType;
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
        temp->isType = getType(temp->lexeme);
	if(0 > temp->isType){
		printf("Error:: %s is not a valid type\n",temp->lexeme);	
	}
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

/* 
 * Declare variables in the current Scope.
 */

void declareVar(int varIndex,int typeIndex){
	addSymbol(varIndex,typeIndex);
	addType(varIndex,typeIndex);
}
/*Returns the type Value after string Comparision from lex*/
int getType(char *lex){
	int isType = -1;
	if(0 == strcmp(INT_TYPE,lex)){
		isType = INT_TYPE_VAL;
	}else if(0 == strcmp(BOOL_TYPE,lex)){
		isType = BOOL_TYPE_VAL;
	}else if(0 == strcmp(STR_TYPE,lex)){
		isType = STR_TYPE_VAL;
	}
	return isType;
}
	/*Fetches the index for the lexeme in the symbol table.*/
int fetchIndex(char *lex,int yyleng){
	struct lexemes* temp;
	int symbol_index;
	int isType = getType(lex);
	if(first == NULL){
		first = createNode(lex,yyleng,isType);
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
		lastNode->next = createNode(lex,yyleng,isType);
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

	ONE_POS = fetchIndex(ONE_VAL,strlen(ONE_VAL));
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
//	printTable();

        printQuadruple();
        printSymbolTable();
}
