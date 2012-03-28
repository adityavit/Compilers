%{
 
#include <stdio.h>
#include <stdlib.h>

//extern int yylex();

// better error reporting
#define YYERROR_VERBOSE

// bison requires that you supply this function
void yyerror(const char *msg)
{
      printf("ERROR(PARSER): %s\n", msg);
}

// variable storage
double vars[26];
%}


%start program
%token PROGRAM PROCEDURE FUNCTION ID VAR TYPE FORWARD BEGIN END
%token IF THEN ELSE WHILE DO FOR TO
%token ARRAY OF RECORD
%token INT OR MOD AND STRING NOT
%token PLUS MINUS RELOP MUL DIV
%expect 1
%%
program : PROGRAM ID ';' typedefinitions variabledefinitions subprogramdeclerations compoundstatements '.';

typedefinitions : /* empty */
		  |TYPE typedefs;

typedefs : 	typedefinition 
	   | typedefinition typedefs;

typedefinition : ID '=' type ';';


variabledefinitions : 	/* empty */
			|VAR variabledecs;

variabledecs : variabledefinition
		| variabledefinition variabledecs;

variabledefinition : identifierlist ':' type ';' ;

subprogramdeclerations : procedureorfunctiondecleration;

procedureorfunctiondecleration : /* empty */
				| procedureorfunction procedureorfunctiondecleration;

procedureorfunction : proceduredecleration|functiondecleration ';';

proceduredecleration : PROCEDURE ID '(' formalparameterlist ')' ';' blockorforward ;

functiondecleration : FUNCTION ID '(' formalparameterlist ')' ':' resulttype ';' blockorforward ;

parameter : identifierlist ':' type;

parameterlist : parameter 
		| parameter ';' parameterlist;

formalparameterlist : /* empty */
			| parameterlist;

resulttype : ID;

blockorforward : block 
		| FORWARD;

block: variabledefinitions compoundstatements;

compoundstatements : BEGIN statementsequence END;

statementsequence : statements;

statements : statement 
	     | statement ';' statements; 

statement : simplestatement 
	    | structuredstatement;

simplestatement : /* empty*/
		 | assignmentorprocedure;

assignmentorprocedure : assignmentstatement| procedurestatement;

assignmentstatement : variable ':=' expression;

procedurestatement : ID '(' actualparameterlist ')' ;

structuredstatement : compoundstatements
		     | ifelsestatement
		     | whiledostatement
		     | forstatement;

ifelsestatement : IF expression THEN statement ELSE statement
		  |IF expression THEN statement;

whiledostatement : WHILE expression DO statement;

forstatement : FOR ID ':=' expression TO expression DO statement;

type : ID | arraytype | recordtype;

arraytype : ARRAY '[' constant '..' constant ']' OF type;

recordtype : RECORD fieldlist END;

fieldlist : formalparameterlist;

sign :	PLUS
	|MINUS;
 
constant : sign INT
	   |INT;

expression : simpleexpression relationoperator;

relationoperator : RELOP;

relationalexpression : /*empty*/
		       | relationoperator simpleexpression;	

simpleexpression : sign term addoperatorterms
		    | term addoperatorterms;

addoperatorterm : addoperator term;

addoperatorterms : /* empty */
	           | addoperatorterm addoperatorterms;
 
addoperator : PLUS 
		| MINUS 
		| OR;

muloperator : MUL 
		| DIV 
		| MOD 
		| AND;

term : factor muloperatorfactors;

muloperatorfactors : /*empty*/
		     |muloperator factor;

factor : INT
	|STRING
	|variable
	|functionreference
	|NOT factor
	|'(' expression ')';

functionreference : ID '(' actualparameterlist ')';

variable : ID
	   |ID componentselection;

variableselection : '.' variable;

componentselection  : variableselection
			|selectioncomponent;

selectioncomponent : '[' expression ']' componentselection;

actualparameterlist : /*empty*/
			| expression expressionsmany;
 
expressionsmany : /* empty*/
			| ',' expression expressionsmany;
identifierlist : ID identifierlistmany;

identifierlistmany : /*empty*/
		      | ',' ID identifierlistmany;

%%

main()
{
        yyparse();
}
