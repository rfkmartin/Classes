;; Copyright 1994, Brown University, Providence, RI
;; See end of file for full copyright information

;; (in-package 'user)

;;****************************
;; Labeling Polyhedral Scenes:
;;****************************

;;;*********************
;;; Abstract Data Types:
;;;*********************

;; A vertex consists of a name, type (one of ELL, FORK, ARROW, or TEE), 
;; list of neighboring vertices, and list of labelings, where a labeling
;; is a list of labels and a label is one of +, -, LEFT, or RIGHT.
(defun make-VERTEX (name type labelings)
  (list name type (list) labelings))
(defun VERTEX-name (v) (first v))
(defun VERTEX-type (v) (second v))
(defun VERTEX-neighbors (v) (third v))
(defun VERTEX-labelings (v) (fourth v))
(defun VERTEX-number-of-labelings (v)
  (length (VERTEX-labelings v)))
(defun set-VERTEX-name (v name) (setf (first v) name))
(defun set-VERTEX-type (v type) (setf (second v) type))
(defun set-VERTEX-neighbors (v neighbors) (setf (third v) neighbors))
(defun set-VERTEX-labelings (v labelings) (setf (fourth v) labelings))
(defun copy-VERTEX (v) (copy-list v))

;; A diagram is just a list of vertices to encode the information from 
;; the line drawings. Lines are implicit in the list of vertices and the
;; information regarding neighboring vertices. The function copy-DIAGRAM
;; allows us to make multiple copies of the same diagram to generate
;; multiple interpretations of an ambiguous line drawing.
(defun make-DIAGRAM (vertices) (list vertices))
(defun DIAGRAM-vertices (d) (first d))
(defun copy-DIAGRAM (d)
  (let ((new (make-diagram (mapcar #'copy-VERTEX
                                   (DIAGRAM-vertices d)))))
    ;; Install the neighbors for the new vertex copies.
    (mapc #'(lambda (vertex) 
              (set-VERTEX-neighbors 
               vertex
               (mapcar #'(lambda (neighbor) 
                           (find-vertex (VERTEX-name neighbor) new))
                       (VERTEX-neighbors vertex))))
          (DIAGRAM-vertices new))
    new))

;;************************************************************
;; Functions for contructing diagrams from vertex descriptors:
;;************************************************************

;; A vertex descriptor is a list consisting of a name and type for 
;; a vertex along with two additional vertex names for an ELL type
;; or three additional vertex names for ARROW, FORK, or TEE types.
;; For example, (A ARROW B C D) is a vertex descriptor for a vertex
;; named A of type ARROW connected to vertices named B C and D. 
;; As another example, (E ELL F G) is a vertex descriptor for a vertex
;; named E of type ELL connected to vertices named F and G.

;; Construct a new vertex given a vertex descriptor.
(defun construct-vertex (vertex-descriptor)
  (make-vertex
   (first vertex-descriptor)  
   (second vertex-descriptor) 
   (possible-labelings (second vertex-descriptor))))

;; Construct a new diagram given a list of vertex descriptors.
(defun construct-diagram (vertex-descriptors)
  (let ((diagram (make-diagram (mapcar #'construct-vertex 
                                       vertex-descriptors))))
    ;; Install the neighbors for the new vertices.
    (mapc #'(lambda (d)
              (set-VERTEX-neighbors 
               (find-vertex (first d) diagram)
               (mapcar #'(lambda (n)
                           (find-vertex n diagram))
                       (v-d-neighbors d))))
          vertex-descriptors)
    diagram))

;;; Given a vertex descriptor, returns a list of the names of
;;; neighboring vertices.
(defun v-d-neighbors (vertex-descriptor)
  (rest (rest vertex-descriptor)))

