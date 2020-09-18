%{
#include "part2.tab.h"
%}
%option yylineno


%%
"SELECT"				return SELECT;
"PROJECT"				return PROJECT;
"CARTESIAN_PRODUCT"	    return CARTESIAN_PRODUCT;
"EQUI_JOIN"				return EQUI_JOIN;
"<="|">="		return OPT;
"<"						return LESS;
">"						return GREAT;
"("                     return OPEN;
")"                     return CLOSE;
"="|"!="				return EQUAL;

[\+\-\*/]               return ARITH;
(\".*\")                return STR;
"AND"|"OR"				return LOG;
","						return COMMA;
[_a-zA-Z][_a-zA-Z0-9]*	return NAME;
[0-9]+                  return NUMBER;
[\n]					return NEWLINE;
"."						return DOT;
.						;


%%

int yywrap(void)
{
	return 1;
}
