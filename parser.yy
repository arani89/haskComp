%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "defs.h"
#include "map_lib.h"
#include "misc.h"

#define MAX 100

typedef struct
{	
	void *dataPtr;	
	struct node *next;
}node;

map_symTab *symTab;
map_data *dataTab;
dataTypeEntry dataList[MAX];

int loop;
float floop;
int yylex(void);
void yyerror(char *);
void * append(node *sPtr,node *n);
%}


%union {
	exprValue value;
	char *svalue;
	multiValue mv;
	}


%token <value> FLOAT
%token <value> INTEGER
%token <value> BOOL
%token <value> CHAR
%token <svalue> VARIABLE


%type <value> expr
/*%type <mv> bseq
%type <mv> blist
%type <mv> fseq
%type <mv> flist
%type <mv> list
*/

%left '-' '+'
%left '*' '/' '%'
%right '^'
%nonassoc UMINUS
%left LOGIC_AND LOGIC_OR LOGIC_NOT
%left EQ LT GT LE GE

%%

program:
| 	program expr '\n'	{
							int dataNo;
							dataNo = map_data_get(dataTab, $2.dataType);
							if (dataNo == -1)
							{
								printf("\nIncorrect data Type");
							}
							else if (strcmp($2.dataType, "Int") == 0)
							{
								printf("%d\n", *(int *)$2.dataPtr);
							}
							else if (strcmp($2.dataType, "Float") == 0)
							{
								printf("%f\n", *(float *)$2.dataPtr);
							}
							else if (strcmp($2.dataType, "Char") == 0)
							{
								printf("'%c'\n", *(char *)$2.dataPtr);
							}
							else if (strcmp($2.dataType, "Bool") == 0)
							{
								if (*(int *)$2.dataPtr)
									printf("True\n");
								else
									printf("False\n");
							}
							else
							{
								printf("Custom data Type, cannot print value");
							}
						}
							
|	program error '\n'	{	}
|	program assign '\n' {	}
|	program '\n'            ;
;

assign:
	  VARIABLE '=' expr	{
	  						symTabEntry *newEntry = NULL;
							int dataId = map_data_get(dataTab, $3.dataType);
							newEntry = malloc(sizeof(symTabEntry));
							newEntry->name = malloc(strlen($1));
							strcpy(newEntry->name, $1);
							newEntry->dataPtr = $3.dataPtr;
							strcpy(newEntry->dataType, $3.dataType);
							map_symTab_set(symTab, $1, newEntry);
	  					}
expr:
 INTEGER			{   int dataId = map_data_get(dataTab, "Int");
						$$.dataPtr = malloc(dataList[dataId].size);
						strcpy($$.dataType, "Int");
						*(int *)$$.dataPtr = *(int *)$1.dataPtr;
						printf("Rule 1\n");
					}
| FLOAT				{ 	int dataId = map_data_get(dataTab, "Float");
						$$.dataPtr = malloc(dataList[dataId].size);
						strcpy($$.dataType, "Float");
						*(float *)$$.dataPtr = *(float *)$1.dataPtr;
						printf("Rule 2\n");
					}
| BOOL				{	int dataId = map_data_get(dataTab, "Bool");
						$$.dataPtr = malloc(dataList[dataId].size);
						strcpy($$.dataType, "Bool");
						*(int *)$$.dataPtr = *(int *)$1.dataPtr;
						printf("Rule 3\n");
					}
| VARIABLE			{
						symTabEntry *entry = NULL;
						entry = map_symTab_get(symTab, $1);
						$$.dataPtr = entry->dataPtr;
						strcpy($$.dataType, entry->dataType);
					}
| CHAR				{
						int dataId = map_data_get(dataTab, "Char");
						$$.dataPtr = malloc(dataList[dataId].size);
						strcpy($$.dataType, "Char");
						*(char *)$$.dataPtr = *(char *)$1.dataPtr;
					}