;; Find the vertex in the given diagram with the given name.
(defun find-vertex (name diagram)
  (find name (DIAGRAM-vertices diagram) :key #'VERTEX-name))

;; Indicate that the line between the two vertices is adjacent to 
;; the ground (floor) by labeling the line - thereby indicating 
;; that the line is concave.
(defun ground (diagram vertex-a vertex-b)
  (let ((v (find-vertex vertex-a diagram))
        (u (find-vertex vertex-b diagram)) i)
    (setq i (index u (VERTEX-neighbors v)))
    (set-VERTEX-labelings v
      (mapcan #'(lambda (l) 
		  (if (eq (nth i l) '-) 
		      (list l)
		    (list)))
              (VERTEX-labelings v)))
    diagram))

;; Compute the index of an item in a list. 
(defun index (item list)
  (aux-index item list 0))
(defun aux-index (item list index)
  (if (null list) (princ "Item not in list!")
      (if (eq item (car list)) index 
          (aux-index item (rest list) (+ 1 index)))))

;;************************************************
;; Functions for displaying vertices and diagrams:
;;************************************************

;; Display a vertex.
(defun show-VERTEX (vertex)
  (format t "~%  ~a/~d ~d:" 
          (VERTEX-name vertex)
          (VERTEX-number-of-labelings vertex)
          (VERTEX-type vertex))
  (mapc #'(lambda (neighbor labels)
            (format t " ~a~a=~a" 
                    (VERTEX-name vertex)
                    (VERTEX-name neighbor) labels))
        (VERTEX-neighbors vertex)
        (matrix-transpose (VERTEX-labelings vertex))))

;; Turn a matrix on its side.
(defun matrix-transpose (matrix)
  (if (null matrix)
      (list)
    (apply #'mapcar #'list matrix)))

;; Display a diagram.
(defun show-DIAGRAM (diagram)
  (mapc #'show-VERTEX 
        (DIAGRAM-vertices diagram))
  (format t "~%For ~d interpretation(s)."
          (reduce #'* (mapcar #'VERTEX-number-of-labelings
                              (DIAGRAM-vertices diagram)))))

;;***************************************
;; Functions to label or check labelings:
;;***************************************

;; There are four vertex types in the trihedral-vertex blocks world
;; used in the examples in this section, ELL, FORK, TEE, and ARROW. 
;; There are two labels for nonoccluding lines in the trihedral-vertex 
;; blocks world, + indicates a nonoccluding convex line and - indicates 
;; a nonoccluding concave line.
;; Occluding lines are labeled with respect to a vertex. 
;; RIGHT indicates an occluding line with the occluding matter to
;; the right of the line as you face outward from the vertex.
;; LEFT indicates an occluding line with the occluding matter to
;; the left of the line as you face outward from the vertex.
;; If a line is labeled RIGHT with respect to the vertex at one end 
;; of the line, then it is labeled LEFT with respect to the vertex 
;; at the other of the line. 

;; The function possible-labelings returns a list of the possible 
;; labelings in the junction catalog for a given vertex type. 
(defun possible-labelings (vertex-type)
  (cond 
   ((eq vertex-type 'ELL)
    ;; There are six possible labelings for an ELL type.        
    '((RIGHT LEFT) (LEFT RIGHT) (+ RIGHT) (LEFT +) (- LEFT) (RIGHT -)))
   ((eq vertex-type 'FORK)
    ;; There are five possible labelings for a FORK type.
    ;;   +\   /+   -\   /-  L\   /R  -\   /L  R\   /-     1\   /2
    ;;     \ /       \ /      \ /      \ /      \ /         \ /
    ;;      |         |        |        |        |    ==>    |
    ;;     +|        -|       -|       R|       L|          3|
    '((+ + +) (- - -) (LEFT RIGHT -)(- LEFT RIGHT)(RIGHT - LEFT)))
   ((eq vertex-type 'TEE)
    ;; There are four possible labelings for a TEE type.
    '((RIGHT LEFT +)(RIGHT LEFT -)(RIGHT LEFT LEFT)(RIGHT LEFT RIGHT)))
   ((eq vertex-type 'ARROW)
    ;; There are three possible labelings for an ARROW type.
    ;;                    2\ 3|  /1  
    ;;                      \ | /   
    '((LEFT RIGHT +) (- - +) (+ + -)))
   (t (princ "Unfamiliar vertex type!"))))

;; The function impossible-vertex returns T if the vertex 
;; has no possible labeling left and NIL otherwise.
(defun impossible-vertex (vertex)
  (null (vertex-labelings vertex)))

;;***************************
;; Waltz filtering algorithm:
;;***************************

;;*******************************************************************
;; 
;; In general, computing a consistent labeling for a polyhedral scene 
;; is computationally hard.
;; In some cases, however, we can eliminate a large number of 
;; impossible labelings, thereby reducing the amount of search 
;; required to find a consistent labeling.
;; The following algorithm, due to Waltz [1975] provides an efficient 
;; filter on the set of possible labelings for a polyhedral scene.
;; 
;; The algorithm works as follows. 
;; We keep a list of the possible list of labelings for each vertex
;; stored with the vertex.
;; For each vertex, we consider for each possible labeling if that
;; labeling is consistent with the possible labelings at neighboring
;; vertices.
;; A labeling is consistent with the possible labelings at neighboring
;; vertices if there is some way that we can assign the labels in the
;; labeling given the labelings at the neighboring vertices.
;; If the labeling is not consistent, then we eliminate the labeling 
;; from the possible labelings stored with the vertex.
;; If we eliminate at least one labeling, then the algorithm applies
;; itself recursively to the neighboring vertices.
;; If the algorithm ever finds a vertex that has no possible labelings,
;; then it halts, otherwise it continues to make recursive calls until 
;; no more labelings can be eliminated.
;; 
;; If there are n vertices and at most L labelings for each vertex
;; type, then the Waltz filtering algorithm will terminate in at most 
;; n X L steps.
;; 
;; It still may be necessary to perform some additional search to 
;; find a consistent labeling. In the exercises, you are asked to 
;; write code to perform this additional search.
;; 
;;*******************************************************************

;; Eliminate labelings in a diagram using the Waltz filtering algorithm.
(defun filter (diagram)
  (format t "~%The initial diagram is:")
  (show-DIAGRAM diagram)
  (mapc #'waltz (DIAGRAM-vertices diagram))
  (format t "~%After filtering the diagram is:")
  (show-DIAGRAM diagram))

;; Reduce the labelings on a vertex by considering the labeling of its
;; neighbors. If we can reduce the number of labelings, then recurse on 
;; the neighboring vertices. Return NIL only if you encounter a vertex
;; with no possible labelings. 
(defun waltz (vertex)
  (let ((old-num (VERTEX-number-of-labelings vertex)))
    (set-VERTEX-labelings vertex (consistent-labelings vertex))
    (if (impossible-vertex vertex) nil
      (or (not (< (VERTEX-number-of-labelings vertex) old-num))
          (every #'waltz (VERTEX-neighbors vertex))))))

;; Return the set of labelings that are consistent with neighbors.
(defun consistent-labelings (vertex)
  (let ((neighbor-labels
          (mapcar #'(lambda (neighbor) (labels-for neighbor vertex))
                  (VERTEX-neighbors vertex))))
    ;; Eliminate labelings that don't have all lines consistent
    ;; with the corresponding line's label from the neighbor.
    ;; Account for LEFT-RIGHT perspective change with reverse-label.
    (mapcan #'(lambda (labeling)
                (if (every #'member 
			   (mapcar #'reverse-label labeling) 
			   neighbor-labels)
		    (list labeling)
		  (list)))
            (VERTEX-labelings vertex))))

;; Return all the labels for the line going to vertex.
(defun labels-for (vertex from)
  (let ((i (index from (VERTEX-neighbors vertex))))
    (mapcar #'(lambda (labeling) (nth i labeling))
            (VERTEX-labelings vertex))))

;; Account for the fact that one vertex's right is another's left.
(defun reverse-label (label)
  (if (eq label 'LEFT) 'RIGHT
      (if (eq label 'RIGHT) 'LEFT label))) 

;;***************
;; Test function:
;;***************

(load "diagrams")

(defun test ()
  (filter (copy-DIAGRAM cube))
  (filter (ground (copy-DIAGRAM cube) 'g 'd))
  (filter (copy-DIAGRAM cube-on-plate))
  (filter (ground (copy-DIAGRAM cube-on-plate) 'k 'm))
  (filter (ground (copy-DIAGRAM tower) 'l 'k))
  (filter (ground (copy-DIAGRAM arch2) 'x 'z))
  (filter (ground (copy-DIAGRAM arch3) 'x 'z)))


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

