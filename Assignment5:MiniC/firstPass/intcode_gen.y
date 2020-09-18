%{
#pragma GCC diagnostic ignored "-Wwrite-strings"
#include <iostream>
#include <string>
#include <vector>
#include <stack>
#include <stdio.h>
#include <algorithm>
#include <utility>
#include <fstream>
#include "first_pass1.h"
#include "first_pass2.h"

using namespace std;
#define YYERROR_VERBOSE 1

extern int yylex();
extern int yyparse();
extern int yylineno;
extern char* yytext;
extern int yyleng;
void yyerror(const char* s);

int CalcOffset;
string text;
eletype resultType;
vector<typeRecord*> typeRecordList;
stack<vector<typeRecord*> > paramListStack;
typeRecord* varRecord;
vector<int> decdimlist;
vector<typeRecord*> globalVariables;

int nextquadraple;
vector<string> functionInstruction;
registerSet tempSet;

vector<funcEntry*> functionEntryRecord;
funcEntry* activeFunctionPointer;
funcEntry* callFuncPtr;
int scope;
int found;
bool foundError;
int numberOfParameters;
string conditionVar;
vector<string> switchVar;
vector<funcEntry*> callFuncPtrList;
vector<string> dimlist;

vector<pair<string,int>> sVar;

%} 

%code requires{
    #include "first_pass1.h"
    #include "first_pass2.h"
}

%union {
    int intval;
    float floatval;
    char *idName;
    int quadraple;

    struct expression expr;
    struct stmt stmtval;
    struct whileexp whileexpval;
    struct shortcircuit shortCircuit;
    struct switchcaser switchCase;
    struct switchtemp switchTemp;
    struct condition2temp ctemp;
}

%token INT FLOAT VOID NUMFLOAT NUMINT ID NEWLINE READ PRINT
%token IF ELSE CASE BREAK DEFAULT CONTINUE WHILE FOR RETURN SWITCH MAIN
%token NOT AND OR LT GT LE GE EQUAL NOTEQUAL
%token LSHIFT RSHIFT PLUSASG MINASG MULASG MODASG DIVASG INCREMENT DECREMENT XOR BITAND BITOR PLUS MINUS DIV MUL MOD
%token COLON QUESTION DOT LCB RCB LSB RSB LP RP SEMI COMMA ASSIGN

%type <idName> NUMFLOAT
%type <idName> NUMINT
%type <idName> ID
%type <expr> EXPR2 TERM FACTOR ID_ARR ASSIGNMENT ASG1 EXPR1 EXPR21 LHS FUNC_CALL BR_DIMLIST
%type <whileexpval> WHILEEXP IFEXP N3 P3 Q3 FOREXP TEMP1
%type <stmtval> BODY WHILESTATEMENT IFSTATEMENT M2 FORLOOP STATEMENT STATMENT_LIST
%type <quadraple> M1 M3 Q4 
%type <shortCircuit> CONDITION1 CONDITION2
%type <switchCase> CASELIST
%type <switchTemp> TEMP2
%type <ctemp> TP1
%%

MAIN_PROGRAM: PROGRAM MAINFUNCTION
    | MAINFUNCTION
;

PROGRAM: PROGRAM FUNCTION_DEFINITION
    | PROGRAM VARIABLE_DECLARATION
    | FUNCTION_DEFINITION
    | VARIABLE_DECLARATION
;

MAINFUNCTION: MAIN_HEAD LCB BODY RCB
    {
        deleteVarList(activeFunctionPointer, scope);
        activeFunctionPointer=NULL;
        scope=0;
        string mercury = "function end";
        generateInstr(functionInstruction, mercury, nextquadraple);
    }
;

MAIN_HEAD: INT MAIN LP RP
    {   
        scope=1;
        activeFunctionPointer = new funcEntry;
        activeFunctionPointer->name = string("main");
        activeFunctionPointer->returnType = INTEGER;
        activeFunctionPointer->numOfParam = 0;
        activeFunctionPointer->parameterList.clear();
        activeFunctionPointer->variableList.clear();  
        activeFunctionPointer->functionOffset = 0;      ;
        typeRecordList.clear();
        int test = testing_function1("test");
        searchFunc(activeFunctionPointer, functionEntryRecord, found);
        if (found) {
            cout << BOLD(FRED("ERROR : At")) << "Line no. " << yylineno << ": Function " << activeFunctionPointer->name <<  " already declared." << endl;
            delete activeFunctionPointer;
            activeFunctionPointer = NULL;
        }   
        else {
            addFunction(activeFunctionPointer, functionEntryRecord);
            scope = 2; 
            string venus = "function begin main";
            generateInstr(functionInstruction, venus, nextquadraple);
        }
    }
;

FUNCTION_DEFINITION: FUNCTION_HEAD LCB BODY RCB
    {
        deleteVarList(activeFunctionPointer, scope);   
        activeFunctionPointer = NULL;
        scope = 0;
        string earth = "function end";
        generateInstr(functionInstruction, earth, nextquadraple);
    }
;

FUNCTION_HEAD: RES_ID LP DECLARE_PARAM_LIST RP
    {
        int found = 0;
        searchFunc(activeFunctionPointer, functionEntryRecord, found);
        int test1 = testing_function1("test");
        string testing1 = testing_function2("testing code");
        if(found){
            cout << BOLD(FRED("ERROR : At")) << "Line no. " << yylineno << ": Function " << activeFunctionPointer->name <<  " already declared." << endl;
            foundError = true;
            delete activeFunctionPointer;
            // cout<<"Function head me activeFunctionPointer deleted"<<endl;
            //for debugging
        }   
        else{
            activeFunctionPointer->numOfParam = typeRecordList.size();
            activeFunctionPointer->parameterList = typeRecordList;
            activeFunctionPointer->functionOffset = 0;
            typeRecordList.clear();
            addFunction(activeFunctionPointer, functionEntryRecord);
            scope = 2; 
            string mars = "function begin _" + activeFunctionPointer->name;
            generateInstr(functionInstruction, mars, nextquadraple);
        }
    }
; 

RES_ID: T ID       
    {   
        scope=1;
        activeFunctionPointer = new funcEntry;
        activeFunctionPointer->name = string($2);
        activeFunctionPointer->returnType = resultType;
    } 
    | VOID ID
    {
        scope=1;
        activeFunctionPointer = new funcEntry;
        activeFunctionPointer->name = string($2);
        activeFunctionPointer->returnType = NULLVOID;
        string testing2 = testing_function2("testing code");
    }
;




DECLARE_PARAM_LIST: DECLARE_PARAMLIST
    | %empty
;

DECLARE_PARAMLIST: DECLARE_PARAMLIST COMMA DECLARE_PARAM
    {
        int found = 0;
        typeRecord* param = NULL;
        searchParam(varRecord->name, typeRecordList, found, param);
        if(found){
            cout << BOLD(FRED("ERROR : At")) << "Line no. " << yylineno << ": Redeclaration of parameter " << varRecord->name <<endl;
        } else {
            // cout << "Variable: "<< varRecord->name << " declared." << endl;
            //debudding
            typeRecordList.push_back(varRecord);
        }
        
    }
    | DECLARE_PARAM
    {  
        int found = 0;
        typeRecord* pn = NULL;
        int test2 = testing_function1("test");
        searchParam(varRecord->name, typeRecordList, found , pn );
        if (found){
            cout << BOLD(FRED("ERROR : At")) << "Line no. " << yylineno << ": Redeclaration of parameter " << varRecord->name <<endl;
        } else {
            // cout << "Variable: "<< varRecord->name << " declared." << endl;
            //debudding
            typeRecordList.push_back(varRecord);
        }
    }
;

DECLARE_PARAM: T ID
    {
        varRecord = new typeRecord;
        varRecord->name = string($2);
        varRecord->type = SIMPLE;
        varRecord->tag = VARIABLE;
        varRecord->scope = scope;
        varRecord->eleType = resultType;
    }
;

BODY: STATMENT_LIST
    {
        $$.nextList = new vector<int>;
        merge($$.nextList, $1.nextList);
        $$.breakList = new vector<int>;
        merge($$.breakList, $1.breakList);
        $$.continueList = new vector<int>;
        merge($$.continueList, $1.continueList);
    }
    | %empty 
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector<int>;
    }
;

