#lang scheme

; -------- 1.1.4 --------

(define (square x)
  (* x x))

; -------- 1.1.7 --------

(define (average a b)
  (/ (+ a b) 2))

(define (improve guess x)
  (average guess (/ x guess)))

; -------- exercise 1.17 --------

(define (double x)
  (* x 2))

(define (halve x)
  (/ x 2))

; -------- end --------

(provide (all-defined-out))
