#include "stdio.h"
#include "stdlib.h"

char INT_TYPE[] = "integer";
int INT_TYPE_VAL = 1;
char BOOL_TYPE[] = "boolean";
int BOOL_TYPE_VAL = 2;
char STR_TYPE[] = "string";
int STR_TYPE_VAL = 3;
char ONE_VAL[] = "1";
int ONE_POS = 0;
char PLUS_SIGN[] = "+";
char MINUS_SIGN[] = "-";
char EQ_SIGN[] = "=";
char OR_SIGN[] = "or";
char MUL_SIGN[] = "*";
char DIV_SIGN[] = "/";
char AND_SIGN[] = "and";
char MOD_SIGN[] = "mod";
char RET_VAL[] = "return";
char FUN_RET[] = "funreturn";
char IF_VAL[] = "if";
char GOTO_VAL[] = "goto";
char LESS_THAN[] = "<=";
char PARAM_VAL[] = "param";
char FUN_CALL[] = "funcall";
char ARR_VAL[] = "array";
char RECORD_VAL[] = "record";

extern void* malloc();
extern struct lexemes{
	char *lexeme;
        int isType;
        int funtionParams;
        struct lexemes* typeNode;	
	struct lexemes* next;
        int isFunction;
}lexemes;

extern struct symbolTable{
	struct element* symbols;
	struct symbolTable* prev;
	struct symbolTable* next;
	char* tableName;
}symbolTable;

extern struct element{
	struct element* nextElement;
	struct lexemes* typeNode;
	struct lexemes* lexemeNode;
}element;

extern struct quadruple{
	char* op;
        char* sign;
	struct lexemes* arg1;
	struct component* subArg1;
	struct lexemes* arg2;
	struct component* subArg2;
	struct lexemes* result;
	struct component* subResult;
	struct lexemes* label;
	struct lexemes* gotoLabel;
	struct quadruple* nextRecord;
	struct quadruple* previousRecord;
}quadruple;

extern struct component{
        struct lexemes* variable;
        char* type;
        struct component* nextComponent;
}component;

struct lexemes* createNode(char * lex,int lexSize,int);
void declareType(int typeIndex);
void declareVar(int,int);
void addType(int idIndex, int typeIndex);
int fetchIndex(char *lex,int yyleng);
void printSymbolTable();
void addFunctionParameter(int idIndex,int);
struct lexemes* fetchLexemeNode(int);

/* Part3 of the project functions */
struct symbolTable* createSymbolTable();
void addSymbol(int lexemeIndex,int typeIndex);
struct element* createSymbol(int,int);
struct element* searchSymbolTable(int);
void deleteSymbolTable();
void addSymbolTable();
void printTable();
void printSymbolSearchError(int);
int checkType(int,int);
void printCheckTypeError(int,int);
int getTypeIndex(int);
int printCheckTypeResult(int,int);
struct element* searchSymbolInCurrentScope(int lexeme);

/* Part4 of the project fucntions. */
int getNewLabel();
int getNewTempVar();
void generateNewTemp(char* buffer);
void generateNewLabel(char* buffer);
struct quadruple* createQuadruple();
void addLabelToCurrentQR(int index);
void addArg1ToCurrentQR(int index);
void addArg2ToCurrentQR(int index);
void addSubArg1ToCurrentQR(int index,char*);
void addSubArg2ToCurrentQR(int index,char*);
void addResultToCurrentQR(int index);
void addSubResultToCurrentQR(int index,char*);
void addGotoLabelToCurrentQR(int index);
void addOperatorToCurrentQR(char* operator);
void addSignToCurrentQR(char* operator);
void addQRecord();
void printQRRecord();