STATMENT_LIST: STATMENT_LIST STATEMENT 
    {
        $$.nextList = new vector<int>;
        int test3 = testing_function1("test");
        merge($$.nextList, $1.nextList);
        merge($$.nextList, $2.nextList);
        $$.breakList = new vector<int>;
        merge($$.breakList, $1.breakList);
        merge($$.breakList, $2.breakList);
        $$.continueList = new vector<int>;
        merge($$.continueList, $1.continueList);
        merge($$.continueList, $2.continueList);
    }
    | STATEMENT 
    {
        $$.nextList = new vector<int>;
        merge($$.nextList, $1.nextList);
        $$.breakList = new vector<int>;
        merge($$.breakList, $1.breakList);
        $$.continueList = new vector<int>;
        merge($$.continueList, $1.continueList);
        int test4 = testing_function1("test");
    }
;

STATEMENT: VARIABLE_DECLARATION
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
    }
    | ASSIGNMENT SEMI
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        if ($1.type != NULLVOID && $1.type != ERRORTYPE)
            tempSet.freeRegister(*($1.registerName));
    } 
    | FORLOOP
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        string testing3 = testing_function2("testing code");
    }
    | IFSTATEMENT
    {
        $$.nextList = new vector<int>;
        int test5 = testing_function1("test");
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        merge($$.continueList, $1.continueList);
        merge($$.breakList, $1.breakList);

    }
    | WHILESTATEMENT
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
    }
    | SWITCHCASE
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
    }
    | LCB {scope++;} BODY RCB 
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        deleteVarList(activeFunctionPointer, scope);
        scope--;
        merge($$.continueList, $3.continueList);
        merge($$.breakList, $3.breakList);
    }
    | BREAK SEMI
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        int test6 = testing_function1("test");
        $$.breakList->push_back(nextquadraple);  
        generateInstr(functionInstruction, "goto L", nextquadraple);      
    }
    | CONTINUE SEMI
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        $$.continueList->push_back(nextquadraple);
        generateInstr(functionInstruction, "goto L", nextquadraple);
    }
    | RETURN ASG1 SEMI 
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        int test7 = testing_function1("test");
        if ($2.type != ERRORTYPE && activeFunctionPointer != NULL) {
            if (activeFunctionPointer->returnType == NULLVOID && $2.type != NULLVOID) {
                cout << BOLD(FRED("ERROR : At")) << "Line no. " << yylineno << ": function " << activeFunctionPointer->name << " has void return type not " << $2.type << endl;
            }
            else if (activeFunctionPointer->returnType != NULLVOID && $2.type == NULLVOID) {
                cout << BOLD(FRED("ERROR : At")) << "Line no. " << yylineno << ": function " << activeFunctionPointer->name << " has non-void return type" << endl;
            }
            else {
                string s;
                if (activeFunctionPointer->returnType != NULLVOID && $2.type != NULLVOID) {
                    if ($2.type == INTEGER && activeFunctionPointer->returnType == FLOATING)  {
                        string floatReg = tempSet.getFloatRegister();
                        s = floatReg + " = " + "convertToFloat(" + *($2.registerName) + ")";
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generateInstr(functionInstruction, s, nextquadraple);
                        s = "return " + floatReg;
                        generateInstr(functionInstruction, s, nextquadraple);
                        tempSet.freeRegister(*($2.registerName));
                        tempSet.freeRegister(floatReg);
                        string testing4 = testing_function2("testing code");
                    }
                    else if ($2.type == FLOATING && activeFunctionPointer->returnType == INTEGER) {
                        string intReg = tempSet.getRegister();
                        s = intReg + " = " + "convertToInt(" + *($2.registerName) + ")";
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generateInstr(functionInstruction, s, nextquadraple);
                        s = "return " + intReg;
                        generateInstr(functionInstruction, s, nextquadraple);
                        tempSet.freeRegister(*($2.registerName));
                        tempSet.freeRegister(intReg);                        
                    }
                    else {
                        s = "return " + *($2.registerName);
                        generateInstr(functionInstruction, s, nextquadraple);
                        tempSet.freeRegister(*($2.registerName));
                    }
                }
                else if (activeFunctionPointer->returnType == NULLVOID && $2.type == NULLVOID) {
                    s = "return";
                    generateInstr(functionInstruction, s, nextquadraple);
                }
                else {
                    foundError = 1;
                    cout << BOLD(FRED("ERROR : At")) << "Line no. " << yylineno << ": Exactly one of function " << activeFunctionPointer->name << "and this return statement has void return type" << endl;
                    if ($2.type != NULLVOID) tempSet.freeRegister(*($2.registerName));
                } 
            }
        }
    }
    | READ ID_ARR SEMI
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        int test8 = testing_function1("test");
        if($2.type == ERRORTYPE){
            foundError = true;
        }
        else{
            string registerName;
            if ($2.type == INTEGER){
                registerName = tempSet.getRegister();
            }
            else {
                registerName = tempSet.getFloatRegister();
            }
            string s;
            s = "read " + registerName;
            generateInstr(functionInstruction, s, nextquadraple);
            s = (*($2.registerName)) + " = " +  registerName;
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(registerName);
            string testing5 = testing_function2("testing code");
            if ($2.offsetRegName != NULL) tempSet.freeRegister(*($2.offsetRegName));
        }
    }
    | PRINT ID_ARR SEMI
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        if($2.type == ERRORTYPE){
            foundError = true;
        }
        else{
            string registerName;
            if ($2.type == INTEGER){
                registerName = tempSet.getRegister();
            }
            else {
                registerName = tempSet.getFloatRegister();
            }
            string s = registerName + " = " + (*($2.registerName)) ;
            generateInstr(functionInstruction, s, nextquadraple);
            s = "print " + registerName;
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(registerName);
            if ($2.offsetRegName != NULL) tempSet.freeRegister(*($2.offsetRegName));
        }
    }
    | error SEMI
    {
        foundError = 1;
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        cout << BOLD(FRED("ERROR : At")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error") << endl;
    }
    | error
    {
        foundError = 1;
        $$.nextList = new vector<int>;
        int test9 = testing_function1("test");
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        cout << BOLD(FRED("ERROR : At")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error") << endl;
    }
;

VARIABLE_DECLARATION: DATA SEMI 
;

DATA: T L
    { 
        patchDataType(resultType, typeRecordList, scope);
        if(scope > 1){
            insertSymTab(typeRecordList, activeFunctionPointer);
            
        }
        else if(scope == 0){
            insertGlobalVariables(typeRecordList, globalVariables);
        }
        typeRecordList.clear();
    }
;

T:  INT         { resultType = INTEGER; }
    | FLOAT     { resultType = FLOATING; }
;    

L: DEC_ID_ARR
    | L COMMA DEC_ID_ARR      
;

DEC_ID_ARR: ID
    {   
        int found = 0;
        typeRecord* variablename = NULL;
        // cout << "Scope : "<<scope<<endl;
        if(activeFunctionPointer!=NULL && scope > 0){
            searchVariable(string($1), activeFunctionPointer, found, variablename, scope);
            if (found) {
                if(variablename->isValid==true){
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at same level " << scope << endl ;
                }
                else{
                    if(variablename->eleType == resultType){
                        variablename->isValid=true;
                        variablename->maxDimlistOffset = max(variablename->maxDimlistOffset,1);
                        variablename->type=SIMPLE;
                    }
                    else {
                        varRecord = new typeRecord;
                        varRecord->name = string($1);
                        varRecord->type = SIMPLE;
                        varRecord->tag = VARIABLE;
                        varRecord->scope = scope;
                        varRecord->isValid=true;
                        varRecord->maxDimlistOffset=1;
                        typeRecordList.push_back(varRecord);
                    }
                }
            }
            else if (scope == 2) {
                typeRecord* pn = NULL;
                searchParam(string($1), activeFunctionPointer->parameterList, found , pn);
                if (found) {
                    // printf("Line no. %d: Vaiable %s is already declared as a parameter with scope %d\n", yylineno, $1, scope);
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared in parameters " << endl ;
                } 
                else {
                    varRecord = new typeRecord;
                    varRecord->name = string($1);
                    varRecord->type = SIMPLE;
                    varRecord->tag = VARIABLE;
                    varRecord->scope = scope;
                    varRecord->isValid=true;
                    varRecord->maxDimlistOffset=1;
                    typeRecordList.push_back(varRecord);
                }
            }
            else {
                varRecord = new typeRecord;
                varRecord->name = string($1);
                varRecord->type = SIMPLE;
                varRecord->tag = VARIABLE;
                varRecord->scope = scope;
                varRecord->isValid=true;
                varRecord->maxDimlistOffset=1;
                typeRecordList.push_back(varRecord);
            }
        }
        else if(scope == 0){
            searchGlobalVariable(string($1), globalVariables, found, variablename, scope);
            if (found) {
                // printf("Variable %s already declared at global level \n", $1);
                cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at global level " << endl ;
            }
            else{
                varRecord = new typeRecord;
                varRecord->name = string($1);
                varRecord->type = SIMPLE;
                varRecord->tag = VARIABLE;
                varRecord->scope = scope;
                varRecord->isValid=true;
                varRecord->maxDimlistOffset=1;
                // cout<<"variable name: "<<varRecord->name<<endl;
                typeRecordList.push_back(varRecord);
                string testing6 = testing_function2("testing code");
            }
        } 
        else {
            foundError = true;
        }
        
    }
    | ID ASSIGN ASSIGNMENT
    {
        int found = 0;
        string testing7 = testing_function2("testing code");
        typeRecord* variablename = NULL;
        if(activeFunctionPointer!=NULL){
            searchVariable(string($1), activeFunctionPointer, found, variablename, scope);
            bool varCreated = false;;
            if (found) {
                if(variablename->isValid==true){
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at same level " << scope << endl ;
                }
                else{
                    if(variablename->eleType == resultType){
                        variablename->isValid=true;
                        variablename->maxDimlistOffset = max(variablename->maxDimlistOffset,1);
                        variablename->type=SIMPLE;
                        varCreated = true;
                    }
                    else {
                        varRecord = new typeRecord;
                        varRecord->name = string($1);
                        varRecord->type = SIMPLE;
                        varRecord->tag = VARIABLE;
                        varRecord->scope = scope;
                        varRecord->isValid=true;
                        varRecord->maxDimlistOffset=1;
                        typeRecordList.push_back(varRecord);
                        varCreated = true;
                    }
                }
            }
            else if (scope == 2) {
                typeRecord* pn = NULL;
                searchParam(string($1), activeFunctionPointer->parameterList, found , pn);
                if (found) {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at parameter level " << endl ;
                } 
                else {
                    varRecord = new typeRecord;
                    varRecord->name = string($1);
                    varRecord->type = SIMPLE;
                    varRecord->tag = VARIABLE;
                    varRecord->scope = scope;
                    varRecord->maxDimlistOffset=1;
                    varRecord->isValid=true;
                    typeRecordList.push_back(varRecord);
                    varCreated = true;
                }
            }
            else {
                varRecord = new typeRecord;
                varRecord->name = string($1);
                varRecord->type = SIMPLE;
                varRecord->tag = VARIABLE;
                varRecord->scope = scope;
                varRecord->maxDimlistOffset=1;
                varRecord->isValid=true;
                typeRecordList.push_back(varRecord);
                varCreated = true;
            }
            if(varCreated){
                if ($3.type == ERRORTYPE) {
                    foundError = true;
                }
                else if ($3.type == NULLVOID) {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Cannot assign void to non-void type " << string($1) << endl;
                    foundError = true;
                }
                else {
                    string registerName;
                    if (resultType == INTEGER && $3.type == FLOATING) {
                        registerName = tempSet.getRegister();
                        string s = registerName + " = convertToInt(" + (*($3.registerName)) + ")";   
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generateInstr(functionInstruction, s, nextquadraple);
                        tempSet.freeRegister(*($3.registerName));
                    }
                    else if(resultType == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                        registerName = tempSet.getFloatRegister();
                        string s = registerName + " = convertToFloat(" + (*($3.registerName)) + ")"; 
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generateInstr(functionInstruction, s, nextquadraple); 
                        tempSet.freeRegister(*($3.registerName));
                    }
                    else {
                        registerName = *($3.registerName);
                    }
                    string dataType = eletypeMapper(resultType);
                    dataType += "_" + to_string(scope);
                    string s =  "_" + string($1) + "_" + dataType + " = " + registerName ;
                    generateInstr(functionInstruction, s, nextquadraple);
                    tempSet.freeRegister(registerName);
                }   
            }
        }
        else if(scope == 0){
            cout << BOLD(FRED("ERROR : ")) << "Line No " << yylineno << ": ID assignments not allowed in global level : Variable " << string($1) << endl;
            foundError = true;
        }
        else {
            foundError = true;
        }
    }
    | ID DEC_BR_DIMLIST
    {
        string testing8 = testing_function2("testing code");
        if (activeFunctionPointer != NULL) {
            int found = 0;
            typeRecord* variablename = NULL;
            searchVariable(string($1), activeFunctionPointer, found, variablename,scope); 
            if (found) {
                if(variablename->isValid==true){
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Variable " << string($1) << " already declared at same level " << scope << endl;
                }
                else{
                    if(variablename->eleType == resultType){
                        variablename->isValid=true;
                        int a=1;
                        for(auto it : decdimlist){
                            a*=(it);
                        }
                        variablename->maxDimlistOffset = max(variablename->maxDimlistOffset,a);
                        if(variablename->type==ARRAY){
                            variablename->dimlist.clear();           
                        }
                        variablename->type=ARRAY;
                        variablename->dimlist = decdimlist;
                    }
                    else {
                        varRecord = new typeRecord;
                        varRecord->name = string($1);
                        varRecord->type = ARRAY;
                        varRecord->tag = VARIABLE;
                        varRecord->scope = scope;
                        varRecord->dimlist = decdimlist;
                        varRecord->isValid=true;
                        int a=1;
                        for(auto it : decdimlist){
                            a*=(it);
                        }
                        varRecord->maxDimlistOffset = a;
                        typeRecordList.push_back(varRecord);
                    }
                }
            }
            else if (scope == 2) {
                typeRecord* pn = NULL;
                searchParam(string($1), activeFunctionPointer->parameterList, found, pn);
                if (found) {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Variable " << string($1) << " already declared at parameter level " << endl;
                } 
                else {
                    varRecord = new typeRecord;
                    varRecord->name = string($1);
                    varRecord->type = ARRAY;
                    varRecord->tag = VARIABLE;
                    varRecord->scope = scope;
                    varRecord->dimlist = decdimlist;
                    varRecord->isValid=true;
                    int a=1;
                    for(auto it : decdimlist){
                        a*=(it);
                    }
                    varRecord->maxDimlistOffset = a;
                    typeRecordList.push_back(varRecord);
                }
            }
            else{
                varRecord = new typeRecord;        
                varRecord->name = string($1);
                varRecord->type = ARRAY;
                varRecord->tag = VARIABLE;
                varRecord->scope = scope;
                varRecord->dimlist = decdimlist;
                varRecord->isValid=true;
                int a=1;
                for(auto it : decdimlist){
                    a*=(it);
                }
                varRecord->maxDimlistOffset = a;
                typeRecordList.push_back(varRecord);
            }
            // decdimlist.clear();  
        } 
        else if(scope == 0){
            typeRecord* variablename = NULL;
            searchGlobalVariable(string($1), globalVariables, found, variablename, scope);
            if (found) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Variable " << string($1) << " already declared at global level " << endl;
            }
            else{
                varRecord = new typeRecord;
                varRecord->name = string($1);
                varRecord->type = ARRAY;
                varRecord->tag = VARIABLE;
                varRecord->scope = scope;
                varRecord->dimlist = decdimlist;
                varRecord->isValid=true;
                int a=1;
                for(auto it : decdimlist){
                    a*=(it);
                }
                varRecord->maxDimlistOffset = a;
                // cout<<"variable name: "<<varRecord->name<<endl;
                typeRecordList.push_back(varRecord);   
            }
        }   
        else{
            foundError = 1;
        }
        decdimlist.clear();
    }
;

DEC_BR_DIMLIST: LSB NUMINT RSB
    {
        decdimlist.push_back(atoi($2));
    }
    | DEC_BR_DIMLIST LSB NUMINT RSB 
    {
        decdimlist.push_back(atoi($3));
    }
;

FUNC_CALL: ID LP PARAMLIST RP
    {
        callFuncPtr = new funcEntry;
        callFuncPtr->name = string($1);
        callFuncPtr->parameterList = typeRecordList;
        callFuncPtr->numOfParam = typeRecordList.size();
        int found = 0;
        // printFunction(activeFunctionPointer);
        // printFunction(callFuncPtr);
        int vfound=0;
        typeRecord* variablename;
        searchVariable(callFuncPtr->name,activeFunctionPointer,vfound,variablename,scope);
        if (vfound) {
            $$.type = ERRORTYPE;
            cout<< BOLD(FRED("ERROR : ")) << "Line no." << yylineno << ": called object "<< callFuncPtr->name << " is not a function or function pointer"<< endl;
        }
        else {
            compareFunc(callFuncPtr,functionEntryRecord,found);
            $$.type = ERRORTYPE;
            if (found == 0) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "No function with name " << string($1) << " exists" << endl;
            }
            else if (found == -1) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "call parameter list does not match with defined paramters of function " << string($1) << endl;
            }
            else {
                $$.type = callFuncPtr->returnType;
                if(callFuncPtr->returnType == INTEGER){
                    $$.registerName = new string(tempSet.getRegister());
                    generateInstr(functionInstruction, "refparam " + (*($$.registerName)), nextquadraple);
                    generateInstr(functionInstruction, "call _" + callFuncPtr->name + ", " + to_string(typeRecordList.size() + 1 ), nextquadraple);      
                }
                else if(callFuncPtr->returnType == FLOATING){
                    $$.registerName = new string(tempSet.getFloatRegister());
                    generateInstr(functionInstruction, "refparam " + (*($$.registerName)), nextquadraple);
                    generateInstr(functionInstruction, "call _" + callFuncPtr->name + ", " + to_string(typeRecordList.size() + 1 ), nextquadraple);      
                }
                else if (callFuncPtr->returnType == NULLVOID) {
                    $$.registerName = NULL;
                    generateInstr(functionInstruction, "call _" + callFuncPtr->name + ", " + to_string(typeRecordList.size()), nextquadraple);      
                }
                else {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Illegal return type of function " << callFuncPtr->name << endl;
                }
            }
        }
        typeRecordList.clear();
        typeRecordList.swap(paramListStack.top());
        paramListStack.pop();
    }
