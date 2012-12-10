%{
#include <stdio.h>
#include <math.h>
int yylex(void);
void yyerror(char *);

enum DataType { boolean, integer, floating };
%}

%union {
	enum DataType dataType;
	double value;
	int ivalue;
	int bvalue;
	}
%token<dvalue> FLOAT
%token<ivalue> INTEGER
%token<bvalue> BOOL
%%

program:
	   program expr '\n'	{
					 switch (dataType)
					 {
						 case boolean:
						 if ($2 == 1)
							 printf("True\n");
						 else
							 printf("False\n");
						 break;
						 case integer:
						 printf("%d", (int)$2);
						 break;
						 case floating:
						 printf("%f", $2);
						 break;
					 }
	   			}

| program '\n' 
|
;
expr:
	INTEGER         
|	FLOAT 
| expr '+' expr		{ $$ = $1 + $3; }
| expr '-' expr		{ $$ = $1 - $3; }
| expr '*' expr     	{ $$ = $1 * $3; }
| expr '/' expr     	{ $$ = $1 / $3; }
| '(' expr ')'	    	{ $$ = $2; }
| expr '*' '*' expr 	{ $$ = pow($1, $4); }
| '-' expr	    	{ $$ = -$2; }
| expr '%' expr		{ $$ = $1 % $3; }
| expr '>' expr		{ $$ = $1 > $3 ? 1 : 0; }
| expr '<' expr		{ $$ = $1 < $3 ? 1 : 0; }
| expr '=' '=' expr 	{ $$ = $1 == $4 ? 1 : 0; }
| expr '>' '=' expr	{ $$ = $1 >= $4 ? 1 : 0; }
| expr '<' '=' expr	{ $$ = $1 <= $4 ? 1 : 0; }
|
;

%%

void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
}
int main(void) {
yyparse();
return 0;
}
