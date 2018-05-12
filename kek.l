%{
#include <cstdio>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "kek.tab.h"

%}
%%
"+" |
"-" |
"*" |
"/" 			{ return yytext[0]; }
";" 			{ return SEMI; }
\n				{ return ENDL; }
"("				{ return LPAREN; }
")"				{ return RPAREN; }
"car"           { return CAR; }
[ \t]			;
[0-9]+			{ yylval.d = atoi(yytext); return NUM; }
. ;
%%
