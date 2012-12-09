%{
#include <stdio.h>
#include <math.h>
int yylex(void);
void yyerror(char *);
//#define YYSTYPE double
%}
%token INTEGER
%token FLOAT
%%
program:
	   program expr '\n'	{ printf("%d\n", $2); }
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
| expr '>' expr		{ $$ = $1 > $3; }
| expr '<' expr		{ $$ = $1 < $3; }
| expr '=' '=' expr 	{ $$ = $1 == $4; }
| expr '>' '=' expr	{ $$ = $1 >= $4; }
| expr '<' '=' expr	{ $$ = $1 <= $4; }
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