;

PARAMLIST: PLIST
    | {paramListStack.push(typeRecordList); typeRecordList.clear();} %empty 
;

PLIST: PLIST COMMA ASSIGNMENT
    {
        varRecord = new typeRecord;
        string testing9 = testing_function2("testing code");
        varRecord->eleType = $3.type;
        if ($3.type == ERRORTYPE) {
            foundError = true;
        }
        else {
            varRecord->name = *($3.registerName);
            varRecord->type = SIMPLE;
            generateInstr(functionInstruction, "param " +  *($3.registerName), nextquadraple);   
            tempSet.freeRegister(*($3.registerName));
        }
        typeRecordList.push_back(varRecord);
    }
    | {paramListStack.push(typeRecordList); typeRecordList.clear();} ASSIGNMENT
    {
        varRecord = new typeRecord;
        varRecord->eleType = $2.type;
        if ($2.type == ERRORTYPE) {
            foundError = true;
        }
        else {
            varRecord->name = *($2.registerName);
            varRecord->type = SIMPLE; 
            generateInstr(functionInstruction, "param " +  *($2.registerName), nextquadraple);   
            tempSet.freeRegister(*($2.registerName));
        }
        typeRecordList.push_back(varRecord);
    }
;

ASSIGNMENT: CONDITION1
    {
        $$.type = $1.type;
        if($$.type != ERRORTYPE && $$.type != NULLVOID) {
            $$.registerName = $1.registerName;
            if($1.jumpList!=NULL){
                vector<int>* qList = new vector<int>;
                qList->push_back(nextquadraple);
                generateInstr(functionInstruction,"goto L",nextquadraple);
                backpatch($1.jumpList, nextquadraple, functionInstruction);
                generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
                generateInstr(functionInstruction,(*($$.registerName)) + " = 1",nextquadraple) ;
                backpatch(qList,nextquadraple,functionInstruction);
                qList->clear();
                generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
            }
        }
    }
    | LHS ASSIGN ASSIGNMENT
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.registerName) << endl;
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else {
            $$.type = $1.type;
            string registerName;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                registerName = tempSet.getRegister();
                string str1 = registerName + " = convertToInt(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, str1, nextquadraple);
                tempSet.freeRegister(*($3.registerName));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                registerName = tempSet.getFloatRegister();
                string str2 = registerName + " = convertToFloat(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, str2, nextquadraple); 
                tempSet.freeRegister(*($3.registerName));
            }
            else {
                registerName = *($3.registerName);
            }
            string str3 = (*($1.registerName)) + " = " + registerName ;
            generateInstr(functionInstruction, str3, nextquadraple);
            int test_1 = testing_function1("test");
            $$.registerName = new string(registerName);
            if ($1.offsetRegName != NULL) tempSet.freeRegister(*($1.offsetRegName));
        }
    }
    | LHS PLUSASG ASSIGNMENT
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            string testing10 = testing_function2("testing code");
            foundError = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.registerName) << endl;
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else {
            $$.type = $1.type;
            string registerName;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                registerName = tempSet.getRegister();
                string str4 = registerName + " = convertToInt(" + (*($3.registerName)) + ")";
                int test_2 = testing_function1("test");  
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, str4, nextquadraple);
                tempSet.freeRegister(*($3.registerName));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                registerName = tempSet.getFloatRegister();
                string str5 = registerName + " = convertToFloat(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, str5, nextquadraple); 
                tempSet.freeRegister(*($3.registerName));
            }
            else {
                registerName = *($3.registerName);
            }
            string string6, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.getRegister();
                string6 = tempReg + " = " + (*($1.registerName));
                generateInstr(functionInstruction, string6, nextquadraple);
            }
            else{
                tempReg = tempSet.getFloatRegister();
                string6 = tempReg + " = " + (*($1.registerName));   
                generateInstr(functionInstruction, string6, nextquadraple);
            }
            string6 = registerName + " = " + registerName + " + " + tempReg;
            generateInstr(functionInstruction, string6, nextquadraple);
            tempSet.freeRegister(tempReg);
            string6 = (*($1.registerName)) + " = " + registerName ;
            generateInstr(functionInstruction, string6, nextquadraple);
            $$.registerName = new string(registerName);
            int test_3 = testing_function1("test");
            if ($1.offsetRegName != NULL) tempSet.freeRegister(*($1.offsetRegName));
        }
    }
    | LHS MINASG ASSIGNMENT
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.registerName) << endl;
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else {
            $$.type = $1.type;
            string registerName;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                registerName = tempSet.getRegister();
                string string7 = registerName + " = convertToInt(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, string7, nextquadraple);
                tempSet.freeRegister(*($3.registerName));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                registerName = tempSet.getFloatRegister();
                string string8 = registerName + " = convertToFloat(" + (*($3.registerName)) + ")"; 
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, string8, nextquadraple); 
                tempSet.freeRegister(*($3.registerName));
            }
            else {
                registerName = *($3.registerName);
            }
            string string9, tmpRegister;
            if($1.type == INTEGER){
                tmpRegister = tempSet.getRegister();
                string9 = tmpRegister + " = " + (*($1.registerName));
                generateInstr(functionInstruction, string9, nextquadraple);
            }
            else{
                tmpRegister = tempSet.getFloatRegister();
                string9 = tmpRegister + " = " + (*($1.registerName));   
                generateInstr(functionInstruction, string9, nextquadraple);
            }
            string9 = registerName + " = " + registerName + " - " + tmpRegister;
            generateInstr(functionInstruction, string9, nextquadraple);
            tempSet.freeRegister(tmpRegister);
            string9 = (*($1.registerName)) + " = " + registerName ;
            generateInstr(functionInstruction, string9, nextquadraple);
            $$.registerName = new string(registerName);
            if ($1.offsetRegName != NULL) tempSet.freeRegister(*($1.offsetRegName));
        }
    }
    | LHS MULASG ASSIGNMENT
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.registerName) << endl;
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else {
            $$.type = $1.type;
            string RegName;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                RegName = tempSet.getRegister();
                string pluto = RegName + " = convertToInt(" + (*($3. registerName)) + ")"; 
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, pluto, nextquadraple);
                tempSet.freeRegister(*($3.registerName));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                RegName = tempSet.getFloatRegister();
                string pluto = RegName + " = convertToFloat(" + (*($3.registerName)) + ")";  
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, pluto, nextquadraple); 
                tempSet.freeRegister(*($3.registerName));
            }
            else {
                RegName = *($3.registerName);
            }
            string pluto, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.getRegister();
                pluto = tempReg + " = " + (*($1.registerName));
                generateInstr(functionInstruction, pluto, nextquadraple);
            }
            else{
                tempReg = tempSet.getFloatRegister();
                pluto = tempReg + " = " + (*($1.registerName));   
                generateInstr(functionInstruction, pluto, nextquadraple);
            }
            pluto = RegName + " = " + RegName + " * " + tempReg;
            generateInstr(functionInstruction, pluto, nextquadraple);
            tempSet.freeRegister(tempReg);
            pluto = (*($1.registerName)) + " = " + RegName ;
            generateInstr(functionInstruction, pluto, nextquadraple);
            $$.registerName = new string(RegName);
            if ($1.offsetRegName != NULL) tempSet.freeRegister(*($1.offsetRegName));
        }
    }
    | LHS DIVASG ASSIGNMENT
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.registerName) << endl;
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else {
            $$.type = $1.type;
            string registerName;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                registerName = tempSet.getRegister();
                string asdf = registerName + " = convertToInt(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, asdf, nextquadraple);
                tempSet.freeRegister(*($3.registerName));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                registerName = tempSet.getFloatRegister();
                string ghjk = registerName + " = convertToFloat(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, ghjk, nextquadraple); 
                tempSet.freeRegister(*($3.registerName));
            }
            else {
                registerName = *($3.registerName);
            }
            string uranus, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.getRegister();
                uranus = tempReg + " = " + (*($1.registerName));
                generateInstr(functionInstruction, uranus, nextquadraple);
            }
            else{
                tempReg = tempSet.getFloatRegister();
                uranus = tempReg + " = " + (*($1.registerName));   
                generateInstr(functionInstruction, uranus, nextquadraple);
            }
            uranus = registerName + " = " + registerName + " / " + tempReg;
            generateInstr(functionInstruction, uranus, nextquadraple);
            tempSet.freeRegister(tempReg);
            uranus = (*($1.registerName)) + " = " + registerName ;
            generateInstr(functionInstruction, uranus, nextquadraple);
            $$.registerName = new string(registerName);
            if ($1.offsetRegName != NULL) tempSet.freeRegister(*($1.offsetRegName));
        }
    }
    | LHS MODASG ASSIGNMENT
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.registerName) << endl;
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else {
            $$.type = $1.type;
            string registerName;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                registerName = tempSet.getRegister();
                string s = registerName + " = convertToInt(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, s, nextquadraple);
                tempSet.freeRegister(*($3.registerName));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                registerName = tempSet.getFloatRegister();
                string s = registerName + " = convertToFloat(" + (*($3.registerName)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generateInstr(functionInstruction, s, nextquadraple); 
                tempSet.freeRegister(*($3.registerName));
            }
            else {
                registerName = *($3.registerName);
            }
            string s, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.getRegister();
                s = tempReg + " = " + (*($1.registerName));
                generateInstr(functionInstruction, s, nextquadraple);
            }
            else{
                tempReg = tempSet.getFloatRegister();
                s = tempReg + " = " + (*($1.registerName));   
                generateInstr(functionInstruction, s, nextquadraple);
            }
            s = registerName + " = " + registerName + " % " + tempReg;
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(tempReg);
            s = (*($1.registerName)) + " = " + registerName ;
            generateInstr(functionInstruction, s, nextquadraple);
            $$.registerName = new string(registerName);
            if ($1.offsetRegName != NULL) tempSet.freeRegister(*($1.offsetRegName));
        }
    }
