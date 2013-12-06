;;;;;; ADDED NEW EXAMPLE FROM QUINLAN PAPER  - 1/18/96
;;;;;; type (play) to run it
;;;;;; if you use cl you should type (setf top-level:*print-level* 8)
;;;;;; to get the results printed completely

;; Copyright 1994, Brown University, Providence, RI
;; See end of file for full copyright information

(in-package user)

;; This file contains all of the code implementing the decision
;; tree method described in the chapter on learning.

(setq *print-pretty* t)

;; A feature is an attribute together with a value.
(defun FEATURE-attribute (feature) (car feature))
(defun FEATURE-value (feature) (cadr feature))

;; A dimension is an attribute together with a set of possible values.
(defun make-DIMENSION (attribute values) (list attribute values))
(defun DIMENSION-attribute (dimension) (car dimension))
(defun DIMENSION-values (dimension) (cadr dimension))

;; A decision tree node consists of examples and child nodes.
(defun make-NODE (examples) (list nil examples (list)))
(defun NODE-attribute (node) (car node))
(defun set-NODE-attribute (node attribute) 
  (setf (car node) attribute))
(defun NODE-examples (node) (cadr node))
(defun NODE-children (node) (caddr node))
(defun set-NODE-children (node children) 
  (setf (caddr node) children))

;; An example is an identifier together with a set of features 
;; that describe the example and a class indicator.
(defun make-EXAMPLE (id features class) (list id features class))
(defun EXAMPLE-id (example) (car example))
(defun EXAMPLE-features (example) (cadr example))
(defun EXAMPLE-class (example) (caddr example))

