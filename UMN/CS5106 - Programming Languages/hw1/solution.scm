;;; A prefix function
;;; Usage example: (prefix '(1 2) '(1 2 3 4))
(define (prefix xs ys)
  (if (null? xs) 
      true
      (if (null? ys) 
          false
          (if (= (car xs) (car ys))
              (prefix (cdr xs) (cdr ys))
              false
          )
      )
  )
)

;;; A sublist function
;;; Usage example: (sublist '(1 2) '(3 4 1 2))
(define (sublist xs ys)
   (if (null? xs)
       true
       (if (null? ys)
          false
          (if (= (car xs) (car ys))
              (if (prefix xs ys)
                   true
                   (sublist xs (cdr ys))
              )
              (sublist xs (cdr ys))
          )
       )
   )
) 
