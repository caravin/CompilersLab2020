#define EOI		    0	/* End of input			*/
#define SEMI		1	/* ; 				*/
#define PLUS 		2	/* + 				*/
#define TIMES		3	/* * 				*/
#define LP		    4	/* (				*/
#define RP		    5	/* )				*/
#define NUM     	6	/* Decimal Number or Identifier */
#define MINUS       7
#define DIVIDE      8
#define LESS        9
#define GREAT       10

#define BEGIN       11
#define END         12
#define ID          13
#define EQUAL       14
#define ASSIGN      15
#define IF          16
#define THEN        17
#define WHILE       18
#define DO          19

extern char *yytext;		/* in lex.c			*/
extern int yyleng;
extern int yylineno;

extern char idname[32];