%{
#include <stdio.h>
#include <stdlib.h>

#include "record.h"
#include "stack.h"
#include "symtab.h"
#include "list.h"

//--------------------------------------------------
// To interface with lex.
//--------------------------------------------------
extern FILE *yyin;
extern int yylex();

FILE *out;
static int errorflag = 0;
char buff[50];
char str_buf[256] = "";
char flt_buf[256] = "";
char currFuncname[20];
int linenumber = 1;
int offset = 0;
int reg_number = 8;
int fltreg_number = 0;
int str_num = 0;
int flt_num = 0;
int ifLabelnum, whileLabelnum;
int forLabelnum, andorLabelnum;
bool dotData = false;
bool isStrings = false;
bool isFloat = false;
bool is_CR = false;

// used for evaulating arguments
enum oper { plus, minus, times, divds, eq, gt, ge, lt, le, ne,or,and} ;

SymbolTable st;
stack ifLabel, whileLabel, forLabel, andorLabel;

// look at each element in the parameter list and determine type
int curRetType;

//--------------------------------------------------
// Flag to indicate if read/write being parsed
// If it is set, then typechecking is turned off.
//--------------------------------------------------
bool noCheck = false; 

// store the return type of current function
int currRetType = undef_type;

static int scope = 0; 

//---------------------------------------------------
// Function declarations used in this file 
//--------------------------------------------------
void addToSymTab(List *, int typ, bool typedefd = false);  
void addFuncToSymTab(char *, char* , List *);
void addFuncToSymTab(char *, int, List *);
void setRetType(int);
void incr_scope();
void decr_scope();
enum dataType checkDefined(char *name, int arrDim[] = 0);
enum dataType checkDefinedFunc(char *name, List *);
void checkRetType(enum dataType );
int constantType(char *);
int yyerror(char *);
ListElement *evaluate(ListElement *, ListElement *, enum oper);
int getDefinedType(char *); 
void setReturnType(int);
void checkReturnType(int);
void checkAndSet(char *);

void gen_head(char *);
void gen_prologue(char *);
void gen_epilogue(char *);
void gen_return(char *);
int getReg();
int getFloatReg();
void print_CR();
%}

%union
{
  int num;
  int array[11];	// 0 is dimension
  char lexeme[50];
  List *list;  
  ListElement *le;
}

%token<lexeme> ID
%token<lexeme> CONSTANT
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

%type<num> type mul_op add_op rel_op
%type<list> id_list init_id_list param_list
%type<le> init_id
%type<num> type
%type<le> expr term factor relop_expr relop_factor relop_term  expr_null
%type<le> param assign_expr cond_test
%type<array> dim dim_fn dim_decl
%type<list> relop_expr_list nonempty_relop_expr_list


%start program

%%
/* ==== Grammar Section ==== */
/* Productions */               /* Semantic actions */
program			: global_decl_list
				;

global_decl_list: global_decl_list global_decl
				|
				;

global_decl		: decl_list function_decl
				| function_decl
				;

function_decl	:type ID  MK_LPAREN {incr_scope(); } param_list	MK_RPAREN MK_LBRACE
				{
				addToSymTab($5,undef_type);
				addFuncToSymTab($2,$1,$5);
				offset = 4;
				gen_head($2);
				gen_prologue($2);
				}
				block MK_RBRACE
				{
				decr_scope();
				gen_epilogue($2);
				if ($5) delete $5;
				checkReturnType($1);
				}
				|ID ID MK_LPAREN {incr_scope(); } param_list MK_RPAREN MK_LBRACE
				{
				addToSymTab($5,undef_type);
				addFuncToSymTab($2,$1,$5);
				offset = 4;
				gen_head($2);
				gen_prologue($2);
				if ($5 != NULL)
					delete $5;
				}
				block MK_RBRACE
				{
				decr_scope();
				gen_epilogue($2);
				struct tData *temp = st.find($1);
				if (temp == NULL)
					yyerror("Return type is not valid ");
				else
					checkReturnType(temp->redefType);		
				}
				| VOID ID MK_LPAREN {incr_scope(); } param_list MK_RPAREN MK_LBRACE
				{		
				addToSymTab($5,undef_type); 
				addFuncToSymTab($2,void_type,$5);
				offset = 4;
				gen_head($2);
				gen_prologue($2);
				if ($5 != NULL)
					delete $5;
				}
				block MK_RBRACE 
				{
				decr_scope();
				gen_epilogue($2);
				checkReturnType(void_type);
				}
				| type ID MK_LPAREN  MK_RPAREN MK_LBRACE 
				{
				incr_scope(); 
				addFuncToSymTab($2,$1,NULL);
				offset = 4;
				gen_head($2);
				gen_prologue($2);
				} 
				block MK_RBRACE 
				{
				decr_scope(); 
				gen_epilogue($2);
				checkReturnType($1);
				}
				| ID ID MK_LPAREN  MK_RPAREN MK_LBRACE 
				{
				incr_scope(); 
				addFuncToSymTab($2,$1,NULL);
				offset = 4;
				gen_head($2);
				gen_prologue($2);
				}
				block MK_RBRACE 
				{
				decr_scope();
				gen_epilogue($2);
				struct tData *temp = st.find($1);
				if (temp == NULL)
					yyerror("Return type is not valid ");
				checkReturnType(temp->redefType);
				}
				| VOID ID MK_LPAREN  MK_RPAREN MK_LBRACE 
				{
				incr_scope(); 
				addFuncToSymTab($2,void_type, NULL);	
				offset = 4;
				gen_head($2);
				gen_prologue($2);
				}
				block MK_RBRACE 
				{
				decr_scope();
				gen_epilogue($2);
				checkReturnType(void_type);
				}
                ;

param_list		: param_list MK_COMMA  param 
				{
				$$->insert($3);
				}
				| param 
				{ 
				$$ = new List; 
				$$->insert($1);
				}
                ;

param			: type ID 
				{
				$$ = new ListElement($2, $1);
				}
				| ID ID 
				{ 
				int typ = getDefinedType($1);
				$$ = new ListElement($2, typ);
				}
				| type ID dim_fn 
				{
				$$ = new ListElement($2,$1,$3); 
				}
				| ID ID dim_fn 
				{	
				int typ = getDefinedType($1);
				$$ = new ListElement($2, typ, $3); 
				}
				;

dim_fn			: MK_LSQBRACE expr_null MK_RSQBRACE dim_fn
				{
				$$[0] = $4[0] + 1;
				}
				| MK_LSQBRACE expr_null MK_RSQBRACE
				{
				$$[0] = 1;
				}
				;


expr_null		: expr { if ($1 != NULL) delete $1; }
				| { $$ = NULL; }  
				;

block			: decl_list stmt_list 
				| stmt_list
				| decl_list
				|
				;
 
decl_list		: decl_list decl
				| decl
				;

decl			: type_decl
				| var_decl
				{
				}
				;

type_decl		: TYPEDEF type id_list MK_SEMICOLON
				{
				// Handle the typdefs by simply inserting into the symbol table as variables
				// and associating the type with the type indicated
				addToSymTab($3,$2, true);
				if ($3 != NULL) delete $3;
				}
				| TYPEDEF VOID id_list MK_SEMICOLON
				{
				addToSymTab($3,void_type, true);
				if ($3 != NULL) delete $3;
				}
				;

var_decl		: type init_id_list MK_SEMICOLON
				{
				addToSymTab($2, $1);
				if ($2 != NULL) delete $2;	
				}
				| ID id_list MK_SEMICOLON 
				{
				struct tData *temp = st.find($1);
				if (temp == NULL)
					{
					sprintf(buff, "Undeclared type %s",$1);
 					yyerror(buff);
					}
				else if (temp->dType != typedefp)
					{
		    		sprintf(buff,"%s is not a defined type",$1);
		    		yyerror(buff);
					}
				else		  // now treat as primitives of the redefType
					{
					printf("typedef of type %d\n", (int)temp->redefType);
					addToSymTab($2,int(temp->redefType));
					}
				if ($2 != NULL)
					delete $2;
				}
				;

type		: INT 
			{
			$$ = int_type;
			}
			| FLOAT 
			{ 
			$$ = float_type; 
			}
			;

