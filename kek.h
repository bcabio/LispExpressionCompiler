
extern int yylineno;

void yyerror(const char *s);

// ast Nodes
struct ast 
{
    const char* nodetype;
    union {
        struct {
            struct ast *r;
            struct ast *l;
        } children;

        struct {
            double value;
            struct ast* next;
        } listnode;
        
        double value;
    } u;
    
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
struct ast *newlist(double d, struct ast* next);

struct ast *append(struct ast* current, struct ast* next);


// Evaluating the ast
double eval(struct ast *);

// Deleting and freeing an ast
void treefree(struct ast *);

// Fix the list stuff yo