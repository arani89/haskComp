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
#endif
