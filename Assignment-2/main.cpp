#include <iostream>
#include <bits/stdc++.h>
using namespace std;
 
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

vector<pair<string,ll> > components;
vector<string> classes;
vector<ll>classes_lineno;
vector<string> constructs;
vector<ll>construct_lineno;
vector<string>inheriteds;
vector<ll>inherited_lineno;
vector<string> operators;
vector<ll>operator_lineno;

vector<string> input;
ll no_class=0;
ll no_object=0;
ll no_constructor=0;
ll no_inherited=0;
ll no_operator=0; 


int check_class(string s, ll line_no){
    ll i=0;
    //removing spaces
    while(s[i]==' '&& i<s.size())i++;
    string temp;
    // checking class
    while(s[i]!=' '&& i<s.size()){
        temp.pb(s[i]);
        i++;
    }

    if(temp=="class"){
        components.pb(mp(temp,line_no));
        while(s[i]==' '&& i<s.size())i++;
        string class_name;
        while(s[i]!=' ' && i<s.size() && s[i]!=':'){
            class_name.pb(s[i]);
            i++;
        }
        classes.pb(class_name);
        classes_lineno.pb(line_no);
        return 1;
    }
    return 0;    
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
            if(s[i]=='(')return 0;
            components.pb(mp("object",line_no));
            for(ll k=i;k<s.size();k++){ 
                if(s[k]=='('){
                    k++;
                    while(s[k]!=')' && k<s.size())k++;
                }
                else if(s[k]==','){components.pb(mp("object",line_no));no_object++;}
            }
            return 1;
        }
    }
    return 0;       
}
int check_construct(string s,ll line_no){
    ll i=0;
    //removing spaces
    while(s[i]==' ' && i<s.size())i++;
    string temp;
    // taking class name
    while(s[i]!=' '&& i<s.size() && s[i]!='('){
        temp.pb(s[i]);
        i++;
    }
    for(ll j=0;j<classes.size();j++){
        if(classes[j]==temp){
            while(s[i]==' ' && i<s.size())i++;
            if(s[i]!='(')return 0;
            components.pb(mp("constructor",line_no));
            constructs.pb(temp);
            construct_lineno.pb(line_no);
            return 1;
        }
    }
    return 0;    
}
int check_inherited(string s,ll line_no){

    ll i=0;
    //removing spaces
    while(s[i]==' '&& i<s.size())i++;
    string temp;
    // checking class
    while(s[i]!=' '&& i<s.size()){
        temp.pb(s[i]);
        i++;
    }

    if(temp!="class")return 0;
    //removing spaces
    while(s[i]==' ' && i<s.size())i++;
    // taking class name
    temp.clear();
    while(s[i]!=' '&& i<s.size() && s[i]!=':'){
        temp.pb(s[i]);
        i++;
    }
    //removing spaces
    while(s[i]==' ' && i<s.size())i++;
    
    if(s[i]!=':')return 0;
    //removing spaces
    i++;
    while(s[i]==' ' && i<s.size())i++;
    //checking type
    string type;
    while(s[i]!=' '&& i<s.size()){
        type.pb(s[i]);
        i++;
    }
    if(type !="public" && type !="protected" && type !="private")return 0;
    //removing spaces
    while(s[i]==' ' && i<s.size())i++;
    string class_parent;
    while(s[i]!=' '&& i<s.size() ){
        class_parent.pb(s[i]);
        i++;
    }
    
    // checking parent class
    for(ll j=0;j<classes.size();j++){
        if(classes[j]==class_parent){
            components.pb(mp("inherited",line_no));
            inheriteds.pb(temp);
            inherited_lineno.pb(line_no);
            return 1;
        }
    }

    return 0;    
}
int check_operator(string s,ll line_no){
    ll i=0;
    //removing spaces
    while(s[i]==' '&& i<s.size())i++;
    string temp;
    // taking class
    while(s[i]!=' '&& i<s.size()){
        temp.pb(s[i]);
        i++;
    }
    for(ll j=0;j<classes.size();j++){
        if(classes[j]==temp){
            //remove spaces
            while(s[i]==' ' && i<s.size())i++;
            string opt;
            while(s[i]!=' '&& i<s.size()){
                opt.pb(s[i]);
                i++;
            }
            if(opt=="operator"){
                components.pb(mp("operator",line_no));
                string operator_name;
                while(s[i]==' ' && i<s.size())i++;
                while(s[i]!=' '&& i<s.size()){
                operator_name.pb(s[i]);
                i++;
                }
                operators.pb(operator_name);
                operator_lineno.pb(line_no);
                return 1;
            }
            
        }
    }
    return 0;    
}

