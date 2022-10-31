#include "list.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int size = 0;

struct node{
    char str[20];
    int token;           
    struct node *next; 
};

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
