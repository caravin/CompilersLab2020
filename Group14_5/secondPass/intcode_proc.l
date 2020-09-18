%{    
# include "intcode_proc.tab.h"
%}
%option noyywrap
%%

"function"                      { return FUNCTION; }
"begin"                         { return BEG; }
"if"                            { return IF; }
"goto"                          { return GOTO; }
"param"                         { return PARAMETERS; }
"refparam"                      { return REF_PARAMETERS; }
"call"                          { return CALL; }
"end"                           { return END; }
"return"                        { return RETURN; }
"convertToFloat"                { return CONVERT_FLOAT; }
"convertToInt"                  { return CONVERT_INT; }
"print"                         { return PRINT;}
"read"                          { return READ; }
"<="                            { return LEQUAL; }
">="                            { return GEQUAL; }
"=="                            { return EQUAL; }
"!="                            { return NOTEQUAL; }
"&&"                            { return AND; }
"||"                            { return OR; }
":"                             { return COLON; }
"["                             { return LSB; }
"]"                             { return RSB; }
"("                             { return LP; }
")"                             { return RP; }
","                             { return COMMA; }
"="                             { return ASSIGN; }
"<"                             { return LESSTHAN; }
">"                             { return GREATERTHAN; }
"~"                             { return NEG; }
"+"                             { return ADD; }
"/"                             { return DIVISION; }
"*"                             { return MULTIPLY; }
"%"                             { return MOD; }

-[0-9]+\.[0-9]*|[0-9]+\.[0-9]*  { yylval.idName = (char *)malloc(100); memset(yylval.idName, 0, 100); memcpy(yylval.idName, yytext, yyleng); return NUM_FLOAT; }
-[0-9]+|[0-9]+                  { yylval.idName = (char *)malloc(100); memset(yylval.idName, 0, 100); memcpy(yylval.idName, yytext, yyleng); return NUM_INT; }
"-"                             { return MINUS; }
[T][0-9]+                       { yylval.idName = (char *)malloc(100); memset(yylval.idName, 0, 100); memcpy(yylval.idName, yytext, yyleng); return REGULAR_INT; }
[F][0-9]+                       { yylval.idName = (char *)malloc(100); memset(yylval.idName, 0, 100); memcpy(yylval.idName, yytext, yyleng); return REGULAR_FLOAT; }
[L][0-9]+                       { yylval.idName = (char *)malloc(100); memset(yylval.idName, 0, 100); memcpy(yylval.idName, yytext, yyleng); return LABEL; }   
[_a-zA-Z][a-zA-Z_0-9]*          { yylval.idName = (char *)malloc(100); memset(yylval.idName, 0, 100); memcpy(yylval.idName, yytext, yyleng); return USER_VAR; }

\n                              { yylineno++;return NEWLINE;}
[ \t]                           { /* ignore whitespace */ }
%%
