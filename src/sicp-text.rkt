#lang racket

(require math/base)

; -------- 1.1.4 --------

(define (square x)
  (* x x))

; -------- 1.1.7 --------

(define (average a b)
  (/ (+ a b) 2))

(define (improve guess x)
  (average guess (/ x guess)))

; -------- exercise 1.9 --------

(define (inc x)
  (+ x 1))

(define (dec x)
  (- x 1))

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

(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder
          (square (expmod base (/ exp 2) m))
          m))
        (else
         (remainder
          (* base (expmod base (- exp 1) m))
          m))))

; racket/base 中的 random 过程有限制，参数不能大于 4294967087。这里使用 math-lib 包中的 random-natural 过程。
(define (fermat-test n)
  (define (try-it a)
    (= (expmod a n n) a))
  (try-it (+ 1 (random-natural (- n 1)))))

(define (fast-prime? n times)
  (cond ((= times 0) true)
        ((fermat-test n) (fast-prime? n (- times 1)))
        (else false)))

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

; -------- 1.3 --------

(define (cube x)
  (* x x x))

; -------- 1.3.1 --------

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))

(define (identity x) x)  ; racket/function 中也有 identity 过程。

; -------- 1.3.3 --------

(define tolerance 0.00001)

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2))
       tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))

; -------- end --------

(provide (all-defined-out))
