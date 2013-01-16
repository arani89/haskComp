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
  %type < mv > fseq
  %type < mv > flist
  %type < mv > list
  %left '-' '+'
  %left '*' '/' '%'
  %right '^'
  %nonassoc UMINUS
  %left LOGIC_AND LOGIC_OR LOGIC_NOT
  %left EQ LT GT LE GE
%%

program:program IF expr THEN
{
  if (*(int *) $3.dataPtr == 0)
    ifflag = 1;
} program '\n' ELSE
{
  if (*(int *) $3.dataPtr != 0)
    ifflag = 1;
} program {   ifflag = 0; } '\n'
| program VARIABLE '=' list '\n'
{
  if (ifflag == 0)
    {
      symTabEntry *newVarEntry = malloc (sizeof (symTabEntry));
      newVarEntry->name = $2;
      newVarEntry->dataPtr = $4.start;
      newVarEntry->isList = 1;
      if ($4.fflag == 0)
	strcpy (newVarEntry->dataType, "Int");
      else if ($4.fflag == 1)
	strcpy (newVarEntry->dataType, "Float");
      else if ($4.fflag == 2)
	strcpy (newVarEntry->dataType, "Bool");
      else if ($4.fflag == 4)
	strcpy (newVarEntry->dataType, "Char");
      else if ($4.fflag == -1)
	strcpy (newVarEntry->dataType, "Null");
      map_symTab_set (symTab, newVarEntry->name, newVarEntry);
    }
  else
    {
      ifflag = 0;
    }

}

|program expr '\n'
{
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
}

|program assign '\n'
{
}

|program '\n';
|;

list:


'[' ']'
{
  if (ifflag == 0)
    {
      $$.start = NULL;
      $$.fflag = -1;
    }
  else
    {
      ifflag = 0;
    }

}
| VARIABLE '+' '+' VARIABLE
{
  symTabEntry *entry1, *entry2;
  if (ifflag == 0)
  {
  	  entry1 = map_symTab_get(symTab, $1);
	  entry2 = map_symTab_get(symTab, $4);
  	  if (entry1 == NULL || entry2 == NULL
	  		|| entry1->isList == 0 || entry2->isList == 0)
	  {

	  	  YYERROR;
	  }
	  else if (strcmp(entry1->dataType, entry2->dataType) != 0)
	  {
	  	if (strcmp(entry1->dataType, "Int") == 0
			&& strcmp(entry2->dataType, "Float") == 0)
		{
	  	  $$.start = append(entry1->dataPtr, entry2->dataPtr);
		  $$.fflag = 1;
		}
		else if (strcmp(entry1->dataType, "Float") == 0
			&& strcmp(entry2->dataType, "Int") == 0)
		{
		  $$.start = append(entry1->dataPtr, entry2->dataPtr);
		  $$.fflag = 1;
		}
	 }
	 else
	 {
	   $$.start = append(entry1->dataPtr, entry2->dataPtr);
	   $$.fflag = 0;
	 }
  }
  ifflag = 0;
}

|flist
{
  if (ifflag == 0)
    {
      $$.start = $1.start;
      $$.fflag = $1.fflag;
      //$$.noOfItems = $1.noOfItems;
    }
  else
    ifflag = 0;
}
;

flist:
STRING
{
  if (ifflag == 0)
    {
      int i;
      node *last = NULL;
      for (i = 1; i < strlen ($1) - 1; i++)
	{
	  node *n = malloc (sizeof (node));
	  char *temp = NULL;
	  temp = malloc (sizeof (char));
	  *temp = $1[i];
	  n->dataPtr = temp;

	  if (i == 1)
	    $$.start = n;
	  else
	    last->next = n;
	  last = n;
	}
      $$.fflag = 4;
      //$$.noOfItems = strlen ($1) - 2;
    }
  else
    ifflag = 0;
}

|'[' fseq ']'
{
  if (ifflag == 0)
    {
      $$.start = $2.start;
      $$.fflag = $2.fflag;
      //$$.noOfItems = $2.noOfItems;
    }
  else
    ifflag = 0;
}

