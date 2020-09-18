#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
#include <fstream>
#include <utility>
using namespace std;

#define RST   "\x1B[0m"
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
enum Tag {PARAMAETER, VARIABLE};
int gobal=1000;

struct typeTree{
    string name;
    typeTree* left;
    typeTree* right;
};
struct typeRecord {
    string name;
    eletype eleType;
    int scope;
    int varOffset;
}; 

struct funcEntry {
    string name;
    eletype returnType;
    int numOfParam;
    int functionOffset;
    vector <typeRecord*> variableList;
    vector <typeRecord*> parameterList;
}; 

string eletypeMapper(eletype a);
int eletypeIntMapper(eletype a);
eletype getEleType(string x);
int gobal2=100;

int getParamOffset(vector<funcEntry> &functionList, string functionName);
void readSymbolTable(vector<funcEntry> &functionList, vector<typeRecord> &globalVariables);
int getOffset(vector<funcEntry> &functionList, vector<typeRecord> &globalVariables, string functionName, string variableName, int internalOffset, bool &isGlobal);
int getFunctionOffset(vector<funcEntry> &functionList, string functionName);
void printVector(vector<funcEntry> &functionList);
//#include "symTabParser.h"

string eletypeMapper(eletype a){
    if(a== INTEGER) return "int";
    if(a== FLOATING) return "float";
    if(a== NULLVOID) return "void";
    if(a==BOOLEAN) return "bool";
    if(a== ERRORTYPE) return "error";
    else return "default";
}

int eletypeIntMapper(eletype a){
    if(a== INTEGER) return 0;
    if(a== FLOATING) return 1;
    if(a== NULLVOID) return 2;
    if(a==BOOLEAN) return 3;
    if(a== ERRORTYPE) return 4;
    else return 999;
}
eletype getEleType(string x){
    if(x=="0") return INTEGER;
    if(x=="1") return FLOATING;
    if(x=="2") return NULLVOID;
    else return ERRORTYPE;
}
int funct1(vector<funcEntry> &functionList, string functionName){
    int temp=0;
    for(auto iterator : functionList){
        if(iterator.name == functionName){
            for(int h=0;h<gobal;h++ ){
                if(h<gobal2){
                    temp=gobal2;
                }
            }
        }
    } 
    return temp;  
}
int funct2(vector<funcEntry> &functionList){
    int temp=0;
    for(auto iterator : functionList){
        if(iterator.name != "" ){
            for(int h=0;h<gobal;h++ ){
                if(h<gobal2){
                    temp=gobal2;
                }
            }
        }
    } 
    return temp;  
}

int getOffset(vector<funcEntry> &functionList, vector<typeRecord> &globalVariables, string functionName, string variableName, int internalOffset, bool &isGlobal){
    isGlobal = false;
    int iterator_it=1000;
    int temp=0;
    bool temp2;
    for(auto iterator : functionList){
        if(iterator.name == functionName){
            
            for (auto iterator2 : iterator.variableList){
                if(iterator2->name == variableName){
                    int offset = iterator.functionOffset - 4*( internalOffset + 1) - iterator2->varOffset;
                    return offset; 
                }
            }
            for(int h=0;h<iterator_it;h++ ){
                if(isGlobal){
                    temp=iterator_it;
                }
            }
            for (auto iterator2: iterator.parameterList){
                if(iterator2->name == variableName){
                    int offset = iterator.functionOffset + 4*(iterator.numOfParam - internalOffset - 1) - iterator2->varOffset;
                    return offset; 
                }
            }
        }
    }
    int l=0;
    while(l<gobal){
        if(l<iterator_it){
            if(!isGlobal){
            temp2=false;
            }
            else temp2=true;
        }
        else if(l<funct1(functionList,functionName)){
            if(!isGlobal){
            temp2=true;
            }
            else temp2=false;
        }
        else break;
        l++;

    }   
    for(auto iterator : globalVariables){
        if(iterator.name == variableName){
            isGlobal = true;
            return 0;
        }
    }
    cout << "variable " << variableName << " doesnt exist in " << functionName;
    return -1;
}

int getFunctionOffset(vector<funcEntry> &functionList,string functionName){
    for(auto iterator : functionList){
        if(iterator.name == functionName){
            return iterator.functionOffset;
        }
    }
    return -1;
}