| expr '+' expr		{
						float val1, val2;
						printf("Rule 4\n");
						int id1, id2, intId;
						intId = map_data_get(dataTab, "Int");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if (id1 == intId && id2 == intId)
						{
							strcpy($$.dataType, "Int");
							$$.dataPtr= malloc(sizeof(int));
							*(int *)$$.dataPtr = val1 + val2;
						}
						else
						{
							strcpy($$.dataType, "Float");
							$$.dataPtr = malloc(sizeof(float));
							*(float *)$$.dataPtr = val1 + val2;
						}
					}
					
| expr '-' expr		{
						float val1, val2;
						printf("Rule 5\n");
						int id1, id2, intId;
						intId = map_data_get(dataTab, "Int");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if (id1 == intId && id2 == intId)
						{
							strcpy($$.dataType, "Int");
							$$.dataPtr= malloc(sizeof(int));
							*(int *)$$.dataPtr = val1 - val2;
						}
						else
						{
							strcpy($$.dataType, "Float");
							$$.dataPtr = malloc(sizeof(float));
							*(float *)$$.dataPtr = val1 - val2;
						}
					}

| expr '*' expr		{
						float val1, val2;
						printf("\nRule 6\n");
						int id1, id2, intId;
						intId = map_data_get(dataTab, "Int");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if (id1 == intId && id2 == intId)
						{
							strcpy($$.dataType, "Int");
							$$.dataPtr= malloc(sizeof(int));
							*(int *)$$.dataPtr = val1 * val2;
						}
						else
						{
							strcpy($$.dataType, "Float");
							$$.dataPtr = malloc(sizeof(float));
							*(float *)$$.dataPtr = val1 * val2;
						}
					}

| expr '*' '*' expr		{
						float val1, val2;
						printf("\nRule 7\n");
						int id1, id2;
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($4), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						strcpy($$.dataType, "Float");
						$$.dataPtr = malloc(sizeof(float));
						*(float *)$$.dataPtr = pow(val1, val2);
					}

| expr '^' expr		{
						float val1, val2;
						printf("Rule 8\n");
						int id1, id2, intId;
						intId = map_data_get(dataTab, "Int");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if (id1 == intId && id2 == intId)
						{
							strcpy($$.dataType, "Int");
							$$.dataPtr= malloc(sizeof(int));
							*(int *)$$.dataPtr = pow(val1, val2);
						}
						else
						{
							strcpy($$.dataType, "Float");
							$$.dataPtr = malloc(sizeof(float));
							*(float *)$$.dataPtr = pow(val1, val2);
						}
					}

| expr '/' expr		{
						float val1, val2;
						printf("Rule 9\n");
						int id1, id2, intId;
						intId = map_data_get(dataTab, "Int");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if (id1 == intId && id2 == intId && val2 != 0)
						{
							strcpy($$.dataType, "Int");
							$$.dataPtr= malloc(sizeof(int));
							*(int *)$$.dataPtr = val1 / val2;
						}
						else
						{
							strcpy($$.dataType, "Float");
							$$.dataPtr = malloc(sizeof(float));
							*(float *)$$.dataPtr = val1 / val2;
						}
					}

| expr GT expr		{
						float val1, val2;
						printf("Rule 10\n");
						int id1, id2, intId, floatId;
						intId = map_data_get(dataTab, "Int");
						floatId = map_data_get(dataTab, "Float");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if ((id1 == intId || id1 == floatId) && 
								(id2 == intId || id2 == floatId))
						{
							strcpy($$.dataType, "Bool");
							$$.dataPtr= malloc(1);
							*(int *)$$.dataPtr = val1 > val2;
						}
					}

| expr LT expr		{
						float val1, val2;
						printf("Rule 11\n");
						int id1, id2, intId, floatId;
						intId = map_data_get(dataTab, "Int");
						floatId = map_data_get(dataTab, "Float");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if ((id1 == intId || id1 == floatId) && 
								(id2 == intId || id2 == floatId))
						{
							strcpy($$.dataType, "Bool");
							$$.dataPtr= malloc(1);
							*(int *)$$.dataPtr = val1 < val2;
						}
					}
					