id_list		: ID
			{
			$$ = new List;
			$$->insert($1);
			}
			| id_list MK_COMMA ID
			{
			$1->insert($3);
			$$ = $1;
			}			          
			| id_list MK_COMMA ID dim_decl
			{
			$1->insert($3,int_type,$4);
			$$ = $1;
			}	
			| ID dim_decl
			{
			$$ = new List;
			$$->insert($1,int_type, $2);
			}
			;
	
init_id_list	: init_id
				{
				$$ = new List;
				$$->insert($1);
				}
				| init_id_list MK_COMMA init_id
				{
				$$ = $1;
				$$->insert($3);
				}
                ;

init_id		: ID
			{
			$$ = new ListElement($1);
			$$->setVal(0);
			}
			| ID dim_decl
			{
			$$ = new ListElement($1,int_type,$2);
			}
			| ID OP_ASSIGN relop_expr
			{
			$$ = new ListElement($1);
			if ($3 != NULL)
				{
				$$->setVal($3->getVal());
				delete $3;					
				}
			}
			;

stmt_list	: stmt_list stmt
			| stmt
			;

stmt            : MK_LBRACE { incr_scope(); } block MK_RBRACE{ decr_scope(); }
                | WHILE MK_LPAREN cond_test
				{
				whileLabel.push(whileLabelnum);
				if (strcmp($3->getName().c_str(), "dummy") != 0)
					{
					fprintf(out, "bclz\t,$%d_Lexit%d\n", $3->getPlace(), whileLabelnum);
					}
				}
				MK_RPAREN stmt
				{
				fprintf(out, "j\t_Test%d:\n", whileLabel.get());
				fprintf(out, "_Lexit%d:\n", whileLabel.get());
				whileLabel.pop();
				}
				| FOR MK_LPAREN assign_expr MK_SEMICOLON cond_test MK_SEMICOLON
				{
				if (strcmp($5->getName().c_str(), "dummy") != 0)
					{
					fprintf(out, "beqz\t$%d,_Lexit%d\n", $5->getPlace(), whileLabelnum);
					}
				fprintf(out, "j\t_Body%d\n", whileLabelnum);
				fprintf(out, "_Inc%d:\n", whileLabelnum);
				}
				assign_expr
				{
				fprintf(out, "j\t_Test%d\n", whileLabelnum);
				fprintf(out, "_Body%d:\n", whileLabelnum);
				}
				MK_RPAREN stmt 
				{
				fprintf(out, "j\t_Inc%d\n", whileLabel.get());
				fprintf(out, "_Lexit%d:\n", whileLabel.get());
				whileLabel.pop();
				}
                | ID OP_ASSIGN relop_expr MK_SEMICOLON
				{
				checkDefined($1);
				struct tData *temp = st.find($1);
				if (($3 != NULL) && (strcmp($3->getName().c_str(), "dummy") == 0))
					{
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							fprintf(out, "li\t$%d, %d\n", reg, (int) $3->getVal());
							fprintf(out, "sw\t$%d, %s\n", reg, temp->token.c_str());
							}
						else if (temp->dType == floatp)
							{
							int reg;
							reg = getFloatReg();
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							temp->place = 0;
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "s.s\t$f%d, %s\n", reg, temp->token.c_str());
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							fprintf(out, "li\t$%d, %d\n", reg, (int) $3->getVal());
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg, temp->offset);
							}
						else if (temp->dType == floatp)
							{
							int reg;
							reg = getFloatReg();
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());							
							strcat(flt_buf, buf);
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "s.s\t$f%d, -%d($fp)\n", reg, temp->offset);
							}
						}
					}
				else if (strcmp($3->getName().c_str(), "temp") == 0)
					{
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							fprintf(out, "move\t$%d, $%d\n", reg, $3->getPlace());
							fprintf(out, "sw\t$%d, %s\n", reg,
							temp->token.c_str());
							}
						else if (temp->dType == floatp)
							{
							int reg;
							reg = getFloatReg();
							fprintf(out, "mov.s\t$f%d, $f%d\n", reg, $3->getPlace());
							fprintf(out, "s.s\t$f%d, %s\n", reg, temp->token.c_str());
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							fprintf(out, "move\t$%d, $%d\n", reg, $3->getPlace());
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg, temp->offset);
							}
						else if (temp->dType == floatp)
							{
							int reg;
							reg = getFloatReg();
							fprintf(out, "mov.s\t$f%d, $f%d\n", reg, $3->getPlace());
							fprintf(out, "s.s\t$f%d, -%d($fp)\n", reg, temp->offset);
							}
						}
					}
				else
					{
					struct tData *temp1 = st.find($3->getName().c_str());
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							if (temp1->offset == 0)
								fprintf(out, "lw\t$%d, %s + %d\n", reg, $3->getName().c_str(), $3->getPlace());
							else
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "sw\t$%d, %s\n", reg,
							temp->token.c_str());
							}
						else if (temp->dType == floatp)
							{
							int reg;
							reg = getFloatReg();
							if (temp1->offset == 0)
								fprintf(out, "l.s\t$%d, %s\n", reg, $3->getName().c_str());
							else
								fprintf(out, "l.s\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "s.s\t$f%d, %s\n", reg, temp->token.c_str());
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							if (temp1->offset == 0)
								fprintf(out, "lw\t$%d, %s + %d\n", reg, $3->getName().c_str(), $3->getPlace());
							else
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg, temp->offset);
							}
						else if (temp->dType == floatp)
							{
							int reg;
							reg = getFloatReg();
							if (temp1->offset == 0)
								fprintf(out, "l.s\t$%d, %s\n", reg, $3->getName().c_str());
							else
								fprintf(out, "l.s\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "s.s\t$f%d, -%d($fp)\n", reg, temp->offset);
							}
						}
					}
				delete $3;
				}
                | ID  dim OP_ASSIGN relop_expr  MK_SEMICOLON
				{
				// array dereferencing, we check the dimensions against the original
				checkDefined($1,$2);

				//compute array offset
				struct tData *temp = st.find($1);
				int space = 0;
				if (temp->arrayDim[0] > 1)
					{
					for (int i = 1; i < $2[0]; i++)
						{
						fprintf(out, "#space = %d\n", space);
						if (!space) space = $2[i];
						space = space * temp->arrayDim[i + 1] + $2[i + 1];
						fprintf(out, "#current offset = %d current index = %d index size = %d\n", space,
						$2[i], temp->arrayDim[i + 1]);
						}
					}
				else
					space += $2[$2[0]];
					
				if (($4 != NULL) && ($4->getVal() != 0))
					{
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							fprintf(out, "li\t$%d, %d\n", reg, (int) $4->getVal());
							fprintf(out, "sw\t$%d, %s + %d\n", reg, temp->token.c_str(), space * 4);
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							fprintf(out, "#local space = %d\n", space);
							int reg;
							reg = getReg();
							fprintf(out, "li\t$%d, %d\n", reg, (int) $4->getVal());
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg, temp->offset + (space * 4));
							}
						fprintf(out, "#Place is %d\n", temp->offset);
						}
					}
				else
					{
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							int reg;
							reg = getReg();
							fprintf(out, "move\t$%d, $%d\n", reg, $4->getPlace());
							fprintf(out, "sw\t$%d, %s + %d\n", reg, temp->token.c_str(), space * 4);
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							fprintf(out, "#local space = %d\n", space);
							int reg;
							reg = getReg();
							fprintf(out, "move\t$%d, $%d\n", reg, $4->getPlace());
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg,
							temp->offset + (space * 4));
							}
						fprintf(out, "#Place is %d\n", temp->offset);
						}
					}

				if ($4 != NULL)
					delete $4;
				}
                | IF MK_LPAREN cond_test MK_RPAREN stmt
				{
				if (strcmp($3->getName().c_str(), "dummy") != 0)
					fprintf(out, "_Lexit%d:\n", ifLabel.get());
				ifLabel.pop();
				}
				| IF MK_LPAREN cond_test MK_RPAREN stmt
				{
				if (strcmp($3->getName().c_str(), "dummy") != 0)
					fprintf(out, "j_Lexit%d\n", ifLabel.get());
				fprintf(out, "_Lelse%d:\n", ifLabel.get());
				}
				ELSE stmt
				{
				fprintf(out, "_Lexit%d:\n", ifLabel.get());
				ifLabel.pop();
				}
                | ID { checkAndSet($1); } MK_LPAREN relop_expr_list MK_RPAREN MK_SEMICOLON
				{
				// function calls ... if read or write we turn off typechecking
				checkDefinedFunc($1,$4);

				if (strcmp($1, "write") == 0)
					{
					ListElement *lTemp;
					lTemp = $4->getFirst();
					struct tData *temp = st.find(lTemp->getName());
					if (lTemp->getType() == intp)
						{
						int reg;
						reg = getReg();
						fprintf(out, "li\t$v0 1\n");
						if (temp->scope == 0)
							fprintf(out, "lw\t$%d %s + %d\n", reg,
							lTemp->getName().c_str(), (int)lTemp->getPlace());
						else
							fprintf(out, "lw\t$%d -%d($fp)\n", reg,
							(int)lTemp->getPlace());
						fprintf(out, "move\t$a0, $%d\n", reg);
						fprintf(out, "syscall\n");
						print_CR();
						}
					else if (lTemp->getType() == floatp)
						{
						fprintf(out, "li\t$v0 2\n");
						if (temp->scope == 0)
							fprintf(out, "l.s\t$f12 %s\n", lTemp->getName().c_str());
						else
							fprintf(out, "l.s\t$f12 -%d($fp)\n", lTemp->getPlace());
						fprintf(out, "syscall\n");
						print_CR();
						}
					else
						{
						fprintf(out, "li\t$v0 4\n");
						fprintf(out, "la\t$a0 %s\n", lTemp->getName().c_str());
						fprintf(out, "syscall\n");
						isFloat = true;
						}
					noCheck = false;
					}
				else if (strcmp($1, "read") == 0)
					{
					ListElement *lTemp;
					lTemp = $4->getFirst();
					struct tData *temp = st.find(lTemp->getName());
					if (lTemp->getType() == intp)
						{
						fprintf(out, "li\t$v0 5\n");
						fprintf(out, "syscall\n");
						if (temp->scope == 0)
							fprintf(out, "sw\t$v0, %s + %d\n",
							lTemp->getName().c_str(), (int)lTemp->getPlace());
						else
							fprintf(out, "sw\t$v0, -%d($fp)\n",
							lTemp->getPlace());
						}
					else if (lTemp->getType() == floatp)
						{
						fprintf(out, "li\t$v0, 6\n");
						fprintf(out, "syscall\n");
						if (temp->scope == 0)
							fprintf(out, "s.s\t$f0, %s\n", lTemp->getName().c_str());
						else
							fprintf(out, "s.s\t$f0, -%d($fp)\n", temp->place);
						}
					noCheck = false;
					}
				else
					printf("function call\n");
				if ($4 != NULL) delete $4;
				}
                | MK_SEMICOLON
                | RETURN
				{
				gen_return(currFuncname);
				}
				MK_SEMICOLON
				{
				setReturnType(void_type);
				}
                | RETURN relop_expr
				{
				fprintf(out, "li\t$v0, $%d\n", $2->getPlace());
				gen_return(currFuncname);
				}
				MK_SEMICOLON
				{
				// note the return type here and check once the entire function is reduced.
				if ($2 != NULL)
					{
					setReturnType($2->getType() );
					delete $2;
					}
				}
                ;

