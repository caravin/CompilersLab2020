#include "lex.h"
#include "symbols.c"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>


char* yytext = ""; /* Lexeme (not '\0'
                      terminated)              */
int yyleng   = 0;  /* Lexeme length.           */
int yylineno = 0;  /* Input line number        */
char idname[32];
int idlength = 0;
char * current;


int lex(void){
   static char input_buffer[1024];
   
   current = yytext + yyleng; /* Skip current*/
                           

   while(1){       /* Get the next one         */

      while(!*current ){
         /* Get new lines, skipping any leading
         * white space on the line,
         * until a nonblank line is found.
         */
         current = input_buffer;
         if(!fgets(input_buffer,1024,stdin)){
            *current = '\0' ;
            return EOI;
         }

         ++yylineno;
         while(isspace(*current)){
            ++current;

         }
      }
      for(; *current; ++current){
         /* Get the next token */
         yytext = current;
         yyleng = 1;
         switch( *current ){
            case ';':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return SEMI;
            case '+':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return PLUS;
            case '<':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return LESS;
            case '>':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return GREAT;
            case '*':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return TIMES;
            case '(':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return LP;
            case ')':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return RP;
            case '-':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;   
               return MINUS;
            case '/':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
                return DIVIDE;
            case ':':
               current++;
               if(*current != '='){
                  current--;
                  fprintf(stderr, "%d: Missing '=' after ':'\n", yylineno);
                  exit(1);
               }
               yyleng++;
                strncpy(idname, yytext, yyleng);   
                idname[yyleng] = '\0';
                idlength = 2;
               return ASSIGN;
            case '=':
                strncpy(idname, yytext, 1);   
                idname[yyleng] = '\0';
                idlength = 1;
               return EQUAL;
            case '\n':
            case '\t': 
            case ' ' :
              break;
            default:               
               if(!isalnum(*current)){
                  fprintf(stderr, "Not alphanumeric <%c>\n", *current);
               }
               else{
                  while(isalnum(*current)){
                     ++current;
                  }
                  yyleng = current - yytext;
                  char *tokens[] = {"if", "then", "while", "do", "begin", "end"};
                  int returnvals[] = {IF, THEN, WHILE, DO, BEGIN, END};
                  int lengths[] = {2,4,5,2,5,3};
                  int i=0;
                  for(i=0; i<6; i++){
                     if(strncmp(yytext, tokens[i],yyleng)==0 && yyleng == lengths[i]){
                        // printf("%s\n", tokens[i]);
                        strncpy(idname, yytext, yyleng);   
                        idname[yyleng] = '\0';
                        idlength = yyleng; 
                        return returnvals[i];
                     }
                  }
                  strncpy(idname, yytext, yyleng);   
                  idname[yyleng] = '\0';
                  idlength = yyleng;       
                  // printf("%s\n", idname);        
                  if(isalpha(idname[0])){
                     return ID;
                  }
                  // char* temp = yytext;
                  for(int i=0;i<yyleng;i++){
                     if(!isdigit(idname[i])){
                        fprintf(stderr, "%d: Fatal error not a number\n", yylineno);
                        exit(1);
                     }
                  }         
                  return NUM;
               }
            break;
         }
      }
   }
}


static int Lookahead = -1; /* Lookahead token  */

int match(int token){
   /* Return true if "token" matches the
      current lookahead symbol.                */

   if(Lookahead == -1)
      Lookahead = lex();

   return token == Lookahead;
}

void advance(void){
/* Advance the lookahead to the next
   input symbol.                               */

    Lookahead = lex();
}


void start_lexical(void)
{
  ssmb* token_table=NULL;
  printf("Started Analysis\n");
  while(1){

    int class=lex();
    if(class==EOI){
      printf("Completed Analysis\n");
      break;
    }
    char name[32]="";
    int class_length;
    char class_name[32]="";

    if(class ==  SEMI){class_length=4;strncpy(class_name, "SEMI", class_length);}
    if(class ==  PLUS){class_length=4;strncpy(class_name, "PLUS", class_length);}
    if(class ==  TIMES){class_length=5;strncpy(class_name, "TIMES", class_length);}
    if(class ==  LP){class_length=2;strncpy(class_name, "LP", class_length);}
    if(class ==  RP){class_length=2;strncpy(class_name, "RP", class_length);}
    if(class ==  NUM){class_length=3;strncpy(class_name, "NUM", class_length);}
    if(class ==  MINUS){class_length=5;strncpy(class_name, "MINUS", class_length);}
    if(class ==  DIVIDE){class_length=6;strncpy(class_name, "DIVIDE", class_length);}
    if(class ==  LESS){class_length=4;strncpy(class_name, "LESS", class_length);}
    if(class ==  GREAT){class_length=5;strncpy(class_name, "GREAT", class_length);}
    if(class ==  EQUAL){class_length=5;strncpy(class_name, "EQUAL", class_length);}
    if(class ==  ASSIGN){class_length=6;strncpy(class_name, "ASSIGN", class_length);}
    if(class ==  IF){class_length=2;strncpy(class_name, "IF", class_length);}
    if(class ==  THEN){class_length=4;strncpy(class_name, "THEN", class_length);}
    if(class ==  WHILE){class_length=5;strncpy(class_name, "WHILE", class_length);}
    if(class ==  DO){class_length=2;strncpy(class_name, "DO", class_length);}
    if(class ==  BEGIN){class_length=5;strncpy(class_name, "BEGIN", class_length);}
    if(class ==  END){class_length=3;strncpy(class_name, "END", class_length);}
    if(class ==  ID){class_length=2;strncpy(class_name, "ID", class_length);}


    insert(&token_table,idname,class_name,class_length,idlength);
  }  

  ssmb* temp=token_table;
  FILE *lexemeFile;
  lexemeFile = fopen("Lexemes.txt", "w");
  while(temp!=NULL){
    fprintf(lexemeFile,"< %s , %s > \n", temp->class, temp->name);
    temp=temp->next;
  }
  return;
}