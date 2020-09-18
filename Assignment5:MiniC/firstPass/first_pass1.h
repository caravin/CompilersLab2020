#pragma once
#include <bits/stdc++.h>
#include <string>
#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
#include <utility>
#include <fstream>
using namespace std;

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

class param
{
    public:
    string param_name;
    int param_type;
    int param_elem_type;
    vector<int>par_dim;
    param(string name,int type,int elemtype)
    {
        param_name=name;
        param_type=type;
        param_elem_type=elemtype;
        
    }
};

class node
{
public:
    char value[20];
    int begin;
    list<int> next;
    list<int> f;
    vector<string>arr;
};

class registerSet {
private:
    vector<int> tempRegister;
    vector<int> floatRegister;
public:
    registerSet(){
        tempRegister.clear();
        for(int i=9; i>=0; i--){
            tempRegister.push_back(i);
        }
        floatRegister.clear();
        for(int i=10; i>=0; i--){
            if(i==0||i==12){
                continue;
            }
            floatRegister.push_back(i);
        }
    }
    void freeRegister(string s);
    string getRegister();
    string getFloatRegister(); 
};

class variables
{
    public:
    string var_name;
    int var_type;
    int var_level;
    int elem_type;
    vector<int>dim;
    string func_name;
    variables(string name,int type,int level,int element_type,string func1)
    {
        var_name=name;
        var_type=type;
        var_level=level;
        elem_type=element_type;
        func_name=func1;
    } 
} ;

class function
{
    public:
    string func_name;
    int return_type;// int float or void
    int num_param;
    vector<param*> param_list;
    function(string name,int type,int number,vector<param*> list)
    {
        func_name=name;
        return_type=type;
        num_param=number;
        param_list=list;
    }
};

void backpatch(vector<int> *&, int, vector<string> &);

void merge(vector<int> *&, vector<int> *&);

void convertfloat(char* &);

void convertint(char* &);

void generateInstr(vector<string> &, string ,int &);

void mergeSwitch(vector<pair<string,int>> *&receiver,vector<pair<string,int>> *&donor); 

int testing_function1(string A);

