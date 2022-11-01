%{
/*
  Proyecto de la clase de Compiladores
  Semestre 2023-1
  Autores: María Emilia Ramírez Gómez y Bryan Vargas Pacheco
  Fecha: Octubre 2022
*/
#include <stdio.h>
#include <stdlib.h>
#include "list.h"

//Apuntador al archivo donde se almacenarán todos los errores que encuentre el compilador. 
FILE *errors; 

struct nodeFloat headFloat, tailFloat; 

void newFloat(char *text);
void newInteger(char *text);
void sendError(int type, FILE *file, char *text);
%}

floatn     ([1-9]*|0?)\.[0-9]+
integern   0|([1-9][0-9]*)|([Oo][1-7][0-7]*)
others     [^ \n]

%%

{floatn}    {newFloat(yytext);}
{integern}  {newInteger(yytext);}
{others}    {sendError(2, errors, yytext);}

%%

void newFloat(char *text){
  addFloatElement(atof(text), &tailFloat);
  //createToken();
  return; 
}

void newInteger(char *text){
  int oNum;
  if(text[0] == 'o' || text[0] == 'O'){
    text[0] = '0'; 
    sscanf(text, "%o", &oNum);
  } else {
    oNum = atoi(text);
  }
    
  //printf("octal: %o, decimal: %d", oNum, oNum);

  //createToken();

}

void sendError(int type, FILE *file, char *text){
  switch(type){
    case 1: 
      fprintf(file, "ERROR: no se encontró el archivo a compilar.\n");
    break;
    case 2:
      fprintf(file, "ERROR: no se reconoce %s como parte del lenguaje.\n", text);
    break; 
  }

  return; 
}

int main(int argn, char* arg[]){
  
  errors = fopen("errors.txt", "w");

  if (argn <= 1){
    sendError(1, errors, ""); 
  } else {
    yyin = fopen(arg[1], "r"); 
    if (yyin != NULL){

      createFloatList(0, &headFloat, &tailFloat);

      yylex();
      fclose(errors);
    } else {
      sendError(1, errors, "");
    }
  }
  return 0; 
}
