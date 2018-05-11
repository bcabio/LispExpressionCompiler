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
	struct ast *node;
	double num;
}

%token ENDL
%token SEMI
%token RPAREN
%token LPAREN
%token NUM

%type <num> NUM
%type <node> lisp list seq

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
	| "car" LPAREN list RPAREN { $$ = newast("lisp", ((struct listnode *) $3)->current); }
	;

list:
	seq
	;

seq:
	lisp { $$ = newlist($1, NULL); }
	| seq lisp { $$ = newast($1, $2); }
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
	a->u.children.l = l;
	a->u.children.r = r;
	return a;
}

struct ast *newnum(double d)
{
	struct ast *n = malloc(sizeof(struct ast));

	if(!n) {
		yyerror("Ran out of space");
		exit(1);
	}
	n->nodetype = "number";
	n->u->value = d;
	return n;
}


struct ast *newlist(struct ast *current, struct ast* next) 
{
	struct ast *n = malloc(sizeof(struct ast));

	if(!n) {
		yyerror("Ran out of space");
		exit(1);
	}

	n->nodetype = "list";
	n->u-listnode->current = current;
	n->u->listnode->next = next;

	return n;
}


double eval(struct ast *node) 
{
	double v;
	const char* nt = node->nodetype;
	
	if(nt == "number") {
		return ((struct numnode *) node)->number; 
	} 
	else if(nt == "+") {
		return eval(node->u->children->l) + eval(node->u->children->r); 
	}
	else if(nt == "-") {
		return eval(node->u->children->l) - eval(node->u->children-->r); 
	}
	else if(nt == "*") {
		return eval(node->u->children->l) * eval(node->u->children->r); 
	}
	else if(nt == "/") {
		if (eval(node->r) == 0) {
			yyerror("Cannot divide by zero");
			exit(1);
		}

		return eval(node->u->children->l) / eval(node->u->children->r); 
	} 
	else if(nt == "lisp") {
		// If only one subtree, it'll be left
		return eval(node->l);
	}
	else if(nt == "car") {
		// v = node->
		return v;
	}
	else {
		yyerror("Internal error: bad eval node");
		exit(1);
	}
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