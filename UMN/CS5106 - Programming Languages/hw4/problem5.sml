val files = [ "alice", "bob", "charles", "dan", "ernie", "fredrick",
              "gary", "harold", "ines", "jonathon", "katherinezeta",
              "lou", "mike", "nancy", "ophelia", "paul", "randall",
              "stephen", "thomas", "vernon" ]

fun take _ [] = []
 |  take 0 _  = []
 |  take n (x::xs) = x :: take (n-1) xs

fun drop _ [] = []
 |  drop 0 x = x
 |  drop n (x::xs) = drop (n-1) xs

fun padTo n str = 
  let 
     fun padTo2 0 xs = xs
      |  padTo2 n [] = #" " :: padTo2 (n-1) [] 
      |  padTo2 n (x::xs) = x :: padTo2 (n-1) xs
  in 
     implode (padTo2 n (explode str))
  end

fun pad [] _ = []
  | pad x 0 = x
  | pad x y = padTo y (hd x)::pad (tl x) y

fun transpose ( [] :: _ ) = []
 |  transpose m = (map hd m) :: transpose (map tl m)

fun maxstrlength [] = 0
 |  maxstrlength (x::xs) =
    let
      val a = size(x)
      val b = maxstrlength(xs)
    in
      if (a>b) then a else b
    end;

fun group _ 0 = []
  | group [] _ = []
  | group x y = take y x :: group (drop y x) y

fun stringify [] = "\n"
  | stringify (x::xs) = x^(stringify xs)

fun padify [] = []
  | padify x = pad (hd x) (maxstrlength(hd x)+1)::padify (tl x)

fun ls1 _ 0 = ""
  | ls1 [] _ = ""
  | ls1 x y =
      let
        val l = length x div y
	val w = maxstrlength(x)+1
        val x1 = pad x w
        val m = group x1 l
        val m1 = transpose m
        fun stringifier [] = ""
         | stringifier x = stringify (hd x)^stringifier (tl x)
      in
        stringifier m1
      end;

fun ls2 _ 0 = ""
  | ls2 [] _ = ""
  | ls2 x y =
      let
        val l = length x div y
        val m = group x l
        val m1 = padify m
        val m2 = transpose m1
        fun stringifier [] = ""
         | stringifier x = stringify (hd x)^stringifier (tl x)
      in
        stringifier m2
      end;