int count_lines(ll line_no){
     ll open=0;
    ll close=0;
    ll no_lines=0;
    line_no--;
    ll flag_br1_open=0;
    ll flag_br1_close=0;
    ll flag_br2_open=0;
    ll flag_br2_close=0;
    ll semi_col=0;
    for(ll i=line_no;i<input.size();i++){
        string temp=input[i];
        ll j=0;
        while(j<temp.size()){
            if(temp[j]=='{')open++;
            if(temp[j]=='}')close++;
            j++;
        }
        ll k=0;
        while(k<temp.size()){
            if(temp[k]=='{')flag_br2_open=1;
            if(temp[k]=='}')flag_br2_close=1;
            if(temp[k]=='(')flag_br1_open=1;
            if(temp[k]==')')flag_br1_close=1;
            if(temp[k]==';')semi_col=1;
            k++;
        }
        if(flag_br2_open==1||flag_br2_close==1||flag_br1_open==1||flag_br1_close==1||semi_col==1)no_lines++;
        if(open!=0 && open==close)break;
    }
    return no_lines;

}

string removeComments(string prgm) 
{ 
    int n = prgm.length(); 
    string res; 
  	bool s_cmt = false; 
    bool m_cmt = false; 
  	for (int i=0; i<n; i++) 
    { 
        if (s_cmt == true && prgm[i] == '\n') 
            s_cmt = false; 
  		else if  (m_cmt == true && prgm[i] == '*' && prgm[i+1] == '/') 
            m_cmt = false,  i++; 
  		else if (s_cmt || m_cmt) 
            continue; 
  		else if (prgm[i] == '/' && prgm[i+1] == '/') 
            s_cmt = true, i++; 
        else if (prgm[i] == '/' && prgm[i+1] == '*') 
            m_cmt = true,  i++; 
  		else  res += prgm[i]; 
    } 
    return res; 
}

int contains(string temp){
	ll i=0;
	string s;
	for(ll i=0;i<temp.size();i++){
		if(temp[i]!=' ' && temp[i]!='\t')s.pb(temp[i]);
	}
	if(s.size()==0)return 1;
	return 0;
}

