;**********************************************************************************************
;Project Name:  Interpreter for a Subset of Racket inside Racket
;Course: CPSC 3740—Spring 2019
;Group Members: Mitra Kazemzadeh (001199759)
;               David Adams (001196035)
;**********************************************************************************************

#lang racket

;;*************************************************************************************
;;function Name: zipperMerge
;;parameters list1 list2
;;A helper function to return a single list of respective pairs from two lists.
;;Used in evaluation of lambda expressions.
;;**************************************************************************************
(define (zipperMerge list1 list2)
  (cond [(or (empty? list1) (empty? list2)) empty]
        [else (cons (cons (car list1) (car list2)) (zipperMerge (cdr list1) (cdr list2)))]
        )
  )

;;************************************************************************************
;;function Name: eval
;;parameters : operand , dictionary, undef
;;A helper function that will take the operator and the dictionary
;;and return the acual value
;;************************************************************************************
(define (eval operand dictionary undef)
       (cond
         [(list? operand)(recEval operand dictionary undef)] ;if a list then pass it again to recEval to be evaluated
         [(string? operand) (display (string-append operand "\n"))] ;if it's a string, then return it with the newline character
         [(number? operand) operand] ;if number then just return the number
         [(null? dictionary) operand] ;if there's no dictionary, there's nothing more we can do, so we return it unaltered.
         [else (if (list? (find-dic dictionary operand dictionary undef))
                   (car(find-dic dictionary operand dictionary undef))
                   (find-dic dictionary operand dictionary undef))] ;If not then it must be a variable so find it in the dictionary
         )
  )

;;**********************************************************************************************
;;Function name:find-dic
;;paraeters:dic,var, dictionary, undef
;finds the value corresponding to a key
;the unaltered dictionary is passed in so that if it needs to call recEval the dictionary is not
;shortened. The undefined dictionary is also passed unaltered.
;;*********************************************************************************************
(define (find-dic dic var dictionary undef)
        (cond
          [(empty? dic) var] ;if dictionary is empty passed variable was not defined
          [(empty? (car dic)) (find-dic (cdr dic) var dictionary undef)] ;skip empty elements in the dictionary
          [(equal? var (caar dic)) (recEval (cdar dic) dictionary undef)] ;if passed variale is equal to car of any of the pairs,return the cdr
          [else (find-dic (cdr dic) var dictionary undef)])) ;Else recursively call the find-dic to check all the pairs

;;**********************************************************************************************
;;Function name:find-expr
;;parameters:dic,var
;Finds and returns the dictionary entry matching the given label (var).
;rather than evaluating the dictionary entry, this function simply returns the whole entry
;;**********************************************************************************************
(define (find-expr dic var)
  (cond
    [(empty? dic) null] ;can't find the expression, return null
    [(equal? var (caar dic)) (car dic)]
    [else (find-expr (cdr dic) var)]
    )
  )


