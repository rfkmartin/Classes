/*
 * 6.088 IAP 2010
 * Assignment #4: Introduction to C++
 *
 * BST.h
 * Header file for the binary search tree
 *
 * You will implement a binary search tree that adheres to this interface.
 *
 */

#ifndef BST_H
#define BST_H

/*
 * Binary search tree
 */
class Node {
   int Val;
   Node *Left;
   Node *Right;
   public:
      Node();
      Node(int val) {Val=val;Left=NULL;Right=NULL;};
      ~Node();
      void nodeInsert(int val);
      bool nodeFind(int val);
      void nodePrintInorder();
};

Node::~Node()
{
   std::cout << "deleting " << Val << std::endl;
   if (this->Left != NULL)
   {
      delete this->Left;
   }
   if (this->Right != NULL)
   {
      delete this->Right;
   }
}

void Node::nodeInsert(int val)
{
   if (val < Val)
   {
      if (Left == NULL)
      {
         Left = new Node(val);
      }
      else
      {
         Left->nodeInsert(val);
      }
   }
   if (val > Val)
   {
      if (Right == NULL)
      {
         Right = new Node(val);
      }
      else
      {
         Right->nodeInsert(val);
      }
   }
}

bool Node::nodeFind(int val)
{
   if (val == Val)
   {
      return 1;
   }
   if (val < Val)
   {
      if (Left == NULL)
      {
         return 0;
      }
      else
      {
         Left->nodeFind(val);
      }
   }
   if (val > Val)
   {
      if (Right == NULL)
      {
         return 0;
      }
      else
      {
         Right->nodeFind(val);
      }
   }
}

void Node::nodePrintInorder()
{
   if (Left != NULL)
   {
      Left->nodePrintInorder();
   }
   std::cout << Val << " ";
   if (Right != NULL)
   {
      Right->nodePrintInorder();
   }
}

class BST {

   Node *root;

   public:

  // DO NOT change the declarations of the given methods.

  // constructor
  BST() { root = NULL; };

  // destructor
  ~BST();

  // inserts "val" into the tree
  void insert(int val);

  // returns true if and only if "val" exists in the tree.
  bool find(int val);

  // prints the tree elements in the in-order traversal order
  void print_inorder();

};

BST::~BST()
{
   delete root;
}

void BST::insert(int val)
{
   if (root == NULL)
   {
      root = new Node(val);
   }
   else
   {
      root->nodeInsert(val);
   }
}

bool BST::find(int val)
{
   return root->nodeFind(val);
}

void BST::print_inorder()
{
   root->nodePrintInorder();
   std::cout << std::endl;
}
#endif  // BST_H
