#include "first_pass1.h"

string convert_to_string(int i){
	string str="";
	str=to_string(i);
	return str;
}

int convert_to_integer(string s){
	int x;
	x=stoi(s);
	return x;
}

void registerSet::freeRegister(string s){
	if (s[0]!='T' && s[0]!='F')	
	{
		cout << "Not a Temporary Variable : " << s << endl;
	}
    else if(s[0]=='T'){
        s[0] = '0';
        int x = convert_to_integer(s);
        for(auto it : tempRegister){
            if(it!=x){
                
            }
            else return;
        }
        // cout<<"FLoat Register Freed "<< s <<endl;
        tempRegister.push_back(x);
    } 
    else {
        s[0] = '0';
        int x = convert_to_integer(s);
        for(auto it:floatRegister){
            if(it!=x){
                
            }
            else return;
        }
        // cout<<"Int Register Freed "<< s <<endl;
        floatRegister.push_back(x);
    } 
}


string registerSet::getRegister() {
    string str = "";
    if(tempRegister.size()!=0){
    	str = str + "T";
	    int x = tempRegister[tempRegister.size()-1];
	    str += convert_to_string(x);
	    tempRegister.pop_back();
	    return str;
    }
    else {
        cout <<"FATAL ERROR : Exceeded the limit of temporary INT registers"<< endl;
        exit(1);
        return str;
    }
    
}

string registerSet::getFloatRegister() {
    string str = "";
    if(floatRegister.size()!=0){
    	str = str + "F";
	    int x = floatRegister[floatRegister.size()-1];
	    str = str + convert_to_string(x);
	    floatRegister.pop_back();
	    return str;
    }
    else {
        cout <<"FATAL ERROR : Exceeded the limit of temporary FLOAT registers"<< endl;
        exit(1);
        return str;
    }
    
}

void backpatch(vector<int> *&line_nos, int label_no, vector<string> &func_inst){
    if(line_nos == NULL){
        cout << "Given that the line numbers for "<<label_no<<" is NULL"<<endl;
        return;
    }
    else {
	    string statement;
	    for(int it : (*line_nos)){
	        // statement = functionInstruction[it];        // statement +=("L"+ to_string(labelNumber));
	        func_inst[it] += (convert_to_string(label_no));
	    }
	    line_nos->clear();
	}
}


void merge(vector<int> *&receiver, vector<int> *&donor) {
    if(receiver == NULL){
        return;
    }
    else if (donor == NULL)
    {
    	return;
    }
    else{
    	for(int i:(*donor)){
	        receiver->push_back(i);
	    }
	    donor->clear();
	    return;
    }
    
}

void generateInstr(vector<string> &func_inst, string instruction, int &next_quadraple){
	next_quadraple++;
    func_inst.push_back(instruction);
    return;
}

void convertfloat(char* c){
	strcat(c,".000000\0");
}

void convertint(char* s){
	s=strtok(s,".");
}

void mergeSwitch(vector<pair<string,int>> *&receiver,vector<pair<string,int>> *&donor) {
    if(receiver == NULL){
        return;
    }
    else if ( donor == NULL)
    {
    	return;
    }
    else{
    	for(auto i:(*donor)){
	        receiver->push_back(i);
	    }
	    donor->clear();
	    return;
    }
    
}
int testing_function1(string A) {
    int n = A.size();
    string t = "";
    for(int i = 0;i<n;i++){
        if(A[i]>='a' && A[i]<='z'){
            t+=A[i];
        }
        if(A[i]>='A' && A[i]<= 'Z'){
            t += A[i]-'A'+'a';
        }
        if(A[i]>='0' && A[i]<='9'){
            t+=A[i];
        }
    }
    int m = t.size();
    for(int i = 0;i<m;i++){
        if(t[i]!=t[m-1-i]){
            return 0;
        }
    }
    return 1;
}
