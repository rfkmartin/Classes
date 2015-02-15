#include <stdio.h>
#include <stdlib.h>
#include "bst.h"

/*
 * Creates a new node from a given value, allocating heap memory for it.
 */
node_t* make_tree(int val) {
  node_t* new_tree = malloc(sizeof(node_t));
  new_tree->val = val;
  new_tree->left = NULL;
  new_tree->right = NULL;
  return new_tree;
}

/*
 * Inserts a new value into a given binary search tree, allocating heap memory
 * for it.
 */
node_t* insert(int val, node_t* cur_root) {
  if (cur_root==NULL)
  {
	  node_t* new_tree = malloc(sizeof(node_t));
	  new_tree->val=val;
	  new_tree->left = NULL;
	  new_tree->right = NULL;
	  return new_tree;
  }
  else
  {
	  if (cur_root->val > val)
	  {
		cur_root->left = insert(val,cur_root->left);
	  }
	  if (cur_root->val < val)
	  {
		cur_root->right = insert(val,cur_root->right);
	  }
	  return cur_root;
  }
}

bool find_val(int val, node_t* root) {
  if (root == NULL)
  {
	  return 0;
  }
  if (root->val == val)
  {
	  return 1;
  }
  else if (root->val > val)
  {
	  return find_val(val,root->left);
  }
  else if (root->val < val)
  {
	  return find_val(val,root->right);
  }
}

/*
 * Given a pointer to the root, frees the memory associated with an entire tree.
 */
void delete_bst(node_t* root) {
	if (root == NULL)
	{
		return;
	}
	delete_bst(root->left);
	root->left = NULL;
	delete_bst(root->right);
	root->right = NULL;
	free(root);
	root = NULL;
}

/* Given a pointer to the root, prints all o fthe values in a tree. */
void print_bst(node_t* root) {
  if (root != NULL) {
    print_bst(root->right);
    printf("%d ", root->val);
    print_bst(root->left);
  }
  return;
}
