%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
extern int yylineno;
char column_list[100];
void projection(char s[]);
void cartesian_product(char f[],char s[]);
void selection(char expr[],char s[]);
int is_number(char s[]) ;
void equijoin(char tab1[],char c[],char tab2[]);

FILE *fnew;
%}
         /* Yacc definitions */
%union
{
	char s[100];
	struct {
     char s[100];
     int  type;
  } id;
	int num;
}
%start start
%token SELECT PROJECT CARTESIAN_PRODUCT EQUI_JOIN NEWLINE OPEN LESSER GREATER EQUAL NE AND OR COMMA CLOSE LE GE DOT MINUS PLUS MUL DIV
/*declaring all the tokens*/
%type <id> condition_1
%type <id> condition_list1
%type <s> condition_list2
%type <id> expression_1
%type <id> expression_2
%token <s> NAME
%token <s> NUMBER
%token <s> STR
%type <s> id_1 
%type <s> number_1 
%left MUL DIV
%left PLUS MINUS

%define parse.error verbose
%%

/* descriptions of expected inputs corresponding actions (in C) */

start: statement_list
statement_list:	statement		
			|statement statement_list /*statement_list gives one or more number of statements*/
			
			
/*statement can be either of the following*/
statement:	PROJECT LESSER attribute_list GREATER OPEN NAME CLOSE NEWLINE	{projection($6);printf("Valid syntax\n");}	/*PROJECT <attr list> (NAME) \n*/

			| SELECT LESSER condition_list1 GREATER OPEN NAME CLOSE NEWLINE {selection($3.s,$6);printf("Valid syntax\n");}	/*SELECT <condn> (NAME) \n*/
			
			| OPEN NAME CLOSE CARTESIAN_PRODUCT OPEN NAME CLOSE NEWLINE {cartesian_product($2,$6);printf("Valid syntax\n");}	/*(NAME) join \n*/

			| OPEN NAME CLOSE EQUI_JOIN LESSER condition_list2 GREATER OPEN NAME CLOSE NEWLINE {equijoin($2,$6,$9);printf("Valid syntax\n");}
			| error NEWLINE {yyerrok;}


condition_list1:	NAME condition_1 {sprintf($$.s,"%s,1,%s",$1,$2.s);}//attribute condn
				|NAME NE STR OR condition_list1{sprintf($$.s,"%s,2,!=,%s,OR,%s",$1,$3,$5.s);}
				|NAME NE STR AND condition_list1{sprintf($$.s,"%s,2,!=,%s,AND,%s",$1,$3,$5.s);}
				|NAME condition_1 OR condition_list1{sprintf($$.s,"%s,1,%s,OR,%s",$1,$2.s,$4.s);}
				|NAME condition_1 AND condition_list1{sprintf($$.s,"%s,1,%s,AND,%s",$1,$2.s,$4.s);}				
				|NAME EQUAL STR OR condition_list1{sprintf($$.s,"%s,2,==,%s,OR,%s",$1,$3,$5.s);}
				|NAME EQUAL STR AND condition_list1{sprintf($$.s,"%s,2,==,%s,AND,%s",$1,$3,$5.s);}
				|NAME EQUAL STR  	{sprintf($$.s,"%s,2,==,%s",$1,$3);}
				|NAME NE STR  	{sprintf($$.s,"%s,2,!=,%s",$1,$3);}

condition_list2:	NAME DOT NAME EQUAL NAME DOT NAME {sprintf($$,"%s.%s,==,%s.%s",$1,$3,$5,$7);}
				|NAME DOT NAME EQUAL NAME DOT NAME AND condition_list2 {sprintf($$,"%s.%s,==,%s.%s,AND,%s",$1,$3,$5,$7,$9);}
				|NAME DOT NAME EQUAL NAME DOT NAME OR condition_list2 {sprintf($$,"%s.%s,==,%s.%s,OR,%s",$1,$3,$5,$7,$9);}
				

