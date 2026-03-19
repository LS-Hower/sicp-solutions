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

; -------- 1.2.6 --------

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (= n (smallest-divisor n)))

; -------- exercise 1.22 --------

(define (runtime)
  (current-process-milliseconds))

(define (timed-prime-test n)
  (newline)
  (display n)
  (start-prime-test n (runtime)))

(define (start-prime-test n start-time)
  (if (prime? n)
      (report-prime (- (runtime) start-time))
      'placeholder))  ; Racket requires a value here

(define (report-prime elapsed-time)
  (display " *** ")
  (display elapsed-time))

; -------- end --------

(provide (all-defined-out))