;; Buildtree implements the basic recursive function for constructing
;; decision trees.
(defun buildtree (node)
  (format t "Class distribution: ~A~%"
          (mapcar #'length (classify (NODE-examples node))))
  (if (< 1 (length (findall (classify (NODE-examples node)) 
			    #'(lambda (s) (not (null s)))))) 
      (let ((dim (splitter node)))
	(format t "Dimension chosen: ~A~%" dim)
	(set-NODE-attribute node (DIMENSION-attribute node))
	(set-NODE-children node
			   (mapcar #'make-NODE 
				   (partition (NODE-examples node) dim)))
	(mapc #'buildtree (NODE-children node)))
    (format t "Terminal node.~%")))

;; Given a set of examples, classify partitions the examples 
;; into classes.
(defun classify (examples)
  (mapcar #'(lambda (class)
	      (findall examples #'(lambda (s) 
				    (eq class (EXAMPLE-class s)))))
	  (classes)))

(defun findall (items test)
  (do ((items items (cdr items)) (results (list)))
      ((null items) results)
      (if (funcall test (car items)) 
	  (setq results (adjoin (car items) results
				:test #'equal)))))

;; Partition takes a set of examples and partitions by the attribute 
;; of a dimension according to the values for that attribute.
(defun partition (examples dimension)
  (let ((attribute (DIMENSION-attribute dimension)))
    (mapcar #'(lambda (value) 
		(findall examples 
			 #'(lambda (example) 
			     (member (list attribute value) 
				     (EXAMPLE-features example)
				     :test #'equal))))
	    (DIMENSION-values dimension))))

;; Splitter finds the attribute that minimizes a particular evaluation
;; function implemented by evaluate.
(defun splitter (node) 
  (do* ((dims (cdr (dimensions)) (cdr dims)) 
	(value (evaluate node (car (dimensions))))
	(splitter (car (dimensions))) (min value))
       ((null dims) splitter)
       (setq value (evaluate node (car dims)))
       (if (< value min)
	   (setq splitter (car dims) min value))))

;; The function evaluate computes the weighted sum of the disorder over 
;; all class partitions for a given attribute partition.
(defun evaluate (node dimension)
  (let ((total (length (NODE-examples node))))
    (apply #'+
	   (mapcar #'(lambda (subset)
		       (* (/ (length subset) total)
			  (disorder (classify subset))))
		   (partition (NODE-examples node) dimension)))))

;; Disorder computes the information value (disorder) associated with a
;; particular class partition according to the formula listed in the 
;; section on decision trees. 
(defun disorder (partition)
  (let* ((sizes (mapcar #'length partition))
	 (total (apply #'+ sizes)))
    (if (= total 0) 0
      (- (log total 2)
	 (apply #'+ (mapcar #'(lambda (s) 
				(if (= s 0) 0 
				  (* (/ s total) (log s 2))))
			    sizes))))))

;; Examples

(defun sunburn ()
  (let ((examples
	 (list
	  (make-EXAMPLE 'Sarah '((hair blonde) (height average) 
			         (weight light) (lotion no)) 'yes)
	  (make-EXAMPLE 'Dana '((hair blonde) (height tall) 
			        (weight average) (lotion yes)) 'no)
	  (make-EXAMPLE 'Alex '((hair brown) (height short) 
			        (weight average) (lotion yes)) 'no)
	  (make-EXAMPLE 'Annie '((hair blonde) (height short) 
			         (weight average) (lotion no)) 'yes)
	  (make-EXAMPLE 'Emily '((hair red) (height average) 
		                 (weight heavy) (lotion no)) 'yes)
	  (make-EXAMPLE 'Pete '((hair brown) (height tall) 
			        (weight heavy) (lotion no)) 'no)
	  (make-EXAMPLE 'John '((hair brown) (height average) 
			        (weight heavy) (lotion no)) 'no)
	  (make-EXAMPLE 'Katie '((hair blonde) (height short) 
			         (weight light) (lotion yes)) 'no))))
    (defun dimensions ()
      (list (make-DIMENSION 'hair '(blonde brown red))
	    (make-DIMENSION 'height '(short tall average))
	    (make-DIMENSION 'weight '(light heavy average))
	    (make-DIMENSION 'lotion '(yes no))))
    (defun classes () '(yes no))
    (buildtree (make-NODE examples))))

(defun robots ()
  (let ((examples
	 (list 
	  (make-EXAMPLE '307 '((status faculty) (floor three) 
			       (dept ee) (size large)) 'no)
	  (make-EXAMPLE '309 '((status staff) (floor three) 
			       (dept ee) (size small)) 'no)
	  (make-EXAMPLE '408 '((status faculty) (floor four) 
			       (dept cs) (size medium)) 'yes)
	  (make-EXAMPLE '415 '((status student) (floor four) 
			       (dept ee) (size large)) 'yes)
	  (make-EXAMPLE '509 '((status staff) (floor five) 
			       (dept cs) (size medium)) 'no)
	  (make-EXAMPLE '517 '((status faculty) (floor five) (dept cs) 
			       (size large)) 'yes)
	  (make-EXAMPLE '316 '((status student) (floor three) 
			       (dept ee) (size small)) 'yes)
	  (make-EXAMPLE '420 '((status staff) (floor four) (dept cs) 
			       (size medium)) 'no ))))
    (defun dimensions ()
      (list (make-DIMENSION 'status '(faculty staff student))
	    (make-DIMENSION 'floor '(three four five))
	    (make-DIMENSION 'dept '(cs ee))
	    (make-DIMENSION 'size '(large medium small))))
    (defun classes () '(yes no))
    (buildtree (make-NODE examples))))

(defun final ()
  (let ((examples (list (make-EXAMPLE 1 '((a 1) (b 0) (c 1)) 1)
			(make-EXAMPLE 2 '((a 1) (b 1) (c 0)) 1)
			(make-EXAMPLE 3 '((a 1) (b 1) (c 1)) 0)
			(make-EXAMPLE 4 '((a 0) (b 0) (c 0)) 0)
			(make-EXAMPLE 5 '((a 1) (b 1) (c 0)) 1)
			(make-EXAMPLE 6 '((a 1) (b 0) (c 0)) 0))))
    (defun dimensions ()
      (list (make-DIMENSION 'a '(0 1))
	    (make-DIMENSION 'b '(0 1))
	    (make-DIMENSION 'c '(0 1))))
    (defun classes () '(0 1))
    (buildtree (make-NODE examples))))

;; Test function.
(defun test ()
  (sunburn)
  (robots)
  (final))

;; added from Quinlan paper
(defun play ()
  (let ((examples (list (make-EXAMPLE 1 '((outlook sunny) (temp hot)
					  (humidity high) (windy false))
				      'no)
			(make-EXAMPLE 2 '((outlook sunny) (temp hot)
					  (humidity high) (windy true))
				      'no)
			(make-EXAMPLE 3 '((outlook overcast) (temp hot)
					  (humidity high) (windy false))
				      'yes)
			(make-EXAMPLE 4 '((outlook rain) (temp mild)
					  (humidity high) (windy false))
				      'yes)
			(make-EXAMPLE 5 '((outlook rain) (temp cool)
					  (humidity normal) (windy false))
				      'yes)
			(make-EXAMPLE 6 '((outlook rain) (temp cool)
					  (humidity normal) (windy true))
				      'no)
			(make-EXAMPLE 7 '((outlook overcast) (temp cool)
					  (humidity normal) (windy true))
				      'yes)
			(make-EXAMPLE 8 '((outlook sunny) (temp mild)
					  (humidity high) (windy false))
				      'no)
			(make-EXAMPLE 9 '((outlook sunny) (temp cool)
					  (humidity normal) (windy false))
				      'yes)
			(make-EXAMPLE 10 '((outlook rain) (temp mild)
					  (humidity normal) (windy false))
				      'yes)
			(make-EXAMPLE 11 '((outlook sunny) (temp mild)
					  (humidity normal) (windy true))
				      'yes)
			(make-EXAMPLE 12 '((outlook overcast) (temp mild)
					  (humidity high) (windy true))
				      'yes)
			(make-EXAMPLE 13 '((outlook overcast) (temp hot)
					  (humidity normal) (windy false))
				      'yes)
			(make-EXAMPLE 14 '((outlook rain) (temp mild)
					  (humidity high) (windy true))
				      'no)
			)))
    (defun dimensions ()
      (list (make-DIMENSION 'outlook '(sunny overcast rain))
	    (make-DIMENSION 'temp '(cool mild hot))
	    (make-DIMENSION 'humidity '(high normal))
	    (make-DIMENSION 'windy '(true false))))
    (defun classes () '(yes no))
    (buildtree (make-NODE examples))))

;; Question 19.4 from Russell&Norvig
(defun hw ()
  (let ((examples (list (make-EXAMPLE 1 '((I1 1) (I2 0) (I3 1)
					  (I4 0) (I5 0) (I6 0)) 1)
			(make-EXAMPLE 2 '((I1 1) (I2 0) (I3 1)
					  (I4 1) (I5 0) (I6 0)) 1)
			(make-EXAMPLE 3 '((I1 1) (I2 0) (I3 1)
					  (I4 0) (I5 1) (I6 0)) 1)
			(make-EXAMPLE 4 '((I1 1) (I2 1) (I3 0)
					  (I4 0) (I5 1) (I6 1)) 1)
			(make-EXAMPLE 5 '((I1 1) (I2 1) (I3 1)
					  (I4 1) (I5 0) (I6 0)) 1)
			(make-EXAMPLE 6 '((I1 1) (I2 0) (I3 0)
					  (I4 0) (I5 1) (I6 1)) 1)
			(make-EXAMPLE 7 '((I1 1) (I2 0) (I3 0)
					  (I4 0) (I5 1) (I6 0)) 0)
			(make-EXAMPLE 8 '((I1 0) (I2 1) (I3 1)
					  (I4 1) (I5 0) (I6 1)) 1)
			(make-EXAMPLE 9 '((I1 0) (I2 1) (I3 1)
					  (I4 0) (I5 1) (I6 1)) 0)
			(make-EXAMPLE 10 '((I1 0) (I2 0) (I3 0)
					  (I4 1) (I5 1) (I6 0)) 0)
			(make-EXAMPLE 11 '((I1 0) (I2 1) (I3 0)
					  (I4 1) (I5 0) (I6 1)) 0)
			(make-EXAMPLE 12 '((I1 0) (I2 0) (I3 0)
					  (I4 1) (I5 0) (I6 1)) 0)
			(make-EXAMPLE 13 '((I1 0) (I2 1) (I3 1)
					  (I4 0) (I5 1) (I6 1)) 0)
			(make-EXAMPLE 14 '((I1 0) (I2 1) (I3 1)
					  (I4 1) (I5 0) (I6 0)) 0))))
    (defun dimensions ()
      (list (make-DIMENSION 'I1 '(0 1))
	    (make-DIMENSION 'I2 '(0 1))
	    (make-DIMENSION 'I3 '(0 1))
	    (make-DIMENSION 'I4 '(0 1))
	    (make-DIMENSION 'I5 '(0 1))
	    (make-DIMENSION 'I6 '(0 1))))
    (defun classes () '(0 1))
    (buildtree (make-NODE examples))))

;; added from Russell&Norvig book
(defun wait ()
  (let ((examples (list (make-EXAMPLE 1 '((alt yes) (bar no)
					  (fri no) (hungry yes)
					  (patrons some) (price $$$)
					  (rain no) (reservation yes)
					  (type french) (est low))
				      'yes)
			(make-EXAMPLE 2 '((alt yes) (bar no)
					  (fri no) (hungry yes)
					  (patrons full) (price $)
					  (rain no) (reservation no)
					  (type thai) (est hi))
				      'no)
			(make-EXAMPLE 3 '((alt no) (bar yes)
					  (fri no) (hungry no)
					  (patrons some) (price $)
					  (rain no) (reservation no)
					  (type burger) (est low))
				      'yes)
			(make-EXAMPLE 4 '((alt yes) (bar no)
					  (fri yes) (hungry yes)
					  (patrons full) (price $)
					  (rain no) (reservation no)
					  (type thai) (est mid))
				      'yes)
			(make-EXAMPLE 5 '((alt yes) (bar no)
					  (fri yes) (hungry no)
					  (patrons full) (price $$$)
					  (rain no) (reservation yes)
					  (type french) (est long))
				      'no)
			(make-EXAMPLE 6 '((alt no) (bar yes)
					  (fri no) (hungry yes)
					  (patrons some) (price $$)
					  (rain yes) (reservation yes)
					  (type italian) (est low))
				      'yes)
			(make-EXAMPLE 7 '((alt no) (bar yes)
					  (fri no) (hungry no)
					  (patrons none) (price $)
					  (rain yes) (reservation no)
					  (type burger) (est low))
				      'no)
	       		(make-EXAMPLE 8 '((alt no) (bar no)
					  (fri no) (hungry yes)
					  (patrons some) (price $$)
					  (rain yes) (reservation yes)
					  (type thai) (est low))
				      'yes)
	       		(make-EXAMPLE 9 '((alt no) (bar yes)
					  (fri yes) (hungry no)
					  (patrons full) (price $)
					  (rain yes) (reservation no)
					  (type burger) (est long))
				      'no)
	       		(make-EXAMPLE 10 '((alt yes) (bar yes)
					  (fri yes) (hungry yes)
					  (patrons full) (price $$$)
					  (rain no) (reservation yes)
					  (type italian) (est mid))
				      'no)
	       		(make-EXAMPLE 11 '((alt no) (bar no)
					  (fri no) (hungry no)
					  (patrons none) (price $)
					  (rain no) (reservation no)
					  (type thai) (est low))
				      'no)
	       		(make-EXAMPLE 12 '((alt yes) (bar yes)
					  (fri yes) (hungry yes)
					  (patrons full) (price $)
					  (rain no) (reservation no)
					  (type burger) (est hi))
				      'yes)
			)))
    (defun dimensions ()
      (list (make-DIMENSION 'alt '(yes no))
	    (make-DIMENSION 'bar '(yes no))
	    (make-DIMENSION 'fri '(no yes))
	    (make-DIMENSION 'hungry '(no yes))
     	    (make-DIMENSION 'patrons '(none some full))
	    (make-DIMENSION 'price '($ $$ $$$))
	    (make-DIMENSION 'rain '(yes no))
	    (make-DIMENSION 'reservation '(yes no))
	    (make-DIMENSION 'type '(french italian thai burger))
	    (make-DIMENSION 'est '(low mid hi long))))
    (defun classes () '(yes no))
    (buildtree (make-NODE examples))))

(defun final1 ()
  (let ((examples
	 (list 
	  (make-EXAMPLE '1 '((size small) (nat esp) 
			       (stat single)) 'yes)
	  (make-EXAMPLE '2 '((size small) (nat ita) 
			       (stat single)) 'no)
	  (make-EXAMPLE '3 '((size large) (nat esp) 
			       (stat married)) 'no)
	  (make-EXAMPLE '4 '((size large) (nat fra) 
			       (stat single)) 'yes)
	  (make-EXAMPLE '5 '((size large) (nat ita) 
			       (stat single)) 'no)
	  (make-EXAMPLE '6 '((size large) (net esp) 
			       (stat single)) 'no)
	  (make-EXAMPLE '7 '((size large) (nat ita) 
			       (stat married))  'yes)
;;	  (make-EXAMPLE '8 '((size small) (nat spanish) 
;;			       (stat married)) 'no )
)))
    (defun dimensions ()
      (list (make-DIMENSION 'size '(small))
	    (make-DIMENSION 'net '(esp ita fra))
	    (make-DIMENSION 'stat '(single married))))
    (defun classes () '(yes no))
    (buildtree (make-NODE examples))))

;; Compute some summary statistics on a decision tree.
(defun split-statistics (node)
  (mapcar #'(lambda (d)
              (format t "~A ~4,3F ~A~%"
                      (DIMENSION-attribute d)
                      (evaluate node d)
                      (mapcar #'(lambda (x) 
                                  (mapcar #'(lambda (y) 
                                              (mapcar #'EXAMPLE-id y)) 
                                          (classify x)))
                              (partition (NODE-examples node) d))))
          (dimensions)))


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

