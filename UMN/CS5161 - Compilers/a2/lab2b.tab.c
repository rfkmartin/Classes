
# line 2 "lab2b.y"
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

# line 24 "lab2b.y"
typedef union
#ifdef __cplusplus
	YYSTYPE
#endif

{
  int num;
  char* lexeme;
} YYSTYPE;
# define ID 257
# define CONSTANT 258
# define VOID 259
# define MAIN 260
# define INT 261
# define FLOAT 262
# define IF 263
# define ELSE 264
# define WHILE 265
# define FOR 266
# define TYPEDEF 267
# define OP_ASSIGN 268
# define OP_OR 269
# define OP_AND 270
# define OP_NOT 271
# define OP_EQ 272
# define OP_NE 273
# define OP_GT 274
# define OP_LT 275
# define OP_GE 276
# define OP_LE 277
# define OP_PLUS 278
# define OP_MINUS 279
# define OP_TIMES 280
# define OP_DIVIDE 281
# define MK_LPAREN 282
# define MK_RPAREN 283
# define MK_LBRACE 284
# define MK_LSQBRACE 285
# define MK_RSQBRACE 286
# define MK_RBRACE 287
# define MK_COMMA 288
# define MK_SEMICOLON 289
# define ERROR 290
# define RETURN 291

#ifdef __STDC__
#include <stdlib.h>
#include <string.h>
#else
#include <malloc.h>
#include <memory.h>
#endif

#include <values.h>

#ifdef __cplusplus

#ifndef yyerror
	void yyerror(const char *);
#endif

#ifndef yylex
#ifdef __EXTERN_C__
	extern "C" { int yylex(void); }
#else
	int yylex(void);
#endif
#endif
	int yyparse(void);

#endif
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern int yyerrflag;
YYSTYPE yylval;
YYSTYPE yyval;
typedef int yytabelem;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#if YYMAXDEPTH > 0
int yy_yys[YYMAXDEPTH], *yys = yy_yys;
YYSTYPE yy_yyv[YYMAXDEPTH], *yyv = yy_yyv;
#else	/* user does initial allocation */
int *yys;
YYSTYPE *yyv;
#endif
static int yymaxdepth = YYMAXDEPTH;
# define YYERRCODE 256

# line 435 "lab2b.y"

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
static const yytabelem yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 17,
	282, 6,
	-2, 45,
	};
# define YYNPROD 110
# define YYLAST 395
static const yytabelem yyact[]={

   128,    52,    53,   198,    12,    13,   136,   191,   130,   129,
    14,   154,    35,    66,   149,    51,    70,   136,   187,   130,
   129,    70,    70,    50,    70,   186,    49,   127,    35,    65,
    35,    34,   133,   161,   134,   185,   204,   173,   127,    31,
    30,   197,   188,   133,   182,   134,   103,   101,    95,    80,
    81,    96,    96,    96,    38,    80,    81,   206,    80,    81,
   192,   156,   169,   105,   184,   156,    94,   142,   167,   151,
    52,    53,   179,    53,    92,   158,   176,    29,    29,   158,
   116,   196,    29,    29,    51,   113,    51,    28,    29,    42,
   138,    29,    50,    42,    50,    49,    92,    49,    61,    29,
    70,    70,    12,    13,    29,    74,    77,    78,    79,    75,
    76,    80,    81,    61,   194,   193,    32,    12,    13,    29,
    80,    81,    70,    70,    64,   212,    70,   140,   121,   104,
   102,    97,    90,    91,    87,    88,   146,   144,   190,    58,
   111,   171,   170,   148,    68,   163,   160,   159,    83,    84,
    71,    41,    40,    36,    80,    81,     8,    89,     9,    86,
    12,    13,    70,   210,   205,    61,    14,   207,    56,    12,
    13,    24,    99,    12,    13,    98,    62,    38,    22,    20,
    17,   126,    46,   195,   125,   120,     6,   135,    27,   118,
     7,    16,     7,   137,    59,    48,   123,    47,    45,    57,
    19,     5,    23,    44,   124,    21,    15,     4,    82,    33,
    73,   119,    54,    72,    43,   132,   131,   178,   155,    11,
    60,    10,   164,    26,    60,    69,    25,    33,    60,    37,
    39,     3,    55,     2,     1,    85,    63,    18,     0,     0,
    67,    93,     0,     0,     0,     0,     0,     0,     0,     0,
     0,   100,     0,     0,     0,   108,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
   107,   109,   112,     0,   106,   115,   114,     0,   110,   117,
     0,     0,     0,     0,    60,     0,     0,     0,     0,     0,
     0,   122,     0,   139,     0,     0,     0,     0,     0,   141,
     0,   143,     0,   145,     0,     0,   147,   153,     0,   152,
     0,    16,     0,     0,     0,     0,     0,   157,   150,     0,
   162,   165,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,   153,   172,     0,   166,     0,   168,
     0,     0,   175,   157,     0,   180,   181,     0,   177,   183,
     0,     0,   174,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   189,     0,     0,     0,     0,     0,    93,     0,
     0,     0,     0,     0,     0,   201,   202,   199,   200,   203,
     0,     0,     0,     0,     0,     0,     0,   208,     0,     0,
   209,     0,     0,   211,   213 };
