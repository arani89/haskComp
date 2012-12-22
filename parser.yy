%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "defs.h"
#include "map_lib.h"


typedef struct
{	
	void *dataPtr;	
	struct node *next;
}node;

map_symTab *symTab;
map_data *dataTab;
int loop;
float floop;
int yylex(void);
void yyerror(char *);
void * append(node *sPtr,node *n);

%}


%union {
	intValue ivalue;
	floatValue fvalue;
	boolValue bvalue;
	char cvalue;
	char *svalue;
	multiValue mv;
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
%type <mv> bseq
%type <mv> blist
%type <mv> fseq
%type <mv> flist
%type <mv> list


%left '-' '+'
%left '*' '/' '%'
%right '^'
%left LOGIC_AND LOGIC_OR LOGIC_NOT
%nonassoc UMINUS

%%

program:
      program list '\n'   	{
						printList((node *)$2.start,$2.fflag);
					}
|	program VARIABLE '=' list '\n'	{				
									symTabEntry *newVarEntry = malloc(sizeof(symTabEntry));
									newVarEntry->name = $2;
									newVarEntry->dataPtr = $4.start;
									newVarEntry->isList = 1;
									if($4.fflag == 0)								
										strcpy(newVarEntry->dataType, "Int");
									else if($4.fflag == 1)
										strcpy(newVarEntry->dataType, "Float");
									else if($4.fflag == 2)
										strcpy(newVarEntry->dataType, "Bool");
									else if($4.fflag == -1)
										strcpy(newVarEntry->dataType, "Null");							
									map_symTab_set(symTab, newVarEntry->name, newVarEntry);			
							}
|	program bexpr '\n'	{
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
								if(entry->isList == 1)
									printList((node *)entry->dataPtr,0);
								else
									printf("%d\n", *(int *)entry->dataPtr);
							}
							else if (strcmp(entry->dataType, "Float") == 0)
							{
								if(entry->isList == 1)
									printList((node *)entry->dataPtr,1);
								else
									printf("%f\n", *(float *)entry->dataPtr);
							}
							else if (strcmp(entry->dataType, "Bool") == 0)
							{
								if(entry->isList == 1)
									printList((node *)entry->dataPtr,2);
								else
								{	switch (*(int *)entry->dataPtr)
									{
										case 1:
										printf("True\n");
										break;
										case 0:
										printf("False\n");
									}
								}
							}
							else if (strcmp(entry->dataType, "Char") == 0)
							{
								printf("%c\n", *(char *)entry->dataPtr);
							}
							else if (strcmp(entry->dataType, "Null") == 0)
							{
								printList((node *)entry->dataPtr,-1);
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

	
list :
	'[' ']' 				{	$$.start = NULL;
							$$.fflag = -1;
						}
	| flist 				{
							$$.start = $1.start;
							$$.fflag = $1.fflag;
							$$.noOfItems = $1.noOfItems;
						}
	| blist 				{
							$$.start = $1.start;
							$$.fflag = $1.fflag;
							$$.noOfItems = $1.noOfItems;
						}
;


flist :
	'[' fseq ']' 			{
							$$.start = $2.start;
							$$.fflag = $2.fflag;
							$$.noOfItems = $2.noOfItems;
						}
	| '[' nexpr '.' '.' nexpr ']' {	printf("[");
							if($2.value <= $5.value)
							{
								for(floop=$2.value; floop <$5.value-1; floop++)
									printf("%f,",floop);
								printf("%f",floop);
							}
							printf("]");	
						}
	| '[' nexpr '.' '.' ']' {		printf("[");
							for(floop=$2.value; ; floop++)
								printf("%f,",floop);
					}
	| flist '+' '+' flist		{
							$$.noOfItems = $1.noOfItems + $4.noOfItems;
							$$.fflag = $1.fflag || $4.fflag;
							$$.start = append((node *)$1.start,(node *)$4.start);
						}
	| VARIABLE				{	symTabEntry *entry = map_symTab_get(symTab, $1);
							if (entry == NULL)
							{
								printf("\nUnrecognized variable\n");
								exit(0);
							}
							else if(entry->isList != 1)
							{
								printf("\nInvalid format\n");
								exit(0);
							}
							else if (strcmp(entry->dataType, "Int") == 0)
							{
								$$.fflag = 0;

							}
							else if (strcmp(entry->dataType, "Float") == 0)
							{
								$$.fflag = 1;
							}
							else 
							{
								printf("\nInvalid type\n");
								exit(0);
							}
							$$.noOfItems = 1;
							$$.start = entry->dataPtr;
						 }
;

fseq :
	INTEGER 				{	node *n = malloc(sizeof(node));
							float *temp = NULL;
							temp = malloc(1);
							*temp = $1.value;
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = 1;
							$$.start = n;
							$$.fflag = 0;
						}
	| fseq ',' INTEGER 		{	node *n = malloc(sizeof(node));
							float *temp = NULL;
							temp = malloc(1);
							*temp = $3.value;
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = $1.noOfItems + 1;
							$$.start = append((node *)$1.start,n);
							$$.fflag = $1.fflag*1;
//							printList((node *)$$.start,1);

						}
	| VARIABLE 				{	symTabEntry *entry = map_symTab_get(symTab, $1);
							node *n = malloc(sizeof(node));
							float *temp = NULL;
							temp = malloc(1);
							if (entry == NULL)
							{
								printf("\nUnrecognized variable\n");
								exit(0);
							}
							else if(entry->isList == 1)
							{
								printf("\nInvalid format\n");
								exit(0);
							}
							else if (strcmp(entry->dataType, "Int") == 0)
							{
								*temp = *(int *)entry->dataPtr;
								$$.fflag = 0;

							}
							else if (strcmp(entry->dataType, "Float") == 0)
							{
								*temp = *(float *)entry->dataPtr;
								$$.fflag = 1;
							}
							else 
							{
								printf("\nInvalid type\n");
								exit(0);
							}
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = 1;
							$$.start = n;

						 }
	| fseq ',' VARIABLE 		{	symTabEntry *entry = map_symTab_get(symTab, $3);
							node *n = malloc(sizeof(node));
							float *temp = NULL;
							temp = malloc(1);
							if (entry == NULL)
							{
								printf("\nUnrecognized variable\n");
								exit(0);
							}
							else if(entry->isList == 1)
							{
								printf("\nInvalid format\n");
								exit(0);
							}
							else if (strcmp(entry->dataType, "Int") == 0)
							{
								*temp = *(int *)entry->dataPtr;
								$$.fflag = $1.fflag*1;

							}
							else if (strcmp(entry->dataType, "Float") == 0)
							{
								*temp = *(float *)entry->dataPtr;
								$$.fflag = 1;
							}
							else 
							{
								printf("\nInvalid type\n");
								exit(0);
							}
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = $1.noOfItems + 1;
							$$.start = append((node *)$1.start,n);
						 }
	| FLOAT 				{	node *n = malloc(sizeof(node));
							float *temp = NULL;
							temp = malloc(1);
							*temp = $1.value;
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = 1;
							$$.start = n;
							$$.fflag = 1;
						}
	| fseq ',' FLOAT 			{	node *n = malloc(sizeof(node));
							float *temp = NULL;
							temp = malloc(1);
							*temp = $3.value;
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = $1.noOfItems + 1;
							$$.start = append((node *)$1.start,n);
							$$.fflag = 1;
						}
; 

blist : '[' bseq ']' 			{
							$$.start = $2.start;
							$$.fflag = $2.fflag;
							$$.noOfItems = $2.noOfItems;
						}
	| blist '+' '+' blist		{
							$$.start = append((node *)$1.start,(node *)$4.start);
							$$.noOfItems = $1.noOfItems + $4.noOfItems;
							$$.fflag = 2;
						}
;

bseq : BOOL {					node *n = malloc(sizeof(node));
							char *temp = NULL;
							temp = malloc(1);
							*temp = $1.value;
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = 1;
							$$.start = n;
							$$.fflag = 2;
		}
	| bseq ',' BOOL {				node *n = malloc(sizeof(node));
							char *temp = NULL;
							temp = malloc(1);
							*temp = $3.value;
							n->dataPtr = temp;
							n->next = NULL;
							$$.noOfItems = $1.noOfItems + 1;
							$$.start = append((node *)$1.start,n);
							$$.fflag = 2;
				}

;


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

void printList(node *sPtr,int flag)
{
	int i;
	node *s = sPtr;
	printf("[");
	if(flag == 2)
	{
		switch (*(int *)s->dataPtr)
		{
			case 1:
				printf("True");
				break;
			case 0:
				printf("False");
			}
		s = s->next;
		while(s != NULL)
		{
			switch (*(int *)s->dataPtr)
			{
				case 1:
					printf(",True");
					break;
				case 0:
					printf(",False");
			}

			s = s->next;
		}
	}
	else if(flag == 0)
	{
		printf("%d",(int)(*(float *)s->dataPtr));
		s = s->next;
		while(s != NULL)
		{
			printf(",%d",(int)*((float *)s->dataPtr));
			s = s->next;
		}
	}
	else if(flag == 1)
	{
		printf("%f",*(float *)sPtr->dataPtr);
		s = s->next;
		while(s != NULL)
		{
			printf(",%f",(*(float *)s->dataPtr));
			s = s->next;
		}
	}
	printf("]");

}

void * append(node *sPtr,node *n)
{
	node *s = sPtr;
	node *t,*p,*p1;
	t = malloc(sizeof(node));
	float *temp = NULL;
	temp = malloc(1);
	*temp = *(float *)s->dataPtr;
//	printf("%f ",*temp);
	t->dataPtr = temp;
	t->next = NULL;
	p1 = t;
	p = t;
	s = s->next;	
	while(s != NULL)
	{
		t = malloc(sizeof(node));
		temp = malloc(1);
		*temp = *(float *)s->dataPtr;
//	printf("%f ",*temp);
		t->dataPtr = temp;
		t->next = NULL;
		p->next = t;
		p = t;
		s = s->next;
	}
	p->next = n;
	return p1;


}



int main(void) {
	init_dataType();
	yyparse();
	return 0;
}