condition_1 :	EQUAL expression_1   {sprintf($$.s,"==,%s",$2.s);}
				| NE expression_1    {sprintf($$.s,"!=,%s",$2.s);}
				| LE expression_1	 {sprintf($$.s,"<=,%s",$2.s);}
				| GE expression_1   {sprintf($$.s,">=,%s",$2.s);}
				| LESSER expression_1 		{sprintf($$.s,"<,%s",$2.s);}
				| GREATER expression_1	{sprintf($$.s,">,%s",$2.s);}
								
			
expression_1	:	expression_2 {if($1.type!=1){int i=0;i=atoi($1.s); sprintf($$.s,"%d",i);$$.type=0;} else {sprintf($$.s,"%s",$1.s);$$.type=1;}}
				|expression_1 PLUS expression_2  {if($1.type!=0 || $3.type!=0){sprintf($$.s,"%s,+,%s",$1.s,$3.s);$$.type=1;} else {int i=0;i=atoi($1.s); int j=0;j=atoi($3.s); i=i+j; sprintf($$.s,"%d",i);$$.type=0;} }		
				|expression_1 MINUS expression_2 {if($1.type!=0 || $3.type!=0) {sprintf($$.s,"%s,+,%s",$1.s,$3.s);$$.type=1;} else {int i=0;i=atoi($1.s); int j=0;j=atoi($3.s); i=i-j; sprintf($$.s,"%d",i);$$.type=0;} }		
					

expression_2:	number_1 {int i=0;i=atoi($1); sprintf($$.s,"%d",i);$$.type=0;}
				|number_1 MUL expression_2 {if($3.type==1) {sprintf($$.s,"%s,*,%s",$1,$3.s);$$.type=1;} else {int i=0;i=atoi($3.s); int j=0;j=atoi($1); i=i*j; sprintf($$.s,"%d",i);$$.type=0;}
										}	
				|number_1 DIV expression_2 {if($3.type==1) {sprintf($$.s,"%s,*,%s",$1,$3.s);$$.type=1;} else{int i=0;i=atoi($3.s); int j=0;j=atoi($1); i=i/j; sprintf($$.s,"%d",i);$$.type=0;}
										}
				|OPEN expression_1 CLOSE {sprintf($$.s,"%s",$2.s);$$.type=$2.type;}
				|OPEN expression_1 CLOSE MUL expression_2 
					{if($2.type!=0 || $5.type!=0) {sprintf($$.s,"%s,*,%s",$2.s,$5.s);$$.type=1;} else {int i=0;i=atoi($2.s); int j=0;j=atoi($5.s); i=i*j; sprintf($$.s,"%d",i);$$.type=0;} 
					 }		
				|OPEN expression_1 CLOSE DIV expression_2 
					{if($2.type!=0 || $5.type!=0){sprintf($$.s,"%s,/,%s",$2.s,$5.s);$$.type=1;} 
					else {int i=0;i=atoi($2.s); int j=0;j=atoi($5.s); i=i/j; sprintf($$.s,"%d",i);$$.type=0;}   }
				|id_1 {sprintf($$.s,"%s,1",$1);$$.type=1;}		
				|id_1 MUL expression_2 {sprintf($$.s,"%s,1,*,%s",$1,$3.s);$$.type=1;}	
				|id_1 DIV expression_2 {sprintf($$.s,"%s,1,/,%s",$1,$3.s);$$.type=1;}
				

attribute_list :	NAME 					{ bzero(column_list,100); strcat(column_list,$1);  }	
				|attribute_list COMMA NAME  {  strcat(column_list,","); strcat(column_list,$3);  }
				
				
number_1:			NUMBER   {sprintf($$,"%s",$1); }
				|MINUS NUMBER {sprintf($$,"-%s",$2); }

id_1:			NAME	{sprintf($$,"%s",$1); } //idnumber_1 of the type some name or number or +, -, *, / number






