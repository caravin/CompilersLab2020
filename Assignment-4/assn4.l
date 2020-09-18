%{
#include "assn4.tab.h"
#include <string.h>
%}
%option yylineno	


%%
"SELECT"				return SELECT;	//token for SELECT
"PROJECT"				return PROJECT;	//token for PROJECT
"CARTESIAN_PRODUCT"	    return CARTESIAN_PRODUCT;	//token for CARTESIAN_PRODUCT
"EQUI_JOIN"				return EQUI_JOIN;	//token for EQUI_JOIN
"<"						return LESSER;//LESS	//token for less than or open angle brace
">"						return GREATER; //GREAT	//token for great than or close angle brace
"="						return EQUAL;
"!="					return NE;//NOTEQUAL	//token for equality operators
"<="					return LE; //LESSEQUAL
">="					return GE; //GREATEREQUAL//token for relational operators
"+"               		return PLUS;	//token for arithematic operators
"-"						return MINUS;
"*"						return MUL;//INTO
"/"						return DIV;
"("                     return OPEN;	//token for open brace
")"                     return CLOSE;	//token for close brace
(\".[^\"]*\")                {  strcpy(yylval.s,yytext) ;return STR;}	 //token for string
"AND"					return AND;
"OR"					return OR;	//token for logical operators
","						return COMMA;	//token for COMMA
[_a-zA-Z][_a-zA-Z0-9]*	{  strcpy(yylval.s,yytext) ;return NAME;}	//token for table name or any attribute name
[0-9]+                  {  strcpy(yylval.s,yytext) ;return NUMBER;}	//token for any number
[\n]					return NEWLINE;	//token for NEWLINE
"."						return DOT;	//token for dot
.						;	//everything else


%%

int yywrap(void)
{
	return 1;	//if yywrap returns 1 then yylex returns 0 which means the end of file
}