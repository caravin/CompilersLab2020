%{
#pragma GCC diagnostic ignored "-Wwrite-strings"
#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
#include <fstream>
#include "secondpass_parser.c"
using namespace std;

#define INT_SIZE 4
#define FLOATSIZE 4

extern int yylex();
extern int yyparse();
extern int yylineno;
extern char* yytext;
extern int yyleng;
void yyerror(char* s);

FILE *mips;
string activeFunc;
int paramOffset;
string returnVal;
int Label_Float = 0;
vector<funcEntry> functionList;
vector<typeRecord> globalVariables;

void saveRegisters(int frameSize);
void retrieveRegisters(int frameSize);  
bool isGlobal;  
%}

%union {
    int intval;
    float floatval;
    char *idName;
}

%token FUNCTION BEG REGULAR_FLOAT LABEL NUM_INT NUM_FLOAT LSB RSB RETURN NEWLINE
%token MULTIPLY DIVISION MOD ADD MINUS
%token EQUAL NOTEQUAL OR AND LESSTHAN GREATERTHAN LEQUAL GEQUAL ASSIGN NEG
%token CONVERT_INT CONVERT_FLOAT LP RP
%token USER_VAR REGULAR_INT PRINT READ
%token COMMA COLON SEMI_COLON END IF GOTO PARAMETERS REF_PARAMETERS CALL


%type <idName> NUM_FLOAT NUM_INT REGULAR_INT REGULAR_FLOAT LABEL USER_VAR 

%%

STMT_LIST: STMT_LIST STMT NEWLINE
    | STMT NEWLINE
;

