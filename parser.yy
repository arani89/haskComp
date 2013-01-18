%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "defs.h"
#include "map_lib.h"
#include "misc.h"

#define MAX 100


  map_symTab *symTab;
  map_data *dataTab;
  dataTypeEntry dataList[MAX];

  int loop, listflag = 0, ifflag = 0;
  float floop;
  int yylex (void);
  void yyerror (char *);

%}


%union
{
  exprValue value;
  char *svalue;
  multiValue mv;
}


 %token < value > FLOAT
  %token < value > INTEGER
  %token < value > BOOL
  %token < value > CHAR
  %token < svalue > VARIABLE
  %token < svalue > IF
  %token < svalue > THEN
  %token < svalue > ELSE
  %token < svalue > STRING
  %type < value > expr
  %type < value > lexpr
  /*%type < mv > fseq*/
  /*%type < mv > flist */
  /*%type < mv > list */
  %left '-' '+'
  %left '*' '/' '%'
  %right '^'
  %nonassoc UMINUS
  %left LOGIC_AND LOGIC_OR LOGIC_NOT
  %left EQ LT GT LE GE
%%

program:program IF expr THEN {  if (*(int *) $3.dataPtr == 0)  ifflag = 1;} program '\n' ELSE {  if (*(int *) $3.dataPtr != 0) ifflag = 1;
} program {  ifflag = 0; } '\n'

|program expr '\n'
{
  //fprintf(stderr, "%d", $2.isList);
  if (ifflag == 0 && $2.isList == 0)
    {
	  int dataNo;
	  dataNo = map_data_get (dataTab, $2.dataType);
	  if (dataNo == -1)
	    {
	      printf ("\nIncorrect data Type");
	    }
	  else if (strcmp ($2.dataType, "Int") == 0)
	    {
	      printf ("%d\n", *(int *) $2.dataPtr);
	    }
	  else if (strcmp ($2.dataType, "Float") == 0)
	    {
	      printf ("%f\n", *(float *) $2.dataPtr);
	    }
	  else if (strcmp ($2.dataType, "Char") == 0)
	    {
	      printf ("'%c'\n", *(char *) $2.dataPtr);
	    }
	  else if (strcmp ($2.dataType, "Bool") == 0)
	    {
	      if (*(int *) $2.dataPtr)
		printf ("True\n");
	      else
		printf ("False\n");
	    }
	  else
	    {
	      printf ("Custom data Type, cannot print value");
	    }
	}
  else if ($2.isList == 1)
	{
		if (strcmp($2.dataType, "Int") == 0)
			printList($2.dataPtr, 0); 
		else if (strcmp($2.dataType, "Float") == 0)
			printList($2.dataPtr, 1);
		else if (strcmp($2.dataType, "Bool") == 0)
			printList($2.dataPtr, 2);
		else if (strcmp($2.dataType, "Char") == 0)
			printList($2.dataPtr, 4);
	}
	ifflag = 0;
    

}

|program error '\n'
{
	printf("Syntax error\n");
}

|program assign '\n'
{
}

|program '\n';
|;

assign:
VARIABLE '=' expr
{
  if (ifflag == 0)
    {
      symTabEntry *newEntry = NULL;
      int dataId = map_data_get (dataTab, $3.dataType);
      newEntry = malloc (sizeof (symTabEntry));
      newEntry->name = malloc (strlen ($1));
      strcpy (newEntry->name, $1);
      newEntry->dataPtr = $3.dataPtr;
      strcpy (newEntry->dataType, $3.dataType);
	  newEntry->isList = $3.isList;
      map_symTab_set (symTab, $1, newEntry);
    }
  else
    ifflag = 0;

}

expr:
INTEGER
{
  if (ifflag == 0)
    {
      int dataId = map_data_get (dataTab, "Int");
      $$.dataPtr = malloc (dataList[dataId].size);
      strcpy ($$.dataType, "Int");
      *(int *) $$.dataPtr = *(int *) $1.dataPtr;
	  $$.isList = 0;
      //printf("Rule 1\n");
    }
}

|FLOAT
{
  if (ifflag == 0)
    {
      int dataId = map_data_get (dataTab, "Float");
      $$.dataPtr = malloc (dataList[dataId].size);
      strcpy ($$.dataType, "Float");
      *(float *) $$.dataPtr = *(float *) $1.dataPtr;
	  $$.isList = 0;
      //printf("Rule 2\n");
    }
}

