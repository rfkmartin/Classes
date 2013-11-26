%{
#include <stdio.h>
#include "lab2b.tab.h"
extern int linenumber;
void lex_cpy_lexeme (void);
%}
letter   [A-Za-z]
digit    [0-9]
A [/]
B [*]
C [^/*]
kwVoid   "void"
kwInt    "int"
kwFloat  "float"
kwIf     "if"
kwElse   "else"
kwWhile  "while"
kwFor	 "for"
kwTypedef "typedef"
kwReturn "return"
ID       ({letter})({letter}|{digit}|"_")*
op_assign        "="
op_or   "||"
op_and  "&&"
op_not  "!"
op_eq   "=="
op_ne   "!="
op_lt   "<"
op_gt   ">"
op_le   "<="
op_ge   ">="
op_plus "+"
op_minus "-"
op_times "*"
op_divide "/"
constant {digit}+(("."){digit}+)?
s-const \"([^"\n])*\"
ws       [ \t]+
newline  "\n"
mk_lparen "("
mk_rparen ")"
mk_lbrace "{"
mk_rbrace "}"
mk_lsqbrace "["
mk_rsqbrace "]"
mk_comma  ","
mk_semicolon ";"
error    .
%%

{ws}            ;   /* do nothing with whitespace */
{kwVoid}        return VOID;
{kwInt}         return INT;
{kwFloat}       return FLOAT;
{kwIf}          return IF;
{kwElse}        return ELSE;
{kwWhile}       return WHILE;
{kwFor}      	return FOR;
{kwTypedef}     return TYPEDEF;
{kwReturn}      return RETURN;
{ID}            { lex_cpy_lexeme (); return ID; }
{op_assign}     return OP_ASSIGN; 
{op_and}        return OP_AND;
{op_or}         return OP_OR;
{op_not}        return OP_NOT;
{op_eq}         return OP_EQ;
{op_ne}         return OP_NE;
{op_lt}         return OP_LT;
{op_gt}         return OP_GT;
{op_le}         return OP_LE;
{op_ge}         return OP_GE;
{op_plus}       return OP_PLUS;
{op_minus}      return OP_MINUS;
{op_times}      return OP_TIMES;
{op_divide}     return OP_DIVIDE;
{constant}      { lex_cpy_lexeme (); return CONSTANT;}
{s-const}       { lex_cpy_lexeme (); return CONSTANT;}
{mk_lparen}     return MK_LPAREN;
{mk_rparen}     return MK_RPAREN;
{mk_lbrace}     return MK_LBRACE;
{mk_rbrace}     return MK_RBRACE;
{mk_lsqbrace}   return MK_LSQBRACE;
{mk_rsqbrace}   return MK_RSQBRACE;
{mk_comma}      return MK_COMMA;
{mk_semicolon}  return MK_SEMICOLON;
{newline}       linenumber += 1;
{A}{B}({A}|{C}|{B}+{C})*{B}+{A}		{ }
{error}         return ERROR;
%%


void lex_cpy_lexeme (void)
{
  yylval.lexeme = (char *)strdup (yytext);
  if (!(yylval.lexeme))
    {
      fputs ("out of memory\n", stderr);
      exit (1);
    }
}