STMT: INT_STMT
    | FLOAT_STMT
    | RETURN REGULAR_FLOAT
    {
        fprintf(mips, "mfc1 $s0, $f%s\n", $2+1);
        fprintf(mips, "move $v0, $s0\n");
        fprintf(mips, "j end_%s\n", activeFunc.c_str());
    }
    
    | PARAMETERS REGULAR_FLOAT
    {
        paramOffset += FLOATSIZE;
        fprintf(mips, "sub $sp, $sp, %d\n", FLOATSIZE);    // addu $sp, $sp, -INT_SIZE
        fprintf(mips, "mfc1 $s0, $f%s\n", $2+1);             // store a float reg into int reg s0
        fprintf(mips, "sw $s0, 0($sp)\n");                 // sw $t0, 0($sp)
    }
    | PARAMETERS REGULAR_INT
    {
        // The initial frame of the caller function remains intact, grows downwards for each param
        paramOffset += INT_SIZE;
        fprintf(mips, "sub $sp, $sp, %d\n", INT_SIZE); // addu $sp, $sp, -INT_SIZE
        fprintf(mips, "sw $t%c, 0($sp)\n", $2[1]);     // sw $t0, 0($sp)
    }
    | READ REGULAR_FLOAT
    {
        fprintf(mips, "li $v0 6\n");
        fprintf(mips, "syscall\n");
        fprintf(mips, "mov.s $f%s, $f0\n", $2+1);
    }
    | IF_STMT
    | FUNCTION END
    {
        int frameSize = getFunctionOffset(functionList, activeFunc);
        fprintf(mips, "end_%s:\n", activeFunc.c_str());
        fprintf(mips, "move $sp, $fp\n");                          // move    $sp,$fp
        fprintf(mips, "lw $ra, %d($sp)\n", frameSize-INT_SIZE);     // lw      $31,52($sp)
        fprintf(mips, "lw $fp, %d($sp)\n", frameSize-2*INT_SIZE);   // lw      $fp,48($sp)
        fprintf(mips, "addu $sp, $sp, %d\n", frameSize);           // addiu   $sp,$sp,56
        fprintf(mips, "j $ra\n");                                  // j       $31
        //nop
    }
    | FUNCTION BEG USER_VAR 
    {
        activeFunc = string($3);
        fprintf(mips, "%s:\n", $3);
        // Push return address and frame pointer to top of frame
        int frameSize = getFunctionOffset(functionList, activeFunc);
        fprintf(mips, "subu $sp, $sp, %d\n", frameSize);
        fprintf(mips, "sw $ra, %d($sp)\n", frameSize-INT_SIZE);
        fprintf(mips, "sw $fp, %d($sp)\n", frameSize-2*INT_SIZE);
        fprintf(mips, "move $fp, $sp\n");
    }
    | REF_PARAMETERS REGULAR_INT 
    {
        returnVal = string($2);
    }
    | REF_PARAMETERS REGULAR_FLOAT
    {
        returnVal = string($2);
    }
    
    | GOTO LABEL
    {
        fprintf(mips, "j %s\n", $2);
    }
    | LABEL COLON
    {
        fprintf(mips, "%s:\n", $1);
    }
    | RETURN 
    {
        fprintf(mips, "j end_%s\n", activeFunc.c_str());
    }
    | RETURN REGULAR_INT
    {
        fprintf(mips, "move $v0, $t%c\n", $2[1]);
        fprintf(mips, "j end_%s\n", activeFunc.c_str());
    }
    | CALL USER_VAR COMMA NUM_INT
    {
        int frameSize = getFunctionOffset(functionList, activeFunc); 
        saveRegisters(frameSize+paramOffset);       // Save all temp registers
        fprintf(mips, "jal %s\n", $2);                     // jal calling
        retrieveRegisters(frameSize+paramOffset);   // retrieve all registers
        if(returnVal[0] == 'F'){
            fprintf(mips, "move $s0, $v0\n");   // move result to refparam
            fprintf(mips, "mtc1 $s0, $f%s\n", returnVal.c_str()+1);   // move result to refparam
        }else if(returnVal==""){

        }  else {
            fprintf(mips, "move $t%c, $v0\n", returnVal[1]);   // move result to refparam 
        }
        int funcParamOffset = getParamOffset(functionList, string($2));
        fprintf(mips, "add $sp, $sp, %d\n", funcParamOffset);  // collapse space used by parameters
        paramOffset-=funcParamOffset;
        returnVal = "";
    }
    
    

    | PRINT REGULAR_INT
    {
        fprintf(mips, "move $a0, $t%s\n", $2+1);
        fprintf(mips, "li $v0 1\n");
        fprintf(mips, "syscall\n");
        fprintf(mips, "li $v0, 4\n");//         li $v0, 4 # system call code for printing string = 4
        fprintf(mips, "la $a0, endline\n");// la $a0, out_string # load address of string to be printed into $a0
        fprintf(mips, "syscall\n");// syscall
    }
    | PRINT REGULAR_FLOAT
    {
        fprintf(mips, "mov.s $f12, $f%s\n", $2+1);
        fprintf(mips, "li $v0 2\n");
        fprintf(mips, "syscall\n");
        fprintf(mips, "li $v0, 4\n");//         li $v0, 4 # system call code for printing string = 4
        fprintf(mips, "la $a0, endline\n");// la $a0, out_string # load address of string to be printed into $a0
        fprintf(mips, "syscall\n");// syscall
    }
    | READ REGULAR_INT
    {
        fprintf(mips, "li $v0 5\n");
        fprintf(mips, "syscall\n");
        fprintf(mips, "move $t%s, $v0\n", $2+1);
    }
    
    
;


