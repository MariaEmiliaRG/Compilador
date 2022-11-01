#ifndef _LIST
#define _LIST
#include "list.c"

void createFloatList(float numF, struct nodeFloat *head, struct nodeFloat *tail);
void addFloatElement(float numF, struct nodeFloat *tail);

void createTokenList(int class, int value, struct nodeToken *head, struct nodeToken *tail);
void addToken(int class, int value, struct nodeToken *tail);

void createList(char const *name, struct node *head, struct node *tail);
void addElement(char const *name, struct node *tail);
void traverse(struct node *head);


#endif
