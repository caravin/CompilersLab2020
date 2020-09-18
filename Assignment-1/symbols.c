#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


typedef struct ssmb {
    char name[32];
    char class[32];
    int length;
    int class_length;
    struct ssmb* next;

}ssmb;

ssmb *newNode() {
    return (ssmb *) malloc(sizeof(ssmb));
}


void insert(ssmb **list, char name[32],char class[32],int class_length, int length) {
    ssmb* temp= *list;
    if(temp==NULL){
    	temp=newNode();
	    strncpy(temp->name,name,length);
	    strncpy(temp->class,class,class_length);
	    temp->class_length=class_length;
	    temp->length = length;
	    temp->next = *list;
	    *list = temp;
    }
    else{
	    while(temp->next!=NULL){
	    	temp=temp->next;
	    }
	    temp->next=newNode();
	    temp=temp->next;
	    strncpy(temp->name,name,length);
	    strncpy(temp->class,class,class_length);
	    temp->class_length=class_length;
	    temp->length = length;
	    temp->next = NULL;
	 }
}

bool present(ssmb *ssmb_list, char name[32], int length) {
    ssmb* list=ssmb_list;
    while (list != NULL) {
        if (strncmp(list->name,name, length) == 0)
            return true;
        list = list->next;
    }   
    return false;
}
