#lang scribble/manual

@title{SICP 解题集 —— 1.3 用高阶函数做抽象}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble-math
          "interaction.rkt")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{练习 1.29 | 辛普森积分法}

@ss-interaction[

(define (simpson-integral f a b n)
  (define (add-2 x)
    (+ 2 x))
  (define (y k)
    (f (+ a (* k h))))
  (define h (/ (- b a) n))
  (* (/ h 3)
     (+ (y 0)
        (* 4 (sum y 1 add-2 (- n 1)))
        (* 2 (sum y 2 add-2 (- n 2)))
        (y n))))
(simpson-integral cube 0.0 1.0 100)
(simpson-integral cube 0.0 1.0 1000)
]

与用许多小长方形不同，辛普森积分法使用了二次函数来逼近被积函数，这样可以得到精度更高的积分结果。

@; ----------------------------------------------------------------------

@section{练习 1.30 | @racket[sum] 过程也要迭代}

@ss-interaction[
(define (sum term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (+ result (term a)))))
  (iter a 0))
(sum identity 1 inc 100)
]
