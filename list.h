#ifndef _LIST
#define _LIST

void createList(char const *name, struct node *head, struct node *tail);
void addElement(char const *name, struct node *tail);
void traverse(struct node *head);

#include "list.c"
#endif
