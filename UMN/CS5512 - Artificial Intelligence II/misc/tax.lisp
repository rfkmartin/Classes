(setf s1 '(e h f))
(setf s2 '(e g f))
(setf s3 '(e j i))
(setf s4 '(e k i))
(setf s5 '(l r p))
(setf s6 '(l q p))
(setf s7 '(l o m))
(setf s8 '(l n m))

(setf a1 (list s1 s2 s3 s4 s5 s6 s7 s8))
(setf a2 (list s1 s3 s2 s5 s7 s8 s4 s6))

(defun pairdiff (x y)
   (union (set-difference x y) (set-difference y x)))

(defun pairsame (x y)
   (length (union x y)))

(defun inters (lst x y)
   (intersection (nth x lst) (nth y lst)))

(defun checkstate (state)
   (and (= 4 (pairsame (nth 0 state) (nth 1 state)))
        (= 4 (pairsame (nth 2 state) (nth 3 state)))
		(= 4 (pairsame (nth 4 state) (nth 5 state)))
		(= 5 (pairsame (nth 0 state) (nth 2 state)))
		(= 6 (pairsame (nth 0 state) (nth 4 state)))))

(defun heuristicA (lst)
   (+ (length (pairdiff (nth 0 lst) (nth 1 lst)))
	  (length (pairdiff (nth 2 lst) (nth 3 lst)))
	  (length (pairdiff (nth 4 lst) (nth 5 lst)))
	  (length (pairdiff (nth 6 lst) (nth 7 lst)))
	  (length (union (union (nth 0 lst) (nth 1 lst)) (union (nth 2 lst) (nth 3 lst))))))

(defun heuristicB (lst)
   (setf rem (union (union (inters lst 0 1) (inters lst 2 3))
                    (union (inters lst 0 2) (inters lst 1 3)))))


(defun do-swap (lst n1 n2)
   (setf temp (nth n1 lst))
   (setf (nth n1 lst) (nth n2 lst))
   (setf (nth n2 lst) temp))
