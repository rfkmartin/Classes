typedef union
{
	int num;
	char *lexeme;
} YYSTYPE;
#define	ID	257
#define	CONSTANT	258
#define	OP_ASSIGN	259
#define	OP_PLUS	260
#define	OP_MINUS	261
#define	OP_TIMES	262
#define	OP_DIVIDE	263
#define	MK_LPAREN	264
#define	MK_RPAREN	265


extern YYSTYPE yylval;
