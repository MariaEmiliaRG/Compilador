%{
/*
  Proyecto de la clase de Compiladores
  Analizador Léxico de un compilador
  Profesora: M.C. Laura Sandoval Montaño
  Grupo: 2
  Semestre 2023-1
  Autores: María Emilia Ramírez Gómez y Bryan Vargas Pacheco
  Fecha de entrega: 02 de noviembre de 2022
*/


/*
  Descripción del programa

*/

/*
  Entradas y salidas
*/

#include <stdio.h>
#include <string.h>
#include "list.h"

int agregarElemento(char *name);
int buscarElemento(char *name);
int catRelacionales(char *name);
void imprimirArchivos();

FILE *ptrSimbolos;
FILE *ptrLiteralesCad;
FILE *ptrTokens;

//Para cadenas de texto
int cuentaLiteralesCad=0;

//Para identificadores
//La estructura de lista utilizada para crear la tabla de simbolos
int cuentaSimbolos = 0;
struct nodeSimbol{
	struct nodeSimbol *next;
	int pos;
	char name[20];
	int tipo;
};

struct list{
  struct nodeSimbol *head;
  struct nodeSimbol *tail;
};

struct list tablaSimbolos;

//Funcion que sirve para agregar nodos a la lista de simbolos
int agregarElemento(char *name){
  int pos = 0;
  //Verifica si existen elementos en la lista, de no existir inicializa la lista
  if(cuentaSimbolos == 0){
    struct nodeSimbol *tmp;
    tmp = (struct nodeSimbol*)malloc(sizeof(struct nodeSimbol));
    tmp -> next = NULL;
    tmp -> pos = cuentaSimbolos;
    srtcpy(tmp->nombre, name);
    tmp -> tipo = -1;
    tablaSimbolos.head = tmp;
    tablaSimbolos.tail = tmp;
    pos = cuentaSimbolos;
    fprintf(ptrSimbolos, "%d %s -1\n", cuentaSimbolos, name);
  }else{//En caso de ya haber elementos
    posicion = buscarElemento(name);//Se almacena la posición que retorna buscarElemento 
    //Si la posición vale -1 significa que el identificcador aún no existe, por lo que se crea, en otro caso solo se almacena la posición
    if(posicion == -1){
      struct nodeSimbol *tmp;
      tmp = (struct nodeSimbol*)malloc(sizeof(struct nodeSimbol));
      tmp -> next = NULL;
      tmp -> pos = cuentaSimbolos;
      srtcpy(tmp -> nombre, name);
      tmp -> tipo = -1;
      tablaSimbolos.tail -> next = tmp;
      tablaSimbolos.tail = tmp;
      posicion = cuentaSimbolos;
      fprintf(ptrSimbolos, "%d %s -1\n", cuentaSimbolos, name);
      cuentaSimbolos++;
    }
  }
  //Retorna la posición del s+imbolo para la generación del token
  return posicion;
}

//Busca un elemento en la tabla de símbolos para ver si existe y retorna una posición
int buscarElemento(char *name){
    struct nodeSimbol *temp = tablaSimbolos.head;
    while(temp != NULL){
    	if(strcmp(temp -> nombre, name) == 0){
    		return temp -> pos;//Retorna la posición en caso de que el identificador exista
    	}
      temp = temp->next;
    }
   return -1;//Retorna menos 1 en caso de que el identificador no exista
}

//Para operadores relacionales

//Retorna el valor de operador relacional de su respectiva tabla para la generación de tokens
int catRelacionales(char *operador){
  if(strcmp(operador, "<") == 0){
    return 0;
  }else if(strcmp(operador, ">") == 0){
    return 1;
  }else if(strcmp(operador, "<=") == 0){
    return 2;
  }else if(strcmp(operador, ">=") == 0){
    return 3;
  }else if(strcmp(operador, "==") == 0){
    return 4;
  }else if(strcmp(operador, "!=") == 0){
    return 5;
  }else{
    return -1;
  }
}

//Imprimit archivos


//Imprime cada una de las tablas que requiere el programa
void imprimirArchivos(){
  char imprimir[40];
  ptrTokens=fopen("Tokens.txt","r");
  printf("Tokens:\n\n");
  while(fgets (imprimir, 40, ptrTokens) != NULL){
    printf("%s", imprimr);
  }
  fclose(ptrTokens);
  printf("\n\n\n");

  printf("Tabla de simbolos");
  if(cuentaSimbolos){
    ptrSimbolos=fopen("TablaSimbolos.txt", "r");
	  while ( fgets (imprimir, 40, ptrSimbolos) != NULL ){
		  printf("%s", imprimir);
    }
	  fclose(ptrSimbolos);
  }else{
    printf("No hay elementos en la tabla de simbolos\n");
  }
  printf("\n\n\n")

  printf("Tabla de literales\n");
    if(cuentaSimbolos){
    ptrLiteralesCad = fopen("TLiteralesCadenas.txt", "r");
	  while ( fgets (imprimir, 40, ptrLiteralesCad) != NULL ){
		  printf("%s", imprimir);
    }
	  fclose(ptrLiteralesCad);
  }else{
    printf("No hay elementos en la tabla de literales cadenas\n");
  }
}

%}
keyword alternative|big|evaluate|instead|large|loop|make|number|other|real|repeat|select|small|step|stop|symbol|throw
ident \$[A-Za-z]+
integer 0|([1-9][0-9]*)|([oO][1-7][0-7]+)
floatn ([1-9]*|0?)\.[0-9]+
constCad ("[^"'\n\r]+")|("'")|('[^'\n\r]')
special [\[\]\(\)\{\},;:]
opArit [-\+\*\\\^/%]
opRel [<>=!]=|[<>]
opAsig [=]
others [^ /n]


%%

{ident} {fprintf(ptrTokens, "(1,%d)\n", agregarElemento(yytext));
        //addToken(1, tailFloat.token, &tailToken);
}
{constCad} {fprintf(ptrTokens, "(4,%d)\n", cuentaLiteralesCad);
            fprintf(ptrLiteralesCad, ("(4,%d)\n", cuentaLiteralesCad));
            cuentaLiteralesCad++;
            //addToken(4, tailFloat.token, &tailToken);
}
{special} {fprintf(ptrTokens, "(5,%c)\n", yytext[0]);
            //addToken(5, tailFloat.token, &tailToken);
}
{opRel} {fprintf(ptrTokens, "(7,%d)\n", catRelacionales(yytext));
        //addToken(7, tailFloat.token, &tailToken);
}
{opArit} {fprintf(ptrTokens, "(6,%c)\n", yytext[0]);
          //addToken(6, tailFloat.token, &tailToken);
}
%%
int main(int argc, char *argv[]){
  yyin=fopen(argv[1], "r");

  //Dando formato a los archivos utilizados
  ptrSimbolos=fopen("TablaSimbolos.txt", "w");
  fprintf(ptrSimbolos, "Tabla de simbolos : \n\n");
  fclose(ptrSimbolos);

  ptrLiteralesCad=fopen("TLiteralesCadenas.txt", "w");
  fprintf(ptrLiteralesCad, "Tabla de literales cadenas : \n\n");
  fclose(ptrLiteralesCad);

  ptrTokens=fopen("Tokens.txt", "w");
  fprintf(ptrTokens, "TOKENS : \n\n");
  fclose(ptrTokens);

  //Asignando apuntadores y abriendo archivos
  ptrSimbolos=fopen("TablaSimbolos.txt", "a");
  ptrLiteralesCad=fopen("TablaLiteralesCadenas.txt", "a");
  ptrTokens=fopen("Tokens.txt", "a");

  //Iniciando analizador léxico
  yylex();

  //Cerrando archivos
  fclose(ptrSimbolos);
  fclose(ptrLiteralesCad);
  fclose(ptrTokens);

  //Imprimiendo archivos
  imprimirArchivos();
  return 0; 
}
