
%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
void yyerror(char *);
#include "defs.h"
#include "y.tab.h"
%}

%%

[0-9]+\.[0-9]+ 		{
						strcpy(yylval.value.dataType, "Float");
						yylval.value.dataPtr = malloc(sizeof(float));
						*(float *)yylval.value.dataPtr = atof(yytext);
						return FLOAT;
					}
[0-9]+	{  	
			strcpy(yylval.value.dataType, "Int");
			yylval.value.dataPtr = malloc(sizeof(int));
			*(int *)yylval.value.dataPtr = atoi(yytext);
			//printf("%d (int) has been read\n", yylval);	
		   	return INTEGER;
		}
if		{
			return IF;
		}
then		{
			return THEN;
		}


[a-z][a-zA-Z0-9_]*	{
			yylval.svalue = (char *)malloc(strlen(yytext) + 1);
			strcpy(yylval.svalue, yytext);			
			return VARIABLE;
		}

'[a-zA-Z0-9]'	{
					strcpy(yylval.value.dataType, "Char");
					yylval.value.dataPtr = malloc(sizeof(char));
					*(char *)yylval.value.dataPtr = yytext[1];
					return CHAR;
				}

&&		{	return LOGIC_AND; }

\|\|		{	return LOGIC_OR;  }

not		{	return LOGIC_NOT; }

True		{
				strcpy(yylval.value.dataType, "Bool");
				yylval.value.dataPtr = malloc(1);
				*(int *)yylval.value.dataPtr = 1;
				return BOOL;
		}
False		{
				strcpy(yylval.value.dataType, "Bool");
				yylval.value.dataPtr = malloc(1);
				*(int *)yylval.value.dataPtr = 0;
				return BOOL;
			}
==		{	return EQ; }
>=		{	return GE; }
>		{	return GT; }
\<=		{	return LE; }
\< 		{	return LT; }
[-+^*()/%><=\n\[\],\.\:] 	{	//printf("%s has been read", yytext);
			return *yytext;
		}
			
[ \t] 		; 	
.       {
			//printf("Invalid character %s", yytext);
			yyerror("invalid character");
		}

%%

int yywrap(void) {
return 1;
}