;

LHS: ID_ARR  
    {
        $$.type = $1.type;
        if ($$.type != ERRORTYPE) {
            $$.registerName = $1.registerName;
            $$.offsetRegName = $1.offsetRegName;
        } 
    } 
;

SWITCHCASE: SWITCH LP ASSIGNMENT RP TEMP1 LCB  CASELIST RCB 
    {
        deleteVarList(activeFunctionPointer,scope);
        scope--;

        int q=nextquadraple;
        vector<int>* qList = new vector<int>;
        qList->push_back(q);
        generateInstr(functionInstruction, "goto L", nextquadraple);
        backpatch($5.falseList, nextquadraple, functionInstruction);
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
        reverse($7.casepair->begin(), $7.casepair->end());
        for(auto it : *($7.casepair)){
            if(it.first == "default"){
                generateInstr(functionInstruction, "goto L"+to_string(it.second), nextquadraple);
            }
            else{
                generateInstr(functionInstruction, "if "+ (*($3.registerName)) +" == "+ it.first + " goto L" + to_string(it.second), nextquadraple);
            }
        }
        $7.casepair->clear();
        backpatch(qList, nextquadraple, functionInstruction);
        backpatch($7.breakList, nextquadraple, functionInstruction);
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
    }
;

TEMP1: %empty
    {
        $$.begin=nextquadraple;
        $$.falseList = new vector<int>;
        $$.falseList->push_back(nextquadraple);
        generateInstr(functionInstruction, "goto L", nextquadraple);
        scope++;
    }
