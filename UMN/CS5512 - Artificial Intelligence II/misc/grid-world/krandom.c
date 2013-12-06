#include "krandom.h"

/*knuth's subtractive generator*/
 float ran3(int *idum)
{ static int inext, inextp;
  static int ma[56];
  static int iff=0;
  int mj,mk;
  int i, ii, k;
  if (*idum < 0 || iff ==0) {
    iff=1;
    mj=MSEED-(*idum < 0 ? -*idum : *idum);
    mj %= MBIG;
    ma[55]=mj;
    mk=1;
    for (i=1;i<=54;i++) {
      ii=(21*i) % 55;
      ma[ii]=mk;
      mk=mj-mk;
      if (mk < MZ) mk +=MBIG;
      mj=ma[ii];
    }
    for (k=1;k<=4;k++)
      for (i=1;i<=55;i++){
	     ma[i] -= ma[1+(i+30) % 55];
	     if (ma[i] < MZ) ma[i] += MBIG;
	  }
    inext=0;
    inextp=31;
    *idum=1;
    }
    if (++inext == 56) inext=1;
    if (++inextp == 56) inextp=1;
    mj=ma[inext]-ma[inextp];
    if (mj < MZ) mj += MBIG;
    ma[inext]=mj;
    return (mj*FAC);
}

int choose_random_int_value(int range)
{
	return ((int) ((double) range * ran3(&seed)));
}

double choose_random_value()
{
	return (ran3(&seed));
}

void initialize_random_number_generator()
{
  printf("\nenter large negative seed:");
  scanf("%d", &seed);
}







