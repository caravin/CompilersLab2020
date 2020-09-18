%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
%}
         /* Yacc definitions */
%start start
%token SELECT PROJECT CARTESIAN_PRODUCT EQUI_JOIN NEWLINE NAME OPEN LESS GREAT EQUAL LOG COMMA ARITH STR CLOSE NUMBER OPT DOT


%%

/* descriptions of expected inputs     corresponding actions (in C) */

start: stmtlist
stmtlist:	stmt		
			|stmt stmtlist 
			
			

stmt:		SELECT LESS conditionlist1 GREAT OPEN NAME CLOSE  NEWLINE  {printf("Valid syntax\n");}
			| PROJECT LESS attributelist GREAT OPEN NAME CLOSE  NEWLINE {printf("Valid syntax\n");}
			| OPEN NAME CLOSE join  NEWLINE {printf("Valid syntax\n");}
			| error NEWLINE {yyerrok;}

join:		CARTESIAN_PRODUCT OPEN NAME CLOSE
			|EQUI_JOIN LESS conditionlist2 GREAT OPEN NAME CLOSE

conditionlist1:	NAME condition1
				|NAME condition1 LOG conditionlist1

condition1 :	 OPT expression1
				| GREAT expression1
				| LESS expression1
				| EQUAL expression1
				| EQUAL STR
expression1	:	idnum1 ARITH expression1
				|OPEN expression1 CLOSE
				|idnum1

idnum1:			NAME
				|NUMBER
				|ARITH NUMBER

conditionlist2:	NAME DOT NAME condition2 
				|NAME DOT NAME condition2 LOG conditionlist2

condition2 :	OPT expression2
				| GREAT expression2
				| LESS expression2
				| EQUAL expression2
expression2	:	idnum2 ARITH expression2
				|OPEN expression2 CLOSE
				|idnum2

idnum2:			NAME DOT NAME
				|NUMBER
				|ARITH NUMBER

attributelist :	NAME
				|NAME COMMA attributelist



%%                     /* C code */


int main (void) {
	
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "Invalid Syntax\n");}