|flist '+' '+' flist
{
  if (ifflag == 0)
    {

      //$$.noOfItems = $1.noOfItems + $4.noOfItems;
      if ($1.fflag == $4.fflag || ($1.fflag == 0 && $4.fflag == 1))
	$$.fflag = $4.fflag;
      else if ($1.fflag == 1 && $4.fflag == 0)
	$$.fflag = $1.fflag;
      else
	{
	  yyerror ("Operand type mismatch");
	  YYERROR;
	}
      $$.start = append ((node *) $1.start, (node *) $4.start);
    }
  else
    ifflag = 0;
}

|'[' expr '.' '.' ']'
{
  if (ifflag == 0)
    {				//printf("[");
      float val1;
      int id1, intId;
      int t;
      intId = map_data_get (dataTab, "Int");
      id1 = getNoId (&($2), dataTab, &val1);
      if (id1 == -1)
	{
	  yyerror ("No such data");
	  YYERROR;
	}
      printf ("[");
      if (id1 == intId)
	{
	  for (t = val1;; t++)
	    printf ("%d,", t);
	}
      else
	{
	  for (floop = val1;; floop++)
	    printf ("%f,", floop);
	}
      $$.fflag = 3;
    }
  else
    ifflag = 0;
}

|'[' expr '.' '.' expr ']'
{
  if (ifflag == 0)
    {
      float val1, val2;
      int id1, id2, intId;
      int t;
      intId = map_data_get (dataTab, "Int");
      id1 = getNoId (&($2), dataTab, &val1);
      if (id1 == -1)
	{
	  yyerror ("No such data");
	  YYERROR;
	}
      id2 = getNoId (&($5), dataTab, &val2);
      if (id2 == -1)
	{
	  yyerror ("No such data");
	  YYERROR;
	}
      printf ("[");
      if (id1 == intId && id2 == intId)
	{
	  if (val1 <= val2)
	    {
	      for (t = val1; t < val2; t++)
		printf ("%d,", t);
	      printf ("%d", t);
	    }
	}
      else
	{
	  if (val1 <= val2)
	    {
	      for (floop = val1; floop < val2; floop++)
		printf ("%f,", floop);
	      printf ("%f", floop);
	    }
	}
      printf ("]\n");
      $$.fflag = 3;
    }
  else
    ifflag = 0;
}

;
fseq:
INTEGER
{
  if (ifflag == 0)
    {
      node *n = malloc (sizeof (node));
      float *temp = NULL;
      temp = malloc (sizeof (float));
      *temp = *(int *) $1.dataPtr;

      n->dataPtr = temp;
      n->next = NULL;
      //$$.noOfItems = 1;
      $$.start = n;
      $$.fflag = 0;

    }
  else
    ifflag = 0;
}

|FLOAT
{
  if (ifflag == 0)
    {
      node *n = malloc (sizeof (node));
      float *temp = NULL;
      temp = malloc (sizeof (float));
      *temp = *(float *) $1.dataPtr;
      n->dataPtr = temp;
      n->next = NULL;
      //$$.noOfItems = 1;
      $$.start = n;
      $$.fflag = 1;
    }
  else
    ifflag = 0;
}

|CHAR
{
  if (ifflag == 0)
    {
      node *n = malloc (sizeof (node));
      char *temp = NULL;
      temp = malloc (sizeof (char));
      *temp = *(char *) $1.dataPtr;
      n->dataPtr = temp;
      n->next = NULL;
      //$$.noOfItems = 1;
      $$.start = n;
      $$.fflag = 4;
    }
  else
    ifflag = 0;
}

|BOOL
{
  if (ifflag == 0)
    {
      node *n = malloc (sizeof (node));
      void *temp = NULL;
      temp = malloc (sizeof (int));
      *(int *) temp = *(int *) $1.dataPtr;

      n->dataPtr = temp;
      n->next = NULL;
      //$$.noOfItems = 1;
      $$.start = n;
      $$.fflag = 2;

    }
  else
    ifflag = 0;
}

