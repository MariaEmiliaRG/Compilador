%{
/*
  Proyecto de la clase de Compiladores
  Semestre 2023-1
  Autores: María Emilia Ramírez Gómez y Bryan [Apellidos]
  Fecha: Octubre 2022
*/
#include <stdio.h>
#include <stdlib.h>

//Apuntador al archivo donde se almacenarán todos los errores que encuentre el compilador. 
FILE *errors; 

void sendError(int type, FILE *file, char *text);
%}

%%

%%

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
      yylex();
      fclose(errors);
    } else {
      sendError(1, errors, "");
    }
  }
  return 0; 
}
