/*
  This program compares the performance of a function sine(x) against the C
  math function sin(x).  Both functions compute the trignometric function sine.
  The performance of the functions is compared by calling each of them 1000
  times.  A tool such as a profiler may then be used to compare the relative
  performance of each function.

  The function sine(x) that is implemented in this file uses the Taylor series
  expansion of sine to compute its value.  This computation requires two
  supporting functions: (1) powerof that takes a floating point number 'p' and
  an exponent 'n' and computes p^n, and (2) factorial that computes the
  factorial of a given integer.  Factorial is a recursive function.

  Author: Vic Thomas.  February 1998.
  */

#include <math.h>

/* function prototypes */
double sine(double);
double powerof(double, int);
int factorial(int);


main()
{
  int i;
  double r;
  
  /* Call our function sine and C library function sin multiple times */
  for (i = 0; i < 10000; i++) { 
    r = sine(M_PI/4);   /* our implementation of the sine function */
    r = sin(M_PI/4);    /* C math library function */
  }
}


/* Function that computes the sine of the value specified in radians */
double sine(double x)
{
  int i;
  double sinex = 0.0;
  int loopCount = 0;
  
  /* Use Taylor series expansion to compute sine */
  for (i = 1; i < 16; i=i+2, loopCount++) {
    sinex += powerof(-1.0, loopCount) * (powerof(x, i)/factorial(i));
  }

  return sinex;
}


/* Function that computes number^exp */ 
double powerof(double number, int exp)
{
  double retval = 1.0;
  int i;
  
  for (i = 0; i < exp; i++) {
    retval *= number;
  }
  return retval;
}


/* Function that returns the factorial of a given number */
int factorial(int n)
{
  int i;
  int temp = 1;

  if (n == 0)
    return temp;
  else
  {
  for (i = 0; i < n; i++)
    temp = temp * i;
  return temp;
  }
}