int main(){ 
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    string s="object1 ; class1 obj";
    
    //---------------------------------------------
    // code to preprocess the input-------------------

    //1.remove comments in the input 

    string orig_code;
    while(getline(cin,s)){
        orig_code.append(s);
        orig_code.append("\n");
    }
    string mod_code1=removeComments(orig_code);

    //2.break a single line with multiple semi colons into diff lines taking care of for loops
    string mod_code2;
    for(ll i=0;i<mod_code1.size();i++){
        if(mod_code1[i]=='('){
            mod_code2.pb(mod_code1[i]);
            i++;
            while(mod_code1[i]!=')' && i<mod_code1.size()){
                mod_code2.pb(mod_code1[i]);
                i++;
            }
            i--;
        }
        else if(mod_code1[i]==';'){
            mod_code2.pb(';');
            mod_code2.pb('\n');
        }
        else mod_code2.pb(mod_code1[i]);
    }
    string mod_code;
    for(ll i=0;i<mod_code2.size();i++)mod_code.pb(mod_code2[i]);

    //3.remove extra lines,tabs in the input and store in "input"
    
    char str[mod_code.size()+1];
    strcpy(str, mod_code.c_str());
    char * token=strtok(str,"\n");
    while (token != NULL) 
    { 
        ll tok_size=sizeof(token)/sizeof(char);
        string temp(token);
        ll a=contains(temp);
        if(!contains(temp)){
            string s;
            ll i=0;
            while( (temp[i]==' '||temp[i]=='\t') &&  i<temp.size())i++;
            for(ll j=i;j<temp.size();j++)s.pb(temp[j]);
            input.pb(s);
            cout<<s<<endl;

        }
        token = strtok(NULL, "\n"); 
    }
    //-------------------------------------------------
    //main code
    /* problems:
        1.if, for 
        2.class and inherited class!! if parent class not present, still it is considering as class
    */ 
    ll line_no=1;
    for(ll j=0;j<input.size();j++){
        s=input[j];
        for(ll i=s.size();i<=1024;i++)s.pb(' ');
        string temp;
        for(ll i=0;i<s.size();i++){
            if(s[i]!=';'  && s[i]!='{' && s[i]!='}')temp.pb(s[i]);
            else{

                if(check_class(temp,line_no))no_class++;
                if(check_object(temp,line_no))no_object++;
                if(check_construct(temp,line_no))no_constructor++;
                if(check_inherited(temp,line_no))no_inherited++;
                if(check_operator(temp,line_no))no_operator++;
                temp.clear();
            }
        }
        if(check_class(temp,line_no))no_class++;
        if(check_object(temp,line_no))no_object++;
        if(check_construct(temp,line_no))no_constructor++;
        if(check_inherited(temp,line_no))no_inherited++;
        if(check_operator(temp,line_no))no_operator++;
        temp.clear();

        line_no++;
    }

    //-----------------------------------------------------------

    //printing values;
    int count_lines_tot=0;
    int obj_lines_tot=no_object;
    int operator_lines_tot=0;
    int inherited_lines_tot=0;
    int construct_lines_tot=0;


fstream fio;
  fio.open("output.txt", ios::in|ios::out|ios::trunc);

    cout<<"classes:--------------------------------"<<endl;
    for(ll i=0;i<classes.size();i++)cout<<classes[i]<<endl;   
    cout<<"components:------------------------------"<<endl;
    for(ll i=0;i<components.size();i++)cout<<components[i].F<<" "<<components[i].S<<endl;
    
    //printing lines of classes;
    fio<<endl<<"lines taken by each class:---------------"<<endl;
    for(ll i=0;i<classes.size();i++){
        ll ans=count_lines(classes_lineno[i]);
        count_lines_tot+=ans;
        fio<<classes[i]<<" "<<ans<<endl;
    }
    fio<<endl<<"lines taken by each operator:---------------"<<endl;
    for(ll i=0;i<operators.size();i++){
        ll ans=count_lines(operator_lineno[i]);
        operator_lines_tot+=ans;
        fio<<operators[i]<<" "<<ans<<endl;
    }
    fio<<endl<<"lines taken by each inherited class:---------------"<<endl;
    for(ll i=0;i<inheriteds.size();i++){
        ll ans=count_lines(inherited_lineno[i]);
        inherited_lines_tot+=ans;
        fio<<inheriteds[i]<<" "<<ans<<endl;
    }
    fio<<endl<<"lines taken by each constructs:---------------"<<endl;
    for(ll i=0;i<constructs.size();i++){
        ll ans=count_lines(construct_lineno[i]);
        construct_lines_tot+=ans;
        fio<<constructs[i]<<" "<<ans<<endl;
    }

    fio<<endl<<"main output---------------------------"<<endl;
    fio<<"class lines tot :"<<count_lines_tot<<endl<<"obj lines tot : "<<obj_lines_tot<<endl<<"operatot lines tot : "<<operator_lines_tot<<endl<<"inherited lines tot : "<<inherited_lines_tot<<endl<<"no constructs : "<<no_constructor<<endl<<endl<<endl;


    fio<<"extra outout sodhi---------------------------------"<<endl;
    fio<<"no classes :"<<no_class<<endl<<"no object : "<<no_object<<endl<<"no operators : "<<no_operator<<endl<<"no inherited : "<<no_inherited<<endl<<"no constructs : "<<no_constructor<<endl;

    
    
    
    return 0;
}