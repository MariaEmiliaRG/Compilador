#include "list.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int size = 0;
int counter = 0;

struct node{
    char str[20];
    int token;           
    struct node *next; 
}*head, *tail;

void createList(char const *name){
    head = (struct node *)malloc(sizeof(struct node)); 
    if(head == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    strcpy(head -> str, name);
    head -> token = counter++;
    head -> next = NULL;
    tail = head;
}

void addElement(char const *name){
    struct node *temp;
    temp = (struct node *)malloc(sizeof(struct node));
    if(temp == NULL){
        printf("ERROR with memory");
        exit(0);
    }
    strcpy(temp -> str, name);
    temp -> token = counter++;
    temp -> next = NULL;
    tail -> next = temp;
    tail = tail->next;
}

void traverse(){
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