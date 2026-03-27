#lang scribble/manual

@title{SICP 解题集 —— 2.1 数据抽象导引}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble-math
          "interaction.rkt")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{练习 2.1 | 有理数的正规化}

@ss-interaction[
(define (make-rat n d)
  (let ([g (gcd (abs n) (abs d))])
    (let ([n1 (/ n g)]
          [d1 (/ d g)])
      (if (< d1 0)
          (cons (- n1) (- d1))
          (cons n1 d1)))))
(print-rat (add-rat one-third one-third))
(print-rat (make-rat 6 (- 8)))
]

这里使用了 Racket 自带的 @racket[gcd] 过程。它其实能够正确处理负数，调用 @racket[(gcd x y)] 就和调用 @racket[(gcd (abs x) (abs y))] 一样。但我们这里还是显式地调用了两次 @racket[abs] 。

@; ----------------------------------------------------------------------

@section{练习 2.2 | 线段的表示}

我们将始点和终点放入一个序对来表示一条线段。

@ss-interaction[
(define (make-point x y) (cons x y))
(define (x-point p) (car p))
(define (y-point p) (cdr p))
(define (make-segment start end) (cons start end))
(define (start-segment s) (car s))
(define (end-segment s) (cdr s))
(define (print-point p)
  (newline)
  (display "(")
  (display (x-point p))
  (display ",")
  (display (y-point p))
  (display ")"))
(define (midpoint-segment s)
  (let ([start (start-segment s)]
        [end (end-segment s)])
    (let ([x0 (x-point start)]
          [y0 (y-point start)]
          [x1 (x-point end)]
          [y1 (y-point end)])
      (make-point (average x0 x1)
                  (average y0 y1)))))
(define source (make-point 3 6))
(define destination (make-point 5 10))
(print-point source)
(print-point destination)
(print-point (midpoint-segment (make-segment source destination)))
]


