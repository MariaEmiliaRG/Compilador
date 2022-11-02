%{
/*
  Proyecto de la clase de Compiladores
  Analizador Léxico de un compilador
  Profesora: M.C. Laura Sandoval Montaño
  Grupo: 3
  Semestre 2023-1
  Autores: María Emilia Ramírez Gómez y Bryan Vargas Pacheco
  Fecha de entrega: 02 de noviembre de 2022
*/


/*
  Descripción del programa
  El programa consiste en el analizador léxico de un compilador, se
  encarga de reconocer los componentes léxicos de un lenguaje.
*/

/*
  Entradas y salidas
  El programa recibe como argumento desde terminal un archivo de texto, el cual 
  Como salida el program genera 5 archivos: "Tokens.txt", "TablaSimbolos.txt"
  "TLiteralesCadenas.txt", "TLiteralesReales.txt" y "errorsFile.txt"
  A su vez el contenido de los archivos  "Tokens.txt", "TablaSimbolos.txt"
  "TLiteralesCadenas.txt" y "TLiteralesReales.txt" se imprimen en pantalla. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h> 

//Archivo donde se almacenarán todos los errores que encuentre el compilador. 
FILE *errorsFile; 

//Archivos donde se almacenarán las tablas de literales, y símbolos.
FILE *ptrSimbolos;
FILE *ptrLiteralesCad;
FILE *ptrReales;

//Archivo donde se almacenarán los tokens. 
FILE *ptrTokens;


//Variables para llevar un control en el manejo de errores. 
int line = 1; 
//Tener el registro de si el caracter previo tampoco ha sido reconocido, de este modo en el archivo de errores podemos mostrar la cadena completa 
//y no caracter por caracter.
int error = 0; 

//Variables para conocer cuántos elementos hemos almacenado en las tablas correspondientes. 
//Para cadenas de texto
int cuentaLiteralesCad=0;
//Variable para llevar la cuenta de identificadores
int cuentaSimbolos = 0;
//Variable para llevar la cuenta de números reales reales
int cuentaReales = 0; 

void newIdent(char *text);
void nexConstCad(char *text);
void newSpecial(char *text);
void newOpRel(char *text);
void newOpArit(char *text);
void newOpAsig();
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

//Estructura donde se almacena el head y tail de la tabla de simbolos
struct listSimbol{
  struct nodeSimbol *head;
  struct nodeSimbol *tail;
};
//Creación de la tabla de símbolos
struct listSimbol tablaSimbolos;


%}
keyword    alternative|big|evaluate|instead|large|loop|make|number|other|real|repeat|select|small|step|stop|symbol|throw
ident      \$[A-Za-z]+
floatn     ([1-9]*|0?)\.[0-9]+
integern   0|([1-9][0-9]*)|([Oo][1-7][0-7]*)
constCad   \"[^\"]{0,100}\"
special    [\[\]\(\)\{\},;:]
opArit     [-\+\*\\\^/%]
opRel      [<>=!]=|[<>]
opAsig     [=]
others     [^ \n]
nextLine   \n
%%
{keyword}   {checkError(); newKeyWord(yytext);}
{ident}     {checkError(); newIdent(yytext);}
{floatn}    {checkError(); newFloat(yytext);}
{integern}  {checkError(); newInteger(yytext);}
{constCad}  {checkError(); nexConstCad(yytext);}
{special}   {checkError(); newSpecial(yytext);}
{opRel}     {checkError(); newOpRel(yytext);}
{opArit}    {checkError(); newOpArit(yytext);}
{opAsig}    {checkError(); newOpAsig();}
{others}    {sendError(yytext);}
{nextLine}  {checkError(); line ++;}
%%
int main(int argn, char* arg[]){
  
  errorsFile = fopen("errors.txt", "w");

  //Comprobar que el usuario halla introducido el archivo a ser compilado. 
  if (argn <= 1){
    fprintf(errorsFile, "ERROR, no se encontró el archivo a compilar."); 
  } else {
    yyin = fopen(arg[1], "r"); 
    //El programa procede si el archivo existe, de lo contrario manda un error. 
    if (yyin != NULL){

      //Creamos archivos en caso de no existir o sobreescribimos. 
      ptrReales = fopen("TLiteralesReales.txt", "w");
      fclose(ptrReales);
      ptrSimbolos=fopen("TablaSimbolos.txt", "w");
      fclose(ptrSimbolos);
      ptrLiteralesCad=fopen("TLiteralesCadenas.txt", "w");
      fclose(ptrLiteralesCad);
      ptrTokens=fopen("Tokens.txt", "w");
      fclose(ptrTokens);

      //Asignando apuntadores y abriendo archivos
      ptrSimbolos=fopen("TablaSimbolos.txt", "a");
      ptrLiteralesCad=fopen("TLiteralesCadenas.txt", "a");
      ptrReales=fopen("TLiteralesReales.txt", "a");
      ptrTokens=fopen("Tokens.txt", "a");
      
      //Inicio de identificación de los componentes léxicos.
      yylex();

      //Cerrando archivos
      fclose(ptrSimbolos);
      fclose(ptrLiteralesCad);
      fclose(ptrTokens);
      fclose(ptrReales);

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
    cuentaSimbolos++;
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


/*
Imprimir un archivo
Se introduce su nombre así como el encabezado que queremos que salga en pantalla para poder identificarlo. 
*/
void imprimirArchivo(char *file, char *text){
  char imprimir[100];
  FILE *ptrFile; 
  ptrFile=fopen(file,"r");
  printf("%s:\n\n", text);
  while(fgets (imprimir, 100, ptrFile) != NULL){
    printf("%s", imprimir);
  }
  fclose(ptrFile);
  printf("\n\n\n");
  return; 
}

/*
Imprime cada una de las tablas que ha generado el programa
Utilizamos la función imprimirArchivo. 
*/
void imprimirArchivos(){
  
  imprimirArchivo("Tokens.txt", "Tokens");

  if(cuentaSimbolos)
    imprimirArchivo("TablaSimbolos.txt", "Tabla de simbolos");
  else 
    printf("No hay elementos en la tabla de simbolos\n");

  if(cuentaLiteralesCad)
    imprimirArchivo("TLiteralesCadenas.txt", "Tabla de literales - cadenas");
  else 
    printf("No hay elementos en la tabla de literales - cadenas\n");

  if(cuentaReales)
    imprimirArchivo("TLiteralesReales.txt", "Tabla de literales - reales");

  return; 
}
//Agrega el token para caracteres especiales
void newSpecial(char *text){
  fprintf(ptrTokens, "(5,%c)\n", text[0]);
  return; 
}

/*
Se realiza la conversión de cadena a flotante, de este modo en la tabla todos los números se ven homogeneos
.23  -> 0.23
0.23 -> 0.23
1.23 -> 1.23
Así mismo, se crea el token correspondiente. 
*/
void newFloat(char *text){
  fprintf(ptrReales, "%d %lf\n", cuentaReales, atof(text));
  fprintf(ptrTokens, "(3,%d)\n", cuentaReales);
  cuentaReales++; 
  return; 
}
//Agrega token para operadores aritméticos
void newOpArit(char *text){
  fprintf(ptrTokens, "(6,%c)\n", text[0]);
  return; 
}
//Agrega el token para operadores de asignación
void newOpAsig(){
  fprintf(ptrTokens, "(8,=)\n");
  return; 
}

/*
En caso de que el número esté en el sistema octal, se realiza la conversión para poder almacenarlo en la tabla de tokens en su forma decimal. 
*/
void newInteger(char *text){
  int oNum;
  if(text[0] == 'o' || text[0] == 'O'){
    text[0] = '0'; 
    sscanf(text, "%o", &oNum);
  } else {
    oNum = atoi(text);
  }

  fprintf(ptrTokens, "(2,%d)\n", oNum);
  return; 
}
//Agrega el token para operadores relacionales
void newOpRel(char *text){
  fprintf(ptrTokens, "(7,%d)\n", catRelacionales(text));
  return; 
}

/*
Identificar en qué posisción del arreglo de palabras reservadas se encuentra el componente léxico
Para ello nos ayudamos del algoritmo de búsqueda binaria, ya que el arreglo se encunetra ordenado y no será necesario realizar muchas iteraciones. 
Posteriormente, se genera el token correspondiente. 
*/
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

  fprintf(ptrTokens, "(0,%d)\n", mid);
  return; 
}
//Agrega el token para identificadores
void newIdent(char *text){
  fprintf(ptrTokens, "(1,%d)\n", agregarElemento(text));
  return;
}

//Agrega una cadena a la tabla de literales cadenas y genera el respectivo token
void nexConstCad(char *text){
  fprintf(ptrTokens, "(4,%d)\n", cuentaLiteralesCad);
  fprintf(ptrLiteralesCad, "%d %s\n", cuentaLiteralesCad, text);
  cuentaLiteralesCad++;
  return; 
}

/*
De no reconocer la cadena como alguna de las clases de los componentes léxicos especificados, esta se irá escribiendo, caracter por caracter hasta hallar un componente léxico 
válido o el fin de archivo
La variable error nos ayuda a saber si el caracter previo tampoco fue reconocido, por ende este forma parte del mismo error. 
*/
void sendError(char *text){
  if (error)
    fprintf(errorsFile, "%s", text);
  else{
    fprintf(errorsFile, "ERROR en la línea %d, no se reconoce %s", line, text);
    error = 1; 
  }   
  return; 
}

/*
En caso de encontrar un componente léxico válido es importante darle continuidad a los errores. Por ello, si la variable error es verdadera, 
hay que agregar un salto de línea en el archivo de errores, y tenemos que modificar la variable error a 0 (falso)
*/
void checkError(){
  if (error){
    error = 0; 
    fprintf(errorsFile, "\n");
  }
  return; 
}