|BOOL
{
  if (ifflag == 0)
    {
      int dataId = map_data_get (dataTab, "Bool");
      $$.dataPtr = malloc (dataList[dataId].size);
      strcpy ($$.dataType, "Bool");
      *(int *) $$.dataPtr = *(int *) $1.dataPtr;
	  $$.isList = 0;
      //printf("Rule 3\n");
    }
}

|VARIABLE
{
  if (ifflag == 0)
    {
      symTabEntry *entry = NULL;
      entry = map_symTab_get (symTab, $1);
      if (entry == NULL)
	  {
	    printf ("\nUnrecognized variable\n");
	    exit (0);
	  }
	  $$.dataPtr = entry->dataPtr;
	  strcpy ($$.dataType, entry->dataType);
	  $$.isList = entry->isList;
    }
	else
		ifflag = 0;
}

|CHAR
{
  if (ifflag == 0)
    {
      int dataId = map_data_get (dataTab, "Char");
      $$.dataPtr = malloc (dataList[dataId].size);
      strcpy ($$.dataType, "Char");
      *(char *) $$.dataPtr = *(char *) $1.dataPtr;
    }
	ifflag = 0;
}

| STRING
{
	if (ifflag == 0) 
	{
		node *prev = NULL;
		int strLen = strlen($1);
		int sCtr;
		for (sCtr = 1; sCtr < strLen - 1; sCtr++)
		{
			node *n;
			n = malloc(sizeof(n));
			n->dataPtr = malloc(sizeof(char));
			*(char *)n->dataPtr = $1[sCtr];
			n->next = NULL;
			if (prev == NULL)
				prev = n;
			else
				prev = append(prev, n);
		}
		$$.dataPtr = prev;
		strcpy($$.dataType, "Char");
		$$.isList = 1;
	}
	ifflag = 0;
}
|'(' expr ')'
{
  if (ifflag == 0)
  {
  	$$ = $2;
  }
  ifflag = 0;
}

|expr '+' expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("Rule 4\n");
      int id1, id2, intId;
      intId = map_data_get (dataTab, "Int");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      if (id1 == intId && id2 == intId)
	{
	  strcpy ($$.dataType, "Int");
	  $$.dataPtr = malloc (sizeof (int));
	  *(int *) $$.dataPtr = val1 + val2;
	}
      else
	{
	  strcpy ($$.dataType, "Float");
	  $$.dataPtr = malloc (sizeof (float));
	  *(float *) $$.dataPtr = val1 + val2;
	}
	$$.isList = 0;
    }
	ifflag = 0;
}

|expr '-' expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("Rule 5\n");
      int id1, id2, intId;
      intId = map_data_get (dataTab, "Int");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      if (id1 == intId && id2 == intId)
	{
	  strcpy ($$.dataType, "Int");
	  $$.dataPtr = malloc (sizeof (int));
	  *(int *) $$.dataPtr = val1 - val2;
	}
      else
	{
	  strcpy ($$.dataType, "Float");
	  $$.dataPtr = malloc (sizeof (float));
	  *(float *) $$.dataPtr = val1 - val2;
	}
	$$.isList = 0;
    }
	ifflag = 0;
}
| '-' expr %prec UMINUS
{
  if (ifflag == 0)
  {
  if (!strcmp($2.dataType, "Int") || !strcmp($2.dataType, "Float") && !$2.isList)
  {
  	 float val;
     int id = getNoId(&($2), dataTab, &val);
	 void *newExpr;
	 newExpr = malloc(dataList[id].size);
	 if (!strcmp($2.dataType, "Int"))
	 	*(int *)newExpr = *(int *)$2.dataPtr * -1;
	 else
	 	*(float *)newExpr = *(float *)$2.dataPtr * -1;

	 $$.dataPtr = newExpr;
	 strcpy($$.dataType, $2.dataType);
	 $$.isList = 0;
  }
  else
  	YYERROR;
  }
  ifflag = 0;
 
}
|expr '*' expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("\nRule 6\n");
      int id1, id2, intId;
      intId = map_data_get (dataTab, "Int");
      id1 = getNoId (&($1), dataTab, &val1);
      
      if (id1 == -1 || $1.isList || $3.isList)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      if (id1 == intId && id2 == intId)
	{
	  strcpy ($$.dataType, "Int");
	  $$.dataPtr = malloc (sizeof (int));
	  *(int *) $$.dataPtr = val1 * val2;
	}
      else
	{
	  strcpy ($$.dataType, "Float");
	  $$.dataPtr = malloc (sizeof (float));
	  *(float *) $$.dataPtr = val1 * val2;
	  $$.isList = 0;
	}
	ifflag = 0;
    }
}