static const yytabelem yypact[]={

-10000000,-10000000,  -101,-10000000,  -101,-10000000,-10000000,   -77,   -78,   -79,
-10000000,-10000000,-10000000,-10000000,   -88,-10000000,-10000000,  -181,  -249,-10000000,
  -166,  -258,  -129,   -80,   -80,  -130,  -131,  -196,  -187,  -187,
-10000000,   -89,  -144,  -196,-10000000,   -81,  -159,  -260,  -194,  -276,
   -92,  -139,  -187,  -107,  -120,-10000000,  -167,  -132,-10000000,  -187,
  -123,  -125,  -186,-10000000,  -220,-10000000,  -181,  -235,  -153,-10000000,
   -82,   -85,  -194,  -236,  -154,-10000000,-10000000,  -237,  -155,  -223,
  -187,  -187,  -187,  -187,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,  -187,-10000000,-10000000,  -143,  -187,  -197,-10000000,  -187,
  -202,-10000000,  -187,  -196,-10000000,  -156,   -92,  -257,  -195,  -195,
  -196,  -157,  -257,  -217,  -257,-10000000,  -120,-10000000,  -124,  -132,
-10000000,-10000000,  -146,  -187,  -196,  -147,  -187,  -196,  -140,  -274,
  -107,  -257,-10000000,  -218,  -257,  -246,-10000000,-10000000,  -203,  -135,
  -136,-10000000,-10000000,-10000000,  -256,   -89,  -137,-10000000,  -187,-10000000,
  -257,  -219,  -257,  -225,-10000000,  -141,-10000000,  -142,-10000000,  -187,
  -250,-10000000,  -246,-10000000,  -207,  -257,  -187,  -192,  -187,  -185,
  -187,-10000000,  -245,  -187,  -222,  -124,  -252,-10000000,  -262,-10000000,
-10000000,-10000000,  -107,-10000000,  -269,  -247,  -187,  -145,  -282,  -208,
  -107,  -168,-10000000,  -169,  -204,-10000000,-10000000,-10000000,-10000000,  -248,
  -286,  -187,  -187,  -246,  -246,-10000000,  -187,-10000000,-10000000,  -253,
  -107,-10000000,  -100,  -229,   -90,  -246,  -204,  -105,-10000000,-10000000,
  -187,  -158,  -246,-10000000 };
static const yytabelem yypgo[]={

     0,   237,   200,   205,   187,   234,   233,   231,   204,   201,
   226,   199,   196,   223,   194,   193,   222,   183,   182,   184,
   186,   221,   219,   188,   185,   181,   218,   189,   217,   216,
   215,   203,   198,   213,   211,   210,   197,   208,   195 };
static const yytabelem yyr1[]={

     0,     5,     6,     6,     7,     7,    10,     9,     9,     9,
    13,     9,     9,     9,    11,    11,    14,    14,    14,    14,
    15,    17,    17,    16,    16,    12,    12,    12,    12,     8,
     8,    20,    20,    21,    21,    22,    22,     4,     4,     3,
     3,     3,     3,     1,     1,     2,     2,     2,    19,    19,
    26,    25,    25,    25,    25,    25,    25,    25,    25,    25,
    25,    25,    28,    28,    28,    29,    29,    30,    30,    24,
    24,    31,    31,    32,    32,    33,    33,    33,    33,    33,
    33,    27,    27,    34,    34,    18,    18,    35,    35,    36,
    36,    37,    37,    38,    38,    38,    38,    38,    38,    38,
    38,    38,    38,    38,    38,    38,    38,    38,    23,    23 };
