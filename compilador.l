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


//Archivo donde se almacena la cadena de atomos
FILE *ptrCadenaAtomos;
FILE *ptrErrores;
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

//Variables utilizadas para el funcionamiento del analizador sintáctico
char cadenaAtomos[2048];  // Longitud m�ximo del programa a analizar = 2048 atomos, 2 kilobytes de espacio en la memoria para atomos.
int cuentaAtomos=0;
int cuentaSintactica=0;
int errorSintactico = 0;
char c;

void newIdent(char *text);
void nexConstCad(char *text);
void newSpecial(char *text);
void newOpRel(char *text);
void newOpArit(char *text);
void newChar(char *text);
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

//Funciones del analizador sintáctico.
void inicializarCadAtomos();
void inicializarCad();
void impCadAt(); 
void Program(); 
void otraFunc(); 
void Func(); 
void Param(); 
void otroParam(); 
void Cuerpo(); 
void Decl(); 
void D(); 
void Tipo(); 
void K(); 
void Q(); 
void N(); 
void C(); 
void A(); 
void AP(); 
void E(); 
void EP(); 
void T(); 
void TP(); 
void F(); 
void R(); 
void RP(); 
void V(); 
void VP(); 
void VPP(); 
void VPPP(); 
void P(); 
void listaP(); 
void W(); 
void I(); 
void IP(); 
void J(); 
void Y(); 
void X(); 
void Z(); 
void H(); 
void CP(); 
void OP(); 
void U(); 
void Devuelve(); 
void valor(); 
void Llama(); 
void arg(); 
void otroArg(); 

void errorSint( char * errores, char * produccion); 


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
carac '.'
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
{carac}     {checkError(); newChar(yytext);}
{special}   {checkError(); newSpecial(yytext);}
{opRel}     {checkError(); newOpRel(yytext);}
{opArit}    {checkError(); newOpArit(yytext);}
{opAsig}    {checkError(); newOpAsig();}
{others}    {sendError(yytext);}
{nextLine}  {checkError(); line ++;}
%%
int main(int argn, char* arg[]){

  inicializarCad();
  inicializarCadAtomos();
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
      ptrCadenaAtomos=fopen("Atomos.txt", "w");
      fclose(ptrCadenaAtomos);
      //Asignando apuntadores y abriendo archivos
      ptrSimbolos=fopen("TablaSimbolos.txt", "a");
      ptrLiteralesCad=fopen("TLiteralesCadenas.txt", "a");
      ptrReales=fopen("TLiteralesReales.txt", "a");
      ptrTokens=fopen("Tokens.txt", "a");
      ptrCadenaAtomos=fopen("Atomos.txt", "a");
      //Inicio de identificación de los componentes léxicos.
      yylex();
      cuentaSintactica = 0;
      c = cadenaAtomos[cuentaSintactica++];
      Program(); 
      
      impCadAt();
      //Cerrando archivos
      fclose(ptrSimbolos);
      fclose(ptrLiteralesCad);
      fclose(ptrTokens);
      fclose(ptrReales);
      fclose(ptrCadenaAtomos);
      //Imprimiendo archivos
      imprimirArchivos();
      
    } else {
      fprintf(errorsFile, "ERROR, no se encontró el archivo a compilar."); 
    }
  }

  fclose(errorsFile);
  return 0; 
}

void inicializarCadAtomos(){
  for(int i = 0; i < 2048; i++){
    cadenaAtomos[i] = '&';
  }
}

void inicializarCad(){
  int i = 0;
  for(i = 0; i < 2048; i++){
    cadenaAtomos[i] = '&';
  }
}

