%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "defs.h"
#include "map_lib.h"

map_symTab *symTab;
map_data *dataTab;

int yylex(void);
void yyerror(char *);

%}


%union {
	intValue ivalue;
	floatValue fvalue;
	boolValue bvalue;
	char cvalue;
	char *svalue;
	}

%token <fvalue> FLOAT
%token <ivalue> INTEGER
%token <bvalue> BOOL
%token <svalue> VARIABLE
%token <cvalue> CHAR

%type <ivalue> iexpr
%type <fvalue> fexpr
%type <fvalue> nexpr
%type <bvalue> bexpr
%type <cvalue> cexpr

%left '-' '+'
%left '*' '/' '%'
%right '^'
%left LOGIC_AND LOGIC_OR LOGIC_NOT
%nonassoc UMINUS

%%

program:
	program bexpr '\n'	{
					 		if ($2.value == 1)
						 		printf("True\n");
					 		else
						 		printf("False\n");
	   					}
|	program fexpr '\n'	{	printf("%f", $2.value);	}
|	program iexpr '\n'	{	printf("%d", $2.value);	}
|	program cexpr '\n'	{	printf("%c", $2);	}
|	program assign '\n'	{	}
|	program VARIABLE '\n'	{	symTabEntry *entry = map_symTab_get(symTab, $2);
							if (entry == NULL)
							{
								printf("\nUnrecognized variable");
							}
							else if (strcmp(entry->dataType, "Int") == 0)
							{
								printf("%d\n", *(int *)entry->dataPtr);
							}
							else if (strcmp(entry->dataType, "Float") == 0)
							{
								printf("%f\n", *(float *)entry->dataPtr);
							}
							else if (strcmp(entry->dataType, "Bool") == 0)
							{
								switch (*(int *)entry->dataPtr)
								{
									case 1:
									printf("True\n");
									break;
									case 0:
									printf("False\n");
								}
							}
							else if (strcmp(entry->dataType, "Char") == 0)
							{
								printf("%c\n", *(char *)entry->dataPtr);
							}
							else	
							{
								printf("Unrecognized data type\n");
							}
						 }
|	program '\n'            ;
|
;

assign:
	VARIABLE '=' iexpr	{
							symTabEntry *newVarEntry = malloc(sizeof(symTabEntry));
							newVarEntry->name = $1;
							int *temp = NULL;
							temp = malloc(sizeof(int));
							*temp = $3.value;
							newVarEntry->dataPtr = temp;
							strcpy(newVarEntry->dataType, "Int");
							map_symTab_set(symTab, newVarEntry->name, newVarEntry);
						}
|	VARIABLE '=' fexpr	{
							symTabEntry *newVarEntry = malloc(sizeof(symTabEntry));
							newVarEntry->name = $1;
							float *temp = NULL;
							temp = malloc(sizeof(float));
							*temp = $3.value;
							newVarEntry->dataPtr = temp;
							strcpy(newVarEntry->dataType, "Float");
							map_symTab_set(symTab, newVarEntry->name, newVarEntry);
						}
|	VARIABLE '=' bexpr	{
							symTabEntry *newVarEntry = malloc(sizeof(symTabEntry));
							newVarEntry->name = $1;
							char *temp = NULL;
							temp = malloc(1);
							*temp = $3.value;
							newVarEntry->dataPtr = temp;
							strcpy(newVarEntry->dataType, "Bool");
							map_symTab_set(symTab, newVarEntry->name, newVarEntry);
						}
|	VARIABLE '=' cexpr	{
							symTabEntry *newVarEntry = malloc(sizeof(symTabEntry));
							newVarEntry->name = $1;
							char *temp = NULL;
							temp = malloc(1);
							*temp = $3;
							newVarEntry->dataPtr = temp;
							strcpy(newVarEntry->dataType, "Char");
							map_symTab_set(symTab, newVarEntry->name, newVarEntry);
						}
nexpr:
     iexpr		{ $$.value = (float)$1.value; }
| fexpr			{ $$.value = $1.value;	}

iexpr:
     INTEGER
| iexpr '+' iexpr		{ $$.value = $1.value + $3.value; }
| iexpr '-' iexpr		{ $$.value = $1.value - $3.value; }
| iexpr '*' iexpr     	{ $$.value = $1.value * $3.value; }
| iexpr '/' iexpr     	{ $$.value = $1.value / $3.value; }
| '(' iexpr ')'	    	{ $$.value = $2.value; }
| iexpr '^' iexpr 	{ $$.value = pow($1.value, $3.value); }
| '-' iexpr %prec UMINUS	{ $$.value = -$2.value; }

fexpr:
     FLOAT
| nexpr '+' nexpr		{ $$.value = $1.value + $3.value; }
| nexpr '-' nexpr		{ $$.value = $1.value - $3.value; }
| nexpr '*' nexpr     	{ $$.value = $1.value * $3.value; }
| nexpr '/' nexpr     	{ $$.value = $1.value / $3.value; }
| '(' fexpr ')'	    	{ $$.value = $2.value; }
| nexpr '^' nexpr 	{ $$.value = pow($1.value, $3.value); }
| '-' fexpr %prec UMINUS	{ $$.value = -$2.value; }
/*Last 4 rules ought to be redundant; but are not (reasons unclear).
Try to fix */
| iexpr '+' nexpr	{ $$.value = $1.value + $3.value; }
| iexpr '-' nexpr	{ $$.value = $1.value - $3.value; }
| iexpr '*' nexpr	{ $$.value = $1.value * $3.value; }
| iexpr '/' nexpr	{ $$.value = $1.value / $3.value; }

bexpr:
     BOOL
| '(' bexpr ')'			{ $$.value = $2.value; }
| nexpr '>' nexpr		{ $$.value = $1.value > $3.value ? 1 : 0; }
| nexpr '<' nexpr		{ $$.value = $1.value < $3.value ? 1 : 0; }
| nexpr '=' '=' nexpr 	{ $$.value = $1.value == $4.value ? 1 : 0; }
| nexpr '>' '=' nexpr	{ $$.value = $1.value >= $4.value ? 1 : 0; }
| nexpr '<' '=' nexpr	{ $$.value = $1.value <= $4.value ? 1 : 0; }
| bexpr LOGIC_AND bexpr { $$.value = $1.value && $3.value; }
| bexpr LOGIC_OR bexpr	{ $$.value = $1.value || $3.value; }
| LOGIC_NOT bexpr	{ $$.value = $2.value ? 0 : 1; }

cexpr:
     CHAR			{ $$ = $1; }
/*expr:
	iexpr         
|	fexpr
|	bexpr
;
*/
%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

void init_dataType()
{
	dataTab = map_data_create();
	symTab = map_symTab_create();

	map_data_set(dataTab, "Int", 4);
	map_data_set(dataTab, "Float", 8);
	map_data_set(dataTab, "Char", 1);
	map_data_set(dataTab, "Bool", 1);
}
int main(void) {
	init_dataType();
	yyparse();
	return 0;
}
