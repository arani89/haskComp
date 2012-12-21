
%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
void yyerror(char *);
#include "defs.h"
#include "y.tab.h"
%}

%%

[0-9]+\.[0-9]+ 		{	yylval.fvalue.value = atof(yytext);
			yylval.fvalue.exprType = floating;			
			return FLOAT;	
		}
[0-9]+	{  	yylval.ivalue.value = atoi(yytext);
			yylval.ivalue.exprType = integer;
			//printf("%d (int) has been read\n", yylval);	
		   	return INTEGER;
		}

[a-z][a-zA-Z0-9_]*	{
			yylval.svalue = (char *)malloc(strlen(yytext) + 1);
			strcpy(yylval.svalue, yytext);			
			return VARIABLE;
		}

'[a-zA-Z0-9]'	{
			yylval.cvalue = yytext[1];
			return CHAR;
		}

&&		{	return LOGIC_AND; }

\|\|		{	return LOGIC_OR;  }

not		{	return LOGIC_NOT; }

True		{	yylval.bvalue.value = 1;
			yylval.bvalue.exprType = boolean;
			return BOOL;
		}
False		{ 	yylval.bvalue.value = 0;
			yylval.bvalue.exprType = boolean;
			return BOOL;
		}
[-+*()/%><=\n\[\],\.] 	{	//printf("%s has been read", yytext);
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