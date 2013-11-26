PROGRAM AST;

(******************************************************************
 * AST.pas
 *
 * creates abstract syntax tree
 *
 * Robert F.K. Martin
 * ID 1505151
 * CSci 5106 - Programming Languages
 * Lab 4
 * 
 *****************************************************************)

TYPE
   prod	   = (add,mul,neg,cnst);
   exprPtr = ^expr;
   expr	   = record
		p	  : prod;
		case kind : (leaf,unary,binary) of
		  leaf	 : (i:integer);
		  unary	 : (c:^expr);
		  binary : (l,r:^expr);
		end; { case }
	

   
VAR
   my_e	 : expr;
   my_ep : exprPtr;

function doAST : exprPtr;
var ptr1, ptr2 : exprPtr;
var ptr3, ptr4 : exprPtr;
var ptr5, ptr6 : exprPtr;
begin
   new(ptr1);
   new(ptr2);
   new(ptr3);
   new(ptr4);
   new(ptr5);
   new(ptr6);
   { 1 }
   ptr1^.p:=cnst;
   ptr1^.i:=1;
   { -1 }
   ptr2^.p:=neg;
   ptr2^.c:=ptr1;
   { 3 }
   ptr3^.p:=cnst;
   ptr3^.i:=3;
   { 2 }
   ptr4^.p:=cnst;
   ptr4^.i:=2;
   {3 * 2 }
   ptr5^.p:=mul;
   ptr5^.l:=ptr3;
   ptr5^.r:=ptr4;
   { -1 + 3 * 2 }
   ptr6^.p:=add;
   ptr6^.l:=ptr2;
   ptr6^.r:=ptr5;

   return ptr6;
end;

function value (my_ep :exprPtr) : integer;
begin
   case my_ep^.p of
     add : return value(my_ep^.l) + value(my_ep^.r);
     mul : return value(my_ep^.l) * value(my_ep^.r);
     neg : return -1 * value(my_ep^.c);
     cnst : return my_ep^.i;
   end;	  
end;

begin
   my_ep:=doAST;
   write("the tree value is ",value(my_ep), ".\n");
end.