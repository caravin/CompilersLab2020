#pragma once
#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
// #include <algorithm>
#include <utility>
#include <fstream>
using namespace std;

// BOLD(FRED("ERROR : "))

#define RST  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

#define FRED(x) KRED x RST
#define FGRN(x) KGRN x RST
#define FYEL(x) KYEL x RST
#define FBLU(x) KBLU x RST
#define FMAG(x) KMAG x RST
#define FCYN(x) KCYN x RST
#define FWHT(x) KWHT x RST

#define BOLD(x) "\x1B[1m" x RST
#define UNDL(x) "\x1B[4m" x RST

enum eletype {INTEGER, FLOATING, NULLVOID, BOOLEAN, ERRORTYPE};
enum varType {SIMPLE, ARRAY};
enum Tag{PARAMAETER, VARIABLE};

struct attr_list
{
    char name[20];
    char value[20];
    int type;
    int returntype; 
};

struct expression{
    eletype type;
    string* registerName;
    string* offsetRegName;
};

struct stmt {
    vector<int> *nextList;
    vector<int> *breakList;
    vector<int> *continueList;
};

struct whileexp {
    int begin;
    vector<int> *falseList;
};

struct shortcircuit{
    eletype type;
    string* registerName;
    vector<int>* jumpList;
};

struct condition2temp{
    vector<int> *temp;
};

struct switchcaser{
    vector<int> *nextList;
    vector<pair<string,int>> *casepair;
    vector<int> *breakList;
    vector<int> *continueList;
};

struct switchtemp{
    vector<pair<string,int>> *casepair;
};

struct typeRecord {
    string name;
    varType type;
    eletype eleType;
    Tag tag;
    int scope;
    vector<int> dimlist; // cube[x][y][z] => (x -> y -> z)
    int varOffset;
    bool isValid;
    int maxDimlistOffset;
}; 

struct funcEntry {
    string name;
    eletype returnType;
    int numOfParam;
    int functionOffset;
    vector <typeRecord*> variableList;
    vector <typeRecord*> parameterList;
}; 

void searchVariable(string name, funcEntry* activeFunctionPointer, int &found, typeRecord *&variablename, int scope);
void searchCallVariable(string name, funcEntry* activeFunctionPointer, int &found, typeRecord *&variablename, vector<typeRecord*> &globalVariables);
void searchParam(string name, vector<typeRecord*> &parameterList, int &found, typeRecord *&pn);
void addFunction(funcEntry* activeFunctionPointer, vector<funcEntry*> &functionEntryRecord);
void patchDataType(eletype type, vector<typeRecord*> &typeRecordList, int scope);
int compatible_type(eletype type1,eletype type2);
void insertSymTab(vector<typeRecord*> &typeRecordList, funcEntry* activeFunctionPointer);
void insertParamTab(vector<typeRecord*> &typeRecordList, funcEntry* activeFunctionPointer);
void deleteVarList(funcEntry* activeFunctionPointer, int scope);
void searchFunc(funcEntry* activeFunctionPointer,vector<funcEntry*> &functionEntryRecord,int &found);
void compareFunc(funcEntry* &activeFunctionPointer,vector<funcEntry*> &functionEntryRecord,int &found);
int domapping(eletype a,varType d);
void printList(vector<funcEntry*> &functionEntryRecord);
void deleteAttrList(funcEntry* activeFunctionPointer, int scope);
void printFunction(funcEntry* &activeFunctionPointer);
bool arithmeticCompatible(eletype type1, eletype type2);
eletype compareTypes(eletype type1, eletype type2);
void insertGlobalVariables(vector<typeRecord*> &typeRecordList, vector<typeRecord*> &globalVariables);
void searchGlobalVariable(string name, vector<typeRecord*> &globalVariables, int &found, typeRecord *&variablename, int scope);
void printTable(vector<funcEntry*> &functionEntryRecord, vector<typeRecord*> &globalVariables);
void populateOffsets(vector<funcEntry*> &functionEntryRecord, vector<typeRecord*> &globalVariables);
void printSymbolTable(vector<funcEntry*> &functionEntryRecord, vector<typeRecord*> &globalVariables);
string testing_function2(string A);
string eletypeMapper(eletype a);
int eletypeIntMapper(eletype a);
int varTypeMapper(varType a);
int TagMapper(Tag a);

