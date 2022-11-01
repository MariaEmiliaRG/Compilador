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

/*
Estructura para crear la lista de los tokens. 
*/
struct nodeToken{
    int class;
    int value;  
    struct nodeToken *next;
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

void createTokenList(int class, int value, struct nodeToken *head, struct nodeToken *tail){
    head = (struct nodeToken *)malloc(sizeof(struct nodeToken)); 
    if(head == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    head -> class = class;
    head -> value = value;
    head -> next = NULL;
    tail = head;
} 

void addToken(int class, int value, struct nodeToken *tail){
    struct nodeToken *temp;
    temp = (struct nodeToken *)malloc(sizeof(struct nodeToken));
    if(temp == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    temp -> class = class;
    temp -> value = value;
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
