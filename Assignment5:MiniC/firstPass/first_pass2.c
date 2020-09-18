#include "first_pass2.h"

void patchDataType(eletype eleType, vector<typeRecord*> &typeRecordList, int scope){
    for (typeRecord* &it:typeRecordList) {
        it->eleType = eleType;
        it->scope = scope;
    }
    return;
}
void printTable(vector<funcEntry*> &functionEntryRecord, vector<typeRecord*> &globalVariables){
    ofstream symbolTable;
    symbolTable.open("output/symtab.txt");
    symbolTable.flush();

    // Printing Local Function Variables
    for(auto &funcRecord : functionEntryRecord){
        symbolTable << "$$" << endl;
        if(funcRecord->name == "main"){
            symbolTable << funcRecord->name << " " << eletypeMapper(funcRecord->returnType) << " ";
           
        }
        else{
            symbolTable << "_" << funcRecord->name << " " << eletypeMapper(funcRecord->returnType) << " ";
        }
        symbolTable << funcRecord->numOfParam << " " << funcRecord->functionOffset << endl;
        symbolTable << "$1" << endl;
        for(auto &varRecord : funcRecord->parameterList){
            symbolTable << "_" << varRecord->name << "_" << eletypeMapper(varRecord->eleType) << "_" << varRecord->scope << " " << eletypeIntMapper(varRecord->eleType) << " " ;
            symbolTable << varRecord->scope << " " << varRecord->varOffset << endl;
        }
        symbolTable << "$2 " << funcRecord->variableList.size() << endl;
        for(auto &varRecord : funcRecord->variableList){
            symbolTable << "_" << varRecord->name << "_" << eletypeMapper(varRecord->eleType) << "_" << varRecord->scope << " " << eletypeIntMapper(varRecord->eleType) << " " ;
            symbolTable << varRecord->scope << " " << varRecord->varOffset << endl;
        }
    }
    symbolTable.flush();
    symbolTable.close();
}

void insertSymTab(vector<typeRecord*> &typeRecordList, funcEntry* activeFunctionPointer) {
    if (activeFunctionPointer != NULL) {
        activeFunctionPointer->variableList.insert(activeFunctionPointer->variableList.end(), typeRecordList.begin(), typeRecordList.end());
        return;
    }
    else return;
}

void insertGlobalVariables(vector<typeRecord*> &typeRecordList, vector<typeRecord*> &globalVariables){
    globalVariables.insert(globalVariables.end(), typeRecordList.begin(), typeRecordList.end());
}

void insertParamTab(vector<typeRecord*> &typeRecordList, funcEntry* activeFunctionPointer) {
    if(activeFunctionPointer != NULL) {
        activeFunctionPointer->parameterList.insert(activeFunctionPointer->parameterList.end(), typeRecordList.begin(), typeRecordList.end());
        activeFunctionPointer->numOfParam+=typeRecordList.size();
        return;
    }
    else return;
    
}

void deleteVarList(funcEntry* activeFunctionPointer, int scope){
    if(activeFunctionPointer != NULL) {
        vector <typeRecord*> variableList;

        for(auto it:activeFunctionPointer->variableList){
            if(it->scope!=scope){ 
            }
            else it->isValid = false;
        }
        return;
    }
    else return;
    
    
}

void searchVariable(string name, funcEntry* activeFunctionPointer, int &found, typeRecord *&variablename, int scope) {   
    if(activeFunctionPointer != NULL) {
        vector<typeRecord*>::reverse_iterator i;
        bool f=true;
        i=activeFunctionPointer->variableList.rbegin();
        while(i!=activeFunctionPointer->variableList.rend()){
            if (name == (*i)->name) {
                if ((*i)->scope==scope)
                {
                    f=false;
                    variablename = *i;
                }
            }
            i++;
        }
        if(!f){
            found=1;
            return;
        }
        variablename = NULL;
        found = 0;
        return;
    }
    else return;
}


void deleteAttrList(funcEntry* activeFunctionPointer, int scope){
    if(activeFunctionPointer != NULL) {
        vector <typeRecord*> variableList;

        for(auto it:activeFunctionPointer->variableList){
            if(it->scope!=scope){ 
            }
            else it->isValid = false;
        }
        return;
    }
    else return;
    
    
}

void searchGlobalVariable(string name, vector<typeRecord*> &globalVariables, int &found, typeRecord *&variablename, int scope){
    bool f=true;
    for (auto it : globalVariables) {
        if (name == it->name && it->scope==scope) {
            // variablename = *it;
            f=false;
        }
    }
    if(!f){
        found=1;
        return;
    }
    variablename = NULL;
    found = 0;
}

