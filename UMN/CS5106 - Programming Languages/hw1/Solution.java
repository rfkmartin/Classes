import java.io.*; 
import java.util.*; 

/******************************************************************
 * Solution.java
 *
 * checks whether a list is a sublist of another
 *
 * Robert F.K. Martin
 * ID 1505151
 * CSci 5106 - Programming Languages
 * Lab 1
 * 
 *****************************************************************/

public class Solution { 

  /* getNum gets an Integer from in */
  static Integer getNum(BufferedReader in) { 
    String it = "";
    try {
      it = in.readLine(); 
    } catch (IOException ioe) { 
      System.out.println("IO error: " + ioe);
    }
    return new Integer(it); 
  }

  public static void main(String args[]) { 
    /* Magic incantaion for line-oriented standard input. 
     * See also BufferedReader.java */
    BufferedReader in = 
      new BufferedReader(new InputStreamReader(System.in)); 

    /* Get list 1 */ 
    System.out.print("How many elements in list 1? "); 
    Integer number = getNum(in); 
    ArrayList listone = new ArrayList(number.intValue()); 
    for (int i = 0; i < number.intValue(); i++) { 
      System.out.print("List 1 - #");
      if (i+1<=9) {
 	System.out.print(" ");
      }
      System.out.print((i+1) + ": ");
      listone.add(getNum(in)); 
    } 

    /* Get list 2 */
    System.out.print("How many elements in list 2? "); 
    number = getNum(in); 
    ArrayList listtwo = new ArrayList(number.intValue()); 
    for (int i = 0; i < number.intValue(); i++) { 
      System.out.print("List 2 - #");
      if (i+1<=9) {
	System.out.print(" ");
      }
      System.out.print((i+1) + ": ");
      listtwo.add(getNum(in)); 
    } 

    boolean good = true;
    /* Special case: list 1 is larger than list 2 */
    if (listone.size() > listtwo.size()) { 
      good = false; 
    } else if (listone.size() == 0) {
	/* Special case of empty list */
	good = true;
    } else {
  /* Compare the first elements of list 1 and 2 incrementally. If a match
   * is found, note the position and continue to match the remainder of 
   * list 1 with list 2. If there are no failures to the end of list 1,
   * we have a match. Otherwise, go back to the previous position in list
   * 2 and continue as before. */
	good = false;
      for (int i = 0; i < listtwo.size(); i++) {
	  int cnt;
        if (((Integer)listone.get(0)).equals((Integer)listtwo.get(i))) {
	    cnt = 1;
	    while (i+cnt <= listtwo.size() && ((Integer)listone.get(cnt)).equals((Integer)listtwo.get(i+cnt))) {
		if (cnt+1==listone.size()) {
		    good = true;
		    break;
		}
		cnt++;
	    }
        }
      }
    }
    if (good) { 
      System.out.println("List 1 is a sublist of list 2."); 
    } else { 
      System.out.println("List 1 is NOT a sublist of list 2."); 
    } 
  }
}
