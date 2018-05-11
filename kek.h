
extern int yylineno;

void yyerror(const char *s);

// ast Nodes
struct ast 
{
    const char* nodetype;
    struct ast *l;
    struct ast *r;
};

// number structs for number leaf nodes?
struct numnode 
{
    const char* nodetype;
    double number;
};

struct listnode
{
    const char* nodetype;
    struct listnode *next;
};

// building the ast
struct ast *newast(const char* nodetype, struct ast *l, struct ast *r);
struct ast *newnum(double d);
struct ast *newlist(struct ast* next);

// Evaluating the ast
double eval(struct ast *);

// Deleting and freeing an ast
void treefree(struct ast *);

// Fix the list stuff yo