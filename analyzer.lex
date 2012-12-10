
%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
void yyerror(char *);
#include "y.tab.h"
char *p = NULL;
char str[100];
%}

enum DataType { boolean, integer, floating};
%union {
	enum DataType dataType;
	double value;
	int ivalue;
	int bvalue;
	}
%%

[0-9]+\.[0-9]+	{	printf("%s", yytext);
			yylval.dvalue = atof(yytext);
			yylval.dataType = floating;
			printf("%f %s (float) has been read\n", yylval, yytext);
			return FLOAT;	
		}
[0-9]+  	{   	yylval.ivalue = atoi(yytext);
			yylval.dataType = integer;
			//printf("%d (int) has been read\n", yylval);	
		    	return INTEGER;
		}
TRUE		{	return BOOL;
		}
FALSE		{ 	return BOOL;
		}
[-+*()/%><=\n] 	{	//printf("%s has been read", yytext);
			return *yytext;
		}
			
[ \t] 		; 	/* skip whitespace */
.               {
			//printf("Invalid character %s", yytext);
			yyerror("invalid character");
		}
%%

int yywrap(void) {
return 1;
}