|expr '*' '*' expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("\nRule 7\n");
      int id1, id2;
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $4.isList)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      id2 = getNoId (&($4), dataTab, &val2);
      if (id2 == -1)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      strcpy ($$.dataType, "Float");
      $$.dataPtr = malloc (sizeof (float));
      *(float *) $$.dataPtr = pow (val1, val2);
	  $$.isList = 0;
    }
	else
		ifflag = 0;
}

|expr '^' expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("Rule 8\n");
      int id1, id2, intId;
      intId = map_data_get (dataTab, "Int");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	{
	  yyerror ("Invalid data symbol");
	  YYERROR;
	}
      if (id1 == intId && id2 == intId)
	{
	  strcpy ($$.dataType, "Int");
	  $$.dataPtr = malloc (sizeof (int));
	  *(int *) $$.dataPtr = pow (val1, val2);
	}
      else
	{
	  strcpy ($$.dataType, "Float");
	  $$.dataPtr = malloc (sizeof (float));
	  *(float *) $$.dataPtr = pow (val1, val2);
	  $$.isList = 0;
	}
    }
	else
		ifflag = 0;
}

|expr '/' expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("Rule 9\n");
      int id1, id2, intId;
      intId = map_data_get (dataTab, "Int");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if (id1 == intId && id2 == intId && val2 != 0)
	{
	  strcpy ($$.dataType, "Int");
	  $$.dataPtr = malloc (sizeof (int));
	  *(int *) $$.dataPtr = val1 / val2;
	}
      else
	{
	  strcpy ($$.dataType, "Float");
	  $$.dataPtr = malloc (sizeof (float));
	  *(float *) $$.dataPtr = val1 / val2;
	  $$.isList = 0;
	}
    }
	else
		ifflag = 0;
}

|expr GT expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("Rule 10\n");
      int id1, id2, intId, floatId;
      intId = map_data_get (dataTab, "Int");
      floatId = map_data_get (dataTab, "Float");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if ((id1 == intId || id1 == floatId) &&
	  (id2 == intId || id2 == floatId))
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 > val2;
	  $$.isList = 0;
	}
    }
	else
		ifflag = 0;
}

|expr LT expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("Rule 11\n");
      int id1, id2, intId, floatId;
      intId = map_data_get (dataTab, "Int");
      floatId = map_data_get (dataTab, "Float");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if ((id1 == intId || id1 == floatId) &&
	  (id2 == intId || id2 == floatId))
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 < val2;
	  $$.isList = 0;
	}
    }
	ifflag = 0;
}

|expr GE expr
{
  if (ifflag == 0)
    {
      float val1, val2;
      printf ("Rule 12\n");
      int id1, id2, intId, floatId;
      intId = map_data_get (dataTab, "Int");
      floatId = map_data_get (dataTab, "Float");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if ((id1 == intId || id1 == floatId) &&
	  (id2 == intId || id2 == floatId))
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 >= val2;
	  $$.isList = 0;
	}
    }
	else
		ifflag = 1;
}

|expr LE expr
{
  if (ifflag == 0)
    {
      printf ("Rule 13\n");
      float val1, val2;
      int id1, id2, intId, floatId;
      intId = map_data_get (dataTab, "Int");
      floatId = map_data_get (dataTab, "Float");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if ((id1 == intId || id1 == floatId) &&
	  (id2 == intId || id2 == floatId))
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 <= val2;
	  $$.isList = 0;
	}
    }
	else
		ifflag = 1;
}

|expr EQ expr
{
  if (ifflag == 0)
    {
      printf ("Rule 14\n");
      float val1, val2;
      int id1, id2, intId, floatId;
      intId = map_data_get (dataTab, "Int");
      floatId = map_data_get (dataTab, "Float");
      id1 = getNoId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getNoId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if ((id1 == intId || id1 == floatId) &&
	  (id2 == intId || id2 == floatId))
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 == val2;
	  $$.isList = 0;
	}
      else
	YYERROR;
    }
	else
		ifflag = 0;
}

