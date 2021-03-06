#ifdef _DEFS_H
#else
#define _DEFS_H

#define DATASIZE 10

typedef struct
{
	int isList;
	char dataType[DATASIZE];
	void *dataPtr;
}exprValue;

typedef struct
{
	char dataType[DATASIZE];
	void *start;	
}multiValue;

typedef struct
{
	int size;
}dataTypeEntry;


typedef struct
{
	int isList;
	char dataType[DATASIZE];
	void *dataPtr;
	char *name;
}symTabEntry;

typedef struct
{	
	void *dataPtr;	
	struct node *next;
}node;

#endif