void impCadAt(){
  int i = 0;
  printf("Cadena de atomos\n");
  fprintf(ptrCadenaAtomos,"Cadena de atomos\n");
  for(i = 0; i < 2048; i++){
    printf("%c ", cadenaAtomos[i]);
    fprintf(ptrCadenaAtomos,"%c", cadenaAtomos[i]);
    if(i % 10 == 0){
      printf("\n");
    }
    if(cadenaAtomos[i] == '&'){
      printf("\n");
      return;
    }
  }
  printf("\n");
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
    cadenaAtomos[cuentaAtomos]='<';
	  cuentaAtomos++;
    return 0;
  }else if(strcmp(operador, ">") == 0){
    cadenaAtomos[cuentaAtomos]='>';
	  cuentaAtomos++;
    return 1;
  }else if(strcmp(operador, "<=") == 0){
    cadenaAtomos[cuentaAtomos]='l';
	  cuentaAtomos++;
    return 2;
  }else if(strcmp(operador, ">=") == 0){
    cadenaAtomos[cuentaAtomos]='u';
	  cuentaAtomos++;
    return 3;
  }else if(strcmp(operador, "==") == 0){
    cadenaAtomos[cuentaAtomos]='e';
	  cuentaAtomos++;
    return 4;
  }else if(strcmp(operador, "!=") == 0){
    cadenaAtomos[cuentaAtomos]='d';
	  cuentaAtomos++;
    return 5;
  }else{
    return -1;
  }
}

//Imprimir archivos


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
  switch(text[0]){
    case '[':
        cadenaAtomos[cuentaAtomos]='[';
        cuentaAtomos++;
    break;
    case ']':
        cadenaAtomos[cuentaAtomos]=']';
        cuentaAtomos++;
    break;
    case '(':
        cadenaAtomos[cuentaAtomos]='(';
        cuentaAtomos++;
    break;
    case ')':
        cadenaAtomos[cuentaAtomos]=')';
        cuentaAtomos++;
    break;
    case '{':
        cadenaAtomos[cuentaAtomos]='{';
        cuentaAtomos++;
    break;
    case '}':
        cadenaAtomos[cuentaAtomos]='}';
        cuentaAtomos++;
    break;
    case ',':
        cadenaAtomos[cuentaAtomos]=',';
        cuentaAtomos++;
    break;
    case ':':
        cadenaAtomos[cuentaAtomos]=':';
        cuentaAtomos++;
    break;
    case ';':
        cadenaAtomos[cuentaAtomos]=';';
        cuentaAtomos++;
    break;
  }
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
  cadenaAtomos[cuentaAtomos]='r';
  cuentaAtomos++;
  cuentaReales++; 
  return; 
}
//Agrega token para operadores aritméticos
void newOpArit(char *text){
  fprintf(ptrTokens, "(6,%c)\n", text[0]);
  switch(text[0]){
    case '+':
        cadenaAtomos[cuentaAtomos]='+';
        cuentaAtomos++;
    break;
    case '-':
        cadenaAtomos[cuentaAtomos]='-';
        cuentaAtomos++;
    break;
    case '*':
        cadenaAtomos[cuentaAtomos]='*';
        cuentaAtomos++;
    break;
    case '/':
        cadenaAtomos[cuentaAtomos]='/';
        cuentaAtomos++;
    break;
    case '%':
        cadenaAtomos[cuentaAtomos]='%';
        cuentaAtomos++;
    break;
    case '^':
        cadenaAtomos[cuentaAtomos]='^';
        cuentaAtomos++;
    break;
    case '\\':
        cadenaAtomos[cuentaAtomos]='\\';
        cuentaAtomos++;
  }
  return; 
}
//Agrega el token para operadores de asignación
void newOpAsig(){
  fprintf(ptrTokens, "(8,=)\n");
  cadenaAtomos[cuentaAtomos]='=';
  cuentaAtomos++;
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
  cadenaAtomos[cuentaAtomos]='n';
  cuentaAtomos++;
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
  if(mid == 0){
    cadenaAtomos[cuentaAtomos]='a';
    cuentaAtomos++;
  }else if(mid == 1){
    cadenaAtomos[cuentaAtomos]='b';
    cuentaAtomos++;
  }else if(mid == 2){
    cadenaAtomos[cuentaAtomos]='f';
    cuentaAtomos++;
  }else if(mid == 3){
    cadenaAtomos[cuentaAtomos]='t';
    cuentaAtomos++;
  }else if(mid == 4){
    cadenaAtomos[cuentaAtomos]='g';
    cuentaAtomos++;
  }else if(mid == 5){
    cadenaAtomos[cuentaAtomos]='w';
    cuentaAtomos++;
  }else if(mid == 6){
    cadenaAtomos[cuentaAtomos]='m';
    cuentaAtomos++;
  }else if(mid == 7){
    cadenaAtomos[cuentaAtomos]='#';
    cuentaAtomos++;
  }else if(mid == 8){
    cadenaAtomos[cuentaAtomos]='o';
    cuentaAtomos++;
  }else if(mid == 9){
    cadenaAtomos[cuentaAtomos]='x';
    cuentaAtomos++;
  }else if(mid == 10){
    cadenaAtomos[cuentaAtomos]='j';
    cuentaAtomos++;
  }else if(mid == 11){
    cadenaAtomos[cuentaAtomos]='h';
    cuentaAtomos++;
  }else if(mid == 12){
    cadenaAtomos[cuentaAtomos]='p';
    cuentaAtomos++;
  }else if(mid == 13){
    cadenaAtomos[cuentaAtomos]='c';
    cuentaAtomos++;
  }else if(mid == 14){
    cadenaAtomos[cuentaAtomos]='q';
    cuentaAtomos++;
  }else if(mid == 15){
    cadenaAtomos[cuentaAtomos]='y';
    cuentaAtomos++;
  }else if(mid == 16){
    cadenaAtomos[cuentaAtomos]='z';
    cuentaAtomos++;
  }
  fprintf(ptrTokens, "(0,%d)\n", mid);
  return; 
}
//Agrega el token para identificadores
void newIdent(char *text){
  fprintf(ptrTokens, "(1,%d)\n", agregarElemento(text));
  cadenaAtomos[cuentaAtomos]='i';
  cuentaAtomos++;
  return;
}

