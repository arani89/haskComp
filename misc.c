#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "defs.h"
#include "map_lib.h"

int getNoId(exprValue *expr, map_data *dt, float *val)
{
	int id;
	if (strcmp(expr->dataType, "Int") == 0
			|| strcmp(expr->dataType, "Float") == 0)
	{
		id = map_data_get(dt, expr->dataType);
	}
	else
	{
		return -1;
	}

	if (strcmp(expr->dataType, "Int") == 0 ||
		   	strcmp(expr->dataType, "Bool") == 0)
	{
		*val = (float)*(int *)expr->dataPtr;
	}
	else
	{
		*val = *(float *)expr->dataPtr;
	}

	return id;
}

int getBoolId(exprValue *expr, map_data *dt, int *val)
{
	int id;
	if (strcmp(expr->dataType, "Bool") == 0)
		id = map_data_get(dt, expr->dataType);
	else
		return -1;

	if (strcmp(expr->dataType, "Bool"))
		*val = *(int *)expr->dataPtr;
	else
		*val = *(int *)expr->dataPtr;
	return id;
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
		fprintf(stderr, "%d",(int)(*(float *)s->dataPtr));
		s = s->next;
		while(s != NULL)
		{
			printf(",%d",(int)(*(float *)s->dataPtr));
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
	else if(flag == 4)
	{
		printf("'%c'",*(char *)sPtr->dataPtr);
		s = s->next;
		while(s != NULL)
		{
			printf(",'%c'",(*(char *)s->dataPtr));
			s = s->next;
		}
	}

	printf("]\n");

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

