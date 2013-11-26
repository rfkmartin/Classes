#ifndef RECORD_H
#define RECORD_H

#include<string>
#define TRUE 1
#define FALSE 0

#define int_type 0
#define float_type 1
#define void_type 2
#define string_type 4
#define undef_type 10

//--------------------------------------------------
// This is the structure that is used in the symbol table
// to store attributes about the tokens.
// To reduce complexity, a general structure is used ...
// which can accomodate everything needed.
// The other approach would have been to use lists to satellite information
//--------------------------------------------------
enum dataType { intp, floatp, voidp, functionp, typedefp, nullp }; 

struct tData {
  string token;
  enum dataType dType,rType;
  int arrayDim;  
  enum dataType redefType;   // redefined to .. using typedef directive
  union {
    int intval;
    float floatval;
    long int address;
  } value;
  // if it is a function ... we need these things
  int nparams;
  enum dataType pbitmap[10];
  // store the type of each argument
  int arrbitmap[10];
  // whether it is an array. If so dimensions are stored here.
  int scope;
  int offset;
};


struct indexType{
	int cnt;
	int Vp;
};

typedef struct {
	int type;
	int idtmp;
	int place;
	tData *pt;
} Ob_desc;

#endif