//Agrega una cadena a la tabla de literales cadenas y genera el respectivo token
void nexConstCad(char *text){
  fprintf(ptrTokens, "(4,%d)\n", cuentaLiteralesCad);
  fprintf(ptrLiteralesCad, "%d %s\n", cuentaLiteralesCad, text);
  cuentaLiteralesCad++;
  cadenaAtomos[cuentaAtomos]='s';
  cuentaAtomos++;
  return; 
}

void newChar(char *text){
  fprintf(ptrTokens, "(4,%c)\n", text[0]);
  cadenaAtomos[cuentaAtomos]='s';
  cuentaAtomos++;
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
    fprintf(errorsFile, "ERROR LEXICO, en la línea %d, no se reconoce %s", line, text);
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

//Funciones utilizadas para el analizador sintáctico

void errorSint(char *errores, char * produccion){
    errorSintactico++;
    fprintf(errorsFile, "ERROR SINTACTICO, en atomo numero %d, valor %c, se eperaba alguno de estos valores: '%s' \n", cuentaSintactica - 1, cadenaAtomos[cuentaSintactica - 1], errores);
    fprintf(errorsFile, "PRODUCCIÓN -> %s\n", produccion);
}

void Program(){
    if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
        Func();
        otraFunc();
        return;
    }else{
        errorSint("bg#yx", "Program");
        return;
    }
}
//& no se ocupa, se usará como fin de cadena
void otraFunc(){
  if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
    Func();
    otraFunc();
    return;
  }else if(c == '&'){
    return;
  }else{
    errorSint("bg#yx&", "otraFunc");
    return;
  }
}

void Func(){
  if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
    Tipo();
    if(c == 'i'){
      c = cadenaAtomos[cuentaSintactica++];
      if(c == '('){
        c = cadenaAtomos[cuentaSintactica++];
        Param();
        if(c == ')'){
            c = cadenaAtomos[cuentaSintactica++];
            if(c == '{'){
                c = cadenaAtomos[cuentaSintactica++];
                Cuerpo();
                    if(c == '}'){
                    c = cadenaAtomos[cuentaSintactica++];
                    return;
                    }else{
                        errorSint("}", "Func");
                    }  
            }else{
                errorSint("{", "Func");
            }
        }else{
        errorSint(")", "Func");
      }
      }else{
        errorSint("(", "Func");
      }
    }else{
      errorSint("i", "Func");
    }

  }else{
    errorSint("bg#yx", "Func");
    return;
  }
}