%%                     /* C code */


int main (void) {
	fnew=fopen("ans.cpp","w");
	fprintf(fnew,"#include<bits/stdc++.h>\nusing namespace std;\nint main(){int ans;\n");
	int k= yyparse(); //call the function so as to cause parsing to occur, returns 0 if eof is reached, 1 if failed due to syntax error
	fprintf(fnew,"return 0;}");
	fclose(fnew);
	return k;
}
void yyerror (char *s) {fprintf (stderr, "Invalid Syntax\n");}


void equijoin(char f[],char expr[],char s[])
{
fprintf(fnew,"cout<<endl;cout<<\"----------New Command Is Executed--------- \";cout<<endl;");
	//checking whether the given files exist or not
	strcat(f,".csv");
	strcat(s,".csv");
	FILE *f1=fopen(f,"r");
	FILE *f2=fopen(s,"r");

	if(f2==NULL)
	{
		fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",s);return;
	}
	if(f1==NULL){
		fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",f);return;
	}
	
	//storing the given table's attributes in h and g
	
	char h[15][100];// 1st attributes
	bzero(h,1500);
	int no_attr1=0; 
	char g[15][100];//2nd attributes
	bzero(g,1500);
	char buffer[1000];
	int no_attr2=0;

	strtok(f,".");
	strtok(s,".");

	bzero(buffer,1000);
	fgets(buffer,1000,f1);
	
	char*t=strtok(buffer,"\n");
	char*temp1=strtok(t,",");
	
	while(1)
	{	if(temp1!=NULL){
			strcat(h[no_attr1],f);
			strcat(h[no_attr1],".");
			strcat(h[no_attr1],temp1);
			temp1=strtok(NULL,",");
			no_attr1++;
		}
		else break;
	}

	bzero(buffer,1000);
	fgets(buffer,1000,f2);
 
	t=strtok(buffer,"\n");
	temp1=strtok(t,",");
	
	while(1)
	{	if(temp1!=NULL){
			strcat(g[no_attr2],s);
			strcat(g[no_attr2],".");
			strcat(g[no_attr2],temp1);
			temp1=strtok(NULL,",");
			no_attr2++;
		}
		else break;
	}
	//storing the data types of the attribute 1=int ,2=string
	int type1[no_attr1];
	

	for(int i=0;i<no_attr1;i++)
	{
		char col_type[50];
		int m=0;
		while(h[i][m]!='(')m++;
		int len=0;
		m++;
		while(h[i][m]!=')'){
			col_type[len]=h[i][m];
			len++;
			m++;
		}
		col_type[len]='\0';

		m=0;		
		while(1){
			if(h[i][m]=='('){
				h[i][m]='\0';
				break;			
			}		
			m++;
		}		
		
		if(strcmp(col_type,"int")==0)
			{type1[i]=1;}
		else
			type1[i]=2;
	}
	int type2[no_attr2];
		
	for(int i=0;i<no_attr2;i++)
	{
		char col_type[50];
		int m=0;
		while(g[i][m]!='(')m++;
		int len=0;
		m++;
		while(g[i][m]!=')'){
			col_type[len]=g[i][m];
			len++;
			m++;
		}
		col_type[len]='\0';
		
		m=0;		
		while(1){
			if(g[i][m]=='('){
				g[i][m]='\0';
				break;			
			}		
			m++;
		}		
		
		
		if(strcmp(col_type,"int")==0)
			{type2[i]=1;}
		else
			type2[i]=2;
	}
	
	//storing the given conditions here in condition_list2	
	char condition_list2[100][100];
	bzero(condition_list2,10000);
	temp1=strtok(expr,",");
	int k=0;
	while(temp1!=NULL)
	{
		strcat(condition_list2[k],temp1);
		temp1=strtok(NULL,",");

		k++;
	}

	//in position we will store where the kth term in the conditions is in the atributes
	int position[k];
	for(int i=0;i<k;i++)
		position[i]=-1;
	

	for(int i=0;i<k;i++)
	{
		if(isalpha(condition_list2[i][0]))
		{

			int x;
			// searching in frst table
			for( x=0;x<no_attr1;x++)
			{
				if(strcmp(condition_list2[i],h[x])==0)
				{
					position[i]=x;
					break;
				}
			}
			if(x==no_attr1)
			{
				// search 2nd table
				for( x=0;x<no_attr2;x++)
				{
					if(strcmp(condition_list2[i],g[x])==0)
					{
						position[i]=no_attr1+x;
						break;
					}
				}
				if((x==no_attr2)&&(strcmp(condition_list2[i],"OR")!=0)&&(strcmp(condition_list2[i],"AND")!=0))
				{
					fprintf(fnew,"cout<<\"%s column doesnt exist\"<<endl;",condition_list2[i]);
					return;
				}
			}
			
		}
	}

	//checking if ther eis any mismatching in the given input conditions
	for(int i=0;i<k;i++)
	{
		if(strcmp(condition_list2[i],"==")==0)
		{
			if(position[i-1]<no_attr1)
			{	
				if(position[i+1]<no_attr1) {
					fprintf(fnew,"cout<<\"attributes from same table on both sides of = sign\"<<endl;");
				 	return;
				}
				
				else{
					if(type2[position[i+1]-no_attr1]!=type1[position[i-1]])
					{
						fprintf(fnew,"cout<<\"Types of attributes on both sides of = doesnt match\"<<endl;");
						return;
					}
				}
			}
			else
			{	if(position[i+1]>=no_attr1){
				 fprintf(fnew,"cout<<\"attributes from same table on both sides of = sign\"<<endl;");
				 return;
			}
				
				else{

					if(type2[position[i-1]-no_attr1]!=type1[position[i+1]])
					{
						fprintf(fnew,"cout<<\"Types of attributes on both sides of = doesnt match\"<<endl;");
						return;
					}
				}
			}
		}
	}

	fclose(f1);fclose(f2);
	strcat(f,".csv");strcat(s,".csv");
	f1=fopen(f,"r");f2=fopen(s,"r");

	fgets(buffer,1000,f1);//1st table attributes
	strtok(buffer,"\n");

	char buffer1[1000];
	fgets(buffer1,1000,f2);strtok(buffer1,"\n");//2nd table attributes

	//printing the heading in the output= all attributes of table1 and 2 together
	fprintf(fnew,"cout<<");
	for(int l=0;l<no_attr1;l++){
		fprintf(fnew,"\"%s,\"",h[l]);
	}
	for(int l=0;l<no_attr2;l++){
		fprintf(fnew,"\"%s,\"",g[l]);
	}
	fprintf(fnew,"<<endl;");

	bzero(buffer,1000);bzero(buffer1,1000);
	fclose(f2);

	//storing the current rows together as astring in cur_rows_comb_str
	char cur_rows_comb_str[1000];
	//storing the current rows together in cur_comb_arr
	char cur_comb_arr[no_attr1+no_attr2][50];

	char temp[1000];
	int z;

	//for each row from table1
	while(fgets(buffer,1000,f1)!=NULL)
	{
		strtok(buffer,"\n");
		f2=fopen(s,"r");

		fgets(buffer1,1000,f2);
		bzero(buffer1,1000);
		//we will check all the combinations of rows of table2
		while(fgets(buffer1,1000,f2)!=NULL)
		{	//storing in cur_rows_comb_str
			bzero(cur_rows_comb_str,1000);
			strcpy(cur_rows_comb_str,buffer);strcat(cur_rows_comb_str,",");
			strcat(cur_rows_comb_str,buffer1);
			strtok(cur_rows_comb_str,"\n");

			//filling in cur_comb_arr from cur_rows_comb_str
			bzero(temp,1000);strcpy(temp,cur_rows_comb_str);
			bzero(cur_comb_arr,50*(no_attr1+no_attr2));
			
			char *roww=strtok(temp,"\n");
			char *attrr=strtok(roww,",");
			
			z=0;
			while(attrr!=NULL)
			{
				strcat(cur_comb_arr[z],attrr);
				z++;
				attrr=strtok(NULL,",");
			}

			//and print ans=given conditions for this particu;ar row combinations
			fprintf(fnew,"ans=");
			for(int i=0;i<k;i++)
			{

				if(strcmp(condition_list2[i],"AND")==0)
				{
					fprintf(fnew,"&&");
				}
				else{
					
					if(strcmp(condition_list2[i],"OR")==0)
					{
						fprintf(fnew,"||");
					}
					else
					{
						if(position[i]!=-1)
						{
							if(position[i]>=no_attr1)
							{
								if(type2[position[i]-no_attr1]==2)
								{
									fprintf(fnew,"\"%s\"",cur_comb_arr[position[i]]);
								}
								else
									fprintf(fnew,"%s",cur_comb_arr[position[i]]);
							}
							else
							{
								if(type1[position[i]]==2)
								{
									fprintf(fnew,"\"%s\"",cur_comb_arr[position[i]]);
								}
								else
									fprintf(fnew,"%s",cur_comb_arr[position[i]]);
							}
						}
						else
							fprintf(fnew,"%s",condition_list2[i]);
					}	
				}
				
			}
			//then print out the row combination
			fprintf(fnew,";\nif(ans==1) cout<<\"%s\"<<endl;",cur_rows_comb_str);
			bzero(buffer1,1000);
		}
		fclose(f2);
		bzero(buffer,1000);
	}
	fclose(f1);
	return;
}

