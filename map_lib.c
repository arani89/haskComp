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

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include "map_lib.h"
#include "defs.h"

map_symTab *map_symTab_create() {
   map_symTab *m;
   m=(map_symTab *)malloc(sizeof(map_symTab));
   m->name=NULL;
   m->value=NULL;
   m->nxt=NULL;

   return m;
}


void map_symTab_set(map_symTab *m,char *name,symTabEntry *value) {
   map_symTab *map;

   if(m->name==NULL) {
      m->name=(char *)malloc(strlen(name)+1);
      strcpy(m->name,name);
      //m->value=(symTabEntry *)malloc(sizeof(symTabEntry));
      m->value = value;
      m->nxt=NULL;
      return;
   }
   for(map=m;;map=map->nxt) {
      if(!strcmp(name,map->name)) {
         if(map->value!=NULL) {
            free(map->value);
            //map->value=(symTabEntry *)malloc(sizeof(symTabEntry));
	    map->value = value;
            return;
         }
      }
      if(map->nxt==NULL) {
         map->nxt=(map_symTab *)malloc(sizeof(map_symTab));
         map=map->nxt;
         map->name=(char *)malloc(strlen(name)+1);
         strcpy(map->name,name);
         //map->value=(symTabEntry *)malloc(sizeof(symTabEntry));
	 map->value = value;
         map->nxt=NULL;
         return;
      }      
   }
}

symTabEntry *map_symTab_get(map_symTab *m,char *name) {
   map_symTab *map;
   for(map=m;map!=NULL;map=map->nxt) {
      if(map->name != NULL && !strcmp(name,map->name)) {
         return map->value;
      }
   }
   return NULL;
}
 
map_data *map_data_create() {
   map_data *m;
   m=(map_data *)malloc(sizeof(map_data));
   m->name=NULL;
   m->value=0;
   m->nxt=NULL;

   return m;
}


void map_data_set(map_data *m,char *name,int value) {
   map_data *map;

   if(m->name==NULL) {
      m->name=(char *)malloc(strlen(name)+1);
      strcpy(m->name,name);
      m->value = value;
      m->nxt=NULL;
      return;
   }
   for(map=m;;map=map->nxt) {
      if(!strcmp(name,map->name)) {
         if(map->value!=-1) {
            //free(map->value);
            map->value = value;
            return;
         }
      }
      if(map->nxt==NULL) {
         map->nxt=(map_data *)malloc(sizeof(map_data));
         map=map->nxt;
         map->name=(char *)malloc(strlen(name)+1);
         strcpy(map->name,name);
         map->value = value;
         map->nxt=NULL;
         return;
      }      
   }
}

int map_data_get(map_data *m,char *name) {
   map_data *map;
   for(map=m;map!=NULL;map=map->nxt) {
      if(!strcmp(name,map->name)) {
         return map->value;
      }
   }
   return -1;
}
 