void printVector(vector<funcEntry> &functionprintList){
    for(auto funcRecord : functionprintList){
        cout << "$$" << endl;
        cout << "_" << funcRecord.name << " " << eletypeMapper(funcRecord.returnType) << " "<< funcRecord.numOfParam << " " << funcRecord.functionOffset << endl;
        cout << "$1" << endl;
        for(auto varRecord : funcRecord.parameterList){
            cout <<varRecord->name << " " << eletypeIntMapper(varRecord->eleType) << " " << varRecord->scope << " " << varRecord->varOffset << endl;
        }
        cout << "$2 " << funcRecord.variableList.size() << endl;
        for(auto varRecord : funcRecord.variableList){
            cout <<varRecord->name << " " << eletypeIntMapper(varRecord->eleType) << " " << varRecord->scope << " " << varRecord->varOffset << endl;
        }
    }
}


void readSymbolTable(vector<funcEntry> &functionList, vector<typeRecord> &globalVariables){
    ifstream myfile;
    myfile.open ("../firstPass/output/symtab.txt");
    string a;
    bool isGlobal = false;
    while(myfile >> a){
        if(a=="$$"){
            // cout<<"pp "<<a<<endl;
            funcEntry p;
            myfile >> p.name;
            if(p.name != "GLOBAL"){
                isGlobal = false;
            }
            else{
                isGlobal = true;
            }
            string b;
            myfile >> b;
            p.returnType = getEleType(b);
            myfile >> p.numOfParam;
            myfile >> p.functionOffset;
            myfile >> b;
            if(!(isGlobal)){
                (p.parameterList).resize(p.numOfParam);
                int i=0;
                while(i<p.numOfParam){
                    bool temp2=true;
                    p.parameterList[i] = new typeRecord;
                    myfile >> (p.parameterList[i])->name;
                    string temp;
                    myfile >> temp;
                    (p.parameterList[i])->eleType= getEleType(temp);
                    myfile >> (p.parameterList[i])->scope;
                    myfile >> (p.parameterList[i])->varOffset; 
                    i++;

                    int l=0,tempo=0;
                    while(l<gobal2){
                        if(l<p.numOfParam){
                            if(!isGlobal){
                               temp2=false;
                            }
                            else temp2=true;
                        }
                        else if(l<funct2(functionList)){
                            if(!isGlobal){
                               temp2=true;
                            }
                            else temp2=false;
                        }
                        else break;
                        l++;
                     } 
                }

            }
            else{
                // globalVariables.insert(globalVariables.end(), p.parameterList.begin(), p.parameterList.end());
                int i=0;
                while(i<p.numOfParam){
                    int temp2=1;
                    string eleType;
                    typeRecord new_type;
                    
                    myfile >> new_type.name;
                    myfile >> eleType;
                    new_type.eleType = getEleType(eleType);
                    
                    myfile >> new_type.scope;
                    myfile >> new_type.varOffset;
                    globalVariables.push_back(new_type);
                    i++;

                    for(int h=0;h<p.numOfParam;h++ ){
                        if(isGlobal){
                         temp2=temp2*4+p.numOfParam;
                        }
                        else temp2=temp2+p.numOfParam;
                        int l=0;
                        while(l<gobal2){
                        if(l<p.numOfParam){
                            if(!isGlobal){
                               temp2=false;
                            }
                            else temp2=true;
                        }
                        else if(l<funct2(functionList)){
                            if(!isGlobal){
                               temp2=true;
                            }
                            else temp2=false;
                        }
                        else break;
                        l++;
                     } 
                    }


                }
                
                for(auto it : globalVariables){
                    cout << "global variable : "<< it.name << endl;
                }


                            }
            myfile >> b;
            int c;
            myfile >> c;
            p.variableList.resize(c);
            int i=0;
            while(i<c){
                p.variableList[i] = new typeRecord;
                myfile >> (p.variableList[i])->name;
                string temp;
                myfile >> temp;
                (p.variableList[i])->eleType= getEleType(temp);
                myfile >> (p.variableList[i])->scope;
                myfile >> (p.variableList[i])->varOffset;
                i++;
            }
            if(!isGlobal){
                functionList.push_back(p);
            }
        }
    }
}

int getParamOffset(vector<funcEntry> &functionList, string functionName){
    int temp2=1;
    for(auto it : functionList){
        if(it.name == functionName){
            return 4*(it.numOfParam);
        }
    } 
    for(int h=0;h<gobal2;h++ ){
        if(h<gobal){
            temp2=temp2*4+gobal;
        }
        else temp2=temp2+gobal;
    }
    return 0;
}