| expr GE expr		{
						float val1, val2;
						printf("Rule 12\n");
						int id1, id2, intId, floatId;
						intId = map_data_get(dataTab, "Int");
						floatId = map_data_get(dataTab, "Float");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if ((id1 == intId || id1 == floatId) && 
								(id2 == intId || id2 == floatId))
						{
							strcpy($$.dataType, "Bool");
							$$.dataPtr= malloc(1);
							*(int *)$$.dataPtr = val1 >= val2;
						}
					}
| expr LE expr		{
						printf("Rule 13\n");
						float val1, val2;
						int id1, id2, intId, floatId;
						intId = map_data_get(dataTab, "Int");
						floatId = map_data_get(dataTab, "Float");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if ((id1 == intId || id1 == floatId) && 
								(id2 == intId || id2 == floatId))
						{
							strcpy($$.dataType, "Bool");
							$$.dataPtr= malloc(1);
							*(int *)$$.dataPtr = val1 <= val2;
						}
					}
| expr EQ expr		{
						printf("Rule 14\n");
						float val1, val2;
						int id1, id2, intId, floatId;
						intId = map_data_get(dataTab, "Int");
						floatId = map_data_get(dataTab, "Float");
						id1 = getNoId(&($1), dataTab, &val1);
						if (id1 == -1)
							YYERROR;
						id2 = getNoId(&($3), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if ((id1 == intId || id1 == floatId) && 
								(id2 == intId || id2 == floatId))
						{
							strcpy($$.dataType, "Bool");
							$$.dataPtr= malloc(1);
							*(int *)$$.dataPtr = val1 == val2;
						}
						else
							YYERROR;
					}
							
| expr LOGIC_AND expr	{
							printf("Rule 15\n");
							int id1, id2, boolId;
							int val1, val2;
							boolId = map_data_get(dataTab, "Bool");
							id1 = getBoolId(&($1), dataTab, &val1);
							fprintf(stderr, "%d %d %d", id1, val1, *(int *)$$.dataPtr);
							if (id1 == -1)
								YYERROR;
							id2 = getBoolId(&($3), dataTab, &val2);
							if (id2 == -1)
								YYERROR;
							if (id1 == boolId && id2 == boolId)
							{
								strcpy($$.dataType, "Bool");
								$$.dataPtr = malloc(1);
								*(int *)$$.dataPtr = val1 && val2;
							}
							else
								YYERROR;
						}
| expr LOGIC_OR expr	{
							printf("Rule 16\n");
							int id1, id2, boolId;
							int val1, val2;
							boolId = map_data_get(dataTab, "Bool");
							id1 = getBoolId(&($1), dataTab, &val1);
							if (id1 == -1)
								YYERROR;
							id2 = getBoolId(&($3), dataTab, &val2);
							if (id2 == -1)
								YYERROR;
							if (id1 == boolId && id2 == boolId)
							{
								strcpy($$.dataType, "Bool");
								$$.dataPtr = malloc(1);
								*(int *)$$.dataPtr = val1 || val2;
							}
							else
								YYERROR;
						}

| LOGIC_NOT expr 	{
						printf("Rule 17\n");
						int id2, boolId;
						int val2;
						boolId = map_data_get(dataTab, "Bool");
						id2 = getBoolId(&($2), dataTab, &val2);
						if (id2 == -1)
							YYERROR;
						if (id2 == boolId)
						{
							strcpy($$.dataType, "Bool");
							$$.dataPtr = malloc(1);
							*(int *)$$.dataPtr = !(int)val2;
						}
						else
							YYERROR;
					}

					
%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

void init_dataType()
{
	dataTab = map_data_create();
	symTab = map_symTab_create();
	
	dataList[0].size = sizeof(int);
	dataList[1].size = sizeof(float);
	dataList[2].size = sizeof(char);
	dataList[3].size = 1;

	map_data_set(dataTab, "Int", 0);
	map_data_set(dataTab, "Float", 1);
	map_data_set(dataTab, "Char", 2);
	map_data_set(dataTab, "Bool", 3);
}

int main(void) {
	
	
	init_dataType();
	yyparse();
	return 0;
}