cond_test		:
				{
				$<num>$ = ++whileLabelnum;
				whileLabel.push(whileLabelnum);
				fprintf(out, "_Ltest%d:\n", whileLabelnum);
				}
				assign_expr
				{
				if (strcmp($2->getName().c_str(), "dummy") != 0)
					{
					int reg;
					reg = $2->getPlace();
					fprintf(out, "beqz\t$%d, _Lexit%d\n", reg, $<num>1);
					}
				$$ = $2;
				}

assign_expr		: ID OP_ASSIGN relop_expr
				{ 
				checkDefined($1);
				struct tData *temp = st.find($1);
				int reg;
				if (temp->dType == intp)
					reg = getReg();
				else if (temp->dType == floatp)
					reg = getFloatReg();
				if (($3 != NULL) && (strcmp($3->getName().c_str(), "dummy") == 0))
					{
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							fprintf(out, "li\t$%d, %d\n", reg, (int) $3->getVal());
							fprintf(out, "sw\t$%d, %s\n", reg, temp->token.c_str());
							}
						else if (temp->dType == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							temp->place = 0;
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "s.s\t$f%d, %s\n", reg, temp->token.c_str());
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							fprintf(out, "li\t$%d, %d\n", reg, (int) $3->getVal());
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg, temp->offset);
							}
						else if (temp->dType == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());							
							strcat(flt_buf, buf);
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "s.s\t$f%d, -%d($fp)\n", reg, temp->offset);
							}
						}
					}
				else if (strcmp($3->getName().c_str(), "temp") == 0)
					{
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							fprintf(out, "move\t$%d, $%d\n", reg, $3->getPlace());
							fprintf(out, "sw\t$%d, %s\n", reg,
							temp->token.c_str());
							}
						else if (temp->dType == floatp)
							{
							fprintf(out, "mov.s\t$f%d, $f%d\n", reg, $3->getPlace());
							fprintf(out, "s.s\t$f%d, %s\n", reg, temp->token.c_str());
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							fprintf(out, "move\t$%d, $%d\n", reg, $3->getPlace());
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg, temp->offset);
							}
						else if (temp->dType == floatp)
							{
							fprintf(out, "mov.s\t$f%d, $f%d\n", reg, $3->getPlace());
							fprintf(out, "s.s\t$f%d, -%d($fp)\n", reg, temp->offset);
							}
						}
					}
				else
					{
					struct tData *temp1 = st.find($3->getName().c_str());
					if (temp->scope == 0)
						{
						if (temp->dType == intp)
							{
							if (temp1->offset == 0)
								fprintf(out, "lw\t$%d, %s + %d\n", reg, $3->getName().c_str(), $3->getPlace());
							else
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "sw\t$%d, %s\n", reg,
							temp->token.c_str());
							}
						else if (temp->dType == floatp)
							{
							if (temp1->offset == 0)
								fprintf(out, "l.s\t$%d, %s\n", reg, $3->getName().c_str());
							else
								fprintf(out, "l.s\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "s.s\t$f%d, %s\n", reg, temp->token.c_str());
							}
						}
					else
						{
						if (temp->dType == intp)
							{
							if (temp1->offset == 0)
								fprintf(out, "lw\t$%d, %s + %d\n", reg, $3->getName().c_str(), $3->getPlace());
							else
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "sw\t$%d, -%d($fp)\n", reg, temp->offset);
							}
						else if (temp->dType == floatp)
							{
							if (temp1->offset == 0)
								fprintf(out, "l.s\t$%d, %s\n", reg, $3->getName().c_str());
							else
								fprintf(out, "l.s\t$%d, -%d($fp)\n", reg, $3->getPlace());							
							fprintf(out, "s.s\t$f%d, -%d($fp)\n", reg, temp->offset);
							}
						}
					}
				$$ = new ListElement("temp", int_type);
				$$->setPlace(reg);
				delete $3;
				}
				| relop_expr
				{
				if ($1 != NULL)
					{
					$$ = $1;
					if ($1->getType() != 0)
						yyerror(" Logical expressions must be of integer type");
					}
				}
				| { $$ = new ListElement("dummy", int_type); }
				;

relop_expr		: relop_term
				{
				if ($1 == NULL)
					$$ = NULL;
				else 
					{
					if ($1->getName() != "" )		
						$$ = $1;
					else
						{
						$$ = NULL;
						delete $1;
						}
					}
				}
				| relop_expr OP_OR
				{
				if ($1)
					fprintf(out, "bnez\t$%d, T%d\n", $1->getPlace(), ++andorLabelnum);
				andorLabel.push(andorLabelnum);
				}
				relop_term
				{
				ListElement *temp = evaluate($1,$4,or); 
				if (temp != NULL)
					$$ = temp;
				fprintf(out, "bnez\t$%d, T%d\n", $4->getPlace(), andorLabel.get());
				}
				;

relop_term		: relop_factor 
				{
				$$ = $1;
				}
				| relop_term OP_AND relop_factor 
				{  
				ListElement *temp = evaluate($1,$3,and); 
				if (temp != NULL)
					$$ = temp;
				else
					{
					// Modify to generate code appropriately.
					if ($1) 
						{
						$$ = $1;
						if ($3) delete $3;
						}  
					else if ($3)
						{
						$$ = $3;
						}
					else
						$$ = $1;  // set to NULL, $1 is NULL 
					}
				}
				;