;

TEMP2:%empty
    {
        $$.casepair = new vector<pair<string,int>>;

    }
;

CASELIST:
    CASE MINUS NUMINT TEMP2 {
        $4.casepair->push_back(make_pair("-"+string($3), nextquadraple));
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
        } COLON BODY 
    CASELIST
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        $$.casepair = new vector<pair<string,int>>;
        merge($$.continueList,$8.continueList);
        merge($$.breakList, $8.breakList);
        merge($$.nextList, $8.nextList);
        merge($$.continueList,$7.continueList);
        merge($$.breakList, $7.breakList);
        merge($$.nextList, $7.nextList);
        mergeSwitch($$.casepair, $8.casepair);
        mergeSwitch($$.casepair, $4.casepair);
    }
    |
    CASE NUMINT TEMP2 {
        $3.casepair->push_back(make_pair(string($2), nextquadraple));
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
        } COLON BODY 
    CASELIST
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        $$.casepair = new vector<pair<string,int>>;
        merge($$.continueList,$6.continueList);
        merge($$.breakList, $6.breakList);
        merge($$.nextList, $6.nextList);
        merge($$.continueList,$7.continueList);
        merge($$.breakList, $7.breakList);
        merge($$.nextList, $7.nextList);
        mergeSwitch($$.casepair, $7.casepair);
        mergeSwitch($$.casepair, $3.casepair);
    }
    | %empty
    {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList = new vector <int>;
        $$.casepair = new vector<pair<string,int>>;
    }
    | DEFAULT COLON TEMP2 {
        $3.casepair->push_back(make_pair("default", nextquadraple));
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
    }
     BODY {
        $$.nextList = new vector<int>;
        $$.breakList = new vector<int>;
        $$.casepair = new vector<pair<string,int>>;
        $$.continueList = new vector <int>;
        merge($$.continueList,$5.continueList);
        merge($$.breakList, $5.breakList);
        merge($$.nextList, $5.nextList);
        mergeSwitch($$.casepair, $3.casepair);
    }
;

M3: %empty
    { 
        $$ = nextquadraple;
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple); 
    }
;

N3: %empty
    { 
        $$.begin = nextquadraple; 
        $$.falseList = new vector<int>;
        $$.falseList->push_back(nextquadraple);
        generateInstr(functionInstruction, "goto L", nextquadraple);
    }
;

P3: %empty 
    { 
        $$.falseList = new vector<int>;
        $$.falseList->push_back(nextquadraple);
        generateInstr(functionInstruction, "goto L", nextquadraple);
        $$.begin = nextquadraple; 
        generateInstr(functionInstruction, "L"+to_string(nextquadraple)+":", nextquadraple);
    }
;

Q3: %empty
    {
        $$.begin = nextquadraple;
        $$.falseList = new vector<int>;
        $$.falseList->push_back(nextquadraple);
    }
;

Q4: %empty
    {
        $$ = nextquadraple;
    }
;

FORLOOP: FOREXP Q4 LCB BODY RCB
    {
        deleteVarList(activeFunctionPointer, scope);
        scope--;
        generateInstr(functionInstruction, "goto L" + to_string($1.begin), nextquadraple); 
        merge($1.falseList,$4.breakList);
        backpatch($4.continueList,$1.begin, functionInstruction);
        backpatch($1.falseList, nextquadraple, functionInstruction);
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple); 
    }
;

