//#include "list.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int size = 0;

struct node{
    char str[20];
    int token;           
    struct node *next; 
};

/*
Estructura para crear la lista que almacenará la tabla de números reales del código. 
*/
struct nodeFloat{
    float num;
    int token;  
    struct nodeFloat *next;
};

void createFloatList(float numF, struct nodeFloat *head, struct nodeFloat *tail){
    head = (struct nodeFloat *)malloc(sizeof(struct nodeFloat)); 
    if(head == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    head -> num = numF;
    head -> token = 0;
    head -> next = NULL;
    tail = head;
} 

void addFloatElement(float numF, struct nodeFloat *tail){
    struct nodeFloat *temp;
    temp = (struct nodeFloat *)malloc(sizeof(struct nodeFloat));
    if(temp == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    temp -> num = numF;
    temp -> token = tail -> token + 1;
    temp -> next = NULL;
    tail -> next = temp;
    tail = tail->next;
}

void createList(char const *name, struct node *head, struct node *tail){
    head = (struct node *)malloc(sizeof(struct node)); 
    if(head == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    strcpy(head -> str, name);
    head -> token = 0;
    head -> next = NULL;
    tail = head;
}

void addElement(char const *name, struct node *tail){
    struct node *temp;
    temp = (struct node *)malloc(sizeof(struct node));
    if(temp == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    strcpy(temp -> str, name);
    temp -> token = tail -> token + 1;
    temp -> next = NULL;
    tail -> next = temp;
    tail = tail->next;
}

void traverse(struct node *head){
    struct node *temp;
    temp = (struct node *)malloc(sizeof(struct node));
    if(head == NULL){
        printf("The list is empty");
        return;
    }
    temp = head;
    while(temp != NULL){
        //Perform what is needed according to the table to be worked on.
        temp = temp->next;
    }
}