relop_factor	: expr 
				{
				$$ = $1;
				}
				| expr rel_op expr 
				{
				ListElement *temp = evaluate($1,$3,$2); 
				if (temp != NULL)
					$$ = temp;
				else if ($2 == eq)
				{
				fprintf(out, "#%s = %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 = a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "seq\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "seq\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "seq\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "seq\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "seq\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "seq\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#seqing 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp->scope == 0)
							{ // a(glob) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp1->scope == 0)
							{ // a(loc) + b(glob)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
							fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else
							{ // a(loc) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.eq.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						}
					$$ = new ListElement("temp", float_type);
					$$->setPlace(reg);
					}
				}
			}
			else if ($2 == ge)
				{
				fprintf(out, "#%s >= %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 = a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sge\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "sge\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "sge\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sge\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "sge\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "sge\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#sgeing 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp->scope == 0)
							{ // a(glob) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp1->scope == 0)
							{ // a(loc) + b(glob)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
							fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else
							{ // a(loc) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.ge.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						}
					$$ = new ListElement("temp", float_type);
					$$->setPlace(reg);
					}
				}
			}
			else if ($2 == le)
				{
				fprintf(out, "#%s <= %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 = a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sle\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "sle\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "sle\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sle\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "sle\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "sle\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#sleing 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.le.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp->scope == 0)
							{ // a(glob) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.le.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp1->scope == 0)
							{ // a(loc) + b(glob)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
							fprintf(out, "c.le.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else
							{ // a(loc) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.le.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						}
					$$ = new ListElement("temp", float_type);
					$$->setPlace(reg);
					}
				}
			}
			else if ($2 == ne)
				{
				fprintf(out, "#%s != %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 = a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sne\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "sne\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "sne\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sne\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "sne\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "sne\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#sneing 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp->scope == 0)
							{ // a(glob) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp1->scope == 0)
							{ // a(loc) + b(glob)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
							fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else
							{ // a(loc) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.ne.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						}
					$$ = new ListElement("temp", float_type);
					$$->setPlace(reg);
					}
				}
			}
			else if ($2 == gt)
				{
				fprintf(out, "#%s > %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 = a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sgt\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "sgt\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "sgt\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sgt\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "sgt\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "sgt\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#sgting 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp->scope == 0)
							{ // a(glob) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp1->scope == 0)
							{ // a(loc) + b(glob)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
							fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else
							{ // a(loc) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.gt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						}
					$$ = new ListElement("temp", float_type);
					$$->setPlace(reg);
					}
				}
			}
			else if ($2 == lt)
				{
				fprintf(out, "#%s < %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 = a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "slt\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "slt\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "slt\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "slt\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "slt\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "slt\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#slting 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp->scope == 0)
							{ // a(glob) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else if (temp1->scope == 0)
							{ // a(loc) + b(glob)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
							fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						else
							{ // a(loc) + b(loc)
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
							fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
							fprintf(out, "c.lt.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
							}
						}
					$$ = new ListElement("temp", float_type);
					$$->setPlace(reg);
					}
				}
				}
				}
				;

rel_op		: OP_EQ { $$ = (int)eq; }
			| OP_GE { $$ = (int)ge; }
			| OP_LE { $$ = (int)le; }
			| OP_NE { $$ = (int)ne; }
			| OP_GT { $$ = (int)gt; } 
			| OP_LT { $$ = (int)lt; }
			;

relop_expr_list	: nonempty_relop_expr_list
				{
				$$ = $1; 
				}
				|
				{
				$$ = NULL;
				}
				;

nonempty_relop_expr_list : nonempty_relop_expr_list MK_COMMA relop_expr 
				{
				$$ = $1;
				$$->insert($3);
				}
				| relop_expr 
				{
				$$ = new List;
				$$->insert($1);		   		
				}
				;

expr		: expr add_op term 
			{ 
			ListElement *temp = evaluate($1,$3,$2); 
//			fprintf(out, "expr add_op term\n");
			if (temp != NULL)
				{
				$$ = temp;
				fprintf(out,"# %f %f\n", temp->getVal(), $$->getVal());
				}
			else if ($2 == plus)
				{
				fprintf(out, "#%s + %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "add\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "add\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "add\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "add\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "add\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "add\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#adding 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "add.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", float_type);
						$$->setPlace(reg);
						}
					else if (($1->getType() == intp) && ($3->getType() == intp))
						{
						fprintf(out, "#adding 2 int dummies\n");
						int reg;
						reg = getReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "add\t$%d, $%d, $%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) +c(glob)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) + c(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) +(b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $3->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "add\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", int_type);
						$$->setPlace(reg);
						}
					}
				}
			// subtract
			else if ($2 == minus)
				{
				fprintf(out, "#%s - %s\n", $1->getName().c_str(),
				$3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sub\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "sub\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "sub\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "sub\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "sub\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "sub\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#subing 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "sub.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", float_type);
						$$->setPlace(reg);
						}
					else if (($1->getType() == intp) && ($3->getType() == intp))
						{
						fprintf(out, "#subing 2 int dummies\n");
						int reg;
						reg = getReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "sub\t$%d, $%d, $%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) +c(glob)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) + c(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) +(b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $3->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "sub\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", int_type);
						$$->setPlace(reg);
						}
					}
				}
			$$->setVal(0);
			}
			| term 
			{
			$$ = $1;
			}
			;

add_op		: OP_PLUS { $$ = (int)plus; }
			| OP_MINUS{ $$ = (int)minus; } 
			;

term		: term mul_op factor 
			{ 
			ListElement *temp = evaluate($1,$3,$2); 
//			fprintf(out, "expr add_op term\n");
			if (temp != NULL)
				{
				$$ = temp;
				$$->setVal(temp->getVal());
				fprintf(out,"# here ?%f %f\n", temp->getVal(), $$->getVal());
				}
			else if ($2 == times)
				{
//				fprintf(out, "#%s * %s\n", $1->getName().c_str(), $3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "mul\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "mul\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "mul\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "mul\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "mul\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "mul\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#muling 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "mul.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", float_type);
						$$->setPlace(reg);
						}
					else if (($1->getType() == intp) && ($3->getType() == intp))
						{
						fprintf(out, "#muling 2 int dummies\n");
						int reg;
						reg = getReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "mul\t$%d, $%d, $%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) +c(glob)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) + c(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) +(b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $3->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "mul\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", int_type);
						$$->setPlace(reg);
						}
					}
				}
			// divide
			else if ($2 == divds)
				{
				fprintf(out, "#%s / %s\n", $1->getName().c_str(),
				$3->getName().c_str());
				if ((int)$1->getVal() != 0)
					{ // is $1 a constant
					if (strcmp($3->getName().c_str(), "temp") != 0)
						{ // $3 is not a dummy variable
						struct tData *temp = st.find($3->getName().c_str());
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + a(glob)
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "div\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							else
								{ // 4 + a(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$3->getPlace());
								fprintf(out, "div\t$%d, $%d, %d\n", reg, reg1, (int)$1->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // 4.5 + a(glob)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // 4.5 + a(loc)
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$3->getPlace());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $3 is a dummy variable
						if ($1->getType() == intp)
							{ // is $1 an integer
							// 4 + (a + b + c)
							int reg;
							reg = getReg();
							fprintf(out, "div\t$%d, $%d, %d\n", reg,
							$3->getPlace(), (int)$1->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($1->getType() == floatp)
							{
							// 4.5 + (a + b + c)
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $1->getVal());							
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg,
							$3->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else if ((int)$3->getVal() != 0)
					{ // is $3 a constant
					if (strcmp($1->getName().c_str(), "temp") != 0)
						{ // $1 is not a dummy variable
						struct tData *temp = st.find($1->getName().c_str());
						if ($3->getType() == intp)
							{ // is $3 an integer
							int reg;
							reg = getReg();
							if (temp->scope == 0)
								{
								// a(glob) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), (int)$3->getPlace());
								fprintf(out, "div\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							else
								{
								// a(loc) + 4
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, (int)$1->getPlace());
								fprintf(out, "div\t$%d, $%d, %d\n", reg, reg1, (int)$3->getVal());
								}
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg1, reg2;
							reg1 = getFloatReg();
							reg2 = getFloatReg();
							if (temp->scope == 0)
								{ // a(glob) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $1->getName().c_str());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg1, reg1,
								reg2);
								}
							else
								{ // a(loc) + 4.5
								fprintf(out, "l.s\t$f%d, _f%d\n", reg1, flt_num - 1);
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2,
								$1->getPlace());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n",
								reg1, reg1, reg2);
								}
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg1);
							}
						}
					else
						{ // $1 is a dummy variable
						if ($3->getType() == intp)
							{ // is $3 an integer
							// (a + b + c) + 4
							int reg;
							reg = getReg();
							fprintf(out, "div\t$%d, $%d, %d\n", reg,
							$1->getPlace(), (int)$3->getVal());
							$$= new ListElement("temp", int_type);
							$$->setPlace(reg);
							}
						else if ($3->getType() == floatp)
							{
							// (a + b + c) + 4.5
							char buf[256];
							sprintf(buf, "_f%d:\t.float %f\n", flt_num++, $3->getVal());
							strcat(flt_buf, buf);
							int reg;
							reg = getFloatReg();
							fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
							fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg,
							$1->getPlace(), flt_num - 1);
							$$ = new ListElement("temp", float_type);
							$$->setPlace(reg);
							}
						}
					}
				else
					{ // neither is a constant
					fprintf(out, "#no constants %d %d\n", $1->getType(), $3->getType());
					if (($1->getType() == floatp) && ($3->getType() == floatp))
						{
						fprintf(out, "#diving 2 int dummies\n");
						int reg;
						reg = getFloatReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) + c(glob)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$%d, %s\n", reg1, $3->getName().c_str());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) +c(loc)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, %s\n", reg1, $1->getName().c_str());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, %s\n", reg2, $3->getName().c_str());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getFloatReg();
								reg2 = getFloatReg();
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "l.s\t$f%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "div.s\t$f%d, $f%d, $f%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", float_type);
						$$->setPlace(reg);
						}
					else if (($1->getType() == intp) && ($3->getType() == intp))
						{
						fprintf(out, "#dividing 2 int dummies\n");
						int reg;
						reg = getReg();
						if ((strcmp($1->getName().c_str(), "temp") == 0) &&
						(strcmp($3->getName().c_str(), "temp") == 0))
							// (a+b) + (c+d)
							fprintf(out, "div\t$%d, $%d, $%d\n", reg, $1->getPlace(), $3->getPlace());
						else if (strcmp($1->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($3->getName().c_str());
							if (temp->scope == 0)
								{ // (a+b) +c(glob)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							else
								{ // (a+b) + c(loc)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $3->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d\n", reg, $1->getPlace(), reg1);
								}
							}
						else if (strcmp($3->getName().c_str(), "temp") == 0)
							{
							struct tData *temp = st.find($1->getName().c_str());
							if (temp->scope == 0)
								{ // a(glob) +(b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $3->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							else
								{ // a(loc) + (b+c)
								int reg1;
								reg1 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d\n", reg, $3->getPlace(), reg1);
								}
							}
						else
							{
							struct tData *temp = st.find($1->getName().c_str());
							struct tData *temp1 = st.find($3->getName().c_str());
							if ((temp->scope == 0) && (temp1->scope == 0))
								{ // a(glob) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp->scope == 0)
								{ // a(glob) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, %s + %d\n", reg1, $1->getName().c_str(), $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else if (temp1->scope == 0)
								{ // a(loc) + b(glob)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, %s + %d\n", reg2, $3->getName().c_str(), $3->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							else
								{ // a(loc) + b(loc)
								int reg1, reg2;
								reg1 = getReg();
								reg2 = getReg();
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg1, $1->getPlace());
								fprintf(out, "lw\t$%d, -%d($fp)\n", reg2, $3->getPlace());
								fprintf(out, "div\t$%d, $%d, $%d \n", reg, reg1, reg2);
								}
							}
						$$ = new ListElement("temp", int_type);
						$$->setPlace(reg);
						}
					}
				}
			$$->setVal(0);
			}
			| factor 
			{
			$$ = $1;
			}
			;

mul_op		: OP_TIMES { $$ = (int)times; }
			| OP_DIVIDE { $$ = (int)divds; }
			;

factor		: MK_LPAREN relop_expr MK_RPAREN
			{
			$$ = $2;
			}	
			| OP_MINUS MK_LPAREN relop_expr MK_RPAREN
			{
			$$ = $3;
			}
			| OP_NOT MK_LPAREN relop_expr MK_RPAREN 
			{
			if ($3 != int_type)
				{
				yyerror("Logical expression must have integer operand");
				$$ = int_type;
				}
			else
				$$ = $3;
			}
			| ID
			{
			struct tData *temp = st.find($1);
			enum dataType rt;
			rt = checkDefined($1);

			if (noCheck)
				{	
				if (rt == intp)
					{
					$$ = new ListElement($1, int_type);
					$$->setPlace(temp->offset);
					}
				else if (rt == floatp)
					{
					$$ = new ListElement($1, float_type);
					$$->setPlace(temp->offset);
					fprintf(out, "#place is %d\n", temp->place);
					}
				}
			else
				{
				if (rt == intp)
					{
					$$ = new ListElement($1,int_type);
					$$->setPlace(temp->offset);
					}
				else if (rt == floatp)
					{
					$$ = new ListElement($1,float_type);
					$$->setPlace(temp->offset);
					}
				else if (rt == voidp)
					{
					$$ = NULL;;
					sprintf(buff, "ID %s is of void type, not allowed as an operand",$1);
					yyerror(buff);
					}
				else
					$$ = NULL;
				}
			}	
			| OP_MINUS ID 
			{
			if (noCheck)
				$$ = NULL;
			else
				{
				enum dataType rt = checkDefined($2);		
				if (rt == intp)
					$$ = new ListElement($2,int_type);
				else if (rt == floatp)
					$$ = new ListElement($2,float_type);
				else if (rt == voidp)
					{
					$$ = NULL;;
					sprintf(buff, "ID %s is of void type, not allowed as an operand",$2);
					yyerror(buff);
					}
				else 
					$$ = NULL;
				}
			}
			| OP_NOT ID 
			{
			if (noCheck)
				$$ = NULL;
			else
				{
				enum dataType rt = checkDefined($2);		
				if (rt == intp)
					$$ = new ListElement($2,int_type);
				else if (rt == floatp)
					$$ = new ListElement($2,float_type);
				else if (rt == voidp)
					{
					$$ = NULL;;
					sprintf(buff, "ID %s is of void type, not allowed as an operand",$2);
					yyerror(buff);
					}
				}
			}
			| CONSTANT 
			{
			int typ = constantType($1);
			if (noCheck)
				{
				if (typ == string_type)
					{
					// string constant
					char tBuff[10];
					sprintf(tBuff, "m%d", str_num++);
					sprintf(buff, "%s:\t.asciiz %s\n", tBuff, $1);
					strcat(str_buf, buff);
					isStrings = true;
					$$ = new ListElement(tBuff, string_type);
					$$->setPlace(str_num - 1);
					}
				else if (typ == int_type)
					{
					$$ = new ListElement("dummy",int_type);
					$$->setVal(atof($1));
					}
				}
			else
				{
				// DO NOT WANT TO DO THIS
				// FOR NOW IS OK????
				
				// constant in an expression
				if (typ == int_type)
					{
					$$ = new ListElement("dummy",int_type);
					$$->setVal(atof($1));
					}
				else if (typ == float_type )
					{
					$$ = new ListElement("dummy",float_type);
					$$->setVal(atof($1));
					isFloat = true;
					}
				else
					{
					yyerror(" Illegal rvalue in expression");
					$$ = NULL;
					}
				}
			}
			| OP_MINUS CONSTANT 
			{
			int typ = constantType($2);
			if (noCheck)
				if (typ == int_type)
					{
					$$ = new ListElement("dummy",int_type);
					$$->setVal(atof($2));
					}
			else
				{
				// DO NOT WANT TO DO THIS
				// FOR NOW IS OK????
				
				// constant in an expression
				if (typ == int_type)
					{
					$$ = new ListElement("dummy",int_type);
					$$->setVal(atof($2) * -1.0);
					}
				else if (typ == float_type )
					{
					$$ = new ListElement("dummy",float_type);
					$$->setVal(atof($2) * -1.0);
					isFloat = true;
					}
				else 
					{
					yyerror(" Illegal rvalue in expression");
					$$ = NULL;
					}
				}
			}
			| OP_NOT CONSTANT 
			{ 
			int typ = constantType($2);
			if (noCheck)
				if (typ == int_type)
					{
					$$ = new ListElement("dummy",int_type);
					$$->setVal(atof($2));
					}
			else
				{
				// DO NOT WANT TO DO THIS
				// FOR NOW IS OK????
				
				// constant in an expression
				if (typ == int_type)
					{
					$$ = new ListElement("dummy",int_type);
					$$->setVal(1.0);
					}
				else if (typ == float_type )
					{
					$$ = new ListElement("dummy",float_type);
					$$->setVal(1.0);
					isFloat = true;
					}
				else 
					{
					yyerror(" Illegal rvalue in expression");
					$$ = NULL;
					}
				}
			}
			| ID  MK_LPAREN relop_expr_list MK_RPAREN 
			{
			if (noCheck)
				$$ = NULL;
			else
				{
				enum dataType rt = checkDefinedFunc($1,$3);		
				if (rt == intp)
					$$ = new ListElement($1,int_type);
				else if (rt == floatp)
					$$ = new ListElement($1,float_type);
				else if (rt == voidp)
					{
					$$ = NULL;
					sprintf(buff, "ID %s is of void type, not allowed as an operand",$1);
					yyerror(buff);
					}
				else 
					$$ = NULL;
				}
			if ($3 != NULL) delete $3;
			}
			| OP_MINUS ID MK_LPAREN relop_expr_list MK_RPAREN 
			{
			if (noCheck)
				$$ = NULL;
			else
				{
				enum dataType rt = checkDefinedFunc($2,$4);		
				if (rt == intp)
					$$ = new ListElement($2,int_type);
				else if (rt == floatp)
					$$ = new ListElement($2,float_type);
				else if (rt == voidp)
					{
					$$ = NULL;;
					sprintf(buff, "ID %s is of void type, not allowed as an operand",$2);
					yyerror(buff);
					}
				else 
					$$ = NULL;
				}
			if ($4 != NULL) delete $4;
			}
			| OP_NOT ID MK_LPAREN relop_expr_list MK_RPAREN 		
			{
			if (noCheck)
				$$ = NULL;
			else
				{
				enum dataType rt = checkDefinedFunc($2,$4);		
				if (rt == intp)
					$$ = new ListElement($2,int_type);
				else if (rt == floatp)
					$$ = new ListElement($2,float_type);
				else if (rt == voidp)
					{
					$$ = NULL;;
					sprintf(buff, "ID %s is of void type, not allowed as an operand",$2);
					yyerror(buff);
					}
				else 
					$$ = NULL; 
				}
				if ($4 != NULL) delete $4;
			}
			| ID dim
			{
			fprintf(out, "#load address plus array\n");

			//compute array offset
			struct tData *temp = st.find($1);
			enum dataType rt =  checkDefined($1,$2);

			int space = 0;
			if (temp->arrayDim[0] > 1)
				{
				for (int i = 1; i < $2[0]; i++)
					{
					fprintf(out, "#space = %d\n", space);
					if (!space) space = $2[i];
					space = space * temp->arrayDim[i + 1] + $2[i + 1];
					fprintf(out, "#current offset = %d current index = %d index size = %d\n", space,
					$2[i], temp->arrayDim[i + 1]);
					}
				}
			else
				space += $2[$2[0]];

			if (noCheck)
				{
				if (rt == intp)
					{
					$$ = new ListElement($1,int_type);
					$$->setPlace(temp->offset + space * 4);
					}
				}
			else 
				{
				if (rt == intp)
					{
					$$ = new ListElement($1,int_type);
					$$->setPlace(temp->offset + space * 4);
					}
				}

			fprintf(out, "#Place is %d\n", temp->offset);
			} 
			| OP_MINUS ID dim 
			{
			fprintf(out, "#load base address plus array\n");
			}
			| OP_NOT ID dim
			{
			fprintf(out, "#load base address plus array\n");
			} 
			;

dim_decl	: MK_LSQBRACE expr MK_RSQBRACE 
			{ 
			$$[0] = 1;
			$$[1] = (int)$2->getVal();
			fprintf(out, "#dim %d=%d\n", $$[0], (int)$2->getVal());
			}
			| dim_decl MK_LSQBRACE expr MK_RSQBRACE 
			{ 
			$$[0]++;
			$$[$$[0]] = (int)$3->getVal(); 
			fprintf(out, "#dim %d=%d\n", $$[0], (int)$3->getVal());
			}
			;

dim			: MK_LSQBRACE expr MK_RSQBRACE 
			{
			$$[0] = 1;
			$$[1] = (int)$2->getVal();
			fprintf(out, "#dim %d\n", (int)$2->getVal());
			}
			| dim MK_LSQBRACE expr MK_RSQBRACE 
			{
			$$[0]++;
			$$[$$[0]] = (int)$3->getVal(); 
			fprintf(out, "#dim %d\n", (int)$3->getVal());
			}
			;
%%


int main (int argc,char **argv)
{
	if (argc > 1)
		yyin = fopen(argv[1],"r");
	else
		yyin = stdin;
	if (argc > 2){
		char buf[80];
		buf[0] = '\0';
		strcat(buf, argv[2]);
		strcat(buf, ".s");
		out = fopen(buf, "w");
		}
	else
		out = fopen("a.out", "w");
    
  yyparse();
  if (errorflag == 0)
  	; // do nothing
//    printf("%s\n", "Parsing Completed. No errors found.");
  else
    printf("Errors encountered \n");
  fclose(yyin);
}


//--------------------------------------------------
// addToSymTab(...)
//	The argument passed is a list of terms from 
//	either a variable decl. (int a,b,c,d; )
//	or from a function call/declaration like
//	int func(int a, int b, int c) ...
//	If dtyp is undef_type, then we have to peek inside each list element 
//	to find the type.
//	In case we are dealing with a typedef'd variable, we have to look it up first
//--------------------------------------------------
  
void addToSymTab(List *l, int dtyp, bool typedefd )
{
// type of current item in list
int dt; 
struct tData srec;
if (l == NULL)
	{
	return;
	}

ListElement *temp ; 
for (temp = l->getFirst(); temp != NULL; temp = l->getNext(temp) )
	{
	// if this is from a parameter list, each list node has different type info 
	// so we look inside each element.
	if (dtyp == undef_type ) 
		dt = temp->getType();
	else dt = dtyp;

	srec.token = temp->getName();
	srec.offset = offset;
	offset += 4;

	if (srec.token == "" ) continue;
	// if this is a typdef statment ...we handle a little differently
	if (typedefd)
		{
		srec.dType = typedefp;
		if (dt == 0)
			srec.redefType = intp;
		else if (dt == 1)
			srec.redefType = floatp;
		else if (dt == 2)
			srec.redefType = voidp;  
		}
	else
		{
		dt==0?srec.dType = intp: srec.dType = floatp;
		for (int i = 0; i <= temp->isArray(); i++)
			srec.arrayDim[i] = temp->getArray(i);
		}
	srec.scope = scope;
	
	if (!typedefd)
		{
		if (!scope)
			{
			srec.offset = 0;
			if (dt == intp)
				{
				if (!dotData) fprintf(out, "\t.data\n");
				dotData = true;
				if (srec.arrayDim[0] == 0)
					{
					srec.value.intval = (int) temp->getVal();
					fprintf(out, "%s:\t.word %d\n", srec.token.c_str(),
					srec.value.intval);
					}
				else
					{
					int space = 1;
					for (int i = 1; i <= srec.arrayDim[0]; i++)
						space *= srec.arrayDim[i];
					fprintf(out, "%s:\t.space %d\n", srec.token.c_str(), 4 * space);
					}
				}
			else if (dt == floatp)
				{
				srec.value.floatval = temp->getVal();
				if (!dotData) fprintf(out, "\t.data\n");
				dotData = true;

				fprintf(out, "%s:\t.float %f\n", srec.token.c_str(), srec.value.floatval);
				}
			}
		else if (scope)
			{
			int reg;
			int space = 1;
			reg = getReg();
			if (dt == intp)
				{
				srec.value.intval = (int) temp->getVal();
				srec.place = srec.offset;

				if (temp->getVal() != 0)
					{
					fprintf(out, "li\t$%d, %d\n", reg, srec.value.intval);
					fprintf(out, "sw\t$%d, -%d($fp)\n", reg, srec.offset);
					}

				for (int i = 1; i <=srec.arrayDim[0]; i++)
					space *= srec.arrayDim[i];
				offset += 4 * (space - 1);
				}
			else if (dt == floatp)
				{
				srec.value.floatval = temp->getVal();
				srec.place = srec.offset;
				fprintf(out, "#%s: %d\n", srec.token.c_str(), srec.place);

				if (temp->getVal() != 0)
					{
					char buf[256];
					sprintf(buf, "_f%d:\t.float %f\n", flt_num++, temp->getVal());							
					strcat(flt_buf, buf);
					int reg;
					reg = getFloatReg();

					fprintf(out, "l.s\t$f%d, _f%d\n", reg, flt_num - 1);
					fprintf(out, "s.s\t$f%d, %d($fp)\n", reg, srec.place);
					}
				}
			}
		}
		if (!st.insert(srec))
			{
			sprintf(buff,"ID %s declared more than once", srec.token.c_str() );
			yyerror(buff);
			}
	}
}

//--------------------------------------------------
// addFuncToSymTab(.....)
//	we go through the parameter list and aggregate
//	then insert into the symbol table. Associate the return type
//	with the data type .. so that in expressions involving function calls, 
//	validation is easy
//--------------------------------------------------
void addFuncToSymTab(char *fname, int typ, List *l)
{
  struct tData srec;
  int dim_p = 0;  
  if (l == NULL)
    {
      srec.nparams = dim_p;
    }
  else 
    {
      ListElement *temp = l->getFirst();
      for (int i=0; i < l->size(); i++ )
	{
	  switch ( temp->getType() ) 
	    {
	    case 0: {
	      srec.pbitmap[dim_p] = intp;
	      break;
	    }
	    case 1: {
	      srec.pbitmap[dim_p] = floatp;
	      break;
	    }
	    default: {
	      string s = temp->getName();
	      sprintf(buff," Illegal actual type for parameter %s ", s.c_str() );
	      yyerror(buff);
	      break;
	    }
	    }
	  srec.arrbitmap[dim_p] = temp->isArray();
	  dim_p++;
	  temp = l->getNext(temp);
	}
      srec.nparams = dim_p;
    }
  srec.token = string(fname);
  if (typ == int_type)
    srec.rType = intp;
  else if (typ == float_type)
    srec.rType = floatp;
  else if (typ == void_type)
    srec.rType = voidp;
  else
    {
      yyerror(" unrecognised return type for function ");
      cout<<"in addFuncToSymTab() ->abort"<<endl;
      abort();
    }
  srec.dType = functionp;
  srec.arrayDim[0] = 0;
  // function def should never be removed from symtab. scope > 0 will cause it to be removed
  srec.scope = 0;  
  if (!st.insert(srec))
    {
      cout<<"Error inserting "<<srec.token<<endl;
      cout<<"in addFuncToSymTab() ->abort"<<endl;
      abort();
    }
}

//--------------------------------------------------
// addFuncToSymTab(char *..., char *...)
//	Same as previous function, except that the
//	return type is a typedef'd variable.
//	We just look it up and pass it on.
//--------------------------------------------------

void addFuncToSymTab(char *fname, char *typ, List *l)     
{
 struct tData srec;
 struct tData *lookp;
 lookp = st.find(typ);
 if (lookp == NULL)
   {
     sprintf(buff,"%s undefined in %s", typ, fname);
     yyerror(buff);
     return;
   } 
 if (lookp->dType != typedefp)
   {
     printf(buff, "return type %s is not a defined type ", typ);
     yyerror(buff);
     return;
   }
 // what is it redifined as 
 int re_type = int(lookp->redefType); 
 addFuncToSymTab(fname, re_type, l);
}


//--------------------------------------------------
// incr_scope
//	everytime we enter a new statement block, 
//	we increment the scope. So that variables declared in this
//	block can be deallocated when we exit.
//--------------------------------------------------
void incr_scope()
{
  scope++;
  SymbolTable::setscope(scope);
}

//--------------------------------------------------
// decr_scope
//	decrease the scope and clean up the symbol table
//	this causes all invalid entries to be removed
//--------------------------------------------------
void decr_scope()
{
  scope--;
  SymbolTable::setscope(scope);
  st.cleanup();
}


//--------------------------------------------------
// checkDefined
//	Check if the variable encountered is previously
//	defined. If array dereferencing is involved, check
//	if the dimensions are correct
//--------------------------------------------------
enum dataType checkDefined(char *name, int arrDim[])
{
  struct tData *temp;
  temp = st.find(name);
  if (temp == NULL)
    {      
      sprintf(buff, "ID %s is not declared ", name);
      yyerror(buff);
      // Function not defined, no more checking required !!
      return nullp;
    }
  else if (arrDim != NULL) {
    //check that the dimensions match
    if (temp->arrayDim[0] != arrDim[0])
      {
	sprintf(buff, "Incompatible Array dimensions %s", name);
	yyerror(buff);
      }
  }  
  return temp->dType;  
}


//--------------------------------------------------
// checkDefinedFunc
//	check if the function call encountered corresponds
//	to a previously defined function.
//	also do typechecking for the arguments being passed
//--------------------------------------------------
enum dataType checkDefinedFunc(char *name, List *l)
{
  if ((strcmp(name,"write") == 0) || (strcmp(name,"read") == 0))
    {
      return voidp;
    }  
  ListElement *ltmp;
  struct tData *funcDef;
  // check if the function is declared earlier.
  funcDef = st.find(name);
  if (funcDef == NULL)
    {
      sprintf(buff, "ID %s is not defined", name);
      yyerror(buff); 
      return nullp; 
    }
  if (l == NULL) return funcDef->rType; 
  // number of parameters being passed to the function
  int list_size = l->size();

  if (funcDef->nparams != list_size )
    {
      sprintf(buff," Incorrect number of parameters to function %s",name);
      yyerror(buff);
      // no more checking returned 
      return nullp;
    }
  // for the actual param list ... do an item by item match with the dummy parameters declrd.
  char buff[40];
  struct tData *paramDef;  
  ltmp = l->getFirst();
  for (int indx = 0 ;indx < list_size ; indx++, ltmp = l->getNext(ltmp) )
    {
      if (!ltmp) continue;
      // check if passed variable is previously declared.
      string txt = ltmp->getName();
      // if a dummy ... only take type into account
      // get type of actual parameter being passed
      int passing_type = ltmp->getType();
      paramDef = (struct tData*)st.find(txt);
      // if the argument is an evaluated expression, we are only interested in the type
      if (txt == string("dummy") )
	{
	  if (passing_type > 1)
	    {
	      sprintf(buff," Illegal actual type for parameter %s ", (ltmp->getName()).c_str() );
	      yyerror(buff);
	      continue;
	    }
	  else
	    continue;
	}

      if ( (paramDef == NULL) && (txt != string("dummy") ))
	{
	  sprintf(buff, "ID %s is not defined ", txt.c_str());
	  yyerror(buff);
	  continue;
	}

      // only int/float can be passed as formal args
      if (passing_type > 1)
	{
	  sprintf(buff," Illegal actual type for parameter %s ", (ltmp->getName()).c_str() );
	  yyerror(buff);
	  continue;
	}
      int p_dim = paramDef->arrayDim[0];
      // dimensions of the vector being passed (as declared)
      //(actual arg) is of type [4][.][.] etc., 
      // dimensions would have been matched while parsing.
      
      //(i)scalar passed to array: 
      if (p_dim == 0 && funcDef->arrbitmap[indx] != 0)
	{
	  sprintf(buff, "Scalar %s being passed to array " , (ltmp->getName()).c_str() );
	  yyerror(buff);
	  continue;
	}

      //(ii)array passed to scalar
      else if (p_dim >0 &&  funcDef->arrbitmap[indx] == 0 )
	{
	  // if we dereference the array  completely... then it is valid
	  if (ltmp->isArray() == p_dim )
	    continue;
	  sprintf(buff, "Array %s being passed to scalar ", (ltmp->getName()).c_str() );
	  yyerror(buff);
	  continue;
	}
    }		
  return funcDef->rType;
}    



//--------------------------------------------------
// checkRetType
//	we earlier set the return type in currRetType
//	match and check if is identical
//--------------------------------------------------
void checkRetType(enum dataType rt)
{
  if (rt == voidp && currRetType== voidp)
    return;
 
  if (rt == intp)
    if (currRetType == intp || currRetType == floatp)
      return;
  yyerror("  Incompatible return type"); 
}

//--------------------------------------------------
// constantType
//	We parsed a literal
//	we scan through it and try to find the data type.
//	Possibly buggy. 1234.12.1234 is treated as a valid float
//--------------------------------------------------
int constantType(char *txt)
{
  int type = int_type;  // integer by default.
  for (unsigned int i = 0; i < strlen(txt); i++)
    {
      if ( !isdigit(txt[i]) )
	{
	  if (txt[i] == '.')
	    type = float_type;
	  else
	    type = string_type;
	}
    }
  return type;
}

//--------------------------------------------------
// evaluate
//	do typechecking for arithmetic and relational operations
//	also reduce the number of terms by combining. Two operands are passed,
//	the type is verified and only one (result) is returned.
//	This can be used for folding constants.
//--------------------------------------------------
ListElement *evaluate(ListElement *arg1, ListElement *arg2, enum oper operand)
{
  bool arith_exp;
  bool float_expr;
  if (operand == plus || operand == minus || operand == times || operand == divds)
    arith_exp = true;
  else
    {
      arith_exp = false;
      float_expr = false;
    }

  ListElement *temp;
  if (arg1 == NULL || arg2 == NULL)
    return NULL;

  if (arg1->getName() == string("temp") || arg2->getName() == string("temp"))
		return NULL;

    // both are non null
  if (arg1->getType() > 1 || arg2->getType() > 1)
    {
      yyerror("Illegal rvalue in expression");      
      return NULL;
    }

  int arg1_typ, arg2_typ;
  arg1_typ = arg1->getType();
  arg2_typ = arg2->getType();
  
  // if we are dealing with a relational expression .. then we have to check for non-integer operands
  if (arith_exp == false)
    if (arg1_typ != int_type  || arg2_typ != int_type)
     {
       cout<<"Operator = "<<int(operand)<<endl;
       yyerror("Non integer argument to relational expression");   
     }
  
  if (arg1->getName() == string("dummy") && arg2->getName() == string("dummy"))
    {
      float op1 = arg1->getVal();
      float op2 = arg2->getVal();
      float fres;
      int ires;
      switch (operand)
	{
	case plus: {	
	  if (float_expr)
	    fres = op1 + op2;
	  else
	    ires = (int)op1 + (int)op2;
	  break;
	}
	case minus: {
	  if (float_expr)
	    fres = op1 - op2;
	  else
	    ires = (int)op1 - (int)op2;
	  break;
	}
	case times: {
	  if (float_expr)
	    fres = op1 * op2;
	  else
	    ires = (int)op1 * (int)op2;
	  break;
	}
	case divds: {
	  if (float_expr)
	    fres = op1 / op2;
	  else
	    ires = (int)op1 / (int)op2;
	  break;
	}
	// the rest use both integer operands
	case gt: {
	  ires = ( (int)op1 > (int)op2 );
	  break;
	}
	case lt: {
	  ires = ( (int)op1 < (int)op2);
	  break;
	}
	case ge: {
	  ires = ( (int)op1 >= (int)op2);
	  break;
	}
	case le: {
	  ires = ( (int)op1 <= (int)op2);
	  break;
	}
	case eq: {
	  ires = ( (int)op1 == (int)op2);
	  break;
	}
	case ne: {
	  ires = ( (int)op1 != (int)op2);
	  break;
	}
	case and: {
	  ires = ( (int)op1 && (int)op2);
	  break;
	}
	case or: {
	  ires = ( (int)op1 && (int)op2);
	  break;
	}
	}
      if (float_expr)
	{
	  temp = new ListElement("dummy",float_type);
	  temp->setVal(fres);
	}
      else
	{
	  temp = new ListElement("dummy", int_type);
	  temp->setVal(ires);
	}
      
      if (arg1) delete arg1;
      if (arg2) delete arg2;
      return temp;      
    }
  
  // NO FOLDING POSSIBLE.

  // Need to modify code to handle passing back both operands
  // one way to do this is to return NULL and check for it at the point of call.

  return NULL;
}


//--------------------------------------------------
// getDefinedType
//	find the data type of the variable (assumed) 
//	declared earlier. 
//--------------------------------------------------
int getDefinedType(char *typ)
{
  struct tData *rec;
  rec = st.find(typ);
  if (rec == NULL)
    {
      sprintf(buff, "%s is not a defined type",typ);
      yyerror(buff);
      return int_type;
      // continue parsing .. assume integer type 
    }
  return int(rec->redefType);
}

  
//--------------------------------------------------
// yyerror
//	print error message. Set error flag and go back to parsing.
//	if error flag is set, we inhibit printing "Success" at the end
//--------------------------------------------------
int yyerror (char *mesg)
{  
  cout<<"Error found in Line "<<linenumber<<endl<<mesg<<endl;
  errorflag = 1;
  return 1;
}

//--------------------------------------------------
// setReturnType | checkReturnType
//	to handle return calls
//	first set the return type as seen in the function declaration
//	later (if there is a return ..) check if the type returned matches.
//--------------------------------------------------

void setReturnType(int typ)
{
  currRetType = typ;
}

void checkReturnType(int typ)
{
  if (currRetType == undef_type)
    return;
  if (currRetType != typ)
    {
      yyerror("incompatible return type");
    }
  currRetType = undef_type;
}

//--------------------------------------------------
// checkAndSet
//	If we are parsing a read/write function
//	we set the flag and all typechecking is turned off.
//--------------------------------------------------
void checkAndSet(char *fname)
{
  if ( (strcmp(fname, "write") == 0)|| (strcmp(fname,"read") == 0) )
    noCheck = true;
}

void gen_head(char *name)
{
	fprintf(out, "\t.text\n");
	fprintf(out, "%s:\n", name);
	dotData = false;
	isStrings = false;
	isFloat = false;
	strcpy(currFuncname, name);
}

void gen_prologue(char *name)
{
	fprintf(out, "sw\t$ra, 0($sp)\n");
	fprintf(out, "sw\t$fp, -4($sp)\n");
	fprintf(out, "add\t$fp, $sp, -4\n");
	fprintf(out, "add\t$sp, $sp, -8\n");
	fprintf(out, "lw\t$2, _framesize_%s\n", name);
	fprintf(out, "sub\t$sp, $sp, $2\n");
	fprintf(out, "_begin_%s:\n", name);
}

void gen_epilogue(char *name)
{
	fprintf(out, "_end_%s:\n", name);
	fprintf(out, "lw\t$ra, 4($sp)\n");
	fprintf(out, "move\t$sp, $fp\n");
	fprintf(out, "lw\t$fp, 0($sp)\n");
	if (strcmp(name, "main") == 0)
		{
		fprintf(out, "li\t$v0, 10\n");
		fprintf(out, "syscall\n");
		}
	else
		fprintf(out, "jr\t$ra\n");
	fprintf(out, "\t.data\n");
	fprintf(out, "_framesize_%s:\t.word %d\n", name, 4 + offset);
	// good place to put string constants
	if (isStrings || is_CR)
		fprintf(out, "%s", str_buf);
	if (isFloat)
		fprintf(out, "%s", flt_buf);
	str_buf[0] = '\0';
	flt_buf[0] = '\0';
}

void gen_return(char *name)
{
	fprintf(out, "j _end_%s\n", name);
}

int getReg()
{
	if (reg_number < 25)
		return reg_number++;
	else
		{
		reg_number = 8;
		return reg_number++;
		}
}

int getFloatReg()
{
	if (fltreg_number < 25)
		{
		fltreg_number++;
		return fltreg_number - 1;
		}
	else
		{
		fltreg_number = 0;
		return fltreg_number;
		}
}

void print_CR()
{
	if (!is_CR)
		{
		is_CR = true;
		strcat(str_buf, "_CR:\t.asciiz \"\\n\"\n");
		}

	fprintf(out, "li\t$v0 4\n");
	fprintf(out, "la\t$a0 _CR\n");
	fprintf(out, "syscall\n");
}