void Param(){
  if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
    Tipo();
    if(c == 'i'){
      c = cadenaAtomos[cuentaSintactica++];
      otroParam();
      return;
    }else{
      errorSint("i", "Param");
    }
    return;
  }else if(c == ')'){
    return;
  }else{
    errorSint("bg#yx)", "Param");
    return;
  }
}

void otroParam(){
  if(c == ','){
    c = cadenaAtomos[cuentaSintactica++];
    Tipo();
    if(c == 'i'){
      c = cadenaAtomos[cuentaSintactica++];
      otroParam();
    }else{
      errorSint("i", "otroParam");
    }
  }else if(c == ')'){
    return;
  }else{
    errorSint(",)", "otroParam");
    return;
  }
}

void Cuerpo(){
  //c = cadenaAtomos[cuentaSintactica++];
  if( c == '}' || c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x' || c == 'i' || c == 'f' || c == 'h' || c == 'w' || c == 'j' || c == '['|| c == 'z'|| c == 'c'){
    Decl();
    listaP();
    return;
  }else{
    errorSint("}bg#yxifhwj[zc", "Cuerpo");
    return;
  }
}

void Decl(){
  if(c == 'i' || c == 'f' || c ==  'h' || c == 'w' || c == 'j' || c == '[' || c == 'z' || c == 'c' || c == '}'){
    return;
  }else if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
    D();
    Decl();
    return;
  }else{
    errorSint("ifhwj[zc}bg#yx", "Decl");
    return;
  }
}

void D(){
  if(c == 'b' || c == 'g' || c == '#' || c == 'y' || c == 'x'){
    Tipo();
    K();
    if(c == ';'){
      c = cadenaAtomos[cuentaSintactica++];
      return;
    }else{
      errorSint(";", "D");
    }
  }else{
    errorSint("bg#yx", "D");
    return;
  }
}