|expr LOGIC_AND expr
{
  if (ifflag == 0)
    {
      printf ("Rule 15\n");
      int id1, id2, boolId;
      int val1, val2;
      boolId = map_data_get (dataTab, "Bool");
      id1 = getBoolId (&($1), dataTab, &val1);
      //fprintf (stderr, "%d %d %d", id1, val1, *(int *) $$.dataPtr);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getBoolId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if (id1 == boolId && id2 == boolId)
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 && val2;
	  $$.isList = 0;
	}
      else
	YYERROR;
    }
	ifflag = 0;
}

|expr LOGIC_OR expr
{
  if (ifflag == 0)
    {
      printf ("Rule 16\n");
      int id1, id2, boolId;
      int val1, val2;
      boolId = map_data_get (dataTab, "Bool");
      id1 = getBoolId (&($1), dataTab, &val1);
      if (id1 == -1 || $1.isList || $3.isList)
	YYERROR;
      id2 = getBoolId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if (id1 == boolId && id2 == boolId)
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 || val2;
	  $$.isList = 0;
	}
      else
	YYERROR;
    }
	else
		ifflag = 0;
}

|LOGIC_NOT expr
{
  if (ifflag == 0)
    {
      printf ("Rule 17\n");
      int id2, boolId;
      int val2;
      boolId = map_data_get (dataTab, "Bool");
      id2 = getBoolId (&($2), dataTab, &val2);
      if (id2 == -1 || $2.isList)
	YYERROR;
      if (id2 == boolId)
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = !(int) val2;
	}
      else
	YYERROR;
    }
	ifflag = 0;	
}
| '[' expr ']'
{
	if (ifflag == 0)
	{
	$$.isList = 1;
	node *n = malloc(sizeof(node));
	n->dataPtr = $2.dataPtr;
	n->next = NULL;
	strcpy($$.dataType, $2.dataType);
	$$.dataPtr = n;
	}
	ifflag = 0;
}
| '[' lexpr ']'
{
	if (ifflag == 0)
	{
	$$.isList = 1;
	$$.dataPtr = $2.dataPtr;
	strcpy($$.dataType, $2.dataType);
	}
	ifflag = 0;
}
| expr '+' '+' expr
{
	if (ifflag == 0)
	{
		if ($1.isList != 1 || $4.isList != 1)
			YYERROR;
		if (!strcmp($1.dataType, $4.dataType))
		{
			node *list = $1.dataPtr;		
			node *newNode = NULL, *prevNode = NULL, *fstNewNode;
			while (list != NULL)
			{
				newNode = malloc(sizeof(node));
				newNode->dataPtr = list->dataPtr;
				newNode->next = NULL;
				if (list == $1.dataPtr)
					fstNewNode = newNode;
				else
					prevNode->next = newNode;
				prevNode = newNode;
				list = list->next;
			}
			$$.isList = 1;
			strcpy($$.dataType, $1.dataType);
			$$.dataPtr = append(fstNewNode, $4.dataPtr);
			void *abc = $$.dataPtr;
		}
		else
			YYERROR;
	}
	ifflag = 0;
}
lexpr:
expr ',' lexpr
{
	if (ifflag == 0)
	{
	node *n = malloc(sizeof(node));
	n->dataPtr = $1.dataPtr;
	n->next = NULL;
	$$.dataPtr = append(n, $3.dataPtr);
	void *abc = $$.dataPtr;
	strcpy($$.dataType, $1.dataType);
	}
	ifflag = 0;
}
| expr ',' expr
{
	if (ifflag == 0)
	{
	node *n1 = malloc(sizeof(node));
	node *n2 = malloc(sizeof(node));
	n1->dataPtr = $1.dataPtr;
	n2->dataPtr = $3.dataPtr;
	n1->next = n2->next = NULL;
	strcpy($$.dataType, $1.dataType);
	$$.dataPtr = append(n1, n2);
	}
	ifflag = 0;
}

