%{
#include <cstdio>
#include <iostream>
#include "kek.h"
using namespace std;

#define YYMAXDEPTH 50000

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
%token CAR
%token CDR

%type <d> NUM
%type <a> lisp list	

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
	;

lisp:
	NUM { $$ = newnum($1); }
	| LPAREN '+' lisp lisp RPAREN { $$ = newast("+", $3, $4); }
	| LPAREN '-' lisp lisp RPAREN { $$ = newast("-", $3, $4); }
	| LPAREN '*' lisp lisp RPAREN { $$ = newast("*", $3, $4); }
	| LPAREN '/' lisp lisp RPAREN { $$ = newast("/", $3, $4); }
	| LPAREN CAR LPAREN list RPAREN RPAREN { $$ = newast("car", NULL, $4); printf("%f\n", eval($$)); }
	;

list:
	lisp { $$ = newlist(eval($1), NULL); }
	| lisp list { $$ = newlist(eval($1), $2); }
	| CDR LPAREN list RPAREN { 
		$$ = newlist(
				$3->u.listnode.next->u.listnode.value, // Get next node's value
				$3->u.listnode.next->u.listnode.next); // Get next next node
		}
	;
%%

int main(int, char**) 
{
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
	struct ast *a = (struct ast*) malloc(sizeof(struct ast));

	if(!a) {
		yyerror("Ran out of space");
		exit(1);
	}
	a->nodetype = "number";
	a->u.value = d;
	return a;
}


struct ast *newlist(double d, struct ast* next) 
{
	struct ast *a = (struct ast*) malloc(sizeof(struct ast));
	if(!a) {
		yyerror("Ran out of space");
		exit(1);
	}

	a->nodetype = "list";
	a->u.listnode.value = d;
	a->u.listnode.next = next;
	return a;
}


double eval(struct ast *node) 
{
	double v;
	const char* nt = node->nodetype;
	
	if(nt == "number") {
		return node->u.value; 
	} 
	else if(nt == "+") {
		return eval(node->u.children.l) + eval(node->u.children.r); 
	}
	else if(nt == "-") {
		return eval(node->u.children.l) - eval(node->u.children.r); 
	}
	else if(nt == "*") {
		return eval(node->u.children.l) * eval(node->u.children.r); 
	}
	else if(nt == "/") {
		if (eval(node->u.children.r) == 0) {
			yyerror("Cannot divide by zero");
			exit(1);
		}

		return eval(node->u.children.l) / eval(node->u.children.r);
	} 
	else if(nt == "car") {
		return node->u.children.r->u.listnode.value;
	}
	else if(nt == "list") {
		return node->u.listnode.value;
	}
	else {
		yyerror("Internal error: bad eval node");
	}
}


void treefree(struct ast *node) 
{
	const char* nt = node->nodetype;
	
	if(nt == "+" || nt == "-" || nt == "*" || nt == "/") {
		treefree(node->u.children.r);
	}
	else if (nt == "number") {
		free(node);
	}
	else {
		yyerror("Internal error: bad free node");
	}
}