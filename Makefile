# A Makefile for simple lex and yacc examples

# Comment out the proper lines below according to the scanner and
# parser generators available in your system

LEX = lex
YACC = yacc -d
# LEX = flex 
# YACC = bison -d

# We assume that your C-compiler is called cc

CC = cc -Wall -g

# calc is the final object that we will generate, it is produced by
# the C compiler from the y.tab.o and from the lex.yy.o

a.out: y.tab.o lex.yy.o map_lib.o misc.o
	$(CC) y.tab.o lex.yy.o map_lib.o misc.o -lfl -lm

# These dependency rules indicate that (1) lex.yy.o depends on
# lex.yy.c and y.tab.h and (2) lex.yy.o and y.tab.o depend on calc.h.
# Make uses the dependencies to figure out what rules must be run when
# a file has changed.

lex.yy.o: lex.yy.c y.tab.h

map_lib.o: map_lib.c map_lib.h

misc.o: misc.c misc.h

## This rule will use yacc to generate the files y.tab.c and y.tab.h
## from our file calc.y

y.tab.c y.tab.h: parser.yy
	$(YACC) -v parser.yy 

## this is the make rule to use lex to generate the file lex.yy.c from
## our file calc.l

lex.yy.c: analyzer.lex
	$(LEX) analyzer.lex


## Make clean will delete all of the generated files so we can start
## from scratch

clean:
	-rm -f *.o lex.yy.c *.tab.*  haskComp *.output