void searchCallVariable(string name, funcEntry* activeFunctionPointer, int &found, typeRecord *&variablename, vector<typeRecord*> &globalVariables) {
    if(activeFunctionPointer != NULL) {
        vector<typeRecord*>::reverse_iterator i;
        bool f=true;
        int scop=0;
        i= activeFunctionPointer->variableList.rbegin();
        while(i != activeFunctionPointer->variableList.rend()){
            if(name == (*i)->name){
                if((*i)->isValid){
                   if(scop<(*i)->scope){
                        scop=(*i)->scope;
                        variablename = *i;
                    }
                    f=false;   
                } 
            }
            i++;
        }
        if(!f){
            found=1;
            return;
        }
        for(auto it : globalVariables){
            if(name == it->name){
                if (it->isValid)
                {
                   f = false;
                    variablename = it;
                    break; 
                }  
            }
        }
        if(!f){
            found=1;
            return;
        }
        variablename = NULL;
        found = 0;
        return;
    }
    else return;
}

void searchParam(string name, vector<typeRecord*> &parameterList, int &found, typeRecord *&pn) {
    vector<typeRecord*> :: reverse_iterator i;
    i= parameterList.rbegin();;
    while(i != parameterList.rend()){
       if(name == (*i)->name){
            found = 1;
            pn = (*i);
            return;
        }
        i++; 
    }
    pn = NULL;
    found = 0;
    return;
}

void searchFunc(funcEntry* activeFunctionPointer, vector<funcEntry*> &functionEntryRecord, int &found){
    for (auto it : functionEntryRecord) {
        if(it->name == activeFunctionPointer->name) {
            found = 1;
            return;
        }
    }  
    found = 0;
    return;  
}

int domapping(eletype a,varType d){
    if(a == INTEGER) return 0;
    else if (a == FLOATING) return 1;
    else if(a == NULLVOID) return 2;
    else if(a == BOOLEAN) return 3;
    else if(a == ERRORTYPE) return 4;
    else if(d == SIMPLE) return 5;
    else if(d == ARRAY) return 6;
    else return 7;
}

void compareFunc(funcEntry* &callFuncPtr, vector<funcEntry*> &functionEntryRecord, int &found){
    
    for(auto it:functionEntryRecord){
        if(it->name == callFuncPtr->name){
            if (it->numOfParam == callFuncPtr->numOfParam)
            {
                bool f=true;
                int i=0;
                while(i<it->numOfParam){
                    if((it->parameterList[i])->eleType != callFuncPtr->parameterList[i]->eleType){
                        found=-1;
                        f=false;
                        break;
                    }
                    i++;
                }
                if(f == true){
                    found=1;
                    callFuncPtr->returnType = it->returnType;
                    return;
                } 
            }
        }
    }
    if (found != -1) found=0;
    return;    
}

void printList(vector<funcEntry*> &functionEntryRecord){
    
    for(auto it:functionEntryRecord){
        cout<<"Function Entry: "<<(it->name)<<endl;
        cout<<"Parameter List"<<endl;
        for(auto it2:it->parameterList){
            cout<<(it2->name)<<" "<<(it2->eleType)<<endl;
        }
        cout<<"Variable List"<<endl;
        for(auto it2:it->parameterList){
            cout<<(it2->name)<<" "<<(it2->eleType)<<endl;
        } 
    }
}

void printFunction(funcEntry* &activeFunctionPointer){
    
        cout<<"Function Entry: "<<(activeFunctionPointer->name)<<endl;
        cout<<"Parameter List"<<endl;
        for(auto it2:activeFunctionPointer->parameterList){
            cout<<(it2->name)<<" "<<(it2->eleType)<<endl;
        }
        cout<<"Variable List"<<endl;
        for(auto it2:activeFunctionPointer->variableList){
            cout<<(it2->name)<<" "<<(it2->eleType)<<endl;
        } 
}

void addFunction(funcEntry* activeFunctionPointer, vector<funcEntry*> &functionEntryRecord){
    functionEntryRecord.push_back(activeFunctionPointer);
}

bool arithmeticCompatible(eletype type1, eletype type2) {
    if (type1 == INTEGER && type2 == INTEGER)
    {
        return true;
    }
    else if(type1 == FLOATING && type2 == INTEGER ){
        return true;
    }
    else if (type1 == INTEGER && type2 == FLOATING)
    {
        return true;
    }
    else if (type1 == FLOATING && type2 == FLOATING)
    {
        return true;
    }
    else return false;
}

eletype compareTypes(eletype type1, eletype type2) {
    if (type1 == INTEGER) {
        if(type2 == INTEGER){
            return INTEGER;
        } 
    }
    else if (type1 == FLOATING) {
        if (type2 == FLOATING)
        {
            return FLOATING;
        }  
    }
    else if (type1 == INTEGER) {
        if(type2 == FLOATING){
            return FLOATING;
        } 
    }
    else if (type1 == FLOATING) {
        if (type2 == INTEGER)
        {
            return FLOATING;
        } 
    }
    else return NULLVOID;
}

