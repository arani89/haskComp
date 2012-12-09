
%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
void yyerror(char *);
#include "y.tab.h"
char *p = NULL;
char str[100];
%}

%%

[0-9]+\.[0-9]+	{	printf("%s", yytext);
			yylval = atof(yytext);
			printf("%f %s (float) has been read\n", yylval, yytext);
			return FLOAT;	
		}
[0-9]+  	{   	yylval = atoi(yytext);
			//printf("%d (int) has been read\n", yylval);	
		    	return INTEGER;
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
