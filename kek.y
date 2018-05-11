%{
#include <cstdio>
#include <iostream>
#include "kek.h"
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern int line_num; 

void yyerror(const char *s);
%}


%union 
{
	struct ast *a;
	double d;
}

%token ENDL
%token SEMI
%token RPAREN
%token LPAREN
%token NUM

%type <d> NUM
%type <a> lisp list seq

%%

kek:
	lines
	;

lines:
	line SEMI ENDL
	| lines line SEMI ENDL
	;

line:
	lisp { printf("Value %4.4g\n", eval($1)); }
	| list
	;

lisp:
	NUM { $$ = newnum($1); }
	| LPAREN '+' lisp lisp RPAREN { $$ = newast("+", $3, $4); }
	| LPAREN '-' lisp lisp RPAREN { $$ = newast("-", $3, $4); }
	| LPAREN '*' lisp lisp RPAREN { $$ = newast("*", $3, $4); }
	| LPAREN '/' lisp lisp RPAREN { $$ = newast("/", $3, $4); }
	| "car" LPAREN list RPAREN { $$ = newast("list", NULL, $3); }
	;

list:
	seq
	;

seq:
	lisp { $$ = newlist(NULL); }
	| seq lisp
	;
%%
int main(int, char**) 
{
	printf("> ");
	yyparse();
	
}

void yyerror(const char *s) 
{
	cout << "EEK, parse error on line " << s << endl;
	// might as well halt now:
	exit(-1);
}

struct ast *newast(const char* nodetype, struct ast *l, struct ast *r) 
{	
	struct ast *a = (struct ast*) malloc(sizeof(struct ast));

	if(!a) {
		yyerror("Ran out of memory");
		exit(1);
	}

	a->nodetype = nodetype;
	a->l = l;
	a->r = r;
	return a;
}

struct ast *newnum(double d)
{
	struct numnode *n = (struct numnode*) malloc(sizeof(struct numnode));

	if(!n) {
		yyerror("Ran out of space");
		exit(1);
	}
	n->nodetype = "number";
	n->number = d;
	return (struct ast *) n;
}


struct ast *newlist(struct ast* next) 
{
	struct listnode *n = (struct listnode*) malloc(sizeof(struct listnode));
	if(!n) {
		yyerror("Ran out of space");
		exit(1);
	}

	n->nodetype = "list";
	n->next = next;
	return (struct ast *) n;
}


double eval(struct ast *node) 
{
	double v;
	const char* nt = node->nodetype;
	
	if(nt == "number") {
		v = ((struct numnode *) node)->number; 
	} 
	else if(nt == "+") {
		v = eval(node->l) + eval(node->r); 
	}
	else if(nt == "-") {
		v = eval(node->l) - eval(node->r); 
	}
	else if(nt == "*") {
		v = eval(node->l) * eval(node->r); 
	}
	else if(nt == "/") {
		if (eval(node->r) == 0) {
			yyerror("Cannot divide by zero");
			exit(1);
		}

		v = eval(node->l) / eval(node->r);
	} 
	else {
		yyerror("Internal error: bad eval node");
	}
	return v;
}


void treefree(struct ast *node) 
{
	const char* nt = node->nodetype;
	
	if(nt == "+" || nt == "-" || nt == "*" || nt == "/") {
		treefree(node->r);
	}
	else if (nt == "number") {
		free(node);
	}
	else {
		yyerror("Internal error: bad free node");
	}
}