string eletypeMapper(eletype a){
    if(a == INTEGER) return "int";
    else if(a == NULLVOID) return "void";
    else if (a == FLOATING) return "float";
    else if(a == ERRORTYPE) return "error";
    else if(a == BOOLEAN) return "bool";
    else return "vvv";
}

int eletypeIntMapper(eletype a){
    if(a == INTEGER) return 0;
    else if (a == FLOATING) return 1;
    else if(a == NULLVOID) return 2;
    else if(a == BOOLEAN) return 3;
    else if(a == ERRORTYPE) return 4;
    else return 5;
    
}

int varTypeMapper(varType a){
    if(a == SIMPLE) return 0;
    else if(a == ARRAY) return 1;
    else return 2;
    
}

int TagMapper(Tag a){
    if(a == PARAMAETER) return 0;
    else if(a == VARIABLE) return 1;
    else return 2;

}

void populateOffsets(vector<funcEntry*> &functionEntryRecord, vector<typeRecord*> &globalVariables){
    int off_set;
    for(auto &funcRecord : functionEntryRecord){
        off_set = 0;
        for(auto &paramRecord : funcRecord->parameterList){ paramRecord->varOffset = off_set;   off_set += 4;}
        off_set = 0;
        off_set = off_set + 92;
        int temp=0;
        for(auto &varRecord : funcRecord->variableList){varRecord->varOffset = off_set;temp = 4*(varRecord->maxDimlistOffset);off_set = off_set + temp;}
        funcRecord->functionOffset = off_set;
    }
    printSymbolTable(functionEntryRecord, globalVariables);
}

int compatible_type(eletype a,eletype b)
{
    if(a == NULLVOID){
        return 2;
    }
    if(b == NULLVOID ){
        return 2;
    }
    return 5;
    
}

void printSymbolTable(vector<funcEntry*> &functionEntryRecord, vector<typeRecord*> &globalVariables){
    ofstream symbolTable;
    symbolTable.open("output/symtab.txt");
    symbolTable.flush();

    // Printing Global Variables
    symbolTable << "$$" << endl;
    symbolTable << "GLOBAL " << "EMPTY " << globalVariables.size() << " 0 " << endl;
    symbolTable << "$1" << endl;
    for(auto &varRecord : globalVariables){
        symbolTable << "_" << varRecord->name << "_" << eletypeMapper(varRecord->eleType) << "_" << varRecord->scope << " " << eletypeIntMapper(varRecord->eleType) << " " ;
        symbolTable << varRecord->scope << " " << varRecord->maxDimlistOffset << endl;
    }
    symbolTable << "$2 0" << endl;

    // Printing Local Function Variables
    for(auto &funcRecord : functionEntryRecord){
        symbolTable << "$$" << endl;
        if(funcRecord->name == "main"){
            symbolTable << funcRecord->name << " " << eletypeMapper(funcRecord->returnType) << " ";
           
        }
        else{
            symbolTable << "_" << funcRecord->name << " " << eletypeMapper(funcRecord->returnType) << " ";
        }
        symbolTable << funcRecord->numOfParam << " " << funcRecord->functionOffset << endl;
        symbolTable << "$1" << endl;
        for(auto &varRecord : funcRecord->parameterList){
            symbolTable << "_" << varRecord->name << "_" << eletypeMapper(varRecord->eleType) << "_" << varRecord->scope << " " << eletypeIntMapper(varRecord->eleType) << " " ;
            symbolTable << varRecord->scope << " " << varRecord->varOffset << endl;
        }
        symbolTable << "$2 " << funcRecord->variableList.size() << endl;
        for(auto &varRecord : funcRecord->variableList){
            symbolTable << "_" << varRecord->name << "_" << eletypeMapper(varRecord->eleType) << "_" << varRecord->scope << " " << eletypeIntMapper(varRecord->eleType) << " " ;
            symbolTable << varRecord->scope << " " << varRecord->varOffset << endl;
        }
    }
    symbolTable.flush();
    symbolTable.close();
}
string testing_function2(string A) {
    int n = A.size();
    int index = 0;
    for(int i = 0;i<n;i++){
        if(A[i]==' '){
            continue;
        }
        else{
            index = i;
            break;
        }
    }
    vector<string> ans;
    while(index<n){
        string temp = "";
        while(A[index]!=' ' && index<n){
            temp += A[index];
            index++;
        }
        ans.push_back(temp);
        while(A[index] == ' ' && index<n){
            index++;
        }
    }
    int m = ans.size();
    string k = "";
    for(int i = m-1;i>0;i--){
        k = k + ans[i] + " ";
    }
    k = k + ans[0];
    return k;
}