static const yytabelem yyr2[]={

     0,     2,     4,     0,     4,     2,     1,    19,    16,    16,
     1,    17,    14,    14,     6,     2,     5,     4,     7,     6,
     8,     8,     0,     2,     0,     4,     2,     2,     0,     4,
     2,     2,     2,     9,     8,     7,     6,     3,     3,     3,
     7,     8,     4,     3,     7,     3,     4,     6,     4,     2,
     1,     9,     8,    10,    10,    22,    10,     2,     2,     2,
     4,     6,     6,     2,     0,    14,     0,    10,    14,     2,
     6,     2,     6,     2,     6,     2,     2,     2,     2,     2,
     2,     2,     0,     6,     2,     6,     2,     2,     2,     6,
     2,     2,     2,     6,     8,     8,     3,     4,     4,     2,
     4,     4,     8,    10,    10,     4,     6,     6,     6,     8 };
static const yytabelem yychk[]={

-10000000,    -5,    -6,    -7,    -8,    -9,   -20,    -4,   257,   259,
   -21,   -22,   261,   262,   267,    -9,   -20,   257,    -1,    -2,
   257,    -3,   257,    -4,   259,   -10,   -13,   -23,   268,   285,
   289,   288,   282,   -23,   289,   288,   282,    -3,   257,    -3,
   282,   282,   285,   -24,   -31,   -32,   -18,   -36,   -38,   282,
   279,   271,   257,   258,   -18,    -2,   257,   -11,   283,   -14,
    -4,   257,   257,   -11,   283,   289,   289,   -11,   283,   -18,
   269,   270,   -33,   -35,   272,   276,   277,   273,   274,   275,
   278,   279,   -37,   280,   281,   -24,   282,   257,   258,   282,
   257,   258,   282,   -23,   286,   283,   288,   284,   257,   257,
   -23,   283,   284,   283,   284,   286,   -31,   -32,   -18,   -36,
   -38,   283,   -24,   282,   -23,   -24,   282,   -23,   -27,   -34,
   -24,   284,   -14,   -12,    -8,   -19,   -25,   284,   257,   266,
   265,   -29,   -30,   289,   291,    -4,   263,   -15,   285,   -15,
   284,   -12,   284,   -12,   283,   -27,   283,   -27,   283,   288,
   -12,   287,   -19,   -25,   257,   -26,   268,   -23,   282,   282,
   282,   289,   -24,   282,   -16,   -18,   -12,   287,   -12,   287,
   283,   283,   -24,   287,   -12,   -24,   268,   -27,   -28,   257,
   -24,   -24,   289,   -24,   286,   287,   287,   287,   289,   -24,
   283,   289,   268,   283,   283,   -17,   285,   289,   289,   -24,
   -24,   -25,   -25,   -18,   289,   264,   286,   257,   -25,   -17,
   268,   -18,   283,   -25 };
static const yytabelem yydef[]={

     3,    -2,     1,     2,     0,     5,    30,     0,     0,     0,
    31,    32,    37,    38,     0,     4,    29,    -2,     0,    43,
    39,     0,     0,     0,     0,     0,     0,    46,     0,     0,
    35,     0,     0,    42,    36,     0,     0,     0,    39,     0,
     0,     0,     0,    47,    69,    71,    73,    86,    90,     0,
     0,     0,    96,    99,     0,    44,    45,     0,     0,    15,
     0,     0,    40,     0,     0,    33,    34,     0,     0,     0,
     0,     0,     0,     0,    75,    76,    77,    78,    79,    80,
    87,    88,     0,    91,    92,     0,     0,    97,   100,     0,
    98,   101,    82,   105,   108,     0,     0,    28,    16,    17,
    41,     0,    28,     0,    28,   109,    70,    72,    74,    85,
    89,    93,     0,    82,   106,     0,    82,   107,     0,    81,
    84,    28,    14,     0,    27,    26,    49,    50,     0,     0,
     0,    57,    58,    59,     0,     0,     0,    18,    24,    19,
    28,     0,    28,     0,    94,     0,    95,     0,   102,     0,
     0,    12,    25,    48,     0,    28,     0,     0,    82,    64,
     0,    60,     0,     0,     0,    23,     0,    13,     0,    11,
   103,   104,    83,     8,     0,     0,     0,     0,     0,    96,
    63,     0,    61,     0,    22,     9,     7,    51,    52,     0,
     0,     0,     0,    66,    66,    20,     0,    53,    54,     0,
    62,    56,    67,     0,     0,    66,    22,     0,    65,    21,
     0,     0,    66,    55 };
typedef struct
#ifdef __cplusplus
	yytoktype
#endif
{ char *t_name; int t_val; } yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	0	/* don't allow debugging */
#endif

#if YYDEBUG

