#include <stdio.h>
#include <string.h>
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