FOREXP: FOR LP ASG1 SEMI M3 ASG1 Q3 {
        if($6.type!=NULLVOID){
            generateInstr(functionInstruction, "if "+ (*($6.registerName)) + " == 0 goto L", nextquadraple);
        }
    } P3 SEMI ASG1 N3 RP 
    {
        backpatch($12.falseList,$5,functionInstruction);
        backpatch($9.falseList,nextquadraple,functionInstruction);
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple); 
        $$.falseList = new vector<int>;
        if($6.type!=NULLVOID){
            $$.falseList->push_back($7.begin);            
        }
        $$.begin = $9.begin;
        scope++;
        if($3.type!=NULLVOID){
            tempSet.freeRegister(*($3.registerName));
        }
        if($6.type!=NULLVOID){
            tempSet.freeRegister(*($6.registerName));
        }
        if($11.type!=NULLVOID){
            tempSet.freeRegister(*($11.registerName));
        }
    }
    | FOR error RP
    {
        foundError = 1;
        $$.falseList = new vector<int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error in for loop, discarded token till RP") << endl;
        scope++;
    }
;

ASG1: ASSIGNMENT
    {
        $$.type= $1.type;
        if ($1.type != ERRORTYPE && $1.type != NULLVOID) {
            $$.registerName = $1.registerName;
        }
    }
    | %empty {
        $$.type = NULLVOID;
    }
;

M1: %empty
    {
        $$=nextquadraple;
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
    }
;

M2: %empty
    {
        $$.nextList = new vector<int>;
        ($$.nextList)->push_back(nextquadraple);
        generateInstr(functionInstruction, "goto L", nextquadraple);
    }
;

IFSTATEMENT: IFEXP LCB BODY RCB 
    {
        deleteVarList(activeFunctionPointer,scope);
        scope--;
        $$.nextList= new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList= new vector<int>;
        merge($$.nextList, $1.falseList);
        merge($$.breakList, $3.breakList);
        merge($$.continueList, $3.continueList);
        backpatch($$.nextList,nextquadraple,functionInstruction);
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
    }
    | IFEXP LCB BODY RCB {deleteVarList(activeFunctionPointer,scope);} M2 ELSE M1 LCB BODY RCB
    {
        deleteVarList(activeFunctionPointer,scope);
        scope--;
        $$.nextList= new vector<int>;
        $$.breakList = new vector<int>;
        $$.continueList= new vector<int>;
        backpatch($1.falseList,$8,functionInstruction);
        merge($$.nextList,$6.nextList );
        backpatch($$.nextList,nextquadraple,functionInstruction);
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
        merge($$.breakList, $3.breakList);
        merge($$.continueList, $3.continueList);
        merge($$.breakList, $10.breakList);
        merge($$.continueList, $10.continueList);
    }
;

IFEXP: IF LP ASSIGNMENT RP 
    {
        if($3.type != ERRORTYPE && $3.type!=NULLVOID){
            $$.falseList = new vector <int>;
            $$.falseList->push_back(nextquadraple);
            if($3.type == NULLVOID){
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << "condition in if statement can't be empty" << endl;
                foundError=true;
            }
            generateInstr(functionInstruction, "if "+ (*($3.registerName)) + " == 0 goto L", nextquadraple);
            scope++;
            tempSet.freeRegister(*($3.registerName));
        } 
    }
    | IF error RP
    {
        foundError = 1;
        $$.falseList = new vector <int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error in if, discarding tokens till RP") << endl;
        scope++;
    }
;

WHILESTATEMENT:  WHILEEXP LCB BODY RCB 
    {
        deleteVarList(activeFunctionPointer,scope);
        scope--;

        generateInstr(functionInstruction, "goto L" + to_string($1.begin), nextquadraple);
        backpatch($3.nextList, $1.begin, functionInstruction);
        backpatch($3.continueList, $1.begin, functionInstruction);
        $$.nextList = new vector<int>;
        merge($$.nextList, $1.falseList);
        merge($$.nextList, $3.breakList);
        backpatch($$.nextList,nextquadraple,functionInstruction);
        generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
    }
;

WHILEEXP: WHILE M1 LP ASSIGNMENT RP
    {
        scope++;
        if($4.type == NULLVOID || $4.type == ERRORTYPE){
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout<<"Expression in if statement can't be empty"<<endl;
            foundError = true;
        }
        else{
            $$.falseList = new vector<int>;
            ($$.falseList)->push_back(nextquadraple);
            generateInstr(functionInstruction, "if " + *($4.registerName) + "== 0 goto L", nextquadraple);
            $$.begin = $2; 
        }
    }
    | WHILE error RP
    {   
        $$.falseList = new vector<int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error in while loop, discarding tokens till RP") << endl;
        scope++;
    }
;

TP1: %empty
{
    $$.temp = new vector<int>;
}
;

CONDITION1: CONDITION1 TP1
    {
        if($1.type!=ERRORTYPE){
            $2.temp->push_back(nextquadraple);
            generateInstr(functionInstruction, "if " + *($1.registerName) + "!= 0 goto L", nextquadraple);

        }
    }
     OR CONDITION2
    {
        if($1.type==ERRORTYPE || $5.type==ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $5.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ": Both the expessions should not be NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());
            vector<int>* qList = new vector<int>;
            if($5.jumpList!=NULL){
                qList->push_back(nextquadraple);
                generateInstr(functionInstruction,"goto L",nextquadraple);
                backpatch($5.jumpList, nextquadraple, functionInstruction);
                generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
                generateInstr(functionInstruction,(*($5.registerName)) + " = 0",nextquadraple) ;
                backpatch(qList,nextquadraple,functionInstruction);
                generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
                qList->clear();
            }
            
            $$.jumpList = new vector<int>;
            merge($$.jumpList,$1.jumpList);
            
            merge($$.jumpList, $2.temp);
            ($$.jumpList)->push_back(nextquadraple);
            generateInstr(functionInstruction, "if " + *($5.registerName) + "!= 0 goto L", nextquadraple);
            string s = (*($$.registerName)) + " = 0";   
            generateInstr(functionInstruction,s,nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($5.registerName)); 
        }
    }
    | CONDITION2
    {
        $$.type = $1.type;
        if ($$.type != ERRORTYPE && $$.type != NULLVOID) {
            $$.registerName = $1.registerName; 
            if($1.jumpList!=NULL){
                vector<int>* qList = new vector<int>;
                qList->push_back(nextquadraple);
                generateInstr(functionInstruction,"goto L",nextquadraple);
                backpatch($1.jumpList, nextquadraple, functionInstruction);
                generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
                generateInstr(functionInstruction,(*($$.registerName)) + " = 0",nextquadraple) ;
                backpatch(qList,nextquadraple,functionInstruction);
                generateInstr(functionInstruction, "L" + to_string(nextquadraple) + ":", nextquadraple);
                qList->clear();   
            }
        }
    }
;  


CONDITION2: CONDITION2 TP1
    {
      if ($1.type!=ERRORTYPE ){

          ($2.temp)->push_back(nextquadraple);
         generateInstr(functionInstruction, "if " + *($1.registerName) + " == 0 " +" goto L", nextquadraple);
      } 
    }
    AND EXPR1 
    {
        if ($1.type==ERRORTYPE || $5.type==ERRORTYPE) {
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $5.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ": Both the expessions should not be NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());
            $$.jumpList = new vector<int>;
            merge($$.jumpList,$1.jumpList);
            vector<int>* qList = new vector<int>;
            
            merge($$.jumpList, $2.temp);
            ($$.jumpList)->push_back(nextquadraple);
            generateInstr(functionInstruction, "if " + *($5.registerName) + " == 0 "+" goto L", nextquadraple);

            string s = (*($$.registerName)) + " = 1";   
            generateInstr(functionInstruction,s,nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($5.registerName));   
        }
    }
    | EXPR1
    {
        $$.type = $1.type;
        if ($1.type != ERRORTYPE && $1.type != NULLVOID) {
            $$.registerName = $1.registerName; 
            $$.jumpList = new vector<int>;
            $$.jumpList=NULL;   
        }
    }
;

EXPR1: NOT EXPR21
    {
        $$.type = $2.type;
        if ($2.type != ERRORTYPE && $2.type != NULLVOID) {
            $$.registerName = $2.registerName;
            string s = (*($$.registerName)) + " = ~" + (*($2.registerName));   
            generateInstr(functionInstruction, s, nextquadraple);
        }
    }
    | EXPR21
    {
        $$.type = $1.type;
        if ($1.type != ERRORTYPE && $1.type != NULLVOID) {
            $$.registerName = $1.registerName;    
        }
    }
