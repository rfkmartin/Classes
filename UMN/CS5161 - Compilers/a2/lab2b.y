%{
/* CSci 5161 - Compilers
   Robert F.K. Martin
   ID# 1505151

   Homework Assignment #2, Problem b
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream.h>
#include "symtab.h"
#define INTEGER 0
#define FLOATER 1
int linenumber = 1;
int scope;
char buff[256];
char *dummy;
SymbolTable st;
extern FILE *yyin;
extern char *yytext;
%}

%union
{
  int num;
  char* lexeme;
}

%token <lexeme> ID
%token <lexeme> CONSTANT
%token VOID    
%token MAIN
%token INT     
%token FLOAT   
%token IF      
%token ELSE    
%token WHILE   
%token FOR
%token TYPEDEF 
%token OP_ASSIGN  
%token OP_OR   
%token OP_AND  
%token OP_NOT  
%token OP_EQ   
%token OP_NE   
%token OP_GT   
%token OP_LT   
%token OP_GE   
%token OP_LE   
%token OP_PLUS 
%token OP_MINUS        
%token OP_TIMES        
%token OP_DIVIDE       
%token MK_LPAREN       
%token MK_RPAREN       
%token MK_LBRACE       
%token MK_LSQBRACE       
%token MK_RSQBRACE       
%token MK_RBRACE       
%token MK_COMMA        
%token MK_SEMICOLON    
%token ERROR
%token RETURN

%type <lexeme> init_id_list, init_id, id_list
%type <num> type

%start program

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
program         : global_decl_list
                ;

global_decl_list: global_decl_list global_decl
                |
                ;

global_decl     : decl_list function_decl
                | function_decl
                ;

function_decl   : type ID
					{
					SymbolTable::setscope(++scope);
					}
				MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE
					{
					st.clean();
					SymbolTable::setscope(--scope);
					}
				| ID ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE
                | VOID ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE
                | type ID
					{
					SymbolTable::setscope(++scope);
					}
				MK_LPAREN  MK_RPAREN MK_LBRACE block MK_RBRACE
					{
					st.clean();
					SymbolTable::setscope(--scope);
					}
                | ID ID MK_LPAREN  MK_RPAREN MK_LBRACE block MK_RBRACE
                | VOID ID MK_LPAREN  MK_RPAREN MK_LBRACE block MK_RBRACE
                ;

param_list      : param_list MK_COMMA  param 
                | param 
                ;

param           : type ID
					{
					SymbolTable::setscope(++scope);
					printf("%d %s %d\n", $1, $2, scope);
					dummy = strtok($2, ",");
					if (dummy == NULL)
						{
						if (!checkVar($2))
							st.insert($2, $1, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						}
					else
						{
						if (!checkVar(dummy))
							st.insert(dummy, $1, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						while ((dummy = strtok(NULL, ",")) != NULL)
							{
							if (!checkVar(dummy))
								st.insert(dummy, $1, "");
							else
								{
								sprintf(buff, "   ID %s declared more than once.", dummy); 
								yyerror(buff);
								}
							} /* end while */
						} /* end else */
					}
				| ID ID
				| type ID dim_fn
					{
					printf("%d %s %d\n", $1, $2, scope);
					dummy = strtok($2, ",");
					if (dummy == NULL)
						{
						if (!checkVar($2))
							st.insert($2, $1, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						}
					else
						{
						if (!checkVar(dummy))
							st.insert(dummy, $1, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						while ((dummy = strtok(NULL, ",")) != NULL)
							{
							if (!checkVar(dummy))
								st.insert(dummy, $1, "");
							else
								{
								sprintf(buff, "   ID %s declared more than once.", dummy); 
								yyerror(buff);
								}
							} /* end while */
						} /* end else */
					}
				| ID ID dim_fn
                ;

dim_fn  		: MK_LSQBRACE expr_null MK_RSQBRACE dim_fn1
				;

dim_fn1			: MK_LSQBRACE expr MK_RSQBRACE dim_fn1
				| 
				;
		
expr_null		: expr
				|
				;

block           : decl_list stmt_list 
                | stmt_list
                | decl_list
                |
                ;
 
decl_list       : decl_list decl
                | decl
                ;

decl            : type_decl
                | var_decl
                ;

type_decl       : TYPEDEF type id_list MK_SEMICOLON
					{
					/* printf("%d %s %d\n", $2, $3, scope); */
					dummy = strtok($3, ",");
					if (dummy == NULL)
						{
						if (!checkVar($3))
							st.insert($3, $2, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						}
					else
						{
						if (!checkVar(dummy))
							st.insert(dummy, $2, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						while ((dummy = strtok(NULL, ",")) != NULL)
							{
							if (!checkVar(dummy))
								st.insert(dummy, $2, "");
							else
								{
								sprintf(buff, "   ID %s declared more than once.", dummy); 
								yyerror(buff);
								}
							} /* end while */
						} /* end else */
					}
				| TYPEDEF VOID id_list MK_SEMICOLON
                ;

var_decl        : type init_id_list MK_SEMICOLON
					{
					/* printf("%d %s %d\n", $1, $2, scope); */
					dummy = strtok($2, ",");
					if (!checkVar($2))
						st.insert($2, $1, "");
					else
						{
						sprintf(buff, "   ID %s declared more than once.", dummy);
						yyerror(buff);
						}
					while ((dummy = strtok(NULL, ",")) != NULL)
						{
						if (!checkVar(dummy))
							st.insert(dummy, $1, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						} /* end while */
					}
                | ID id_list MK_SEMICOLON 
                ;


type            : INT
					{ $$ = INTEGER; }
                | FLOAT
					{ $$ = FLOATER; }
                ;


id_list         : ID
					{
					sprintf(buff, "%s", $1);
					$$ = (char *)strdup(buff);
					}
                | id_list MK_COMMA ID
					{
					sprintf(buff, "%s", $1);
					$$ = (char *)strdup(buff);
					}
                | id_list MK_COMMA ID dim
       		 	| ID dim
				;


init_id_list    : init_id
					{
					sprintf(buff, "%s", $1);
					$$ = (char *)strdup(buff);
					}
                | init_id_list MK_COMMA init_id 
					{
					sprintf(buff, ",%s", $3);
					$$ = (char *)strcat($$, buff);
					}
                ;

init_id         : ID
					{ sprintf(buff, "%s", $1);
					$$ = (char *)strdup(buff);
					}
				| ID dim
                | ID OP_ASSIGN relop_expr
                ;

stmt_list       : stmt_list stmt
                | stmt
                ;
		
/*  You will have to handle loop constructs and conditional expressions here */
/* These have been removed from the statement section */
stmt            : MK_LBRACE
					{
					SymbolTable::setscope(++scope);
					}
				block MK_RBRACE
					{
					st.clean();
					SymbolTable::setscope(--scope);
					}
                | ID  OP_ASSIGN relop_expr MK_SEMICOLON
                | ID  dim OP_ASSIGN relop_expr  MK_SEMICOLON
                | ID MK_LPAREN relop_expr_list MK_RPAREN MK_SEMICOLON
				| FOR MK_LPAREN for_expr MK_SEMICOLON relop_expr MK_SEMICOLON ID OP_ASSIGN expr MK_RPAREN stmt
				| WHILE MK_LPAREN relop_expr MK_RPAREN stmt
				| matched
				| unmatched
                | MK_SEMICOLON
                | RETURN MK_SEMICOLON
                | RETURN relop_expr MK_SEMICOLON
                ;
				
for_expr		: ID  OP_ASSIGN relop_expr
				| relop_expr
				|
				;

matched:		IF MK_LPAREN relop_expr MK_RPAREN stmt ELSE stmt
				|
				;

unmatched:		IF MK_LPAREN relop_expr MK_RPAREN stmt
				| IF MK_LPAREN relop_expr MK_RPAREN stmt ELSE stmt
				;
				
relop_expr      : relop_term
                | relop_expr OP_OR relop_term
                ;

relop_term      : relop_factor
                | relop_term OP_AND relop_factor
                ;

relop_factor    : expr
                | expr rel_op expr
                ;

rel_op          : OP_EQ
                | OP_GE
                | OP_LE
                | OP_NE
                | OP_GT
                | OP_LT
                ;

relop_expr_list : nonempty_relop_expr_list 
                | 
                ;

nonempty_relop_expr_list        : nonempty_relop_expr_list MK_COMMA relop_expr
                | relop_expr
                ;

expr            : expr add_op term
                | term
                ;

add_op          : OP_PLUS
                | OP_MINUS
                ;

term            : term mul_op factor
                | factor
                ;

mul_op          : OP_TIMES
                | OP_DIVIDE
                ;

factor          : MK_LPAREN relop_expr MK_RPAREN
                | OP_MINUS MK_LPAREN relop_expr MK_RPAREN
                | OP_NOT MK_LPAREN relop_expr MK_RPAREN
                | ID
					{
					if (checkVar($1))
						;
					else
						{
						sprintf(buff, "   ID %s is not declared", $1);
						yyerror(buff);
						}
					}
                | OP_MINUS ID
                | OP_NOT ID
                | CONSTANT
                | OP_MINUS CONSTANT
                | OP_NOT  CONSTANT
                | ID MK_LPAREN relop_expr_list MK_RPAREN
                | OP_MINUS ID MK_LPAREN relop_expr_list MK_RPAREN
                | OP_NOT ID MK_LPAREN relop_expr_list MK_RPAREN
				| ID dim
        		| OP_MINUS ID dim
        		| OP_NOT ID dim
                ;

dim 			: MK_LSQBRACE expr MK_RSQBRACE
				| dim MK_LSQBRACE expr MK_RSQBRACE
				;
				
%%
void yyerror (char *);


/* #include "lex.yy.c" */
void main (int argc, char *argv[])
{
	argc--; argv++;
	if (argc > 0) 
		yyin = fopen(argv[0],"r");
	else 
		yyin = stdin;

	scope = 1;
	SymbolTable::setscope(scope);
	yyparse();

/*	st.print(); */

	fclose(yyin);
} 

void yyerror (char *mesg)
{
	printf("%s%d\n%s\n", "Error found in line ", linenumber, mesg);
}

int checkVar(char *dummy)
{
	if ((void *)st.find(dummy, scope) != NULL)
		return 1;
	else
		return 0;
}