;**********************************************************************************************
;;Function name:recEval
;;parameters:prog,dictionary,undef
;;Recursively evaluates prog by adding to dictionary when needed.
;;Elements are removed from the dictionary list simply through recursion
;;undef contains all of the functions being defined by letrec, which
;; only letrec can add to
;**********************************************************************************************
(define (recEval prog dictionary undef)
  ;********************************************************************************************
  ;;Implementing simple constants and variables
  ;;A non-list variable simply returns itself
  ;********************************************************************************************
  (if (not (list? prog))
      (eval prog dictionary undef)
  
    (let ((key (car prog)))
    
      (cond
        [(number? key) prog]
        ;********************************************************************************************
        ;;Implementing quoted constants and variables
        ;;A quoted variable simply returns itself
        ;********************************************************************************************
        [(equal? key 'quote) (second prog)]
        
        ;***************************************************************************************
        ;;Implementing the arithmatic operations
        ;;Just simply do the arithmetic operation by leting eval function take care of finding
        ;;the actual value of the operands
        ;***************************************************************************************
        [(equal? key '+) (+ (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
        
        [(equal? key '-) (- (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
        
        [(equal? key '*) (* (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
       
        [(equal? key '/) (/ (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
        
        
        
        
        ;***************************************************************************************
        ;Implementing the Relational operators
        ;;Just simply do the relational operation by leting eval function take care of finding
        ;;the actual value of the operands
        ;***************************************************************************************
        
        [(equal? key '<) (< (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
        
        [(equal? key '>) (> (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
      
        [(equal? key '<=) (<= (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
      
        [(equal? key '>=) (>= (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
        
        [(equal? key '=) (= (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]

        [(equal? key 'equal?) (equal? (eval (second prog) dictionary undef) (eval (third prog) dictionary undef))]
        
        
        
        
        ;***************************************************************************************
        ;Implementing List
        ;***************************************************************************************
        [(equal? key 'car) (caadr(second prog))] ;;caadr is shortcut for car(car(cdr)). This was necessary
        ;;since the second element is ''()
        [(equal? key 'cdr) (cdadr (second prog))]
        ;[(equal? key 'cons) (cons (second prog))]
        [(equal? key 'pair?) (pair? (cadr (second prog)))]
        
        ;***************************************************************************************
        ;Implementing If statement
        ;If the second member of the list which is the conditional is returning #true then pass
        ;the third part to the recEval to be executed, If returns #false, then pass the fourth
        ;part to the recEval to be executed.
        ;***************************************************************************************
        [(equal? key 'if) ( if (equal? #true (recEval (second prog) dictionary undef)) (recEval (third prog) dictionary undef)
                               (recEval(fourth prog) dictionary undef))]
        
        
        ;***************************************************************************************
        ;Implementing let
        ;First it will pass a new dictionary by let which will take the lates version of dictionary
        ;and simply add the new defined variables at the begining of it then pass the rest of the
        ;prog to recEval again which might potentially be a let expresion again       
        ;***************************************************************************************
        [(equal? key 'let) (recEval (third prog) (append (second prog)  dictionary) undef)]

       ;***************************************************************************************
        ;Implementing letrec
        ;It will bind the variables to their values, which may contain the variables themselves.
        ;It will therefore be recursively handled for its unbound variable if needed, such as when
        ;the variable is a function containing itself
        [(equal? key 'letrec) (recEval (third prog) (append (second prog) dictionary) (append (second prog) undef))]
        
        ;***************************************************************************************
        ;Implementation of lambda
        ;Lambda applies a given function to variables, which are assigned values in the dictionary
        ; prior to evaluation.
        ;***************************************************************************************
        [(list? key) (cond
                       [(equal? (car key) 'lambda)
                        (recEval
                         (third key)
                         (append (zipperMerge (second key) (cdr prog))  dictionary) undef)]
                       [else (recEval (car prog) dictionary undef)]
                       )]
        
        ;***************************************************************************************
        ;Undefined key
        ;This else statement is meant to stand in place of the #UNDEFINED operator tag for letrec
        ;If the operator is unknown, then it must be evaluated.
        ;This is not properly implemented, so any unknown operator is evaluated,
        ; regardless of whether letrec first encountered it or not.
        ;***************************************************************************************
        [else (if (or (not (equal? (find-expr undef key) null)) (not (equal? (find-expr dictionary key) null)))
                  (recEval key (append
                                (zipperMerge (second (second (find-expr dictionary key)))
                                             (if (not (list? (recEval (cdr prog) dictionary undef)))
                                                 (list (recEval (cdr prog) dictionary undef))
                                                 (recEval (cdr prog) dictionary undef)))
                                dictionary) undef)
                  prog)]
        ))))

;*****************************************************************************************
;;Function name: startEval
;;parameters: prog
;;Takes the initial expression to be evaluated (prog) and passes it to the
;;recEval function to be recursively evaluated with a dictionary
;*****************************************************************************************
(define (startEval prog)
  (recEval prog '() '())
  )

;*****************************************************************************
;Provide statement to allow these definitions to be imported by other modules
;*****************************************************************************
(provide (all-defined-out))