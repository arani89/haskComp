#ifndef _MISC_H
#define _MISC_H

int getNoId(exprValue *expr, map_data *dt, float *val);
int getBoolId(exprValue *expr, map_data *dt, int *val);
void * append(node *sPtr,node *n);
void printList(node *sPtr,int flag);

#endif
