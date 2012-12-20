// map_lib
// A simple associative-array library for C
//
// License: MIT / X11
// Copyright (c) 2009 by James K. Lawless
// jimbo@radiks.net http://www.radiks.net/~jimbo
// http://www.mailsend-online.com
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.


#ifndef MAP_LIB_H
#define MAP_LIB_H
#include "defs.h"
typedef struct map_symTab{
   struct map_symTab *nxt;
   char *name;
   symTabEntry *value;
}map_symTab ;

typedef struct map_data{
	struct map_data *nxt;
	char *name;
	int value;
}map_data;
	

map_symTab *map_symTab_create();
void map_symTab_set(map_symTab *m,char *name,symTabEntry *value);
symTabEntry *map_symTab_get(map_symTab *m,char *name);

map_data *map_data_create();
void map_data_set(map_data *m,char *name, int value);
int map_data_get(map_data *m,char *name);
#endif
 
