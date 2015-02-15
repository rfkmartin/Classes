/*
 * 6.088 IAP 2010  
 * Assignment #5: Inheritance and Polymorphism
 * 
 * Expression.h
 * Header file for the abstract base class Expression
 */

#ifndef EXPRESSION
#define EXPRESSION

/*
 * Expression
 */
class Expression {

 public: 
  virtual ~Expression() {}
  
  // Returns the result of evaluating this expression.
  virtual float eval() const = 0;

  // Prints the expression. DO NOT evaluate before printing.
  virtual void print() const = 0;  
};

#endif  // EXPRESSION
