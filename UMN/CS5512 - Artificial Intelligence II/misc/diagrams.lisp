;; Copyright 1994, Brown University, Providence, RI
;; See end of file for full copyright information

;; (in-package 'user)

;;**********
;; Examples:
;;**********

;;******************************************
;; Consistency check for vertex descriptors:
;;******************************************

;; Check if a list of vertex descriptors is consistent.
(defun check-diagram (vertex-descriptors)
  (let ((errors 0))
    (dolist (v-d vertex-descriptors)
      (let ((vertex1 (first v-d))
            (v-type (second v-d)))
        ;; Check that the number of neighbors is right for
        ;; the vertex type and that the vertex type is legal.
        (if (not (= (length (v-d-neighbors v-d))
                    (cond ((member v-type '(ARROW FORK TEE)) 3) 
                          ((eq v-type 'ELL) 2) 
                          (t -1))))
          (progn (format t "~%Illegal type/neighbor combo: ~a" v-d)
                 (setq errors (+ 1 errors))))
        ;; Check that each neighbor vertex, vertex2, is 
        ;; connected to this vertex, vertex1, exactly once.
        (dolist (vertex2 (v-d-neighbors v-d))
          (if (not (= 1 (let ((count 0))
                          (dolist (v-d2 vertex-descriptors)
                            (if (and (eq (first v-d2) vertex2)
                                     (member vertex1 
					     (v-d-neighbors v-d2)))
                              (setq count (+ 1 count))))
                          count)))
            (progn (format t "~%Inconsistent vertex: ~a-~a" 
			   vertex1 vertex2)
                   (setq errors (+ 1 errors)))))))
    (if (> errors 0)
      (format t "~%Inconsistent diagram: ~d total error(s)." errors)))
  vertex-descriptors)

(setq cube 
      (construct-diagram
       (check-diagram '((a FORK b c d)
                        (b ELL g e a)
                        (c ARROW e f a)
                        (d ARROW f g a)
                        (e ELL c b)
                        (f TEE d c)
                        (g ELL b d)))))

(setq cube-on-plate 
      (construct-diagram
       (check-diagram '((a FORK b c d)
                        (b ARROW g e a)
                        (c ARROW e f a)
                        (d ARROW f g a)
                        (e ELL c b)
                        (f FORK d c i)
                        (g FORK b d h)
                        (h ARROW l g j)
                        (i ARROW f m j)
                        (j FORK h i k)
                        (k ARROW m l j)
                        (l ELL h k)
                        (m ELL k i)))))

(setq tower 
      (construct-diagram
       (check-diagram '((a FORK b c d)     (n ELL q o) 
                        (b ARROW g e a)    (o ARROW y j n)
                        (c ARROW e f a)    (p ELL r i)
                        (d ARROW f g a)    (q ARROW n s w)
                        (e ELL c b)        (r ARROW s p x)
                        (f FORK d c i)     (s ELL r q)
                        (g FORK b d h)     (t ARROW w x z)
                        (h ARROW l g j)    (u ARROW x y z)
                        (i ARROW f m p)    (v ARROW y w z)
                        (j FORK h o k)     (w FORK t v q)
                        (k ARROW m l j)    (x FORK r u t)
                        (l ELL h k)        (y FORK v u o)
                        (m ELL k i)        (z FORK t u v)))))

(setq arch1 
      (construct-diagram
       (check-diagram '((a ARROW e b c)  (p ELL o q)
                        (b ELL d a)      (q TEE p i r)
                        (c FORK a d g)   (r TEE j s q)
                        (d FORK c b m)   (s ELL r t)
                        (e ELL a f)      (t ARROW v s k)
                        (f TEE e g n)    (u ELL t l)
                        (g ARROW h f c)  (v ELL 2 4)
                        (h TEE g i o)    (w ARROW x 1 y)
                        (i TEE h j q)    (x ELL w z)
                        (j TEE i k r)    (y FORK w 2 z)
                        (k TEE j l t)    (z ARROW 3 x y)
                        (l TEE k m v)    (1 TEE n o w)
                        (m ELL l d)      (2 ARROW v 3 y)
                        (n ELL f 1)      (3 ELL z 2)
                        (o ARROW p 1 h)  (4 TEE u l v)))))

(setq arch2 
      (construct-diagram
       (check-diagram '((a ARROW e b c)  (p ELL o q)
                        (b ELL d a)      (q TEE p i r)
                        (c FORK a d g)   (r TEE j s q)
                        (d FORK c b m)   (s ELL r t)
                        (e ELL a f)      (t ARROW u s k)  ;; t-u not t-v
                        (f TEE e g n)    (u ELL t 4)      ;; u-4 not u-l
                        (g ARROW h f c)  (v ELL 2 4)
                        (h TEE g i o)    (w ARROW x 1 y)
                        (i TEE h j q)    (x ELL w z)
                        (j TEE i k r)    (y FORK w 2 z)
                        (k TEE j l t)    (z ARROW 3 x y)
                        (l TEE k m 4)    (1 TEE n o w)    ;; l-4 not l-v
                        (m ELL l d)      (2 ARROW v 3 y)
                        (n ELL f 1)      (3 ELL z 2)
                        (o ARROW p 1 h)  (4 TEE u l v)))))

(setq arch3 
      (construct-diagram
       (check-diagram '((a ARROW e b c)  (p ELL o q)
                        (b ELL d a)      (q TEE p i r)
                        (c FORK a d g)   (r TEE j s q)
                        ;; d is an ARROW, not a FORK
                        (d ARROW b m c)  (s ELL r t) 
                        (e ELL a f)      (t ARROW u s k)    
                        (f TEE e g n)    (u ELL t 4)      
                        (g ARROW h f c)  (v ELL 2 4)
                        (h TEE g i o)    (w ARROW x 1 y)
                        (i TEE h j q)    (x ELL w z)
                        (j TEE i k r)    (y FORK w 2 z)
                        (k TEE j l t)    (z ARROW 3 x y)
                        (l TEE k m 4)    (1 TEE n o w)    
                        (m ELL l d)      (2 ARROW v 3 y)
                        (n ELL f 1)      (3 ELL z 2)
                        (o ARROW p 1 h)  (4 TEE u l v)))))

(princ "Diagrams are loaded.")


;; Copyright 1994, Brown University, Providence, RI
;; Permission to use and modify this software and its documentation
;; for any purpose other than its incorporation into a commercial
;; product is hereby granted without fee.  Permission to copy and
;; distribute this software and its documentation only for
;; non-commercial use is also granted without fee, provided, however
;; that the above copyright notice appear in all copies, that both
;; that copyright notice and this permission notice appear in
;; supporting documentation, that the name of Brown University not
;; be used in advertising or publicity pertaining to distribution
;; of the software without specific, written prior permission, and
;; that the person doing the distribution notify Brown University
;; of such distributions outside of his or her organization. Brown
;; University makes no representations about the suitability of this
;; software for any purpose. It is provided "as is" without express
;; or implied warranty.  Brown University requests notification of
;; any modifications to this software or its documentation.
;;
;; Send the following redistribution information
;;
;; 	Name:
;; 	Organization:
;; 	Address (postal and/or electronic):
;;
;; To:
;; 	Software Librarian
;; 	Computer Science Department, Box 1910
;; 	Brown University
;; 	Providence, RI 02912
;;
;; 		or
;;
;; 	brusd@cs.brown.edu
;;
;; We will acknowledge all electronic notifications.

