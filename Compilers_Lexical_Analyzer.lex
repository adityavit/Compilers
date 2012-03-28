/* 
 * Description: Compilers Lexical Analyzer for python like programming language.Uses Flex to generate the file.Gnerates Lexical tokens and symbol table.
 * @Author: Aditya Bhatia.
 * To run this file.
 * >flex Compilers_Lexical_Analyzer.lex
 * >gcc lex.yy.c -lfl
 * >./a.out <program code file name> <output file name>
 *
 */


digit		[0-9]
letter		[a-zA-Z]+
keyword 	program|and|begin|forward|div|do|else|end|for|function|if|array|mod|not|of|or|procedure|record|then|to|type|var|while
relop	 	"="|"<"|"<="|">"|">="|"<>"
symbols	 	"+"|"-"|"*"|"."|","|":"|";"|":="|".."|"("|")"|"["|"]"

%%
	/*Keyword Match*/
{keyword}			fprintf(yyout,"KEYWORD: %s\n",yytext);
	/*String Literal Match*/
\"{letter}*\"			fprintf(yyout,"STRING: %d %s\n",fetchIndex(yytext,yyleng),yytext);
	/*Indentifier Match */
{letter}({letter}|{digit}|_)*	fprintf(yyout,"ID: %d %s\n", fetchIndex(yytext,yyleng),yytext);
	/*Number Match*/
{digit}+			fprintf(yyout,"NUM: %d %s\n",fetchIndex(yytext,yyleng),yytext);
	/*Relational Operator Match*/
{relop}				fprintf(yyout,"RELOP: %s\n",yytext);
	/*Symbols Match*/
{symbols}			fprintf(yyout,"SYMBOL: %s\n",yytext);

	/*comments Match*/
\{([^\{\}]|.|\n)*\}			;
	/*Matches Default Characters*/
.|\n				;
%%

extern void* malloc();
struct lexemes{
	char *lexeme;	
	struct lexemes* next;
};

struct lexemes* first = NULL;
	/*Creates a new Node in the linked list*/
struct lexemes* createNode(char * lex,int lexSize){

	struct lexemes* temp = (struct lexemes *) malloc(sizeof(struct lexemes));
	char * templexeme = (char *) malloc(lexSize +1);
	strcpy(templexeme,lex);
	temp->lexeme = templexeme;
	temp->next = NULL;
	return temp;
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
	fprintf(yyout,"lexeme : Index\n");
	struct lexemes* temp = first;
	int symbol_index = 0;
	while(temp != NULL){
		fprintf(yyout,"%s : %d\n",temp->lexeme,++symbol_index);
		temp = temp->next;
	}
}
	/* Main Function */
int main(int argc,char * argv[])
{
	if(argc==3){
  	yyin = fopen(argv[1],"r");
	yyout = fopen(argv[2],"w");
	}else{
		printf("Improper Arguments \n 1.Input file name \n 2. Output file name\n");
	exit(-1);
	}
	yylex();
	fprintf(yyout,"**************Symbol Table*************\n");
	printSymbolTable();
	fclose(yyin);
	fclose(yyout);
	return 0;
}