| expr ',' expr '.' '.' expr
{
	if (ifflag == 0)
	{
	if (!strcmp($1.dataType, "Int") && !strcmp($6.dataType, "Int") && !strcmp($3.dataType, "Int"))
	{
		node *n1 = malloc(sizeof(node));
		node *n2 = malloc(sizeof(node));
		node *n3;
		n1->dataPtr = $1.dataPtr;
		n1->next = n2;
		n2->next = NULL;
		n2->dataPtr = $3.dataPtr;
		int i = *(int *)n1->dataPtr;
		int j = *(int *)n2->dataPtr;
		int diff = j - i;
		i = i + diff;
		while (i < *(int *)$6.dataPtr)
		{
			i = i + diff;
			n3 = malloc(sizeof(node));
			n3->dataPtr = malloc(sizeof(int));
			*(int *)(n3->dataPtr) = i;
			n1 = append(n1, n3);
		}
		$$.dataPtr = n1;
	}
	else if (!strcmp($1.dataType, "Float") && !strcmp($3.dataType, "Float") && !strcmp($6.dataType, "Float"))
	{
		node *n1 = malloc(sizeof(node));
		node *n2 = malloc(sizeof(node));
		node *n3 = NULL;
		n1->dataPtr = $1.dataPtr;
		n1->next = n2;
		n2->next = NULL;
		n2->dataPtr = $3.dataPtr;
		float i, j, diff, k;
		if (!strcmp($1.dataType, $6.dataType))
		{
			i = *(float *)n1->dataPtr;
			j = *(float *)$6.dataPtr;
			k = *(float *)n2->dataPtr;
		}
		diff = k - i;
		i = i + diff;
		while (i < j)
		{
			i = i + diff;
			n3 = malloc(sizeof(node));
			n3->dataPtr = malloc(sizeof(float));
			*(float *)(n3->dataPtr) = i;
			n1 = append(n1, n3);
		}
		$$.dataPtr = n1;
	}
	//printList($$.dataPtr, 0);
	}
	else
		YYERROR;
	ifflag = 0;
}
| expr '.' '.' expr
{
	if (ifflag == 0)
	{
	if (!strcmp($1.dataType, "Int") && !strcmp($4.dataType, "Int"))
	{
		node *n1 = malloc(sizeof(node));
		node *n2 = NULL;
		n1->dataPtr = $1.dataPtr;
		int i = *(int *)n1->dataPtr;
		while (i < *(int *)$4.dataPtr)
		{
			i++;
			n2 = malloc(sizeof(node));
			n2->dataPtr = malloc(sizeof(int));
			*(int *)(n2->dataPtr) = i;
			n1 = append(n1, n2);
		}
		$$.dataPtr = n1;
	}
	else if (!strcmp($1.dataType, "Float") || !strcmp($4.dataType, "Float"))
	{
		node *n1 = malloc(sizeof(node));
		node *n2 = NULL;
		n1->dataPtr = $1.dataPtr;
		float i, j;
		if (!strcmp($1.dataType, $4.dataType))
		{
			i = *(float *)n1->dataPtr;
			j = *(float *)$4.dataPtr;
		}
		else if (!strcmp($1.dataType, "Float"))
		{
			i = *(float *)n1->dataPtr;
			j = *(int *)$4.dataPtr;	
		}
		else
		{
			i = *(int *)n1->dataPtr;
			j = *(float *)$4.dataPtr;
		}
		while (i < j)
		{
			i++;
			n2 = malloc(sizeof(node));
			n2->dataPtr = malloc(sizeof(float));
			*(float *)(n2->dataPtr) = i;
			n1 = append(n1, n2);
		}
		$$.dataPtr = n1;
	}
	//printList($$.dataPtr, 0);
	}
	else
		YYERROR;
	ifflag = 0;
}
%%

void
yyerror (char *s)
{
  fprintf (stderr, "%s\n", s);
}

void
init_dataType ()
{
  dataTab = map_data_create ();
  symTab = map_symTab_create ();

  dataList[0].size = sizeof (int);
  dataList[1].size = sizeof (float);
  dataList[2].size = sizeof (char);
  dataList[3].size = 1;

  map_data_set (dataTab, "Int", 0);
  map_data_set (dataTab, "Float", 1);
  map_data_set (dataTab, "Char", 2);
  map_data_set (dataTab, "Bool", 3);
}

int
main (void)
{
  init_dataType ();
  yyparse ();
  return 0;
}
