/******************************************************************
 * solution.c
 *
 * checks whether a list is a sublist of another
 *
 * Robert F.K. Martin
 * ID 1505151
 * CSci 5106 - Programming Languages
 * Lab 1
 * 
 *****************************************************************/

#include <stdio.h> 

#define MAX_ELEMENTS 50

int getnum() { 
  int number;
  scanf("%d", &number);
  return number;
}

int main (int argc, char* argv[]) { 
  int one[MAX_ELEMENTS]; 
  int two[MAX_ELEMENTS]; 
  int usedone, usedtwo, i,cnt;
  /* Get the first list */
  printf("How many elements in list 1? "); 
  usedone = getnum(); 
  for (i = 0; i < usedone; i++) { 
    printf("List 1 - #%2d: ", (i+1)); 
    one[i] = getnum(); 
  }
  /* Get the second list */
  printf("How many elements in list 2? "); 
  usedtwo = getnum(); 
  for (i = 0; i < usedtwo; i++) { 
    printf("List 2 - #%2d: ", (i+1)); 
    two[i] = getnum(); 
  }

  /* Degenerate case: list one is larger than list two */
  if (usedone > usedtwo) { 
    printf("List 1 is NOT a sublist of list 2.\n");
    return 0; 
  }

  /* Degenerate case: list one is empty list */
  if (usedone == 0) { 
    printf("List 1 is a sublist of list 2.\n");
    return 0; 
  }

  /* Compare the first elements of list 1 and 2 incrementally. If a match
   * is found, note the position and continue to match the remainder of 
   * list 1 with list 2. If there are no failures to the end of list 1,
   * we have a match. Otherwise, go back to the previous position in list
   * 2 and continue as before. */
  for (i = 0; i < usedtwo; i++) { 
    if (one[0] == two[i]) {
      cnt=1;
      while (i+cnt<=usedtwo&&one[cnt]==two[i+cnt]) {
	if (cnt+1==usedone) {
	  printf("List 1 is a sublist of list 2.\n");
	  return 0;
	}
	cnt++;
      }
    } 
  } 
  printf("List 1 is NOT a sublist of list 2.\n");  
  return 0; 
} 
