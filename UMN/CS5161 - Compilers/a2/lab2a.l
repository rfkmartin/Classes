%{
#include <stdio.h>
#include "lab2a.tab.h"
%}

letter		[A-Za-z]
digit		[0-9]
ID			({letter})({letter}|{digit}|"_")*
op_assign	"="
op_plus		"+"
op_minus	"-"
op_times	"*"
op_divide	"/"
constant	{digit}+(("."){digit}+)?
mk_lparen	"("
mk_rparen	")"
ws			[ \t]+
%%

{ws}		; /* do nothing */
{ID}		{ yylval.lexeme = (char *) strdup(yytext); return ID; }
{op_assign}	return OP_ASSIGN; 
{op_plus}	return OP_PLUS;
{op_minus}	return OP_MINUS;
{op_times}	return OP_TIMES;
{op_divide}	return OP_DIVIDE;
{constant}	{ yylval.num = atoi(yytext); return CONSTANT;}
{mk_lparen}	return MK_LPAREN;
{mk_rparen}	return MK_RPAREN;
%%



