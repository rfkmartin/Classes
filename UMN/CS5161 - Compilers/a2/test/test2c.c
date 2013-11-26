/*  code to check for function parameter mismatches  */

int ident_fn(int a)
{ 
  /* do nothing */
  return a;
}

int sum_fn(int a, int b)
{
  /* do a litle more */
  int sum;
  sum = a + b;
  return sum;
}

int max_fn(int a, int b, int c)
{
  /* a lot more */
  if (a > b)
    {
      if (b > c)
	{
	  return a;
	}
      else 
	{
	  return c;
	}
    }
  else 
    {
      if ( b > c)
	{
	  return b;
	}
      else 
	{
	  return c;
	}
    }
}



void main()
{
  int num1, num2, num3;
  int numarray[20];
  float fltarray[25];
  int max, sum, ident;
  float f1 = 0.01, f2= 200.20;
  
  write ("enter numbers ");
  read(num1);
  read(num2);
  read(num3);
  sum = sum_fn(num1, num2, num3);
  max = max_fn(num1, ident_fn(num2), num3);
  ident = ident_fn(sum_fn(num1, num2));
  max = max_fn(f1, f2);
  ident = ident_fn(fltarray[0]);
  sum  = sum_fn(numarray[0], numarray[3]);
}
