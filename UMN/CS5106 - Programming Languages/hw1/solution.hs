prefix [] ys = True
prefix xs [] = False
prefix (x:xs) (y:ys) = if x == y then prefix xs ys else False

sublist [] ys = True
sublist xs [] = False
sublist (x:xs) (y:ys) = if x == y then if prefix xs ys then True else sublist (x:xs) ys else sublist (x:xs) ys