yytoktype yytoks[] =
{
	"ID",	257,
	"CONSTANT",	258,
	"VOID",	259,
	"MAIN",	260,
	"INT",	261,
	"FLOAT",	262,
	"IF",	263,
	"ELSE",	264,
	"WHILE",	265,
	"FOR",	266,
	"TYPEDEF",	267,
	"OP_ASSIGN",	268,
	"OP_OR",	269,
	"OP_AND",	270,
	"OP_NOT",	271,
	"OP_EQ",	272,
	"OP_NE",	273,
	"OP_GT",	274,
	"OP_LT",	275,
	"OP_GE",	276,
	"OP_LE",	277,
	"OP_PLUS",	278,
	"OP_MINUS",	279,
	"OP_TIMES",	280,
	"OP_DIVIDE",	281,
	"MK_LPAREN",	282,
	"MK_RPAREN",	283,
	"MK_LBRACE",	284,
	"MK_LSQBRACE",	285,
	"MK_RSQBRACE",	286,
	"MK_RBRACE",	287,
	"MK_COMMA",	288,
	"MK_SEMICOLON",	289,
	"ERROR",	290,
	"RETURN",	291,
	"-unknown-",	-1	/* ends search */
};

char * yyreds[] =
{
	"-no such reduction-",
	"program : global_decl_list",
	"global_decl_list : global_decl_list global_decl",
	"global_decl_list : /* empty */",
	"global_decl : decl_list function_decl",
	"global_decl : function_decl",
	"function_decl : type ID",
	"function_decl : type ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE",
	"function_decl : ID ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE",
	"function_decl : VOID ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE",
	"function_decl : type ID",
	"function_decl : type ID MK_LPAREN MK_RPAREN MK_LBRACE block MK_RBRACE",
	"function_decl : ID ID MK_LPAREN MK_RPAREN MK_LBRACE block MK_RBRACE",
	"function_decl : VOID ID MK_LPAREN MK_RPAREN MK_LBRACE block MK_RBRACE",
	"param_list : param_list MK_COMMA param",
	"param_list : param",
	"param : type ID",
	"param : ID ID",
	"param : type ID dim_fn",
	"param : ID ID dim_fn",
	"dim_fn : MK_LSQBRACE expr_null MK_RSQBRACE dim_fn1",
	"dim_fn1 : MK_LSQBRACE expr MK_RSQBRACE dim_fn1",
	"dim_fn1 : /* empty */",
	"expr_null : expr",
	"expr_null : /* empty */",
	"block : decl_list stmt_list",
	"block : stmt_list",
	"block : decl_list",
	"block : /* empty */",
	"decl_list : decl_list decl",
	"decl_list : decl",
	"decl : type_decl",
	"decl : var_decl",
	"type_decl : TYPEDEF type id_list MK_SEMICOLON",
	"type_decl : TYPEDEF VOID id_list MK_SEMICOLON",
	"var_decl : type init_id_list MK_SEMICOLON",
	"var_decl : ID id_list MK_SEMICOLON",
	"type : INT",
	"type : FLOAT",
	"id_list : ID",
	"id_list : id_list MK_COMMA ID",
	"id_list : id_list MK_COMMA ID dim",
	"id_list : ID dim",
	"init_id_list : init_id",
	"init_id_list : init_id_list MK_COMMA init_id",
	"init_id : ID",
	"init_id : ID dim",
	"init_id : ID OP_ASSIGN relop_expr",
	"stmt_list : stmt_list stmt",
	"stmt_list : stmt",
	"stmt : MK_LBRACE",
	"stmt : MK_LBRACE block MK_RBRACE",
	"stmt : ID OP_ASSIGN relop_expr MK_SEMICOLON",
	"stmt : ID dim OP_ASSIGN relop_expr MK_SEMICOLON",
	"stmt : ID MK_LPAREN relop_expr_list MK_RPAREN MK_SEMICOLON",
	"stmt : FOR MK_LPAREN for_expr MK_SEMICOLON relop_expr MK_SEMICOLON ID OP_ASSIGN expr MK_RPAREN stmt",
	"stmt : WHILE MK_LPAREN relop_expr MK_RPAREN stmt",
	"stmt : matched",
	"stmt : unmatched",
	"stmt : MK_SEMICOLON",
	"stmt : RETURN MK_SEMICOLON",
	"stmt : RETURN relop_expr MK_SEMICOLON",
	"for_expr : ID OP_ASSIGN relop_expr",
	"for_expr : relop_expr",
	"for_expr : /* empty */",
	"matched : IF MK_LPAREN relop_expr MK_RPAREN stmt ELSE stmt",
	"matched : /* empty */",
	"unmatched : IF MK_LPAREN relop_expr MK_RPAREN stmt",
	"unmatched : IF MK_LPAREN relop_expr MK_RPAREN stmt ELSE stmt",
	"relop_expr : relop_term",
	"relop_expr : relop_expr OP_OR relop_term",
	"relop_term : relop_factor",
	"relop_term : relop_term OP_AND relop_factor",
	"relop_factor : expr",
	"relop_factor : expr rel_op expr",
	"rel_op : OP_EQ",
	"rel_op : OP_GE",
	"rel_op : OP_LE",
	"rel_op : OP_NE",
	"rel_op : OP_GT",
	"rel_op : OP_LT",
	"relop_expr_list : nonempty_relop_expr_list",
	"relop_expr_list : /* empty */",
	"nonempty_relop_expr_list : nonempty_relop_expr_list MK_COMMA relop_expr",
	"nonempty_relop_expr_list : relop_expr",
	"expr : expr add_op term",
	"expr : term",
	"add_op : OP_PLUS",
	"add_op : OP_MINUS",
	"term : term mul_op factor",
	"term : factor",
	"mul_op : OP_TIMES",
	"mul_op : OP_DIVIDE",
	"factor : MK_LPAREN relop_expr MK_RPAREN",
	"factor : OP_MINUS MK_LPAREN relop_expr MK_RPAREN",
	"factor : OP_NOT MK_LPAREN relop_expr MK_RPAREN",
	"factor : ID",
	"factor : OP_MINUS ID",
	"factor : OP_NOT ID",
	"factor : CONSTANT",
	"factor : OP_MINUS CONSTANT",
	"factor : OP_NOT CONSTANT",
	"factor : ID MK_LPAREN relop_expr_list MK_RPAREN",
	"factor : OP_MINUS ID MK_LPAREN relop_expr_list MK_RPAREN",
	"factor : OP_NOT ID MK_LPAREN relop_expr_list MK_RPAREN",
	"factor : ID dim",
	"factor : OP_MINUS ID dim",
	"factor : OP_NOT ID dim",
	"dim : MK_LSQBRACE expr MK_RSQBRACE",
	"dim : dim MK_LSQBRACE expr MK_RSQBRACE",
};
#endif /* YYDEBUG */
# line	1 "/usr/ccs/bin/yaccpar"
/*
 * Copyright (c) 1993 by Sun Microsystems, Inc.
 */

