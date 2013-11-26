#include<iostream.h>
#include<string>

#define TRUE 1
#define FALSE 0


// symbol table record structure

struct tData {
  string token;
  int type;
  int scope;
  string Typdef;
};




class TreeElement {
 private:
  struct tData item;
  TreeElement *left;
  TreeElement *right;
  TreeElement *parent;

 public:
  TreeElement(string,int, int, string);
  ~TreeElement();
  void Printf();
  void SetLeft(TreeElement* );
  void SetRight(TreeElement* );
  void SetParent(TreeElement* );
  TreeElement* GetLeft();
  TreeElement* GetRight();
  TreeElement* GetParent();
  int GetScope() { return item.scope; }
  struct tData* GetData();
  void SetData(struct tData*);
  // the string passing will be slow .. change to pointers perhaps
  int NodeCmp(string , int);
  void Print();
};

class Tree {
 private:
  TreeElement *root;
  int insertions;
    
 public:
  Tree();
  ~Tree();
  bool Insert(string, int, int, string);
  struct tData* Find(string, int);
  void RecursePrint(TreeElement *);
  void Walk();
  void Clean(int);
  void TruncateTree(TreeElement *);
  void DeleteOutofScope(TreeElement *, int);
};

  
  

  

