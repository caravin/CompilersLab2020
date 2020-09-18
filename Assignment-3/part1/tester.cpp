#include <bits/stdc++.h>
#include "part1.h"
#include "lex.yy.c"
using namespace std;
#define pb push_back
extern int yylex();
extern int yylineno;
extern char* yytext;

#define ll long long
#define mod 1000000007
#define rep(i,a,b) for( i=a;i<b;i++)
#define repi(i,a,b) for( i=b-1;i>=a;i--)
#define F first
#define S second
#define pb push_back
#define MT make_tuple
#define V(a) vector<a>
#define mp make_pair
#define pll pair<ll,ll>
#define inf 1000000
#define maxn 5000007

vector<string> classes;

int check_class(string s, ll line_no){
    ll i=0;
    //removing spaces
    string temp;
    // checking class
    while(s[i]!=' '&& i<s.size())i++;

    i++;
    string class_name;
    while(s[i]!=' ' && i<s.size() && s[i]!=':'){
        class_name.pb(s[i]);
        i++;
    }
    classes.pb(class_name);
    return 1;    
}

int check_object(string s,ll line_no){
     ll i=0;
    //removing spaces
    while(s[i]==' ' && i<s.size())i++;
    string temp;
    // taking class name
    while(s[i]!=' '&& i<s.size()){
        temp.pb(s[i]);
        i++;
    }
    for(ll j=0;j<classes.size();j++){
        if(classes[j]==temp){
            while(s[i]==' ' && i<s.size())i++;
            return 1;
        }
    }
    return 0;
}
int check_construct(string s,ll line_no){
    ll i=0;

    //removing spaces
    string temp;
    // taking class name
    while(s[i]!=' '&& i<s.size() && s[i]!='('){
        temp.pb(s[i]);
        i++;
    }
    for(ll j=0;j<classes.size();j++){
    
        if(classes[j]==temp){
            while(s[i]==' ' && i<s.size())i++;
            return 1;
        }
    }
    return 0;  
}
int check_inherited(string s,ll line_no){

    ll i=0;
    string temp;
    // checking class
    while(s[i]!=' '&& i<s.size())i++;
    //removing spaces
    // taking class name
    temp.clear();
    while(s[i]!=' '&& i<s.size() && s[i]!=':'){
        temp.pb(s[i]);
        i++;
    }
    //removing spaces
    //moving past colon
    i++;
    //removing spaces
    i++;
    //checking type
    while(s[i]!=' '&& i<s.size())i++;
    //removing spaces
    i++;
    string class_parent;
    while(s[i]!=' '&& i<s.size() ){
        class_parent.pb(s[i]);
        i++;
    }
    // checking parent class
    for(ll j=0;j<classes.size();j++){
        if(classes[j]==class_parent){
            return 1;
        }
    }
    return 0;    
}
int check_operator(string s,ll line_no){
    ll i=0;
    //removing spaces
    string temp;
    // taking class
    while(s[i]!=' '&& i<s.size()){temp.pb(s[i]);i++;}


    for(ll j=0;j<classes.size();j++){
        if(classes[j]==temp){
                return 1;  
        }
    }
    return 0;    
}

int class_line=0,inh_line=0,obj_line=0,constr_line=0,oper_line=0;
int last_class=0,last_inh=0,last_obj=0,last_constr=0,last_oper=0;;


int main(void) 
{

	int ntoken, vtoken;
	bool flag=false;

	ntoken = yylex();
	
	while(ntoken) {
		switch(ntoken)
		{
			case P_BRAC:{
							flag=true;break;
						}
			case N_BRAC :{
							flag=false;break;
						}
			case CLASS:	{
						if(!flag)
						{char *token=yytext;
							if(check_class(token,yylineno)){
								if(yylineno!=last_class){
									last_class=yylineno;
									class_line+=1;
								}
							}
						}
						break;}
			case INH:   {if(!flag){ 
						char *token=yytext;
						if(check_inherited(token,yylineno)){
							if(yylineno!=last_class){
                                last_class=yylineno;
                                class_line+=1;
                            }
                            if(yylineno!=last_inh){
								last_inh=yylineno;
								inh_line+=1;
							}
						}
						}
						break;}
			case OBJ: 	{if(!flag){ 
						char *token=yytext;
						if(check_object(token,yylineno)){
							if(yylineno!=last_obj){
							
								last_obj=yylineno;
								obj_line+=1;
							}
						}
						}
						break;}
			case CONS:{if(!flag){ 
						char *token=yytext;

						if(check_construct(token,yylineno)){
					
							if(yylineno!=last_constr){
								last_constr=yylineno;
								constr_line+=1;
							}
						}
						}
						break;}
			case OPER:{if(!flag){ 
						char *token=yytext;
						//cout<<token<<endl;
						if(check_operator(token,yylineno)){
							if(yylineno!=last_oper){
								last_oper=yylineno;
								oper_line+=1;
							}
						}
						}
						break;}

		}
		ntoken = yylex();
	}
	
	cout<<"Classes :"<<class_line<<"\n"<<"Objects : "<<obj_line<<"\n"<<"Inheritances : "<<inh_line<<"\nConstructors :"<<constr_line<<"\nOperators: "<<oper_line<<endl;
	return 0;
}