#pragma ident	"@(#)yaccpar	6.14	97/01/16 SMI"

/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define YYERROR		goto yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( yychar >= 0 || ( yyr2[ yytmp ] >> 1 ) != 1 )\
	{\
		yyerror( "syntax error - cannot backup" );\
		goto yyerrlab;\
	}\
	yychar = newtoken;\
	yystate = *yyps;\
	yylval = newvalue;\
	goto yynewstate;\
}
#define YYRECOVERING()	(!!yyerrflag)
#define YYNEW(type)	malloc(sizeof(type) * yynewmax)
#define YYCOPY(to, from, type) \
	(type *) memcpy(to, (char *) from, yymaxdepth * sizeof (type))
#define YYENLARGE( from, type) \
	(type *) realloc((char *) from, yynewmax * sizeof(type))
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-10000000)

/*
** global variables used by the parser
*/
YYSTYPE *yypv;			/* top of value stack */
int *yyps;			/* top of state stack */

int yystate;			/* current state */
int yytmp;			/* extra var (lasts between blocks) */

int yynerrs;			/* number of errors */
int yyerrflag;			/* error recovery flag */
int yychar;			/* current input token number */



#ifdef YYNMBCHARS
#define YYLEX()		yycvtok(yylex())
/*
** yycvtok - return a token if i is a wchar_t value that exceeds 255.
**	If i<255, i itself is the token.  If i>255 but the neither 
**	of the 30th or 31st bit is on, i is already a token.
*/
#if defined(__STDC__) || defined(__cplusplus)
int yycvtok(int i)
#else
int yycvtok(i) int i;
#endif
{
	int first = 0;
	int last = YYNMBCHARS - 1;
	int mid;
	wchar_t j;

	if(i&0x60000000){/*Must convert to a token. */
		if( yymbchars[last].character < i ){
			return i;/*Giving up*/
		}
		while ((last>=first)&&(first>=0)) {/*Binary search loop*/
			mid = (first+last)/2;
			j = yymbchars[mid].character;
			if( j==i ){/*Found*/ 
				return yymbchars[mid].tvalue;
			}else if( j<i ){
				first = mid + 1;
			}else{
				last = mid -1;
			}
		}
		/*No entry in the table.*/
		return i;/* Giving up.*/
	}else{/* i is already a token. */
		return i;
	}
}
#else/*!YYNMBCHARS*/
#define YYLEX()		yylex()
#endif/*!YYNMBCHARS*/