void project_function(char* char_buffer,FILE* file1, FILE* fnew,int* project,int j,int k){
	char relation[j][20];
	while(fgets(char_buffer,1000,file1))
	{
	
		memset(relation,0,20*j);
		int l = 0;
		char* char1 = strtok(char_buffer,"\n");
		char* char2 = strtok(char1,",");
		while(char2!=NULL)
		{
			strcat(relation[l],char2);
			l++;
			char2 = strtok(NULL,",");
		}
		for(int i=0;i<k;i++)
		{
			fprintf(fnew,"cout<<\"%s,\";",relation[project[i]]);
			
		}
		fprintf(fnew,"cout<<endl;");

		memset(char_buffer,0,1000);
	}
}
void project_set(int* project,int l){
	for(int i = 0;i<l;i++){
		project[i] = -1;
	}
}


void projection(char string_in[])
{
fprintf(fnew,"cout<<endl;cout<<\"----------New Command Is Executed--------- \";cout<<endl;");
	strcat(column_list,"\0");	
	strcat(string_in,".csv");
	FILE *file1 = fopen(string_in,"r");
	if(file1==NULL)
	{
		fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",string_in);	
		return;
	}
	char char_buffer[1000];
	memset(char_buffer,0,1000);
	fgets(char_buffer,1000,file1);

	char h[15][20];
	memset(h,0,300); 

	char* temp = strtok(char_buffer,"\n");
	char* temp1 = strtok(temp,",");
	int j=0;
	while(temp1!=NULL)
	{
		strcat(h[j],temp1);
		temp1=strtok(NULL,",");
		j++;

	}
	
	int k1 = 0;
	while(k1!=j){
		strtok(h[k1],"(");
		k1++;
	}
	int project[20];
	int n = 20;
	project_set(project,n);
	char* temp2 = strtok(column_list,",");
	int k = 0;
	
	while(temp2!=NULL)
	{
		int l1 = 0;
		while(l1!=j){
			if(strcmp(temp2,h[l1])==0)
			{
				project[k]=l1;
				break;
			}
			l1++;
		}
		if(project[k]==-1)
		{
			fprintf(fnew,"cout<<\"%s column not present in table\"<<endl;",temp2);
	 		return;
		}
		k++;
		temp2=strtok(NULL,",");
	}
	for(int i=0;i<k;i++)
	{
		fprintf(fnew,"cout<<\"%s,\";",h[project[i]]);
	}

	fprintf(fnew,"cout<<endl;");

	memset(char_buffer,0,1000);
	
	project_function(char_buffer,file1,fnew,project,j,k);

	fclose(file1);
	return;
}

