/*  code to test expression mismatches, scoping rules etc. */
typedef int myInt;


int arraysum(int arr[], int size)
{
  int i;
  int sum = 0;
  for (i=0; i< size; i = i+ 1)
    {
      sum = sum + arr[i];
    }
  return sum;
}


void main()
{
  int a,b,c,d,e;
  float e,f,g,h,i,j,k;
  myInt sum;
  int narray[10][10];  
  sum = 0;
  while (sum < 100)
    {
      int a,b,c;
      a = 4;
      b = 3;
      c = 3;
      narray[sum] = (f+g+h)/(i+j-2);
      sum = sum + a + b + c;      
    }
  write(narray[sum - 10]);
  sum = (f+g+h)/(i+j-2);
  write(sum);
  sum = arraysum(a,b);
}

  
