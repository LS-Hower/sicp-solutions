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
  (define (coefficient k)
    (cond [(or (= k 0) (= k n)) 1]
          [(even? k) 2]
          [else 4]))
  (define (calculate h)
    (define (y k)
      (f (+ a (* k h))))
    (define (y-with-coefficient k)
      (* (coefficient k) (y k)))
    (* (/ h 3)
       (sum y-with-coefficient 0 inc n)))
  (calculate (/ (- b a) n)))
(simpson-integral cube 0.0 1.0 100)
(simpson-integral cube 0.0 1.0 1000)
]

与用许多小长方形不同，辛普森积分法使用了二次函数来逼近被积函数，这样可以得到精度更高的积分结果。

可以看到， @racket[n] 等于 @racket[100] 时结果与 @racket[0.25] 的差距，与 @racket[n] 等于 @racket[1000] 时的差距相比，甚至还更小了。可以猜测，这里出现的误差已经主要是由浮点运算本身的舍入误差造成的了，辛普森积分法本身的误差应该已经是次要的了。事实上，辛普森积分法的误差 @${E} 满足：

@$${
  E \le \dfrac{M \cdot (b-a)^5}{180n^4}
}

其中 @${M} 是 @${f(x)} 的四阶导函数 @${\dfrac{\mathrm{d}^4f(x)}{\mathrm{d}x^4}} 在区间 @${[a,b]} 上的最大值。而在这里，我们的 @${f(x) = x^3} ，它最高只有 3 次，于是四阶导数直接恒等于 @${0} ，所以辛普森积分法对于 @${f(x) = x^3} 的误差其实理论上等于 @${0} 。所以，哪怕 @racket[n] 等于 2 或者 4，也可以期望它几乎没有误差。

@ss-interaction[
(simpson-integral cube 0.0 1.0 2)
(simpson-integral cube 0.0 1.0 4)
(simpson-integral cube 0.0 1.0 10)
]

而且，由于要加的项很少，所以舍入误差反而也非常小。

此外，原书脚注 23 中提到 @racket[sqrt-iter] 过程使用 @racket[1.0] 而非 @racket[1] 来启动计算，以迫使解释器进行浮点运算而不是有理数运算。这里也用了 @racket[0.0] 和 @racket[1.0] 启动计算来达到相同的目的。

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

分为 (a) (b) 两小题。

@subsection{小题 1.31 (a)}

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

@subsection{小题 1.31 (b)}

上面那个版本产生递归计算过程，下面写一个产生迭代计算过程的版本。模仿 @secref["exercise 1.30"] 的做法，我们可以写出代码。

这里也有类似的不变量。每次调用 @racket[(iter i result)] 时，都满足： @racket[result] 乘以 @racket[(product term i next b)] 所得的积不变，且等于要计算出的最终结果。

@ss-interaction[
(define (product term a next b)
  (define (iter i result)
    (if (> i b)
        result
        (iter (next i) (* result (term i)))))
  (iter a 1))
(product identity 1 inc 6)
]

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.32"]{练习 1.32 | @racket[sum] 与 @racket[product] 的统一（是累积操作，不是取对数）}

分为 (a) (b) 两小题。

@subsection{小题 1.32 (a)}

刚才把 @racket[sum] 改成 @racket[product] 只需要把 @racket[+] 改成 @racket[*] 以及把 @racket[0] 改成 @racket[1] 就已经初见端倪了，这里潜在地有一个更加一般的抽象。我们将 @racket[+] 改成 @racket[combiner] ，将 @racket[0] 改成 @racket[null-value] ，就可以得到这个更通用的 @racket[accumulate] 函数。

@ss-interaction[
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
                (accumulate combiner null-value term (next a) next b))))
(accumulate + 0 identity 1 inc 100)
(accumulate * 1 identity 1 inc 6)
]

“所有的项都用完时的基本值” @racket[null-value] 对应着 @secref["exercise 1.31"] 中所提到的单位元。然而，用户传入的 @racket[null-value] 不一定非得是 @racket[combiner] 运算的单位元（这个 @racket[combiner] 运算也完全可以不满足交换律、结合律，也可以不需要有单位元）。

@subsection{小题 1.32 (b)}

刚才的版本产生递归计算过程，现在写一个产生迭代过程的版本。

@ss-interaction[
(define (accumulate combiner null-value term a next b)
  (define (iter i result)
    (if (> i b)
        result
        (iter (next i) (combiner result (term i)))))
  (iter a null-value))
(accumulate + 0 identity 1 inc 6)
(accumulate * 1 identity 1 inc 6)
]

不变量已经在 @secref["exercise 1.30"] 和 @secref["exercise 1.31"] 分别写过一次了，现在再写一次不变量。每次调用 @racket[(iter i result)] 时，都满足： @racket[result] 与 @racket[(accumulate combiner null-value term i next b)] 作为参数调用 @racket[combiner] 所得到的结果不变，且等于要计算出的最终结果。

@; ----------------------------------------------------------------------

@section{练习 1.33 | @racket[filtered-accumulate] 过程}

多加一个 @tt{if} 判断：如果 @racket[(term i)] 满足 @racket[take?] 谓词，则进行 @racket[combiner] 运算算出新的 @racket[result] 并在下一次调用 @racket[iter] 时将原本的 @racket[result] 替换掉，否则不替换。

