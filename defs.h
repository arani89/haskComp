#ifdef _DEFS_H
#else
#define _DEFS_H

enum DataType
{
	floating, integer, boolean
};

typedef struct
{
	enum DataType exprType;
	int value;
}intValue;

typedef struct
{
	enum DataType exprType;
	float value;
}floatValue;

typedef struct
{
	enum DataType exprType;
	int value;
}boolValue;

/*typedef struct
{
	char *dataTypeName;
	int dataSize;
}dataTypeEntry; */

typedef struct
{
	int isList;
	char dataType[10];
	void *dataPtr;
	char *name;
}symTabEntry;

#endif