;

EXPR21: EXPR2 EQUAL EXPR2
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else {
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());     
            string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " == " + (*($3.registerName))   ;
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($3.registerName));  
        }   
    }
    | EXPR2 NOTEQUAL EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());     
            string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " != " + (*($3.registerName));   
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($3.registerName));  
        }   
    }
    | EXPR2 LT EXPR2 
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());     
            string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " < " + (*($3.registerName));   
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($3.registerName));  
        }   
    }
    | EXPR2 GT EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());     
            string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " > " + (*($3.registerName));   
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($3.registerName));  
        }   
    }
    | EXPR2 LE EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
            foundError = true;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());     
            string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " <= " + (*($3.registerName));   
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($3.registerName));  
        }   
    }
    | EXPR2 GE EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.registerName = new string(tempSet.getRegister());     
            string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " >= " + (*($3.registerName));  
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(*($1.registerName));
            tempSet.freeRegister(*($3.registerName));  
        }   
    } 
    | EXPR2 
    {
        $$.type = $1.type; 
        if($$.type == ERRORTYPE){
            foundError = true;
        }
        else{
            if($1.type != NULLVOID){
                $$.registerName = new string(*($1.registerName)); 
                delete $1.registerName; 
            }
        }    
    }
;

EXPR2:  EXPR2 PLUS TERM
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE; 
            foundError = true; 
        }
        else {
            if (arithmeticCompatible($1.type, $3.type)) {
                $$.type = compareTypes($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($1.registerName));
                    $1.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($3.registerName));
                    $3.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }

                if ($$.type == INTEGER) 
                    $$.registerName = new string(tempSet.getRegister());
                else
                    $$.registerName = new string(tempSet.getFloatRegister());
                    
                string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " + " + (*($3.registerName));;   
                generateInstr(functionInstruction, s, nextquadraple);
                tempSet.freeRegister(*($1.registerName));
                tempSet.freeRegister(*($3.registerName));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }
    }
    | EXPR2 MINUS TERM
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            foundError = true;  
        }
        else {
            if (arithmeticCompatible($1.type, $3.type)) {
                $$.type = compareTypes($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($1.registerName));
                    $1.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($3.registerName));
                    $3.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }

                if ($$.type == INTEGER) 
                    $$.registerName = new string(tempSet.getRegister());
                else
                    $$.registerName = new string(tempSet.getFloatRegister());
                    
                string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " - " + (*($3.registerName));;   
                generateInstr(functionInstruction, s, nextquadraple);
                tempSet.freeRegister(*($1.registerName));
                tempSet.freeRegister(*($3.registerName));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }
    }
    | TERM 
    { 
        $$.type = $1.type; 
        if ($1.type == ERRORTYPE) {
            foundError = true;
        }
        else {
            if($1.type!= NULLVOID){
                $$.registerName = new string(*($1.registerName)); 
                delete $1.registerName;
            }         
        } 
    }
;

TERM: TERM MUL FACTOR
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;  
        }
        else {
            if (arithmeticCompatible($1.type, $3.type)) {
                $$.type = compareTypes($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($1.registerName));
                    $1.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($3.registerName));
                    $3.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }

                if ($$.type == INTEGER) 
                    $$.registerName = new string(tempSet.getRegister());
                else
                    $$.registerName = new string(tempSet.getFloatRegister());
                    
                string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " * " + (*($3.registerName));;   
                generateInstr(functionInstruction, s, nextquadraple);
                tempSet.freeRegister(*($1.registerName));
                tempSet.freeRegister(*($3.registerName));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }
    }
    | TERM DIV FACTOR  
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
        $$.type = ERRORTYPE;  
        }
        else {
            if (arithmeticCompatible($1.type, $3.type)) {
                $$.type = compareTypes($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($1.registerName));
                    $1.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.getFloatRegister();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.registerName)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.freeRegister(*($3.registerName));
                    $3.registerName = &newReg;
                    generateInstr(functionInstruction, s, nextquadraple);
                }

                if ($$.type == INTEGER) 
                    $$.registerName = new string(tempSet.getRegister());
                else
                    $$.registerName = new string(tempSet.getFloatRegister());
                    
                string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " / " + (*($3.registerName));   
                generateInstr(functionInstruction, s, nextquadraple);
                tempSet.freeRegister(*($1.registerName));
                tempSet.freeRegister(*($3.registerName));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }   
    }  
    | TERM MOD FACTOR
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;  
        }
        else {
            if ($1.type == INTEGER && $3.type == INTEGER) {
                $$.type = INTEGER;
                $$.registerName = new string(tempSet.getRegister());  
                string s = (*($$.registerName)) + " = " + (*($1.registerName)) + " % " + (*($3.registerName));;   
                generateInstr(functionInstruction, s, nextquadraple);
                tempSet.freeRegister(*($1.registerName));
                tempSet.freeRegister(*($3.registerName));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }   
    }
    | FACTOR 
    { 
        $$.type = $1.type; 
        if ($1.type == ERRORTYPE) {
            foundError = true;
        }
        else {
            if($1.type != NULLVOID){
                $$.registerName = new string(*($1.registerName)); 
                delete $1.registerName;
            }  
        } 
    }
;

FACTOR: ID_ARR  
    { 
        $$.type = $1.type;
        if ($$.type != ERRORTYPE) {
            if ($$.type == INTEGER)
                $$.registerName = new string(tempSet.getRegister());
            else $$.registerName = new string(tempSet.getFloatRegister());
            string s = (*($$.registerName)) + " = " + (*($1.registerName)) ;
            generateInstr(functionInstruction, s, nextquadraple);
            if($1.offsetRegName != NULL){
                tempSet.freeRegister((*($1.offsetRegName)));
            }
        }
    }
    | MINUS ID_ARR
    {
        $$.type = $2.type;
        if($2.type != ERRORTYPE){
            string s="";
            if ($$.type == INTEGER){
                $$.registerName = new string(tempSet.getRegister());
                string temp=tempSet.getRegister();
                string temp1=tempSet.getRegister();
                generateInstr(functionInstruction, temp + " = 0", nextquadraple);
                generateInstr(functionInstruction, temp1 + " = " +  (*($2.registerName)), nextquadraple);
                s = (*($$.registerName)) + " = " + temp + " -" + temp1 ;
                tempSet.freeRegister(temp);
                tempSet.freeRegister(temp1);
            }
            else{ 
                $$.registerName = new string(tempSet.getFloatRegister());
                string temp=tempSet.getFloatRegister();
                string temp1=tempSet.getRegister();
                generateInstr(functionInstruction, temp + " = 0", nextquadraple);
                generateInstr(functionInstruction, temp1 + " = " +  (*($2.registerName)), nextquadraple);
                s = (*($$.registerName)) + " = 0 -" + temp1 ;
                tempSet.freeRegister(temp);
                tempSet.freeRegister(temp1);
            }
            // string s = (*($$.registerName)) + " = 0 -" + (*($2.registerName)) ;
            generateInstr(functionInstruction, s, nextquadraple);
            if($2.offsetRegName != NULL){
                tempSet.freeRegister((*($2.offsetRegName)));
            }
        }       
    }
    | MINUS NUMINT
    {
        $$.type = INTEGER; 
        $$.registerName = new string(tempSet.getRegister());
        string s = (*($$.registerName)) + " = -" + string($2) ;
        generateInstr(functionInstruction, s, nextquadraple);  
        
    }
    | NUMINT    
    { 
        $$.type = INTEGER; 
        $$.registerName = new string(tempSet.getRegister());
        string s = (*($$.registerName)) + " = " + string($1) ;
        generateInstr(functionInstruction, s, nextquadraple);  
    }
    | MINUS NUMFLOAT
    {
        $$.type = FLOATING;
        $$.registerName = new string(tempSet.getFloatRegister());
        string s = (*($$.registerName)) + " = " + string($2) ;
        generateInstr(functionInstruction, s, nextquadraple);  
    }
    | NUMFLOAT  
    { 
        $$.type = FLOATING;
        $$.registerName = new string(tempSet.getFloatRegister());
        string s = (*($$.registerName)) + " = " + string($1) ;
        generateInstr(functionInstruction, s, nextquadraple);  
    }
    | FUNC_CALL 
    { 
        $$.type = $1.type; 
        if ($1.type == ERRORTYPE) {
            if ($1.type == NULLVOID){
                delete callFuncPtr;
            }
            else {
                $$.registerName = $1.registerName;
                delete callFuncPtr;
            }
        }; 
    }
    | LP ASSIGNMENT RP 
    { 
        $$.type = $2.type; 
        if ($2.type != ERRORTYPE) {
            $$.registerName = $2.registerName;
        }
    }
    | ID_ARR INCREMENT
    {
        if ($1.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.getRegister();
            $$.registerName = new string(newReg); 
            string s = newReg + " = " + (*($1.registerName)) ;
            generateInstr(functionInstruction, s, nextquadraple); // T2 = i
            string newReg2 = tempSet.getRegister();
            s = newReg2 + " = " + newReg + " + 1"; // T3 = T2+1
            generateInstr(functionInstruction, s, nextquadraple);
            s = (*($1.registerName)) + " = " + newReg2; // i = T3
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(newReg2);
            if($1.offsetRegName != NULL){
                tempSet.freeRegister((*($1.offsetRegName)));
            }
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable "<< *($1.registerName) << endl; 
        }
    } 
    | ID_ARR DECREMENT
    {
        if ($1.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.getRegister();
            $$.registerName = new string(newReg);
            string s = newReg + " = " + (*($1.registerName)); // T0 = i
            generateInstr(functionInstruction, s, nextquadraple);
            string newReg2 = tempSet.getRegister();
            s = newReg2 + " = " + newReg + " - 1"; // T3 = T2+1
            generateInstr(functionInstruction, s, nextquadraple);
            s = (*($1.registerName)) + " = " + newReg2; // i = T3
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(newReg2); 
            if($1.offsetRegName != NULL){
                tempSet.freeRegister((*($1.offsetRegName)));
            }    
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable " << *($1.registerName) << endl; 
        }
    } 
    | INCREMENT ID_ARR
    {
        if ($2.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.getRegister();
            string s = newReg + " = " + (*($2.registerName)); // T2 = i
            generateInstr(functionInstruction, s, nextquadraple);
            string newReg2 = tempSet.getRegister();
            $$.registerName = new string(newReg2);
            s = newReg2 + " = " + newReg + " + 1"; // T3 = T2+1
            generateInstr(functionInstruction, s, nextquadraple);
            s = (*($2.registerName)) + " = " + newReg2; // i = T3
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(newReg); 
            if($2.offsetRegName != NULL){
                tempSet.freeRegister((*($2.offsetRegName)));
            }     
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable "<<*($2.registerName) << endl; 
        }
    } 
    | DECREMENT ID_ARR
    {
        if ($2.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.getRegister();
            string s = newReg + " = " + (*($2.registerName)); // T2 = i
            generateInstr(functionInstruction, s, nextquadraple);
            string newReg2 = tempSet.getRegister();
            $$.registerName = new string(newReg2);
            s = newReg2 + " = " + newReg + " - 1"; // T3 = T2+1
            generateInstr(functionInstruction, s, nextquadraple);
            s = (*($2.registerName)) + " = " + newReg2; // i = T3
            generateInstr(functionInstruction, s, nextquadraple);
            tempSet.freeRegister(newReg);
            if($2.offsetRegName != NULL){
                tempSet.freeRegister((*($2.offsetRegName)));
            }         
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable " << *($2.registerName) << endl; 
        }
    }
