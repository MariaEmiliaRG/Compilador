%{
/*
  Proyecto de la clase de Compiladores
  Semestre 2023-1
  Autores: María Emilia Ramírez Gómez y Bryan Vargas Pacheco
  Fecha: Octubre 2022
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "list.h"

//Apuntador al archivo donde se almacenarán todos los errores que encuentre el compilador. 
FILE *errorsFile; 

struct nodeFloat headFloat, tailFloat;
struct nodeToken headToken, tailToken;


//Variables para llevar un control en el manejo de errores. 
int line = 1; 
int error = 0; 

void newFloat(char *text);
void newInteger(char *text);
void newKeyWord(char *text);
void sendError(char *text);
void checkError();
%}

keyWord    alternative|big|evaluate|instead|large|loop|make|number|other|real|repeat|select|small|step|stop|symbol|throw
floatn     ([1-9]*|0?)\.[0-9]+
integern   0|([1-9][0-9]*)|([Oo][1-7][0-7]*)
others     [^ \n]
nextLine   \n

%%

{keyWord}   {checkError(); newKeyWord(yytext);}
{floatn}    {checkError(); newFloat(yytext);}
{integern}  {checkError(); newInteger(yytext);}
{others}    {sendError(yytext);}
{nextLine}  {checkError(); line ++;}

%%

void newFloat(char *text){
  addFloatElement(atof(text), &tailFloat);
  addToken(3, tailFloat.token, &tailToken);
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
  addToken(2, oNum, &tailToken);
  return; 
}

void newKeyWord(char *text){
  char *keyWords[] = {"alternative","big","evaluate","instead","large","loop","make","number",
                      "other","real","repeat","select","small","step","stop","symbol","throw"};

  //Algoritmo de búsqueda binaria para hallar la posición de la palabra reservada y añadirlo al token. 
  int min = 0;
  int max = 16;
  int mid = (max + min)/2;

  while(max >= min){
    //text es mayor
    mid = (max + min)/2;
    if(strcmp(keyWords[mid],text) > 0)
      max = mid - 1; 
    else if (strcmp(keyWords[mid],text) < 0)
      min = mid + 1; 
    else 
      break; 
  }
  addToken(0, mid, &tailToken);
}

void sendError(char *text){
  if (error)
    fprintf(errorsFile, "%s", text);
  else{
    fprintf(errorsFile, "ERROR en la línea %d, no se reconoce %s", line, text);
    error = 1; 
  }   
  return; 
}

void checkError(){
  if (error){
    error = 0; 
    fprintf(errorsFile, "\n");
  }
  return; 
}

int main(int argn, char* arg[]){
  
  errorsFile = fopen("errors.txt", "w");

  if (argn <= 1){
    fprintf(errorsFile, "ERROR, no se encontró el archivo a compilar."); 
  } else {
    yyin = fopen(arg[1], "r"); 
    if (yyin != NULL){

      createFloatList(0, &headFloat, &tailFloat);
      createTokenList(-1, -1, &headToken, &tailToken);

      yylex();
      
    } else {
      fprintf(errorsFile, "ERROR, no se encontró el archivo a compilar."); 
    }
  }

  fclose(errorsFile);
  return 0; 
}
