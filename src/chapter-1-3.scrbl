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

@section[#:tag "exercise 1.30"]{练习 1.30 | @racket[sum] 过程也要迭代}

依旧用不变量的思想来分析。每次调用 @racket[(iter i result)] 时，都满足： @racket[result] 加上 @racket[(sum term i next b)] 所得的和不变，且等于要计算出的最终结果。

@ss-interaction[
(define (sum term a next b)
  (define (iter i result)
    (if (> i b)
        result
        (iter (next i) (+ result (term i)))))
  (iter a 0))
(sum identity 1 inc 100)
]

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.31"]{练习 1.31 | @racket[product] 过程}

分为 a 和 b 两小题。

@subsection{1.31 的 a 小题}

依旧如法炮制，模仿正文里的 @racket[sum] ，但是把加法 @racket[+] 改成乘法 @racket[*] ，并且把 @racket[0] 改成 @racket[1] 。因为 0 是加法的单位元，而 1 是乘法的单位元。任何数加 0 都等于它本身，任何数乘 1 都等于它本身。

@ss-interaction[
(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
         (product term (next a) next b))))
(product identity 1 inc 6)
]

一般地，当 @racket[term] 为 @${f} ， @racket[next] 为 @racket[inc] 时， @racket[product] 计算的是

@$${
  \prod_{x=a}^{b} f(x) = f(a) + f(a+1) + \cdots + f(b)
}

@subsection{1.31 的 b 小题}

上面那个版本产生递归计算过程，下面写一个产生迭代计算过程的版本。模仿 @secref["exercise 1.30"] 的做法，我们可以写出代码。

这里也有类似的不变量。每次调用 @racket[(iter i result)] 时，都满足： @racket[result] 乘以 @racket[(product term i next b)] 所得的积不变，且等于要计算出的最终结果。

@ss-interaction[
(define (product term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (* result (term a)))))
  (iter a 1))
(product identity 1 inc 6)
]

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.32"]{练习 1.32 | @racket[sum] 与 @racket[product] 的统一（是累积操作，不是取对数）}

分为 a 和 b 两小题。

@subsection{1.32 的 a 小题}

刚才把 @racket[sum] 改成 @racket[product] 只需要把 @racket[+] 改成 @racket[*] 以及把 @racket[0] 改成 @racket[1] 就已经初见端倪了，这里潜在地有一个更加一般的抽象。我们将 @racket[+] 改成 @racket[combiner] ，将 @racket[0] 改成 @racket[null-value] ，就可以得到这个更通用的 @racket[accumulate] 函数。

@ss-interaction[
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
                (accumulate combiner null-value term (next a) next b))))
(accumulate + 0 identity 1 inc 6)
(accumulate * 1 identity 1 inc 6)
]

“所有的项都用完时的基本值” @racket[null-value] 对应着 @secref["exercise 1.31"] 中所提到的单位元。

@subsection{1.32 的 b 小题}

刚才的版本产生递归计算过程，现在写一个产生迭代过程的版本。

@ss-interaction[
(define (accumulate combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (combiner result (term a)))))
  (iter a null-value))
(accumulate + 0 identity 1 inc 6)
(accumulate * 1 identity 1 inc 6)
]

不变量已经在 @secref["exercise 1.30"] 和 @secref["exercise 1.31"] 分别写过一次了，现在再写一次不变量。每次调用 @racket[(iter i result)] 时，都满足： @racket[result] 与 @racket[(accumulate combiner null-value term i next b)] 作为参数调用 @racket[combiner] 所得到的结果不变，且等于要计算出的最终结果。
