(* A prefix function.
   Usage example: prefix [1,2] [1,2,3,4] ; 
*)
fun prefix [] ys = true
 |  prefix xs [] = false
 |  prefix (x::xs) (y::ys) = if x = y then prefix xs ys else false

fun sublist [] ys = true
 |  sublist xs [] = false
 |  sublist (x::xs) (y::ys) = if x = y then if prefix xs ys then true else sublist (x::xs) ys else sublist (x::xs) ys