|VARIABLE
{
  if (ifflag == 0)
    {
      symTabEntry *entry = map_symTab_get (symTab, $1);
      node *n = malloc (sizeof (node));
      void *temp = NULL;

      if (entry == NULL)
	{
	  printf ("\nUnrecognized variable\n");
	  exit (0);
	}
      else if (entry->isList == 1)
	{
	  yyerror ("Invalid format\n");
	  YYERROR;
	}
      else if (strcmp (entry->dataType, "Int") == 0)
	{
	  temp = malloc(sizeof(int));
	  *(int *) temp = *(int *) entry->dataPtr;
	  $$.fflag = 0;
	}
      else if (strcmp (entry->dataType, "Char") == 0)
	{
	  temp = malloc(sizeof(char));
	  *(char *) temp = *(char *) entry->dataPtr;
	  $$.fflag = 4;

	}
      else if (strcmp (entry->dataType, "Float") == 0)
	{
	  temp = malloc(sizeof(float));
	  *(float *) temp = *(float *) entry->dataPtr;
	  $$.fflag = 1;
	}
      else if (strcmp (entry->dataType, "Bool") == 0)
	{
	  temp = malloc(sizeof(int));
	  *(int *) temp = *(int *) entry->dataPtr;
	  $$.fflag = 2;

	}

      else
	{
	  yyerror ("Invalid type\n");
	  YYERROR;
	}
      n->dataPtr = temp;
      n->next = NULL;
      //$$.noOfItems = 1;
      $$.start = n;

    }
  else
    ifflag = 0;
}

|fseq ',' fseq
{
  if (ifflag == 0)
    {
      if ($1.fflag != $3.fflag)
	if ($1.fflag == 2 || $3.fflag == 2 || $1.fflag == 4 || $3.fflag == 4)
	  {
	    yyerror ("Invalid operation\n");
	    YYERROR;
	  }
      $$.fflag = ($1.fflag >= $3.fflag) ? $1.fflag : $3.fflag;
      //$$.noOfItems = $1.noOfItems + $3.noOfItems;
      $$.start = append ((node *) $1.start, (node *) $3.start);

    }

}

;
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
      //printf("Rule 3\n");
    }
}

|list
{
  $$.isList = 1;
  switch ($1.fflag)
    {
    case 0:
      strcpy ($$.dataType, "Int");
      break;
    case 1:
      strcpy ($$.dataType, "Float");
      break;
    case 2:
      strcpy ($$.dataType, "Bool");
      break;
    case 4:
      strcpy ($$.dataType, "Char");
      break;
    }
	$$.dataPtr = $1.start;
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
      else if (entry->isList == 1)
	{
	  if (strcmp (entry->dataType, "Int") == 0)
	    {
	      printList ((node *) entry->dataPtr, 0);
	    }
	  else if (strcmp (entry->dataType, "Float") == 0)
	    {
	      printList ((node *) entry->dataPtr, 1);
	    }
	  else if (strcmp (entry->dataType, "Char") == 0)
	    {
	      printList ((node *) entry->dataPtr, 4);
	    }
	  else if (strcmp (entry->dataType, "Bool") == 0)
	    {
	      printList ((node *) entry->dataPtr, 2);
	    }
	  else
	    {
	      yyerror ("Invalid type\n");
	      YYERROR;
	    }
	  listflag = 1;
	}
      else
	{
	  listflag = 0;
	  $$.dataPtr = entry->dataPtr;
	  strcpy ($$.dataType, entry->dataType);
	}
    }
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
}

|'(' expr ')'
{
  $$ = $2;
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
      if (id1 == -1)
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
    }
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
      if (id1 == -1)
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
    }
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
      if (id1 == -1)
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
	}
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
      if (id1 == -1)
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
    }
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
      if (id1 == -1)
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
	}
    }
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
      if (id1 == -1)
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
	}
    }
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
      if (id1 == -1)
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
	}
    }
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
      if (id1 == -1)
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
	}
    }
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
      if (id1 == -1)
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
	}
    }
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
      if (id1 == -1)
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
	}
    }
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
      if (id1 == -1)
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
	}
      else
	YYERROR;
    }
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
      fprintf (stderr, "%d %d %d", id1, val1, *(int *) $$.dataPtr);
      if (id1 == -1)
	YYERROR;
      id2 = getBoolId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if (id1 == boolId && id2 == boolId)
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 && val2;
	}
      else
	YYERROR;
    }
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
      if (id1 == -1)
	YYERROR;
      id2 = getBoolId (&($3), dataTab, &val2);
      if (id2 == -1)
	YYERROR;
      if (id1 == boolId && id2 == boolId)
	{
	  strcpy ($$.dataType, "Bool");
	  $$.dataPtr = malloc (1);
	  *(int *) $$.dataPtr = val1 || val2;
	}
      else
	YYERROR;
    }
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
      if (id2 == -1)
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
}

%%void
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
