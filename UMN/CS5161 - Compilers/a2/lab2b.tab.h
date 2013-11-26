
typedef union
#ifdef __cplusplus
	YYSTYPE
#endif

{
  int num;
  char* lexeme;
} YYSTYPE;
extern YYSTYPE yylval;
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
