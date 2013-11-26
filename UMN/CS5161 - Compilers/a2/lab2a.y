%{
%}

%union
{
	int num;
	char *lexeme;
}

%token <lexeme> ID
%token <num> CONSTANT
%token OP_ASSIGN
%token OP_PLUS
%token OP_MINUS
%token OP_TIMES
%token OP_DIVIDE
%token MK_LPAREN
%token MK_RPAREN

%right '='
%left '-' '+'
%left '*' '/'

%type <lexeme> expr

%% /* Grammar rules and actions follow */

input:	/* empty */
		| ID { printf("lvalue %s\n", $1); } OP_ASSIGN expr { printf("=\n"); }
;

expr:	expr OP_PLUS expr { printf("+\n"); }
		| expr OP_MINUS expr { printf("-\n"); }
		| expr OP_TIMES expr { printf("*\n"); }
		| expr OP_DIVIDE expr { printf("/\n"); }
		| CONSTANT OP_PLUS CONSTANT { printf("push %d\n", $1 + $3); }
		| CONSTANT OP_MINUS CONSTANT { printf("push %d\n", $1 - $3); }
		| CONSTANT OP_TIMES CONSTANT { printf("push %d\n", $1 * $3); }
		| CONSTANT OP_DIVIDE CONSTANT { printf("push %d\n", $1 / $3); }
		| MK_LPAREN expr MK_RPAREN { $$ = $2; } 
		| CONSTANT	{ printf("push %d\n", $1); }
		| ID		{ printf("rvalue %s\n", $1); }
;

%%

#include <ctype.h>
/* Possibly for later use.
   Cannot figure our compile errors
#include "lex.yy.c"
main (argc, argv)
     int argc;
char *argv[];
{
    argc--; argv++;
    if (argc > 0) 
      yyin = fopen(argv[0],"r");
    else 
      yyin = stdin;
    yyparse();
     printf("%s\n", "Parsing Successfully.");

     fclose(yyin);
  }
*/
main()
{
	yyparse();
}

#include <stdio.h>

yyerror (char *s)  /* Called by yyparse on error */
{
	printf ("Error: %s\n", s);
}
