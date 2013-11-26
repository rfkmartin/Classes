#include"tree.h"

TreeElement::TreeElement(string data, int typ, int scp, string typdef)
{
  left = NULL;
  right = NULL;
  item.token = data;
  item.type = typ;
  item.scope = scp;
  item.Typdef = typdef;
}


TreeElement::~TreeElement()
{
  if (left != NULL)
    delete left;
  if (right != NULL)
    delete right;
}



void TreeElement::SetParent(TreeElement *p)
{
  parent = p;
}



void TreeElement::SetLeft(TreeElement *l)
{
  left = l;
}


TreeElement* TreeElement::GetLeft()
{
  return this->left;
}


TreeElement* TreeElement::GetParent()
{
  return this->parent;
}


void TreeElement::SetRight(TreeElement *r)
{
  right = r;
}


TreeElement* TreeElement::GetRight()
{
  return this->right;
}


void TreeElement::Print()
{
  cout<<this->item.token<<"("<<this->item.scope<<")"<<endl;
}


struct tData* TreeElement::GetData()
{
  return &(this->item);
}



void TreeElement::SetData(struct tData* t)
{
  if ((this->item).token != t->token)
    abort();
  
  return;
}

// this is used to order among records ...since they have 2 sorting fields (name and scope)
int TreeElement::NodeCmp(string t, int scp = 0)
{
  // break a tie with the scope value
  if ( (this->item).token == t) 
    {
      if ( (this->item).scope == scp ) return 0;
      else if ( (this->item).scope > scp) return -1;
      else return +1;
    }

  if ( (this->item).token < t) return 1;
  return -1;
}


Tree::Tree()
{
 root = NULL;
 insertions = 0;
}


Tree::~Tree()
{
 if (root != NULL)
   delete root;
 // to make sure there are no dangling pointers
 root = NULL;
}


struct tData* Tree::Find(string data, int scp)
{
  int result;
  TreeElement *temp = root;
  TreeElement *backptr;
  bool done = FALSE;
  // if tree is empty
  if (root == NULL)
    {
      return NULL;
    }
  // tree is nonempty
  while (( temp != NULL)&& (!done) )
    {
      result = temp->NodeCmp(data,scp);
      if (result == 0)
	  return (temp->GetData());
      else
	{
	  if (result < 0)
	    {
	      backptr = temp;
	      temp = temp->GetLeft();
	    } 
	  else {
	    backptr = temp;
	    temp = temp->GetRight();
	  }
	}
    }
  if (!done) return NULL;
  else abort();
  // abort because either the entry should match .. or "done" should be false ..
  // the other case is an exception.
}


bool Tree::Insert(string data, int type, int scp, string typdef)
{
  int result;
  TreeElement *temp = root;
  TreeElement *backptr;
  bool done = FALSE;
  
  // if tree is empty
  insertions ++;
  if (root == NULL)
    {
      root = new TreeElement(data, type, scp, typdef);
      root->SetParent(NULL);
      return true;
    }
  // tree is nonempty
  while ((temp != NULL)&& (!done))
    {
      result = temp->NodeCmp(data,scp);
      if (result == 0)
	done = 1;
      else
	{
	  if (result < 0)
	    {
	      backptr = temp;
	      temp = temp->GetLeft();
	    } 
	  else {
	    backptr = temp;
	    temp = temp->GetRight();
	  }
	}
    }
  if (done)
    {
      // symbol was already present ... return an error.
      return false;
    }
  else
    {
      // backptr points to the parent of the new node
      // we remember the old value of "result"
      TreeElement *node = new TreeElement(data, type, scp, typdef);
      if (result < 0)
	  backptr->SetLeft(node);
      else
	backptr->SetRight(node);      
      node->SetParent(backptr);
    }  
  return true;
}



// to walk down the tree, function is a wrapper, since i can't access root 
// from outside class
void Tree::Walk()
{
  if (root != NULL)
    RecursePrint(root);
}

// wrapper method, also does handles case when root is  NULL
void Tree::Clean(int sc)
{
  if (root != NULL)
    DeleteOutofScope(root, sc);
}


// Traverse the tree "in-order" 
// will only need this routine for debugging
void Tree::RecursePrint(TreeElement *t)
{
  TreeElement *l = t->GetLeft();
  TreeElement *r = t->GetRight();
  if (l != NULL)
    RecursePrint(l);
  t->Print();
  if (r != NULL)
    RecursePrint(r); 
}
     

// visit each node (postorder) and remove nodes with stale scope
// "post-order" ensures that a subtree is clean before the parent is checked.
void Tree::DeleteOutofScope(TreeElement *t, int scp)
{
  TreeElement *l = t->GetLeft();
  TreeElement *r = t->GetRight();  
  if (l != NULL)
    DeleteOutofScope(l,scp);
  if (r != NULL)
    DeleteOutofScope(r,scp); 
  if ( t->GetScope() > scp)
    TruncateTree(t);
}



// have to delete a particular tree node
// make sure that the resulting tree is still a valid search tree.
void Tree::TruncateTree(TreeElement *t)
{  
  TreeElement *lft = t->GetLeft();
  TreeElement *rgt = t->GetRight();

  // is a leaf node, no adjustments required
  if (lft == NULL && rgt == NULL)
    {
      t->Print();
      TreeElement *p = t->GetParent();
      // for root node (parent == NULL)
      if (p != NULL)
	{
	  if (p->GetLeft() == t )
	    p->SetLeft(NULL);
	  else if (p->GetRight() == t)
	    p->SetRight(NULL);
	} 
      if (t == root) 
	{
	  delete t;
	  root = NULL;
	  return;
	}
      delete t;
      t = NULL;      
      return;
    }
  // interior node
  // first pull out the right child
  TreeElement *temp,*prnt = t->GetParent();

  // travel down the tree to find the leftmost node
  for (lft = rgt->GetLeft(); lft->GetLeft() != NULL; lft = lft->GetLeft()) ;

  // this is the node that we have to move to the top...
   if (lft != NULL)
    {
      temp = lft->GetParent();
      temp->SetLeft(NULL);
    }
  
  lft->SetLeft(t->GetLeft() );
  lft->SetRight(t->GetRight());
  lft->SetParent(prnt);
  if (t == root)
    root = lft;
  // now delete the reference to the node to be deleted.
  t->Print();
  delete t;
  t = NULL;
}
  
  
  
    
  


