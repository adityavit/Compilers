/* 
 * Description: Compilers Lexical Analyzer for python like programming language.Uses Flex to generate the file.Gnerates Lexical tokens and symbol table.
 * @Author: Aditya Bhatia.
 * To run this file.
 * >flex Compilers_Lexical_Analyzer.lex
 * gcc lex.yy.c -lfl
 * >./a.out <program code file name> <output file name>
 *
 */

%{
   #include "Compilers_Parser.tab.h"
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>
   	
%}
digit		[0-9]
letter		[a-zA-Z]+
PROGRAM         program
PROCEDURE	procedure
FUNCTION	function
TYPE		type
VAR		var
FORWARD		forward
TBEGIN		begin
END		end
IF		if
THEN		then
ELSE		else
WHILE		while
DO		do
TO		to
FOR		for
ARRAY		array
RECORD		record
OF		of
INT		int
OR		or
MOD		mod
AND		and
STRING		string
NOT		not
PLUS   		"+"
MINUS		"-"
MUL		"*"
DIV 		div
relop	 	"="|"<"|"<="|">"|">="|"<>"
SEMICOLON	";"
DOT		"."
EQ		"="
COLEQ		":="
COMMA		","
RBRACEOPEN	"("
RBRACECLOSE	")"
SBRACEOPEN	"["
SBRACECLOSE	"]"
COLON		":"
DOUBLEDOT	".."

%%
	/*Keyword Match*/
{PROGRAM}			{printresult("PROGRAM",PROGRAM);return PROGRAM;}
{PROCEDURE}			{printresult("PROCEDURE",PROCEDURE);return PROCEDURE;}
{FUNCTION}			{printresult("FUNCTION",FUNCTION);return FUNCTION;}
{TYPE}				{printresult("TYPE",TYPE);return TYPE;}
{VAR}				{printresult("VAR",VAR);return VAR;}
{FORWARD}			{printresult("FORWARD",FORWARD);return FORWARD;}
{TBEGIN}			{printresult("TBEGIN",TBEGIN);return TBEGIN;}
{END}				{printresult("END",END);return END;}
{IF}				{printresult("IF",IF);return IF;}
{THEN}				{printresult("THEN",THEN);return THEN;}
{ELSE}				{printresult("ELSE",ELSE);return ELSE;}
{WHILE}				{printresult("WHILE",WHILE);return WHILE;}
{DO}				{printresult("DO",DO);return DO;}
{TO}				{printresult("TO",TO);return TO;}
{FOR}				{printresult("FOR",FOR);return FOR;}
{ARRAY}				{printresult("ARRAY",ARRAY);return ARRAY;}
{RECORD}			{printresult("RECORD",RECORD);return RECORD;}
{OF}				{printresult("OF",OF);return OF;}
{OR}				{printresult("OR",OR);return OR;}
{MOD}				{printresult("MOD",MOD);return MOD;}
{AND}				{printresult("AND",AND);return AND;}
{NOT}				{printresult("NOT",NOT);return NOT;}
{PLUS}				{printresult("PLUS",PLUS);return PLUS;}
{MINUS}				{printresult("MINUS",MINUS);return MINUS;}
{MUL}				{printresult("MUL",MUL);return MUL;}
{DIV}				{printresult("DIV",DIV);return DIV;}
{SEMICOLON}			{printresult("SEMICOLON",SEMICOLON);return SEMICOLON;}
{DOT}				{printresult("DOT",DOT);return DOT;}
{EQ}				{printresult("EQ",EQ);return EQ;}
{COLEQ}				{printresult("COLEQ",COLEQ);return COLEQ;}
{COMMA}				{printresult("COMMA",COMMA);return COMMA;}
{COLON}				{printresult("COLON",COLON);return COLON;}
{RBRACEOPEN}			{printresult("RBRACEOPEN",RBRACEOPEN);return RBRACEOPEN;}
{RBRACECLOSE}			{printresult("RBRACECLOSE",RBRACECLOSE);return RBRACECLOSE;}
{SBRACEOPEN}			{printresult("SBRACEOPEN",SBRACEOPEN);return SBRACEOPEN;}
{SBRACECLOSE}			{printresult("SBRACECLOSE",SBRACECLOSE);return SBRACECLOSE;}
{DOUBLEDOT}			{printresult("DOUBLEDOT",DOUBLEDOT);return DOUBLEDOT;}


	/*String Literal Match*/
\"{letter}*\"			{fetchIndex(yytext,yyleng);printresult(yytext,STRING);return STRING;}
	/*Indentifier Match */
{letter}({letter}|{digit}|_)*   {yylval.id =fetchIndex(yytext,yyleng);printresult(yytext,ID);return ID;}
	/*Number Match*/
{digit}+			{yylval.digit = fetchIndex(yytext,yyleng);printresult(yytext,INT);return INT;}
	/*Relational Operator Match*/
{relop}				{printresult(yytext,RELOP);return RELOP;}
	/*comments Match*/
\{[^\}]*\}		;

[\t\n]				;
	/*Matches Default Characters*/
.				;
%%

int printresult(char* string,int returnvalue){
	//fprintf(yyout,"%s--%d\n",string,returnvalue);
	return returnvalue;

}
	/* Main Function */
/*
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
}*/