void Tipo(){
  if(c == 'b'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == 'g'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == '#'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == 'y'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == 'x'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else{
    errorSint("bg#yx", "Tipo");
    return;
  }
}

void K(){
  if(c == 'i'){
    c = cadenaAtomos[cuentaSintactica++];
    Q();
    return;
  }else{
    errorSint("i", "K");
    return;
  }
}

void Q(){
  if( c == ';'){
    return;
  }else if( c == '='){
    c = cadenaAtomos[cuentaSintactica++];
    N();
    C();
    return;
  }else if(c == ','){
    c = cadenaAtomos[cuentaSintactica++];
    K();
    return;
  }else{
    errorSint(";=,", "Q");
    return;
  }
}

void N(){
  if(c == 'n'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == 'r'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == 's'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else{
    errorSint("nrs", "N");
    return;
  }
}

void C(){
  if(c == ';'){
    return;
  }else if(c == ','){
    c = cadenaAtomos[cuentaSintactica++];
    K();
    return;
  }else{
    errorSint(";,", "C");
    return;
  }
}

void A(){
  if(c == 'i'){
    c = cadenaAtomos[cuentaSintactica++];
    if(c == '='){
      c = cadenaAtomos[cuentaSintactica++];
      AP();
      if(c == ';'){
        c = cadenaAtomos[cuentaSintactica++];
        return;
      }else{
        errorSint(";", "A");
      }
    }else{
      errorSint("=", "A");
      return;
    }
  }else{
    errorSint("i", "A");
    return;                        
  }
}


void AP(){
  if(c == 's'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == '(' || c == 'i' || c == 'n' || c == 'r' || c == '['){
      E();
      return;
  }else{
    errorSint("s(inr[", "AP");
    return;
  }
}

void E(){
    if(c=='('||c=='i'||c=='n'||c=='r'||c=='['){
        T();
        EP();
        return;
    }else{
      errorSint("(inr[", "E");
    }
}

void EP(){
  if(c=='+' || c=='-'){
    c = cadenaAtomos[cuentaSintactica++];
    T();
    EP();
  }else if(c==';' || c==')'){
    return;
  }else{
      errorSint("+-;)", "EP");
  }
  return;
}

void T(){
    if(c=='('||c=='i'||c=='n'||c=='r'||c=='['){
      F();
      TP();
      return;
    }else{
       errorSint("(inr[", "T");
    }
     return;
}


void TP(){
    if(c == '*'|| c == '/'||c == '\\'||c == '%'||c == '^'){
        c = cadenaAtomos[cuentaSintactica++];
        F();
        TP();
    }else if(c == ';'|| c == ')'|| c == '+'||c == '-'){
        return;
    }else{
      errorSint("%*/\\^;)+-", "TP");
    }
}


void F(){
  if(c=='('){
    c = cadenaAtomos[cuentaSintactica++];
    E();
    if(c==')'){
      c = cadenaAtomos[cuentaSintactica++];
      return;
    }else{
      errorSint(")", "F");
    }
    return;
  }else if(c=='i'||c=='n'||c=='r'){
    c = cadenaAtomos[cuentaSintactica++];
    return;
  }else if(c == '['){
    Llama();
    return;
  }else{
    errorSint("(inr[(", "F");
  }
  return;
}

void R(){
  if(c =='i'){
    c = cadenaAtomos[cuentaSintactica++];
    RP();
    V();
    return;
  }else if(c == 'n'){
    c = cadenaAtomos[cuentaSintactica++];
    RP();
    VP();
    return;
  }else if(c=='r'){
    c = cadenaAtomos[cuentaSintactica++];
    RP();
    VPP();
    return;
  }else if(c=='s'){
    c = cadenaAtomos[cuentaSintactica++];
    RP();
    VPPP();
    return;
  }else{
    errorSint("inrs", "R");
    return;
  }
    return;
}

void RP(){
    if(c=='>'||c=='<'||c=='l'||c=='e'||c=='d'||c=='u'){
        c = cadenaAtomos[cuentaSintactica++];
        return;
    }else{
        errorSint("><ledu", "RP");
    }
    return;
}

void V(){
  if( c == 'i' || c == 'n' || c == 'r' || c == 's')
    c = cadenaAtomos[cuentaSintactica++];
  else 
    errorSint("inrs", "V");
  return; 
}

void VP(){
  if ( c == 'n' || c == 'i')
    c = cadenaAtomos[cuentaSintactica++]; 
  else 
    errorSint("ni", "VP"); 
  return; 
}

void VPP(){
  if ( c == 'r' || c == 'i' )
    c = cadenaAtomos[cuentaSintactica++]; 
  else 
    errorSint("ri", "VPP"); 
  return; 
}

void VPPP(){
  if (c == 's' || c == 'i' )
    c = cadenaAtomos[cuentaSintactica++]; 
  else 
    errorSint("si", "VPPP"); 
  return; 
}

void P(){
  if (c == 'i')
    A(); 
  else if (c == 'f')
    I(); 
  else if (c == 'h')
    H(); 
  else if (c == 'w')
    W(); 
  else if (c == 'j')
    J(); 
  else if (c == '[')
    Llama(); 
  else if (c == 'z')
    Devuelve();
  else if (c == 'c'){
    c = cadenaAtomos[cuentaSintactica++];  
    if(c == ';'){
      c = cadenaAtomos[cuentaSintactica++];  
    }else{
      errorSint(";","P");    
    }
  }else 
    errorSint("ifhwj[zc", "P"); 
  return; 
}

void listaP(){
  if ( c == '}' || c == ':' || c == 't' || c == 'q' || c == 'a' || c == 'o' ) //+FDC
    return; 
  else if (c == 'i' || c == 'f' || c == 'h' || c == 'w' || c == 'j' || c == '[' || c == 'z' || c == 'c'){
    P(); 
    listaP(); 
  }else 
    errorSint("}:tqaoifhwj[zc", "listaP"); 
  return;
}

void W(){
  if (c == 'w'){
    c = cadenaAtomos[cuentaSintactica++]; 
    if (c == '('){
      c = cadenaAtomos[cuentaSintactica++];
      R(); 
      if (c == ')'){
        c = cadenaAtomos[cuentaSintactica++];
        if (c == 'm'){
          c = cadenaAtomos[cuentaSintactica++];
          if ( c == '{'){
            c = cadenaAtomos[cuentaSintactica++];
            listaP(); 
            if (c == '}')
              c = cadenaAtomos[cuentaSintactica++]; 
            else 
              errorSint("}", "W");
          } else 
            errorSint("{", "W");
        } else 
          errorSint("m", "W"); 
      } else 
        errorSint(")", "W");
    } else 
      errorSint("(", "W");
  } else 
    errorSint("w", "W"); 
  return; 
}

void I(){
  if (c == 'f'){
    c = cadenaAtomos[cuentaSintactica++];
    if (c == '('){
      c = cadenaAtomos[cuentaSintactica++]; 
      R(); 
      if (c == ')'){
        c = cadenaAtomos[cuentaSintactica++];
        listaP(); 
        IP(); 
        if (c == ':')
          c = cadenaAtomos[cuentaSintactica++]; 
        else 
          errorSint(":", "I");  
      } else 
        errorSint(")", "I"); 
    } else 
      errorSint("(", "I"); 
  } else 
    errorSint("f", "I"); 

  return; 
}

void IP(){
  if (c == 't'){
    c = cadenaAtomos[cuentaSintactica++]; 
    listaP(); 
  } else if (c == ':')
    return; 
  else 
    errorSint(":t", "IP"); 
  return; 
}

void J(){
  if (c == 'j'){
    c = cadenaAtomos[cuentaSintactica++]; 
    if (c == '('){
      c = cadenaAtomos[cuentaSintactica++]; 
      Y(); 
      X(); 
      Z(); 
      if (c == '{'){
        c = cadenaAtomos[cuentaSintactica++]; 
        listaP(); 
        if (c == '}')
          c = cadenaAtomos[cuentaSintactica++]; 
        else 
          errorSint("}", "J"); 
      } else  
        errorSint("{", "J"); 
    } else 
      errorSint("(", "J"); 
  } else 
    errorSint("j", "J"); 
  return; 
}

void Y(){
  if (c == 'i'){
    c = cadenaAtomos[cuentaSintactica++];
    if (c == '='){
      c = cadenaAtomos[cuentaSintactica++]; 
      E(); 
      if (c == ';')
        c = cadenaAtomos[cuentaSintactica++]; 
      else 
        errorSint(";", "Y"); 
    } else
      errorSint("=", "Y");
  } else if (c == ';')
    c = cadenaAtomos[cuentaSintactica++]; 
  else 
    errorSint("i;", "Y"); 
  return; 
}

void X(){
  if ( c == 'i' || c == 'n' || c == 'r' || c == 's'){
    R(); 
    if (c == ';')
      c = cadenaAtomos[cuentaSintactica++];
    else 
      errorSint(";", "X"); 
  } else if (c == ';')
    c = cadenaAtomos[cuentaSintactica++]; 
  else 
    errorSint("inrs;", "X"); 
  return; 
}

void Z(){
  if (c == 'i'){
    c = cadenaAtomos[cuentaSintactica++]; 
    if (c == '='){
      c = cadenaAtomos[cuentaSintactica++]; 
      E(); 
      if (c == ')')
        c = cadenaAtomos[cuentaSintactica++];
      else 
        errorSint(")", "Z"); 
    } else 
      errorSint("=", "Z"); 
  } else if (c == ')')
    c = cadenaAtomos[cuentaSintactica++]; 
  else 
    errorSint("i)", "Z"); 
  return; 
}

void H(){
  if (c == 'h'){
    c = cadenaAtomos[cuentaSintactica++]; 
    if (c == '('){
      c = cadenaAtomos[cuentaSintactica++]; 
      if (c == 'i'){
        c = cadenaAtomos[cuentaSintactica++]; 
        if (c == ')'){
          c = cadenaAtomos[cuentaSintactica++]; 
          if (c == '{'){
            c = cadenaAtomos[cuentaSintactica++]; 
            CP(); 
            OP(); 
            if (c == '}')
              c = cadenaAtomos[cuentaSintactica++]; 
            else 
              errorSint("}", "H"); 
          } else 
            errorSint("{", "H"); 
        } else 
          errorSint(")", "H"); 
      } else 
        errorSint("i", "H"); 
    } else 
      errorSint("(", "H"); 
  } else 
    errorSint("h", "H");
  return; 
}

void CP(){
  if (c == 'a'){
    c = cadenaAtomos[cuentaSintactica++]; 
    if (c == 'n'){
      c = cadenaAtomos[cuentaSintactica++]; 
      if (c == ':'){
        c = cadenaAtomos[cuentaSintactica++]; 
        listaP(); 
        U(); 
        CP(); 
      } else 
        errorSint(":", "CP"); 
    } else 
      errorSint("n", "CP"); 
  } else if (c == 'o' || c == '}')
    return; 
  else 
    errorSint("ao}", "CP"); 
  return; 
}

void OP(){
  if (c == 'o'){
    c = cadenaAtomos[cuentaSintactica++]; 
    if (c == ':'){
      c = cadenaAtomos[cuentaSintactica++]; 
      listaP(); 
    } else 
      errorSint(":", "OP"); 
  } else if (c == '}')
    return; 
  else 
    errorSint("o}", "OP"); 
  return; 
}

void U(){
  if (c == 'q')
    c = cadenaAtomos[cuentaSintactica++]; 
  else if ( c == 'a' || c == 'o' || c == '}') //+FDC
    return; 
  else 
    errorSint("qao}", "U"); 
  return; 
}

void Devuelve(){
  if ( c == 'z'){
    c = cadenaAtomos[cuentaSintactica++];
    if (c == '('){
      c = cadenaAtomos[cuentaSintactica++];
      valor();
      if (c == ')'){
        c = cadenaAtomos[cuentaSintactica++];
        if (c == ';')
          c = cadenaAtomos[cuentaSintactica++];
        else 
          errorSint(";", "Devuelve");
      } else 
        errorSint(")", "Devuelve");
    } else
      errorSint("(", "Devuelve");
  } else
    errorSint("z", "Devuelve"); 
  return; 
}

void valor(){
  if (c == 'i' || c == 'n' || c == 'r' || c == 's')
    V(); 
  else if (c == ')')
    return; 
  else 
    errorSint("inrs)", "valor"); 
  return; 
}

void Llama(){
  if (c == '['){
    c = cadenaAtomos[cuentaSintactica++]; 
    if (c == 'i'){
      c = cadenaAtomos[cuentaSintactica++]; 
      if ( c == '('){
        c = cadenaAtomos[cuentaSintactica++]; 
        arg(); 
        if (c == ')'){
          c = cadenaAtomos[cuentaSintactica++]; 
          if (c == ']')
            c = cadenaAtomos[cuentaSintactica++]; 
          else 
            errorSint("]", "Llama"); 
        } else
          errorSint(")", "Llama"); 
      } else 
        errorSint("(", "Llama"); 
    } else 
      errorSint("i", "Llama");
  } else  
    errorSint("[", "Llama"); 
  return;
}

void arg(){
  if (c == ')')
    return; 
  else if (c == 'i' || c == 'n' || c == 'r' || c == 's'){
    V(); 
    otroArg(); 
  } else
    errorSint(")inrs", "arg"); 
  return; 
}

void otroArg(){
  if ( c == ','){
    c = cadenaAtomos[cuentaSintactica++]; 
    V(); 
    otroArg(); 
  } else if (c == ')') // +FDC
    return; 
  else 
    errorSint(",)", "otroArg"); 
  return;
}
