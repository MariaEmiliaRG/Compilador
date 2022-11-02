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
#include <stdlib.h>
#include <string.h> 
#include "list.h"

//Apuntador al archivo donde se almacenarán todos los errores que encuentre el compilador. 
FILE *errorsFile; 

FILE *ptrSimbolos;
FILE *ptrLiteralesCad;
FILE *ptrTokens;

//Variables para llevar un control en el manejo de errores. 
int line = 1; 
int error = 0; 
//Para cadenas de texto
int cuentaLiteralesCad=0;
//Para identificadores
int cuentaSimbolos = 0;

void newFloat(char *text);
void newInteger(char *text);
void newKeyWord(char *text);
void sendError(char *text);
void checkError();
int agregarElemento(char *name);
int buscarElemento(char *name);
int catRelacionales(char *name);
void imprimirArchivos();


//Para identificadores
//La estructura de lista utilizada para crear la tabla de simbolos
struct nodeSimbol{
	struct nodeSimbol *next;
	int pos;
	char nombre[20];
	int tipo;
};

struct listSimbol{
  struct nodeSimbol *head;
  struct nodeSimbol *tail;
};

//TODO: Pasarlo a archivos. 
struct listFloat{
  struct nodeFloat *head;
  struct nodeFloat *tail;
};

struct listToken{
  struct nodeToken *head;
  struct nodeToken *tail;
};

struct listSimbol tablaSimbolos;
struct listFloat tablaReales; 
struct listToken tokens; 

struct nodeFloat headFloat, tailFloat;
struct nodeToken headToken, tailToken;

%}
keyword    alternative|big|evaluate|instead|large|loop|make|number|other|real|repeat|select|small|step|stop|symbol|throw
ident      \$[A-Za-z]+
floatn     ([1-9]*|0?)\.[0-9]+
integern   0|([1-9][0-9]*)|([Oo][1-7][0-7]*)
constCad   \"[^\"]{0,38}\"
special    [\[\]\(\)\{\},;:]
opArit     [-\+\*\\\^/%]
opRel      [<>=!]=|[<>]
opAsig     [=]
others     [^ \n]
nextLine   \n

%%
{keyword}   {checkError(); newKeyWord(yytext);}
{ident}     {checkError(); fprintf(ptrTokens, "(1,%d)\n", agregarElemento(yytext));}
{floatn}    {checkError(); newFloat(yytext);}
{integern}  {checkError(); newInteger(yytext);}
{constCad}  {checkError(); fprintf(ptrTokens, "(4,%d)\n", cuentaLiteralesCad);
            fprintf(ptrLiteralesCad, "%d %s\n", cuentaLiteralesCad, yytext);
            cuentaLiteralesCad++;}
{special}   {checkError(); fprintf(ptrTokens, "(5,%c)\n", yytext[0]);}
{opRel}     {checkError(); fprintf(ptrTokens, "(7,%d)\n", catRelacionales(yytext));}
{opArit}    {checkError(); fprintf(ptrTokens, "(6,%c)\n", yytext[0]);}
{others}    {sendError(yytext);}
{nextLine}  {checkError(); line ++;}

%%
int main(int argn, char* arg[]){
  
  errorsFile = fopen("errors.txt", "w");

  if (argn <= 1){
    fprintf(errorsFile, "ERROR, no se encontró el archivo a compilar."); 
  } else {
    yyin = fopen(arg[1], "r"); 
    if (yyin != NULL){

      createFloatList(0, &headFloat, &tailFloat);
      createTokenList(-1, -1, &headToken, &tailToken);

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


      yylex();

            //Cerrando archivos
      fclose(ptrSimbolos);
      fclose(ptrLiteralesCad);
      fclose(ptrTokens);

      //Imprimiendo archivos
      imprimirArchivos();
      
    } else {
      fprintf(errorsFile, "ERROR, no se encontró el archivo a compilar."); 
    }
  }

  fclose(errorsFile);
  return 0; 
}


//Funcion que sirve para agregar nodos a la lista de simbolos
int agregarElemento(char *name){
  int posicion = 0;
  //Verifica si existen elementos en la lista, de no existir inicializa la lista
  if(cuentaSimbolos == 0){
    struct nodeSimbol *tmp;
    tmp = (struct nodeSimbol*)malloc(sizeof(struct nodeSimbol));
    tmp -> next = NULL;
    tmp -> pos = cuentaSimbolos;
    strcpy(tmp->nombre, name);
    tmp -> tipo = -1;
    tablaSimbolos.head = tmp;
    tablaSimbolos.tail = tmp;
    posicion = cuentaSimbolos;
    fprintf(ptrSimbolos, "%d %s -1\n", cuentaSimbolos, name);
  }else{//En caso de ya haber elementos
    posicion = buscarElemento(name);//Se almacena la posición que retorna buscarElemento 
    //Si la posición vale -1 significa que el identificcador aún no existe, por lo que se crea, en otro caso solo se almacena la posición
    if(posicion == -1){
      struct nodeSimbol *tmp;
      tmp = (struct nodeSimbol*)malloc(sizeof(struct nodeSimbol));
      tmp -> next = NULL;
      tmp -> pos = cuentaSimbolos;
      strcpy(tmp -> nombre, name);
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
    printf("%s", imprimir);
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
  printf("\n\n\n");

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