int is_number(char s[]) 
{ 
    for (int i = 0; i < strlen(s); i++) 
        if (isdigit(s[i]) == 0) 
            return 0; 
  
    return 1; 
}

void selection(char expression[],char fname[])
{
fprintf(fnew,"cout<<endl;cout<<\"----------New Command Is Executed--------- \";cout<<endl;");
//	fprintf(fnew,"\t//-------- SELECT OPERATION IS CALLED--------\n\t//Table Name:%s\n\t//Condition:%s\n",fname,expression);
	strcat(fname,".csv");
	FILE *file=fopen(fname,"row_data");
	//we need to check if the given file exists or not
	if(file==NULL)
	{
		fprintf(fnew,"string s=\"%s\";\ncout<<s<<\" Table doesnt exist\";\n",fname);
		return;
	}
	
	char line[1000];
	char buffer[1000];
	char cols[15][50];
	bzero(cols,300); 
	char *temp;
	char *temp_string;
	int no_columns=0;
	char express[100][100];
	bzero(express,10000);
	
	//Get the information of columns and the expression into required arrays
	fgets(line,1000,file);
	temp=strtok(line,"\n");	
	strcpy(buffer,line);
	temp_string=strtok(temp,",");
	while(1)
	{
		if(temp_string==NULL)break;
		strcat(cols[no_columns],temp_string);
		temp_string=strtok(NULL,",");
		no_columns++;
	}
	bzero(line,1000);
	temp_string=strtok(expression,",");
	int k=0;
	while(1)
	{
		if(temp_string==NULL)break;
		strcat(express[k],temp_string);
		temp_string=strtok(NULL,",");
		k++;
	}

	//derive the type of data from the column names.1->int.2->string.
	//printf("ok\n");
	int cols_type[no_columns];
	for(int i=0;i<no_columns;i++)
	{
		char col_type[50];
		int m=0;
		while(cols[i][m]!='(')m++;
		int len=0;
		m++;
		while(cols[i][m]!=')'){
			col_type[len]=cols[i][m];
			len++;
			m++;
		}
		col_type[len]='\0';
		//printf("%s %s\n",col_type,cols[i]);
		//cols[i]=col_type;
		m=0;		
		while(1){
			if(cols[i][m]=='('){
				cols[i][m]='\0';
				break;			
			}
			else if(cols[i][m]=='\0')break;		
			m++;
		}		
		//temp=strtok(cols[i],"(");
		//temp=strtok(NULL,")");
		
		if(strcmp(col_type,"int")==0)
			{cols_type[i]=1;}
		else
			{cols_type[i]=2;}
	}
	//for(int i=0;i<k;i++)printf("%s %d\n",cols[i],cols_type[i] );


//--------------------------check for data type mismatches and fill column_pointer--------------
	int column_pointer[k];
	for(int i=0;i<k;i++)column_pointer[i]=-1;
	for(int i=0;i<k;i++){
		if(isalpha(express[i][0])){
			if(strcmp(express[i],"OR")==0)continue;
			if(strcmp(express[i],"AND")==0)continue;
			int x;
			for( x=0;x<no_columns;x++){
				if(strcmp(express[i],cols[x])==0)break;
			}
			if(x==no_columns){
				fprintf(fnew,"cout<<\"%s column doesnt exist\"<<endl;",express[i]);
				return;
			}
			if(cols_type[x]!=express[i+1][0]-'0'){
				fprintf(fnew,"cout<<\"cols_type Mismatch\"<<endl;");
				return;
			}
			column_pointer[i]=x;
		}
		else{
			continue;
		}
	}
//	for(int i=0;i<k;i++)printf("%s %d\n",express[i],column_pointer[i] );

//------------------------------Print the output in the ans.cpp file---------------------
	fprintf(fnew,"cout<<\"%s\";",buffer);
	fprintf(fnew,"cout<<endl;");
	char row_data[no_columns][20];
	char complete_row_data[1000];
	int g,i;
	while(fgets(line,1000,file) ){
		// store the entire row in a buffer
		bzero(complete_row_data,1000);
		strcpy(complete_row_data,line);
		strtok(complete_row_data,"\n");
		
		//store the data in a row in a array row_data  
		bzero(row_data,20*no_columns);
		char *line_data=strtok(line,"\n");
		char *col_data=strtok(line_data,",");
		g=0;
		i=0;
		while(1){
			if(col_data==NULL)break;
			strcat(row_data[g],col_data);
			col_data=strtok(NULL,",");
			g++;
		}

		//get the required data from row data and create a boolean expression
		fprintf(fnew,"ans=");
	    for(i=0;i<k;i++){
			if(strcmp(express[i],"AND")==0)fprintf(fnew,"&&");            //AND operator in the boolean expression
			else if(strcmp(express[i],"OR")==0)fprintf(fnew,"||");        //OR operator in the boolean expression
			else if(column_pointer[i]!=-1){                               //some data belonging to a row 
				if(cols_type[column_pointer[i]]==2){
					fprintf(fnew,"\"%s\"",row_data[column_pointer[i]]);
					i++;
				}
				else if(row_data[column_pointer[i]][0]!='\0'){
					fprintf(fnew,"%s",row_data[column_pointer[i]]);
					i++;
				}
				else{
					fprintf(fnew,"-1");
					i++;
				}
			}                                            
			else{
				fprintf(fnew,"%s",express[i]);
			}
		}
		fprintf(fnew,";\nif(ans==1) cout<<\"%s\"<<endl;",complete_row_data);
		bzero(line,1000);
	}
}