INT_STMT:  REGULAR_INT ASSIGN REGULAR_INT MOD REGULAR_INT
    {
        fprintf(mips, "div $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
        fprintf(mips, "mfhi $t%c\n", $1[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT EQUAL REGULAR_INT
    {
        fprintf(mips, "seq $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT NOTEQUAL REGULAR_INT
    {
        fprintf(mips, "sne $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT ADD REGULAR_INT
    {
        fprintf(mips, "add $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT MINUS REGULAR_INT
    {
        fprintf(mips, "sub $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT MULTIPLY REGULAR_INT
    {
        fprintf(mips, "mul $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
	| REGULAR_INT ASSIGN REGULAR_INT ADD NUM_INT
    {
        fprintf(mips, "addu $t%c, $t%c, %s\n", $1[1], $3[1], $5);
    }
    | REGULAR_INT ASSIGN REGULAR_INT MINUS NUM_INT
    {
        fprintf(mips, "subu $t%c, $t%c, %s\n", $1[1], $3[1], $5);
    }
    
    | REGULAR_INT ASSIGN REGULAR_INT DIVISION REGULAR_INT
    {
        fprintf(mips, "div $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
        fprintf(mips, "mflo $t%c\n", $1[1]);
    }
    
    | REGULAR_INT ASSIGN REGULAR_INT AND REGULAR_INT 
    {
        // hack, will not arise when short-circuit is done
        fprintf(mips, "sne $t%c, $t%c, 0\n", $3[1], $3[1]);
        fprintf(mips, "sne $t%c, $t%c, 0\n", $5[1], $5[1]);
        fprintf(mips, "and $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT OR REGULAR_INT
    {
        fprintf(mips, "or $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT LESSTHAN REGULAR_INT
    {
        fprintf(mips, "slt $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT GREATERTHAN REGULAR_INT
    {
        fprintf(mips, "sgt $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT LEQUAL REGULAR_INT
    {
        fprintf(mips, "sle $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGULAR_INT ASSIGN REGULAR_INT GEQUAL REGULAR_INT
    {
        fprintf(mips, "sge $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
	| USER_VAR ASSIGN REGULAR_INT
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($1), 0, isGlobal)+paramOffset;
       	if(isGlobal) {
            fprintf(mips, "sw $t%s, %s\n", $3+1, $1); 
        }
        else{
            fprintf(mips, "sw $t%c, %d($sp)\n", $3[1], offset);
        }
    }
    | USER_VAR LSB REGULAR_INT RSB ASSIGN REGULAR_INT
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($1), 0, isGlobal)+paramOffset;
        if(isGlobal){
            fprintf(mips, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INT_SIZE);
            fprintf(mips,"la $s1, %s\n", $1);
            fprintf(mips,"addu $s0, $s1, $t%s\n", $3+1);
            fprintf(mips,"sw $t%s, 0($s0)\n", $6+1);
        } 
        else{
            fprintf(mips, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INT_SIZE);
            fprintf(mips,"li $s1, %d\n", offset);
            fprintf(mips,"addu $s0, $sp, $s1\n");
            fprintf(mips,"sub $s0, $s0, $t%s\n", $3+1);
            fprintf(mips,"sw $t%s, 0($s0)\n", $6+1);
        }
    }
    | USER_VAR LSB NUM_INT RSB ASSIGN REGULAR_INT
    {
        // useless
        int offset = getOffset(functionList, globalVariables, activeFunc, string($1), 0, isGlobal)+paramOffset;
        fprintf(mips, "sw $t%c, %d($sp)\n", $3[1], offset);
    }
    
    | REGULAR_INT ASSIGN NUM_INT
    {
        fprintf(mips, "li $t%c, %s\n", $1[1], $3);
    }
    | REGULAR_INT ASSIGN REGULAR_INT
    {
        fprintf(mips, "move $t%c, $t%c\n", $1[1], $3[3]);
    }
    | REGULAR_INT ASSIGN CONVERT_INT LP REGULAR_FLOAT RP
    {
        fprintf(mips, "cvt.w.s $f%s, $f%s\n", $5+1, $5+1);
        fprintf(mips, "mfc1 $t%c, $f%s\n", $1[1], $5+1);
    }
    | REGULAR_INT ASSIGN USER_VAR LSB REGULAR_INT RSB
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($3), 0, isGlobal)+paramOffset;
        if(isGlobal) {
            fprintf(mips, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INT_SIZE);
            fprintf(mips,"la $s0, %s\n", $3);
            fprintf(mips,"addu $s0, $s0, $t%s\n", $3+1);
            fprintf(mips,"lw $t%s, 0($s0)\n", $1+1);
        }
        else{
            fprintf(mips, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INT_SIZE);
            fprintf(mips,"li $s1, %d\n", offset);
            fprintf(mips,"addu $s0, $sp, $s1\n");
            fprintf(mips,"sub $s0, $s0, $t%s\n", $5+1);
            fprintf(mips,"lw $t%s, 0($s0)\n", $1+1);
        } 
    }
    | REGULAR_INT ASSIGN USER_VAR LSB NUM_INT RSB
    {
        //useless
        int offset = getOffset(functionList, globalVariables, activeFunc, string($3), 0, isGlobal)+paramOffset;
        fprintf(mips, "sw $t%c, %d($sp)\n", $1[1], offset);
    }
    
    | REGULAR_INT ASSIGN USER_VAR
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($3), 0, isGlobal)+paramOffset;
        if(!isGlobal){
            fprintf(mips, "lw $t%c, %d($sp)\n", $1[1], offset);
        } else {
            fprintf(mips, "lw $t%c, %s\n", $1[1], $3);
        }
    }   
;

FLOAT_STMT: REGULAR_FLOAT ASSIGN REGULAR_FLOAT ADD REGULAR_FLOAT
    {
        fprintf(mips, "add.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGULAR_FLOAT ASSIGN REGULAR_FLOAT MINUS REGULAR_FLOAT
    {
        fprintf(mips, "sub.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGULAR_FLOAT ASSIGN REGULAR_FLOAT MULTIPLY REGULAR_FLOAT
    {
        fprintf(mips, "mul.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGULAR_FLOAT ASSIGN REGULAR_FLOAT DIVISION REGULAR_FLOAT
    {
        fprintf(mips, "div.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGULAR_FLOAT ASSIGN NUM_FLOAT
    {
        fprintf(mips, "li.s $f%s, %s\n", $1+1, $3);
    }
    | REGULAR_FLOAT ASSIGN REGULAR_FLOAT
    {
        fprintf(mips, "mov.s $f%s, $f%s\n", $1+1, $3+1);
    }
    
    | REGULAR_INT ASSIGN REGULAR_FLOAT LESSTHAN REGULAR_FLOAT
    {
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "c.lt.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    | REGULAR_INT ASSIGN REGULAR_FLOAT GREATERTHAN REGULAR_FLOAT
    {
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "c.le.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    | REGULAR_INT ASSIGN REGULAR_FLOAT LEQUAL REGULAR_FLOAT
    {
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "c.le.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    | REGULAR_INT ASSIGN REGULAR_FLOAT GEQUAL REGULAR_FLOAT
    {
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "c.lt.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    
    | REGULAR_INT ASSIGN REGULAR_FLOAT AND REGULAR_FLOAT
    {
        fprintf(mips, "li.d $f31, 0\n");
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "c.eq.s $f%s, $f31\n", $3+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "c.eq.s $f%s, $f31\n", $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    | REGULAR_INT ASSIGN REGULAR_FLOAT OR REGULAR_FLOAT
    {
        fprintf(mips, "li.d $f31, 0\n");
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "c.eq.s $f%s, $f31\n", $3+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "c.eq.s $f%s, $f31\n", $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    | REGULAR_FLOAT ASSIGN CONVERT_FLOAT LP REGULAR_INT RP
    {
        // convert from integer to float
        fprintf(mips, "mtc1 $t%c, $f%s\n", $5[1], $1+1);
        fprintf(mips, "cvt.s.w $f%s, $f%s\n", $1+1, $1+1);
    }
    | REGULAR_INT ASSIGN REGULAR_FLOAT EQUAL REGULAR_FLOAT
    {
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "c.eq.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    | REGULAR_INT ASSIGN REGULAR_FLOAT NOTEQUAL REGULAR_FLOAT
    {
        fprintf(mips, "li $t%c, 1\n", $1[1]);
        fprintf(mips, "c.eq.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $t%c, 0\n", $1[1]);
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        Label_Float++;
    }
    | REGULAR_FLOAT ASSIGN USER_VAR
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($3), 0, isGlobal)+paramOffset;
        if(!isGlobal){
            fprintf(mips, "l.s $f%s, %d($sp)\n", $1+1, offset);
        } else {
            fprintf(mips, "l.s $f%s, %s\n", $1+1, $3);
        }
    }
    | REGULAR_FLOAT ASSIGN USER_VAR LSB REGULAR_INT RSB
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($3), 0, isGlobal)+paramOffset;
        if(isGlobal){
            fprintf(mips, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INT_SIZE);
            fprintf(mips,"la $s1, %s\n", $3);
            fprintf(mips,"addu $s0, $s1, $t%s\n", $5+1);
            fprintf(mips,"l.s $f%s, 0($s0)\n", $1+1);
        } else {
            
            fprintf(mips, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INT_SIZE);
            fprintf(mips, "subu $s0, $sp, $t%s\n", $5+1);
            fprintf(mips, "l.s $f%s, %d($s0)\n", $1+1, offset);
        }
    }
    | USER_VAR ASSIGN REGULAR_FLOAT
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($1), 0, isGlobal)+paramOffset;
        if(!isGlobal){
            fprintf(mips, "s.s $f%s, %d($sp)\n", $3+1, offset);
        } else {
            fprintf(mips, "s.s $f%s, %s\n", $3+1, $1);
        }
    }
    | USER_VAR LSB NUM_INT RSB ASSIGN REGULAR_FLOAT
    {
        //useless
        int offset = getOffset(functionList, globalVariables, activeFunc, string($1), 0, isGlobal)+paramOffset;
        fprintf(mips, "s.s $f%s, %d($sp)\n", $3+1, offset);
    }
    | USER_VAR LSB REGULAR_INT RSB ASSIGN REGULAR_FLOAT
    {
        int offset = getOffset(functionList, globalVariables, activeFunc, string($1), 0, isGlobal)+paramOffset;
        if(isGlobal){
        	fprintf(mips, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INT_SIZE);
            fprintf(mips,"la $s1, %s\n", $1);
            fprintf(mips,"addu $s0, $s1, $t%s\n", $3+1);
            fprintf(mips,"s.s $f%s, 0($s0)\n", $6+1);
        } else {

            fprintf(mips, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INT_SIZE);
            fprintf(mips,"li $s1, %d\n", offset);
            fprintf(mips,"addu $s0, $sp, $s1\n");
            fprintf(mips,"sub $s0, $s0, $t%s\n", $3+1);
            fprintf(mips,"s.s $f%s, 0($s0)\n", $6+1);            
        }
    }
;

IF_STMT:IF REGULAR_FLOAT EQUAL NUM_INT GOTO LABEL
    {
        fprintf(mips, "mtc1 $0, $f31\n");
        fprintf(mips, "cvt.s.w $f31, $f31\n");
        fprintf(mips, "li $s0, 1\n");
        fprintf(mips, "c.eq.s $f%s, $f31\n", $2+1);
        fprintf(mips, "bc1t FLOAT%d\n", Label_Float);
        fprintf(mips, "li $s0, 0\n");
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        fprintf(mips, "beq $s0, 1, %s\n", $6);
        Label_Float++;
    }
    | IF REGULAR_FLOAT NOTEQUAL NUM_INT GOTO LABEL
    {
        fprintf(mips, "mtc1 $0, $f31\n");
        fprintf(mips, "cvt.s.w $f31, $f31\n");
        fprintf(mips, "li $s0, 1\n");
        fprintf(mips, "c.eq.s $f%s, $f31\n", $2+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float); // goto label float when equal to 0
        fprintf(mips, "li $s0, 0\n");
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        fprintf(mips, "beq $s0, 1, %s\n", $6);
        Label_Float++;
    } 
	| IF REGULAR_FLOAT EQUAL REGULAR_FLOAT GOTO LABEL
    {
        fprintf(mips, "li $s0, 1\n");
        fprintf(mips, "c.eq.s $f%s, $f%s\n", $2+1, $4+1);
        fprintf(mips, "bc1t FLOAT%d\n", Label_Float);
        fprintf(mips, "li $s0, 0\n");
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        fprintf(mips, "beq $s0, 1, %s\n", $6);
        Label_Float++;
    }
    | IF REGULAR_FLOAT NOTEQUAL REGULAR_FLOAT GOTO LABEL
    {
        fprintf(mips, "li $s0, 1\n");
        fprintf(mips, "c.eq.s $f%s, $f%s\n", $2+1, $4+1);
        fprintf(mips, "bc1f FLOAT%d\n", Label_Float);
        fprintf(mips, "li $s0, 0\n");
        fprintf(mips, "FLOAT%d:\n", Label_Float);
        fprintf(mips, "beq $s0, 1, %s\n", $6);
        Label_Float++;
    }
    | IF REGULAR_INT EQUAL NUM_INT GOTO LABEL
    {
        fprintf(mips, "beq $t%c, %s, %s\n", $2[1], $4, $6);
    }
    | IF REGULAR_INT NOTEQUAL NUM_INT GOTO LABEL
    {
        fprintf(mips, "bne $t%c, %s, %s\n", $2[1], $4, $6);
    }
    | IF REGULAR_INT EQUAL REGULAR_INT GOTO LABEL
    {
        fprintf(mips, "beq $t%c, $t%c, %s\n", $2[1], $4[1], $6);
    }
    | IF REGULAR_INT NOTEQUAL REGULAR_INT GOTO LABEL
    {
        fprintf(mips, "bne $t%c, $t%c, %s\n", $2[1], $4[1], $6);
    } 
;

%%

void saveRegisters(int frameSize){
    for(int i=0; i<10; i++){
        fprintf(mips, "sw $t%d, %d($sp)\n", i, frameSize-2*INT_SIZE-(i+1)*INT_SIZE);
    }
    for(int i=0; i<11; i++){
        fprintf(mips, "s.s $f%d, %d($sp)\n", i, frameSize-2*INT_SIZE-(i+11)*INT_SIZE);
    }
}

void retrieveRegisters(int frameSize){
    for(int i=0; i<10; i++){
        fprintf(mips, "lw $t%d, %d($sp)\n", i, frameSize-2*INT_SIZE-(i+1)*INT_SIZE);
    }
    for(int i=0; i<11; i++){
        fprintf(mips, "l.s $f%d, %d($sp)\n", i, frameSize-2*INT_SIZE-(i+11)*INT_SIZE);
    }
}

void yyerror(char *s)
{      
    printf("\nSyntax error %s at line %d\n", s, yylineno);
    // cout << BOLD(FRED("Error : ")) << FYEL("Syntax error " + string(s) + "in intermediate code at line " + to_string(yylineno)) << endl;
    fflush(stdout);
}

int main(int argc, char **argv)
{
    readSymbolTable(functionList, globalVariables);
    returnVal = ""; 
    isGlobal = false;
    mips = fopen("mips.s", "w");
    fflush(mips);
    fprintf(mips,".data\n");
    for(auto it : globalVariables){
        fprintf(mips, "%s: .space %d\n", it.name.c_str(), 4*(it.varOffset));
    }
    fprintf(mips,"endline: .asciiz \"\\n\"\n");
    fprintf(mips,".text\n");
    paramOffset = 0;
    Label_Float = 0;
    yyparse();
    fflush(mips);
    fclose(mips);
}