;

ID_ARR: ID
    {   
        // retrieve the highest level id with same name in param list or var list or global list
        int found = 0;
        typeRecord* variablename = NULL;
        searchCallVariable(string($1), activeFunctionPointer, found, variablename, globalVariables); 
        $$.offsetRegName = NULL;
        if(found){
            if (variablename->type == SIMPLE) {
                $$.type = variablename->eleType;
                string dataType = eletypeMapper($$.type);
                dataType += "_" + to_string(variablename->scope);
                $$.registerName = new string("_" + string($1) + "_" + dataType);
            }
            else {
                $$.type = ERRORTYPE;
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << $1 << " is declared as an array but is being used as a singleton" << endl; 
            }
        }
        else {
            if (activeFunctionPointer != NULL)
                searchParam(string ($1), activeFunctionPointer->parameterList, found, variablename);
            if (found) {
                if (variablename->type == SIMPLE) {
                    $$.type = variablename->eleType;
                    string dataType = eletypeMapper($$.type);
                    dataType += "_" + to_string(variablename->scope);
                    $$.registerName = new string("_" + string($1) + "_" + dataType);
                }
                else {
                    $$.type = ERRORTYPE;
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                    cout << $1 << " is declared as an array but is being used as a singleton" << endl;
                }
            }
            else {
                $$.type = ERRORTYPE;
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Undeclared identifier " << $1 << endl;
            }
        }
    }
    | ID BR_DIMLIST
    {
        // retrieve the highest level id with same name in param list or var list
        int found = 0;
        typeRecord* variablename = NULL;
        $$.offsetRegName = NULL; 
        if($2.type == ERRORTYPE){
            foundError = true;
            $$.type = ERRORTYPE;
        }
        else{
            searchCallVariable(string($1), activeFunctionPointer, found, variablename, globalVariables); 
            if(found){
                if (variablename->type == ARRAY) {
                    if (dimlist.size() == variablename->dimlist.size()) {
                        $$.type = variablename->eleType;
                        // calculate linear address using dimensions then pass to FACTOR
                        string offsetRegister = tempSet.getRegister();
                        string dimlistRegister = tempSet.getRegister();
                        string s = offsetRegister + " = 0";
                        generateInstr(functionInstruction, s, nextquadraple);
                        for (int i = 0; i < variablename->dimlist.size(); i++) {
                            s = offsetRegister + " = " + offsetRegister + " + " + dimlist[i];
                            generateInstr(functionInstruction, s, nextquadraple);
                            // offset += dimlist[i];
                            if (i != variablename->dimlist.size()-1) {
                                // offset *= variablename->dimlist[i+1];
                                s = dimlistRegister + " = " + to_string(variablename->dimlist[i+1]);
                                generateInstr(functionInstruction, s, nextquadraple);                                
                                s = offsetRegister + " = " + offsetRegister + " * " + dimlistRegister;
                                generateInstr(functionInstruction, s, nextquadraple);
                            }
                            tempSet.freeRegister(dimlist[i]);
                        }
                        string dataType = eletypeMapper($$.type);
                        dataType += "_" + to_string(variablename->scope); 
                        s = "_" + string($1) + "_" + dataType ;
                        s += "[" + offsetRegister + "]";
                        $$.registerName = new string(s);
                        tempSet.freeRegister(dimlistRegister);
                        $$.offsetRegName = new string(offsetRegister);
                        
                    }
                    else {
                        $$.type = ERRORTYPE;
                        cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                        cout << "Dimension mismatch: " << $1 << " should have " << dimlist.size() <<" dimensions" << endl;
                    }
                }
                else {
                    $$.type = ERRORTYPE;
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                    cout << string($1) << " is declared as a singleton but is being used as an array" << endl; 
                }
            }
            else {
                $$.type = ERRORTYPE;
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Undeclared identifier " << $1 << endl;
            }
            dimlist.clear();
        }
    }
;

BR_DIMLIST: LSB ASSIGNMENT RSB
    {
        if ($2.type == INTEGER) {
            dimlist.push_back(*($2.registerName));
        }
        else {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "One of the dimension of an array cannot be evaluated to integer" << endl;
        }
    }    
    | BR_DIMLIST LSB ASSIGNMENT RSB 
    {
        if ($3.type == INTEGER) {
            dimlist.push_back(*($3.registerName));
        }
        else {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "One of the dimension of an array cannot be evaluated to integer" << endl;
        }  
    }
;

%%

void yyerror(const char *s)
{      
    foundError=1;
    fprintf (stderr, "%s\n", s);
    // cout << "Line no. " << yylineno << ": Syntax error" << endl;
    // fflush(stdout);
}

int main(int argc, char **argv)
{
    nextquadraple = 0;
    scope = 0;
    found = 0;
    CalcOffset = 0;
    foundError=false;
    switchVar.clear();
    dimlist.clear();
    
    yyparse();
    populateOffsets(functionEntryRecord, globalVariables);
    ofstream outinter;
    outinter.open("./output/intermediate.txt");
    if(!foundError){
        for(auto it:functionInstruction){
            outinter<<it<<endl;
        }
        cout << BOLD(FGRN("Intermediate Code Generated")) << endl;
    } else {
        cout << BOLD(FRED("Exited without intermediate code generation")) << endl;
    }
    outinter.close();
}