int checkTable(FILE *filename){
    if(filename==NULL) return 0;
}

void cartesian_product(char f[],char s[])
{
fprintf(fnew,"cout<<endl;cout<<\"----------New Command Is Executed--------- \";cout<<endl;");
	strcat(f,".csv");
	strcat(s,".csv");
	
	FILE *f1=fopen(f,"r");
	FILE *f2=fopen(s,"r");

	int t1=checkTable(f1);
	int t2=checkTable(f2);

	if (t1 == 0) {
        fprintf(fnew,"cout<<\"Table %s not present\"<<endl;",f);
        return;
    }
    else if (t2 == 0) {
        fprintf(fnew,"cout<<\"Table %s not present\"<<endl;", s);
        return;
    }
	
	char buffer1[1000];
	char buffer2[1000];
	fgets(buffer1,1000,f1);
	strtok(buffer1,"\n");
	fgets(buffer2,1000,f2);
	strtok(buffer2,"\n");
	fprintf(fnew,"cout<<\"%s,%s\"<<endl;",buffer1,buffer2);
	memset(buffer1,0,1000);
	memset(buffer2,0,1000);
	fclose(f2);
	while(1){
		if(fgets(buffer1,1000,f1)!=NULL){
			strtok(buffer1,"\n");
			FILE *f2=fopen(s,"r");
			fgets(buffer2,1000,f2);
			memset(buffer2,0,1000);
			while(1){
				if(fgets(buffer2,1000,f2)==NULL){
					break;
				}
				else{
					strtok(buffer2,"\n");
					fprintf(fnew,"cout<<\"%s,%s\"<<endl;",buffer1,buffer2);
					memset(buffer2,0,1000);
				}
			}
			fclose(f2);
			memset(buffer1,0,1000);
		}
		else break;
	}
	
	fclose(f1);

}
