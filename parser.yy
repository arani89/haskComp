%{
#include <stdio.h>
#include <math.h>
#include "defs.h"
int yylex(void);
void yyerror(char *);

%}


%union {
	intValue ivalue;
	floatValue fvalue;
	boolValue bvalue;
	}

%token <fvalue> FLOAT
%token <ivalue> INTEGER
%token <bvalue> BOOL

%type <ivalue> iexpr
%type <fvalue> fexpr
%type <fvalue> nexpr
%type <bvalue> bexpr
%left '-' '+'
%left '*' '/' '%'
%right '^'
%nonassoc UMINUS

%%

program:
	program bexpr '\n'	{
					 if ($2.value == 1)
						 printf("True\n");
					 else
						 printf("False\n");
	   			}
|	program fexpr '\n'	{	printf("%f", $2.value);	}
|	program iexpr '\n'	{	printf("%d", $2.value);	}
|	program '\n'            ;
|
;

nexpr:
     iexpr		{ $$.value = (float)$1.value; }
| fexpr			{ $$.value = $1.value;	}

iexpr:
     INTEGER
| iexpr '+' iexpr		{ $$.value = $1.value + $3.value; }
| iexpr '-' iexpr		{ $$.value = $1.value - $3.value; }
| iexpr '*' iexpr     	{ $$.value = $1.value * $3.value; }
| iexpr '/' iexpr     	{ $$.value = $1.value / $3.value; }
| '(' iexpr ')'	    	{ $$.value = $2.value; }
| iexpr '^' iexpr 	{ $$.value = pow($1.value, $3.value); }
| '-' iexpr %prec UMINUS	{ $$.value = -$2.value; }

fexpr:
     FLOAT
| nexpr '+' nexpr		{ $$.value = $1.value + $3.value; }
| nexpr '-' nexpr		{ $$.value = $1.value - $3.value; }
| nexpr '*' nexpr     	{ $$.value = $1.value * $3.value; }
| nexpr '/' nexpr     	{ $$.value = $1.value / $3.value; }
| '(' fexpr ')'	    	{ $$.value = $2.value; }
| nexpr '^' nexpr 	{ $$.value = pow($1.value, $3.value); }
| '-' fexpr %prec UMINUS	{ $$.value = -$2.value; }
/*Last 4 rules ought to be redundant; but are not (reasons unclear).
Try to fix */
| iexpr '+' nexpr	{ $$.value = $1.value + $3.value; }
| iexpr '-' nexpr	{ $$.value = $1.value - $3.value; }
| iexpr '*' nexpr	{ $$.value = $1.value * $3.value; }
| iexpr '/' nexpr	{ $$.value = $1.value / $3.value; }

bexpr:
     BOOL
| nexpr '>' nexpr	{ $$.value = $1.value > $3.value ? 1 : 0; }
| nexpr '<' nexpr	{ $$.value = $1.value < $3.value ? 1 : 0; }
| nexpr '=' '=' nexpr 	{ $$.value = $1.value == $4.value ? 1 : 0; }
| nexpr '>' '=' nexpr	{ $$.value = $1.value >= $4.value ? 1 : 0; }
| nexpr '<' '=' nexpr	{ $$.value = $1.value <= $4.value ? 1 : 0; }

/*expr:
	iexpr         
|	fexpr
|	bexpr
;
*/
%%

void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
}

int main(void) {
yyparse();
return 0;
}