注意：书中说的是“只组合起由给定范围所得到的项里的那些满足特定条件的项”，而不是“只组合起由给定范围里的那些满足特定条件的部分所得到的项”。说白了，就是谓词要取的参数是 @racket[(term i)] ，而不是 @racket[i] 。

@ss-interaction[
(define (filtered-accumulate take? combiner null-value term a next b)
  (define (iter i result)
    (define (handle term-of-i)
      (if (> i b)
          result
          (iter (next i)
                (if (take? term-of-i)
                    (combiner result term-of-i)
                    result))))
    (handle (term i)))
  (iter a null-value))
]

上述代码在 @racket[iter] 过程的内部定义了 @racket[handle] 过程，避免了对 @racket[(term i)] 的重复求值。稍后章节会介绍 @tt{lambda} 和 @tt{let} 特殊形式，方便我们更清晰地表达这样的意图。

利用这个 @racket[filtered-accumulate] 过程，我们可以做出 (a) (b) 两小题。

@subsection{小题 1.33 (a)}

@ss-interaction[
(define (prime-sum-between a b)
  (filtered-accumulate prime? + 0 identity a inc b))
(prime-sum-between 5 13)
(+ 5 7 11 13)
]

@subsection{小题 1.33 (b)}

@racket[coprime?] 过程判断两数是否互素。

@ss-interaction[
(define (coprime? a b)
  (= 1 (gcd a b)))

(define (coprime-product n)
  (define (coprime-to-n? i)
    (coprime? i n))
  (filtered-accumulate coprime-to-n? * 1 identity 1 inc n))

(coprime-product 8)
(* 1 3 5 7)
]

@racket[coprime-product] 过程所计算的函数有一个专门的名字：“phi-torial”。OEIS 也收录了这一数列： @hyperlink["https://oeis.org/A001783"]{A001783} 。

@; ----------------------------------------------------------------------

@section{练习 1.34 | （伪）欧米伽}

@ss-interaction[
(define (f g)
  (g 2))
(f square)
(f (lambda (z) (* z (+ z 1))))
]

若要求值 @racket[(f f)] ，则要求值 @racket[(f 2)] 。

若要求值 @racket[(f 2)] ，则要求值 @racket[(2 2)] 。

但 @racket[2] 不是一个过程，所以无法求值。可以查看下方的报错：

@ss-interaction[(f f)]

@; ----------------------------------------------------------------------

@section{练习 1.35 | 不动点求 @${\varphi}}

首先证明 @${\varphi} 是函数 @${x \mapsto 1 + \dfrac{1}{x}} 的不动点。将 @${\varphi} 代入，得：

@$${
  \begin{align*}
    1 + \dfrac{1}{\varphi} &= 1 + \dfrac{2}{1 + \sqrt{5}}  \\
                           &= 1 + \dfrac{2 (1 - \sqrt{5})}{(1 + \sqrt{5})(1 - \sqrt{5})}  \\
                           &= 1 + \dfrac{2 (1 - \sqrt{5})}{-4}  \\
                           &= \dfrac{1 + \sqrt{5}}{2}  \\
                           &= \varphi
  \end{align*}
}

现在用 @racket[fixed-point] 求 @${\varphi} ：

@ss-interaction[
(fixed-point (lambda (x) (+ 1 (/ 1 x))) 1.0)
]

非常顺利。 @${\varphi} 的实际值为 @${\dfrac{1 + \sqrt{5}}{2} = 1.6180339887 \ldots} 。

@; ----------------------------------------------------------------------

@section{练习 1.36 | 平均阻尼对收敛速度的影响}

先对 @racket[fixed-point] 做修改，使其能够打印计算中产生的近似值序列：

@ss-interaction[
(define (fixed-point-with-steps f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2))
       tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (newline)
      (display next)
      (if (close-enough? guess next)
          next
          (try next))))
  (newline)
  (display first-guess)
  (try first-guess))
]

这里的技巧是，先打印最初的猜测值，然后每次计算出下一个值时立即打印，就不会有遗漏了。

对 @${x \mapsto \dfrac{\ln 1000}{\ln x}} 做平均阻尼，得到的函数是 @${x \mapsto \dfrac{x + \dfrac{\ln 1000}{\ln x}}{2}} 。

现在用刚编写的 @racket[fixed-point-with-steps] 来计算它们各自的不动点。注意到 @${4^4 = 256} ，而 @${5^5 = 3125} 。所以我们用 @racket[4.5] 作为初始猜测值：

@ss-interaction[
(fixed-point-with-steps (lambda (x)
                          (/ (log 1000) (log x)))
                        4.5)
(fixed-point-with-steps (lambda (x)
                          (/ (+ x (/ (log 1000) (log x))) 2))
                        4.5)
]

可以看到，经过平均阻尼后，收敛速度明显加快，所需步数变少了。

在实数范围内，这个解可以用 @${x = e^{W(\ln 1000)}} 来表示，其中 @${W} 是朗伯 W 函数，是 @${x \mapsto xe^x} 的反函数。解的精确值为 @${4.55553570519512802 \ldots} 。

@; TODO 写过程自动计算所需步数并写在文档里？