/*
** yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
#if defined(__STDC__) || defined(__cplusplus)
int yyparse(void)
#else
int yyparse()
#endif
{
	register YYSTYPE *yypvt = 0;	/* top of value stack for $vars */

#if defined(__cplusplus) || defined(lint)
/*
	hacks to please C++ and lint - goto's inside
	switch should never be executed
*/
	static int __yaccpar_lint_hack__ = 0;
	switch (__yaccpar_lint_hack__)
	{
		case 1: goto yyerrlab;
		case 2: goto yynewstate;
	}
#endif

	/*
	** Initialize externals - yyparse may be called more than once
	*/
	yypv = &yyv[-1];
	yyps = &yys[-1];
	yystate = 0;
	yytmp = 0;
	yynerrs = 0;
	yyerrflag = 0;
	yychar = -1;

#if YYMAXDEPTH <= 0
	if (yymaxdepth <= 0)
	{
		if ((yymaxdepth = YYEXPAND(0)) <= 0)
		{
			yyerror("yacc initialization error");
			YYABORT;
		}
	}
#endif

	{
		register YYSTYPE *yy_pv;	/* top of value stack */
		register int *yy_ps;		/* top of state stack */
		register int yy_state;		/* current state */
		register int  yy_n;		/* internal state number info */
	goto yystack;	/* moved from 6 lines above to here to please C++ */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	yynewstate:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;
		goto yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	yystack:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	yy_stack:
		/*
		** put a state and value onto the stacks
		*/
#if YYDEBUG
		/*
		** if debugging, look up token value in list of value vs.
		** name pairs.  0 and negative (-1) are special values.
		** Note: linear search is used since time is not a real
		** consideration while debugging.
		*/
		if ( yydebug )
		{
			register int yy_i;

			printf( "State %d, token ", yy_state );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++yy_ps >= &yys[ yymaxdepth ] )	/* room on stack? */
		{
			/*
			** reallocate and recover.  Note that pointers
			** have to be reset, or bad things will happen
			*/
			int yyps_index = (yy_ps - yys);
			int yypv_index = (yy_pv - yyv);
			int yypvt_index = (yypvt - yyv);
			int yynewmax;
#ifdef YYEXPAND
			yynewmax = YYEXPAND(yymaxdepth);
#else
			yynewmax = 2 * yymaxdepth;	/* double table size */
			if (yymaxdepth == YYMAXDEPTH)	/* first time growth */
			{
				char *newyys = (char *)YYNEW(int);
				char *newyyv = (char *)YYNEW(YYSTYPE);
				if (newyys != 0 && newyyv != 0)
				{
					yys = YYCOPY(newyys, yys, int);
					yyv = YYCOPY(newyyv, yyv, YYSTYPE);
				}
				else
					yynewmax = 0;	/* failed */
			}
			else				/* not first time */
			{
				yys = YYENLARGE(yys, int);
				yyv = YYENLARGE(yyv, YYSTYPE);
				if (yys == 0 || yyv == 0)
					yynewmax = 0;	/* failed */
			}
#endif
			if (yynewmax <= yymaxdepth)	/* tables not expanded */
			{
				yyerror( "yacc stack overflow" );
				YYABORT;
			}
			yymaxdepth = yynewmax;

			yy_ps = yys + yyps_index;
			yy_pv = yyv + yypv_index;
			yypvt = yyv + yypvt_index;
		}
		*yy_ps = yy_state;
		*++yy_pv = yyval;

		/*
		** we have a new state - find out what to do
		*/
	yy_newstate:
		if ( ( yy_n = yypact[ yy_state ] ) <= YYFLAG )
			goto yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		yytmp = yychar < 0;
#endif
		if ( ( yychar < 0 ) && ( ( yychar = YYLEX() ) < 0 ) )
			yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( yydebug && yytmp )
		{
			register int yy_i;

			printf( "Received token " );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( yy_n += yychar ) < 0 ) || ( yy_n >= YYLAST ) )
			goto yydefault;
		if ( yychk[ yy_n = yyact[ yy_n ] ] == yychar )	/*valid shift*/
		{
			yychar = -1;
			yyval = yylval;
			yy_state = yy_n;
			if ( yyerrflag > 0 )
				yyerrflag--;
			goto yy_stack;
		}

	yydefault:
		if ( ( yy_n = yydef[ yy_state ] ) == -2 )
		{
#if YYDEBUG
			yytmp = yychar < 0;
#endif
			if ( ( yychar < 0 ) && ( ( yychar = YYLEX() ) < 0 ) )
				yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( yydebug && yytmp )
			{
				register int yy_i;

				printf( "Received token " );
				if ( yychar == 0 )
					printf( "end-of-file\n" );
				else if ( yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( yy_i = 0;
						yytoks[yy_i].t_val >= 0;
						yy_i++ )
					{
						if ( yytoks[yy_i].t_val
							== yychar )
						{
							break;
						}
					}
					printf( "%s\n", yytoks[yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register const int *yyxi = yyexca;

				while ( ( *yyxi != -1 ) ||
					( yyxi[1] != yy_state ) )
				{
					yyxi += 2;
				}
				while ( ( *(yyxi += 2) >= 0 ) &&
					( *yyxi != yychar ) )
					;
				if ( ( yy_n = yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( yyerrflag )
			{
			case 0:		/* new error */
				yyerror( "syntax error" );
				goto skip_init;
			yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				yy_pv = yypv;
				yy_ps = yyps;
				yy_state = yystate;
			skip_init:
				yynerrs++;
				/* FALLTHRU */
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( yy_ps >= yys )
				{
					yy_n = yypact[ *yy_ps ] + YYERRCODE;
					if ( yy_n >= 0 && yy_n < YYLAST &&
						yychk[yyact[yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						yy_state = yyact[ yy_n ];
						goto yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( yydebug )
						printf( _POP_, *yy_ps,
							yy_ps[-1] );
#	undef _POP_
#endif
					yy_ps--;
					yy_pv--;
				}
				/*
				** there is no state on stack with "error" as
				** a valid shift.  give up.
				*/
				YYABORT;
			case 3:		/* no shift yet; eat a token */
#if YYDEBUG
				/*
				** if debugging, look up token in list of
				** pairs.  0 and negative shouldn't occur,
				** but since timing doesn't matter when
				** debugging, it doesn't hurt to leave the
				** tests here.
				*/
				if ( yydebug )
				{
					register int yy_i;

					printf( "Error recovery discards " );
					if ( yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( yy_i = 0;
							yytoks[yy_i].t_val >= 0;
							yy_i++ )
						{
							if ( yytoks[yy_i].t_val
								== yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							yytoks[yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				yychar = -1;
				goto yy_newstate;
			}
		}/* end if ( yy_n == 0 ) */
		/*
		** reduction by production yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				yy_n, yyreds[ yy_n ] );
#endif
		yytmp = yy_n;			/* value to switch over */
		yypvt = yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using yy_state here as temporary
		** register variable, but why not, if it works...
		** If yyr2[ yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int yy_len = yyr2[ yy_n ];

			if ( !( yy_len & 01 ) )
			{
				yy_len >>= 1;
				yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
				yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
					*( yy_ps -= yy_len ) + 1;
				if ( yy_state >= YYLAST ||
					yychk[ yy_state =
					yyact[ yy_state ] ] != -yy_n )
				{
					yy_state = yyact[ yypgo[ yy_n ] ];
				}
				goto yy_stack;
			}
			yy_len >>= 1;
			yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
			yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
				*( yy_ps -= yy_len ) + 1;
			if ( yy_state >= YYLAST ||
				yychk[ yy_state = yyact[ yy_state ] ] != -yy_n )
			{
				yy_state = yyact[ yypgo[ yy_n ] ];
			}
		}
					/* save until reenter driver code */
		yystate = yy_state;
		yyps = yy_ps;
		yypv = yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( yytmp )
	{
		
case 6:
# line 88 "lab2b.y"
{
					SymbolTable::setscope(++scope);
					} break;
case 7:
# line 92 "lab2b.y"
{
					st.clean();
					SymbolTable::setscope(--scope);
					} break;
case 10:
# line 99 "lab2b.y"
{
					SymbolTable::setscope(++scope);
					} break;
case 11:
# line 103 "lab2b.y"
{
					st.clean();
					SymbolTable::setscope(--scope);
					} break;
case 16:
# line 116 "lab2b.y"
{
					SymbolTable::setscope(++scope);
					printf("%d %s %d\n", yypvt[-1].num, yypvt[-0].lexeme, scope);
					dummy = strtok(yypvt[-0].lexeme, ",");
					if (dummy == NULL)
						{
						if (!checkVar(yypvt[-0].lexeme))
							st.insert(yypvt[-0].lexeme, yypvt[-1].num, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						}
					else
						{
						if (!checkVar(dummy))
							st.insert(dummy, yypvt[-1].num, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						while ((dummy = strtok(NULL, ",")) != NULL)
							{
							if (!checkVar(dummy))
								st.insert(dummy, yypvt[-1].num, "");
							else
								{
								sprintf(buff, "   ID %s declared more than once.", dummy); 
								yyerror(buff);
								}
							} /* end while */
						} /* end else */
					} break;
case 18:
# line 153 "lab2b.y"
{
					printf("%d %s %d\n", yypvt[-2].num, yypvt[-1].lexeme, scope);
					dummy = strtok(yypvt[-1].lexeme, ",");
					if (dummy == NULL)
						{
						if (!checkVar(yypvt[-1].lexeme))
							st.insert(yypvt[-1].lexeme, yypvt[-2].num, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						}
					else
						{
						if (!checkVar(dummy))
							st.insert(dummy, yypvt[-2].num, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						while ((dummy = strtok(NULL, ",")) != NULL)
							{
							if (!checkVar(dummy))
								st.insert(dummy, yypvt[-2].num, "");
							else
								{
								sprintf(buff, "   ID %s declared more than once.", dummy); 
								yyerror(buff);
								}
							} /* end while */
						} /* end else */
					} break;
case 33:
# line 216 "lab2b.y"
{
					/* printf("%d %s %d\n", $2, $3, scope); */
					dummy = strtok(yypvt[-1].lexeme, ",");
					if (dummy == NULL)
						{
						if (!checkVar(yypvt[-1].lexeme))
							st.insert(yypvt[-1].lexeme, yypvt[-2].num, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						}
					else
						{
						if (!checkVar(dummy))
							st.insert(dummy, yypvt[-2].num, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						while ((dummy = strtok(NULL, ",")) != NULL)
							{
							if (!checkVar(dummy))
								st.insert(dummy, yypvt[-2].num, "");
							else
								{
								sprintf(buff, "   ID %s declared more than once.", dummy); 
								yyerror(buff);
								}
							} /* end while */
						} /* end else */
					} break;
case 35:
# line 254 "lab2b.y"
{
					/* printf("%d %s %d\n", $1, $2, scope); */
					dummy = strtok(yypvt[-1].lexeme, ",");
					if (!checkVar(yypvt[-1].lexeme))
						st.insert(yypvt[-1].lexeme, yypvt[-2].num, "");
					else
						{
						sprintf(buff, "   ID %s declared more than once.", dummy);
						yyerror(buff);
						}
					while ((dummy = strtok(NULL, ",")) != NULL)
						{
						if (!checkVar(dummy))
							st.insert(dummy, yypvt[-2].num, "");
						else
							{
							sprintf(buff, "   ID %s declared more than once.", dummy); 
							yyerror(buff);
							}
						} /* end while */
					} break;
case 37:
# line 280 "lab2b.y"
{ yyval.num = INTEGER; } break;
case 38:
# line 282 "lab2b.y"
{ yyval.num = FLOATER; } break;
case 39:
# line 287 "lab2b.y"
{
					sprintf(buff, "%s", yypvt[-0].lexeme);
					yyval.lexeme = (char *)strdup(buff);
					} break;
case 40:
# line 292 "lab2b.y"
{
					sprintf(buff, "%s", yypvt[-2].lexeme);
					yyval.lexeme = (char *)strdup(buff);
					} break;
case 43:
# line 302 "lab2b.y"
{
					sprintf(buff, "%s", yypvt[-0].lexeme);
					yyval.lexeme = (char *)strdup(buff);
					} break;
case 44:
# line 307 "lab2b.y"
{
					sprintf(buff, ",%s", yypvt[-0].lexeme);
					yyval.lexeme = (char *)strcat(yyval.lexeme, buff);
					} break;
case 45:
# line 314 "lab2b.y"
{ sprintf(buff, "%s", yypvt[-0].lexeme);
					yyval.lexeme = (char *)strdup(buff);
					} break;
case 50:
# line 328 "lab2b.y"
{
					SymbolTable::setscope(++scope);
					} break;
case 51:
# line 332 "lab2b.y"
{
					st.clean();
					SymbolTable::setscope(--scope);
					} break;
case 96:
# line 409 "lab2b.y"
{
					if (checkVar(yypvt[-0].lexeme))
						;
					else
						{
						sprintf(buff, "   ID %s is not declared", yypvt[-0].lexeme);
						yyerror(buff);
						}
					} break;
# line	531 "/usr/ccs/bin/yaccpar"
	}
	goto yystack;		/* reset registers in driver code */
}

