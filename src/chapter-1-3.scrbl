#lang scribble/manual

@title{SICP 解题集 —— 1.3 用高阶函数做抽象}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble-math
          "interaction.rkt"
          "utils.rkt")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{练习 1.29 | @racket[simpson-integral] ：辛普森积分法}

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

其中 @${M} 是 @${f(x)} 的四阶导函数在区间 @${[a,b]} 上的最大值。而在这里，我们的 @${f(x) = x^3} ，它最高只有 3 次，于是四阶导数直接恒等于 @${0} ，所以辛普森积分法对于 @${f(x) = x^3} 的误差其实理论上等于 @${0} 。所以，哪怕 @racket[n] 等于 2 或者 4，也可以期望它几乎没有误差。

@ss-interaction[
(simpson-integral cube 0.0 1.0 2)
(simpson-integral cube 0.0 1.0 4)
(simpson-integral cube 0.0 1.0 10)
]

而且，由于要加的项很少，所以舍入误差反而也非常小。

此外，原书 1.1.7 节的一个脚注中提到 @racket[sqrt-iter] 过程使用 @racket[1.0] 而非 @racket[1] 来启动计算，以迫使解释器进行浮点运算而不是有理数运算。这里也用了 @racket[0.0] 和 @racket[1.0] 启动计算来达到相同的目的。

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

@section[#:tag "exercise 1.31"]{练习 1.31 | @racket[product] ：多项相乘}

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
  \prod_{x=a}^{b} f(x) = f(a) \cdot f(a+1) \cdot f(a+2) \cdots f(b-1) \cdot f(b)
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

@section[#:tag "exercise 1.32"]{练习 1.32 | @racket[accumulate] ：累积，将 @racket[sum] 与 @racket[product] 推广}

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

@section{练习 1.33 | @racket[filtered-accumulate] ：带过滤的累积}

多加一个 @tt{if} 判断：如果 @racket[(term i)] 满足 @racket[take] 谓词，则进行 @racket[combiner] 运算算出新的 @racket[result] 并在下一次调用 @racket[iter] 时将原本的 @racket[result] 替换掉，否则不替换。

注意：书中说的是“只组合起由给定范围所得到的项里的那些满足特定条件的项”，而不是“只组合起由给定范围里的那些满足特定条件的部分所得到的项”。说白了，就是谓词要取的参数是 @racket[(term i)] ，而不是 @racket[i] 。

@ss-interaction[
(define (filtered-accumulate take combiner null-value term a next b)
  (define (iter i result)
    (define (handle term-of-i)
      (if (> i b)
          result
          (iter (next i)
                (if (take term-of-i)
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

@racket[coprime-product] 过程所计算的函数有一个专门的名字：“phi-torial”。OEIS 也收录了这一数列： @oeis-sequence{A001783} 。

@; ----------------------------------------------------------------------

@section{练习 1.34 | @${\omega \, (C \, I \, 2)}}

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

@section[#:tag "exercise 1.36"]{练习 1.36 | 平均阻尼对收敛速度的影响}

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

朗伯（J@._ H@._ Lambert）是一名数学家。 @Secref["exercise 1.39"] 中对他有更多讲述。

@; TODO 写过程自动计算所需步数并写在文档里？

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.37"]{练习 1.37 | @racket[cont-frac] ：计算 k 项有限连分式}

分为 (a) (b) 两小题。

@subsection{小题 1.37 (a)}

这一小题我们先写产生递归计算过程的版本。一种方式是内部定义：

@ss-interaction[
(define (cont-frac n d k)
  (define (cont-frac-from i)
    (if (> i k)
        0
        (/ (n i)
           (+ (d i)
              (cont-frac-from (+ i 1))))))
  (cont-frac-from 1))

(define (phi-of k)
  (+ 0.0 (cont-frac (lambda (i) 1)
                    (lambda (i) 1)
                    k)))

(phi-of 10)
]

这里 @racket[phi-of] 过程对 @racket[cont-frac] 算出的结果加了一个浮点数 @racket[0.0] 。原因在 @hyperlink["./additional-lisp.html"]{补充的 Lisp 知识} 这一页面中说过，对整数做除法运算得到的是“有理数对象”，要和浮点数做一些运算才能变成浮点数。

另一种方式避免了内部定义，而是直接递归调用自己，途中对 @racket[n] 和 @racket[d] 做了变换：

@ss-interaction[
(define (cont-frac n d k)
  (if (= k 0)
      0
      (/ (n 1)
         (+ (d 1)
            (cont-frac (lambda (i) (n (+ i 1)))
                       (lambda (i) (d (+ i 1)))
                       (- k 1))))))

(phi-of 10)
]

第二种方法可以这样直观理解：

@$${
  f = \dfrac{N_1}{D_1 + \dfrac{N_2}{D_2 + \dfrac{N_3}{D_3 + \dfrac{N_4}{\ddots + \dfrac{N_K}{D_K}}}}}
}

可以转化成：

@$${
  f = \dfrac{N_1}{D_1 + \dfrac{{N'}_1}{{D'}_1 + \dfrac{{N'}_2}{{D'}_2 + \dfrac{{N'}_3}{\ddots + \dfrac{{N'}_{K-1}}{{D'}_{K-1}}}}}}
}

其中 @${N'} 和 @${D'} 的定义是 @${{N'}_i = N_{i+1}, \, {D'}_i = D_{i+1}} 。第二种方法的代码其实就是直接从这个思想翻译过来的。

现在我们找一下多大的 @racket[k] 能使近似值有 4 位精度。我们熟知 @${\dfrac{1}{\varphi} = 0.6180339887 \ldots} ，因此可以说“有 4 位精度”意味着 @${0.6180 \le f < 0.6181} 。另一种合理判断方式是看 @${\left| f - \dfrac{1}{\varphi} \right| \le 0.00005} 。现在把两种都实现一下。

@ss-interaction[
(define phi-inv (/ (- (sqrt 5) 1) 2))
(define (find-smallest-satisfy mapping pred)
  (define (try i)
    (if (pred (mapping i))
        i
        (try (+ i 1))))
  (try 0))
(define k-1
  (find-smallest-satisfy phi-of
                         (lambda (f)
                           (and (<= 0.6180 f)
                                (< f 0.6181)))))
(define k-2
  (find-smallest-satisfy phi-of
                         (lambda (f)
                           (<= (abs (- f phi-inv)) 0.00005))))
k-1
k-2
(phi-of k-1)
(phi-of k-2)
]

上述寻找最小的 k 的算法并非所需步数最少的算法。若找出的结果为 @${k} ，则所需步数是 @${\Theta(k^2)} 。有两种改进思路：

@itemlist[
  #:style 'ordered
  @item{我们发现 @racket[(find-smallest-satisfy mapping pred)] 是在寻找最小的 @racket[k] 使得 @racket[(pred (mapping k))] 为真。如果对于所有比 @racket[k] 大的数，谓词也都成立（对于第一种判断标准不一定成立，对于第二种则应该是成立的），那么可以用二分查找的方法找到 @racket[k] 。至于开始时的右端点，可以从 @racket[1] 、 @racket[2] 、 @racket[4] 、 @racket[8] ……中逐个猜测直到发现一个使谓词为真的。因为计算 @racket[(cont-frac n d k)] 是需要 @${\Theta(k)} 步的，所以我们还不能直接下定论说步数是 @${\Theta(\log k)} ，需要进一步分析。我们设找到的右端点为 @${2^m} ，那么在试探上界时所消耗的步数是 @${\Theta(1 + 2 + 4 + \cdots + 2^m) = \Theta(2^{m+1}) = \Theta(k)} 。而接下来为了确定具体结果，我们要用区间 @${[2^{m-1}, \, 2^m]} 之间的数调用 @${\Theta(k)} 次谓词。每次调用谓词时都需要 @${\Theta(k)} 步，于是总共需要 @${\Theta(k \log k)} 步。两步加起来，最终需要的步数是 @${\Theta(k \log k)} 。可以看出，谓词的计算拖慢了我们的速度。因此引出下面第二条：}
  @item{可以使用原书 1.2.2 节一个脚注中所提到的记忆技术，用之前算出过的结果来快速计算出 @racket[k] 更大时的结果。虽然一般情况下 @${f_{K-1} = \dfrac{N_1}{D_1 + \dfrac{N_2}{\ddots + \dfrac{N_{K-1}}{D_{K-1}}}}} 的结果并不能用于计算 @${f_K = \dfrac{N_1}{D_1 + \dfrac{N_2}{\ddots + \dfrac{N_K}{D_K}}}} ，但在这里， @${N_i} 和 @${D_i} 都恒等于 @${1} ，所以其实还真可以：有 @${f_K = \dfrac{1}{1 + f_{K-1}}} 。这样就可以用 @${\Theta(K)} 步算出从 @${f_1} 到 @${f_K} 的所有值了，从而我们能够用 @${\Theta(k)} 步找到答案。}
]

最后，其实如果将 k 项截断得到的结果，从 k=0 开始，全都写出来，会是这样的：

@$${
\dfrac{0}{1}, \,
\dfrac{1}{1}, \,
\dfrac{1}{2}, \,
\dfrac{2}{3}, \,
\dfrac{3}{5}, \,
\dfrac{5}{8}, \,
\dfrac{8}{13}, \,
\ldots
}

分子和分母其实是相错了一位的斐波那契数列。这也印证了一个结论：斐波那契数列后项与前项之比逐渐趋近于 @${\varphi} 。在刚才第二种改进方法中，对结果的记忆，其实是对斐波那契数列的记忆，甚至还重复了一次。

@subsection{小题 1.37 (b)}

迭代计算过程版本：

@ss-interaction[
(define (cont-frac n d k)
  (define (iter i acc)
    (if (= i 0)
        acc
        (iter (- i 1)
              (/ (n i)
                 (+ (d i) acc)))))
  (iter k 0))
(phi-of 15)
]

与递归计算过程版本不同，这个代码从连分数右下往左上计算。不变量是，每次调用 @racket[(iter i acc)] 时，都有：这个连分式的“ @racket[i] 项截断”，和 @racket[acc] 相加，和是恒定的，且等于要最终计算出的结果。

其实如果理解了这个不变量的思想，这个迭代版其实似乎会比递归版更自然、更容易理解。

这道题也是少数一些我在高中偷偷读 SICP 时就做了的题之一，现在我可以直接把自己曾经写在书上的答案抄到这里（幸好书本还幸存着）。当时还不知道“不变量”这一工具，写出迭代版本就遇到了一点困难。不过，最终写出的代码倒是非常适合用不变量来证明正确性的。

@; ----------------------------------------------------------------------

@section{练习 1.38 | 连分数算 @${\mathrm{e}}}

其实我还偷偷用了 1.2.6 部分的 @racket[divides?] 过程。

@ss-interaction[
(+ 2.0
   (cont-frac (lambda (i) 1)
              (lambda (i)
                (let ([i+1 (+ i 1)])
                  (if (divides? 3 i+1)
                      (* (/ i+1 3) 2)
                      1)))
              11))
]

作为对比，自然对数底的精确值为 @${\mathrm{e} = 2.718281828459 \ldots} 。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.39"]{练习 1.39 | @racket[tan-cf] ：连分数算 @${\tan x}}

虽然乍一看，这个分式中的加号变成了减号，似乎让我们不得不重写 @racket[cont-frac] 过程，但其实我们完全可以做一个变换：

@$${
  \tan x
  =
  \dfrac{x}{1 - \dfrac{x^2}{3 - \dfrac{x^2}{5 - \ddots}}}
  =
  \dfrac{x}{1 + \dfrac{-x^2}{3 + \dfrac{-x^2}{5 + \ddots}}}
}

这样就可以重复利用 @racket[cont-frac] 过程了，而不用傻乎乎地重写一个和 @racket[cont-frac] 几乎一样的新过程，只把加号改成减号。（我是不会讲出自己在高中偷偷读 SICP 的时候一开始真的只想到了这种笨方法这件事的。）

@ss-interaction[
(define (tan-cf x k)
  (+ 0.0
     (cont-frac (lambda (i)
                  (if (= i 1)
                      x
                      (- (square x))))
                (lambda (i)
                  (- (* 2 i) 1))
                k)))
]

看看用它计算 @${\tan \dfrac{\pi}{4} = 1} 效果如何：

@ss-interaction[
(tan-cf (/ pi 4) 0)
(tan-cf (/ pi 4) 1)
(tan-cf (/ pi 4) 2)
(tan-cf (/ pi 4) 3)
(tan-cf (/ pi 4) 4)
(tan-cf (/ pi 4) 5)
(tan-cf (/ pi 4) 6)
(tan-cf (/ pi 4) 7)
(tan-cf (/ pi 4) 8)
(tan-cf (/ pi 4) 9)
]

与 @secref["exercise 1.37"] 一样，对 @racket[cont-frac] 的结果加上浮点数以迫使它从有理数变成浮点数。

题中所说的 J@._ H@._ Lambert 其实就是 @secref["exercise 1.36"] 中提到的“朗伯 W 函数”中的朗伯。朗伯还是第一个证明 @${\pi} 是无理数的人，用到的其实也就是本题中他发现的这个连分式。大体思路是，先证明了如果 @${x} 是非零的有理数，那么上述连分式必定是无理数。而我们知道 @${\tan \dfrac{\pi}{4} = 1} 是有理的，所以 @${\dfrac{\pi}{4}} 一定不是有理数（所以是无理数）。所以 @${\pi} 也是无理数。详细的证明过程可以在网上找到。

@; ----------------------------------------------------------------------

@section{练习 1.40 | 牛顿法解三次方程}

@racket[newtons-method] 过程太好用了，我们真就只需要把 @racket[cubic] 写成对三次多项式函数求值就可以了：

@ss-interaction[
(define (cubic a b c)
  (lambda (x)
    (+ (cube x)
       (* a (square x))
       (* b x)
       c)))
(define poly1437 (cubic 4 3 7))
(define r (newtons-method poly1437 -4.0))
r
(poly1437 r)
]

可以看到，求出的根 @racket[r] 重新代入多项式函数 @racket[poly1437] 之后得到的结果确实非常接近 @racket[0] 。

@; ----------------------------------------------------------------------

@section{练习 1.41 | @racket[double] ：“使过程应用两次程度的能力”}

@ss-interaction[
(define (double f)
  (lambda (x)
    (f (f x))))
]

@itemlist[
  #:style 'ordered
  @item{@racket[double] 会使一个过程被应用的次数乘以 2。}
  @item{@racket[(double double)] 会使一个过程被 @racket[double] 给应用 2 次，也就是说，被应用的次数将乘以 2 共 2 次。也就是说，被应用的次数将乘以 4。}
  @item{@racket[(double (double double))] 会使一个过程被 @racket[(double double)] 给应用 2 次，也就是说，被应用的次数将乘以 4 共 2 次。也就是说，被应用的次数将乘以 16。}
]

所以 @racket[((double (double double)) inc)] 能够将参数增加 @racket[16] 。验证一下书上的例子：

@ss-interaction[
(inc 8)
((double inc) 8)
(((double double) inc) 8)
(((double (double double)) inc) 8)
]

@; ----------------------------------------------------------------------

@section{练习 1.42 | @racket[compose] ：函数复合}

@ss-interaction[
(define (compose f g)
  (lambda (x)
    (f (g x))))
((compose square inc) 6)
]

下一题 @secref["exercise 1.43"] 将会着重讲解函数复合。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.43"]{练习 1.43 | @racket[repeated] ：函数迭代}

我们先不用 @racket[compose] 过程，而是直接用更传统一些的方法：

@ss-interaction[
(define (repeated f n)
  (define (transform x)
    (define (iter current steps-last)
      (if (= steps-last 0)
          current
          (iter (f current) (- steps-last 1))))
    (iter x n))
  transform)
((repeated square 2) 5)
]

我们接下来用函数复合这一工具来做一些研究。数学上将函数复合记为 @${f \circ g} ，有 @${(f \circ g)(x) = f(g(x))} 。所以我们可以发现，“ @${n} 次重复应用 @${f} ”应该得到的是函数 @${\underbrace{f \circ f \circ \cdots \circ f}_n} 。数学上将其记为 @${f^{(n)}} ，加括号以示和乘幂不同。

函数复合是满足结合律的，想一想就知道非常显然：

@itemlist[@item{函数 @${f \circ (g \circ h)} 会对参数先应用 @${h} 函数，再应用 @${g} 函数，再应用 @${f} 函数；}
          @item{函数 @${(f \circ g) \circ h} 也是会对参数先应用 @${h} 函数，再应用 @${g} 函数，再应用 @${f} 函数。}]

（怎么感觉说了好多废话。）

我们利用 @racket[compose] 过程重新实现一下 @racket[repeated] 过程：

@ss-interaction[
(define (repeated f n)
  (if (= n 0)
      identity
      (compose f (repeated f (- n 1)))))
((repeated square 2) 5)
]

看起来有些熟悉，其实是 1.2.4 章节写出的求幂过程和它很像。那个章节里还做到了优化，只用 @${\Theta(\log n)} 的步数就算出了一个数的 @${n} 次幂。事实上，模仿那个章节里的规则，我们可以写出：

@$${
  f^{(n)} =
  \begin{cases}
    \mathrm{id}, & \text{if } n = 0  \\
    (f \circ f)^{(n/2)}, & \text{if } n > 0 \text{ and } n \text{ is even}  \\
    f \circ f^{(n-1)}, & \text{if } n > 0 \text{ and } n \text{ is odd}  \\
  \end{cases}
}

其中 @${\mathrm{id}} 函数就是恒等函数，在 Scheme 里是我们见过的 @racket[identity] 过程，它直接返回原参数不变。对一个 @${x} 应用 @${0} 次 @${f} 仍然会得到 @${x} ，很合理。

我们可以立即将上述想法翻译成 Scheme 代码：

@ss-interaction[
(define (repeated f n)
  (cond [(= n 0) identity]
        [(even? n) (repeated (compose f f) (/ n 2))]
        [else (compose f (repeated f (- n 1)))]))
((repeated square 2) 5)
]

这样，就可以用 @${\Theta(\log n)} 步把 @${f^{(n)}} 构造出来了。但是，将结果实际应用于一个参数，也就是在求 @${f(f(\cdots f(x) \cdots))} 时，计算所需的步数仍然是 @${\Theta(n)} ，不会加速。所以我们干的事是在用对数次步数搭建一个会执行线性次步数的过程。想想也是，如果对于一切可以计算的函数 @${f} ，我们都可以非常快速地计算 @${f(f(\cdots f(x) \cdots))} ，这也太荒诞了——包括三体问题在内的许多有关混沌的难题都可以随意解决了，那会是一个什么样的世界呢。

言归正传，既然最终要应用于参数时终究总是需要线性次步数，我们可以改变的是求出 @${f^{(n)}} 的所需步数。此时我们回头一看，最开始那个使用内部定义而不使用 @racket[compose] 的方式所需步数正是 @${\Theta(1)} 。而第二个方式——朴素地使用 @racket[compose] ，所需步数则是 @${\Theta(n)} 。

但是话又说回来了，没能加速，是因为 @racket[compose] 函数什么也没有干。如果我们在 @racket[compose] 的过程中真正做到了让步数减少，就又可以加速了。比如说，如果 @${f(x) = kx} 的话，我们可以用一个数值 @${k} 来表示这个函数，而在所谓的“函数组合”过程中，我们做的是让 @${k_1} 和 @${k_2} 相乘，算出一个新的数值来，这就是所谓的把 @${f_1} 和 @${f_2} 组合了。这样，我们可以对数步数算出 @${f^{(n)}} 。由于 @${f^{(n)}(x) = k^n x} ，它是被 @${k^n} 这个数值表示的，也就是说，最后算出来的是 @${k^n} 。等于说，这其实是在变相地用快速幂算法计算 @${k^n} ！

与之类似：

@itemlist[@item{仿射变换 @${f(x) = a x + b} 可以用有序实数对 @${(a, b)} 表示，而 @${(a, b)} 和 @${(c, d)} 的组合其实就是 @${(ac, ad+b)} ，因为若 @${f(x) = a x + b} 且 @${g(x) = c x + d} ，则 @${f(g(x)) = a (c x + d) + b = (ac) x + (ad + b)} ，这还是一个仿射变换，可以用 @${(ac, ad+b)} 表示；}
          @item{左乘矩阵 @${f(\vec{x}) = M \cdot \vec{x}} （其中 @${M} 是 @${n \times n} 矩阵）可以用矩阵 @${M} 它自己来表示，而函数复合其实就是矩阵乘法；}
          @item{在刚才的仿射变换中，还可以推广，将 @${a} 和 @${b} 分别视为 @${n \times n} 矩阵和 @${n} 维列向量，进行矩阵和向量的乘法以及向量加法；}
          @item{练习 1.19 中的 @${T_{p,q}} 变换其实只是刚才左乘矩阵 @${f(\vec{x}) = M \cdot \vec{x}} 的另一种表示方式而已，在这里 @${M} 其实是 @${\begin{bmatrix} p+q & q \\ q & p \end{bmatrix}} 。}]

在第二章，学会组合数据之后，上述的想法都可以轻松实现。

@; ----------------------------------------------------------------------

@section{练习 1.44 | @racket[smooth] ：函数平滑}

@ss-interaction[
(define (smooth f)
  (lambda (x)
    (/ (+ (f (- x dx))
          (f x)
          (f (+ x dx)))
       3)))
(define (smooth-n f n)
  ((repeated smooth n) f))

((smooth-n sin 0) (/ pi 4))
((smooth-n sin 1) (/ pi 4))
((smooth-n sin 2) (/ pi 4))
((smooth-n sin 3) (/ pi 4))
]

@; ----------------------------------------------------------------------

@section{练习 1.45 | 要做多少次平均阻尼}

先来点理论分析。设可导函数 @${f} 有一个不动点 @${r} ，即 @${f(r) = r} ；还有 @${x_0} 非常接近 @${r} ，我们可以说 @${x_0 = r + h} ，其中 @${h} 是绝对值非常小的数。设 @${x_1 = f(x_0), \, x_2 = f(x_1)} ，以此类推。这个数列 @${{x_n}} 是越来越靠近 @${r} 还是越来越远离 @${r} 呢？

我们只看前两项 @${x_0, \, x_1} 。我们希望 @${x_1} 与 @${r} 的距离比 @${x_0} 与 @${r} 的距离要更小，即

@$${
  \begin{align*}
    |x_1 - r| &< |x_0 - r|  \\
    |f(x_0) - r| &< |x_0 - r|  \\
    |f(x_0) - f(r)| &< |x_0 - r|  \\
    |f(r + h) - f(r)| &< |r + h - r|  \\
    |f(r + h) - f(r)| &< |h|  \\
    \left| \dfrac{f(r + h) - f(r)}{h} \right| &< 1
  \end{align*}
}

既然 @${h} 是绝对值非常小的数，那么我们可以近似地认为上式左边就是 @${f} 在 @${r} 处的导数。所以上式变为

@$${|Df(r)| \lessapprox 1}

这是我们希望的；如果它成立，那么数列 @${{x_n}} 就能不断逼近 @${r} 了。而在 @${h} 趋近于 @${0} 时，该式可以说是使用了严格的 @${<} 号。

总结就是，对于可导函数，想要有机会通过不动点迭代算法来逐渐逼近不动点，就需要其在不动点附近的导数绝对值小于 @${1} 。在数学上，这样的不动点称为“吸引不动点”。

如果画出函数迭代的蛛网图，其实可以直观地看出来。

换一个角度，如果放大很多倍，函数 @${f} 在 @${r} 处的图象就会像直线一样了，直线点斜式是 @${y - f(r) = Df(r) (x - r)} 。我们可以对一次函数作分析，来了解逼近速度。具体地，每迭代一次，距离将会缩短到上一次的 @${Df(r)} 倍。显然这个数的绝对值应该小于 @${1} 才会让距离越来越近，又一次印证了“导数绝对值小于 @${1} ”这个要求。

（图先欠着）

@; TODO: 给出蛛网图

在对求 @${n} 次方根的问题作分析之前，我们先来看一下对函数 @${f} 做 @${k} 次平均阻尼究竟会发生什么。我们将做了 @${k} 次平均阻尼的函数记作 @${f_k} 。计算可得：

@$${
  \begin{align*}
    f_0(x) &= f(x)  \\
    f_1(x) &= \dfrac{x + f(x)}{2}  \\
    f_2(x) &= \dfrac{3x + f(x)}{4}  \\
    f_3(x) &= \dfrac{7x + f(x)}{8}  \\
           & \vdots
  \end{align*}
}

可以观察到，有 @${f_k(x) = \dfrac{(2^k-1)x + f(x)}{2^k}} 。这可以用数学归纳法证明。

现在要和刚才有关吸引不动点的结论结合起来。我们对 @${f_k} 求导，得到

@$${
  \begin{align*}
    Df_k(x) &= \dfrac{(2^k-1) + Df(x)}{2^k}  \\
            &= 1 + \dfrac{Df(x) - 1}{2^k}
  \end{align*}
}

因此，我们希望 @${\left| 1 + \dfrac{Df(r) - 1}{2^k} \right| < 1} ，即

@$${
  \begin{align*}
    -1 &< 1 + \dfrac{Df(r) - 1}{2^k} &< 1  \\
    -2 &< \dfrac{Df(r) - 1}{2^k} &< 0  \\
    -2^{k+1} &< Df(r) - 1 &< 0  \\
    -2^{k+1} + 1 &< Df(r) &< 1  \\
  \end{align*}
}

可以从中看到，做平均阻尼能使 @${r} 变成吸引不动点，当且仅当 @${Df(r) < 1} 。此时只需要找到 @${k} 满足 @${-2^{k+1} + 1 < Df(r)} 即可，上式变形可得 @${k > \log_2(1 - Df(r)) - 1} 。 @bold{这就是平均阻尼所需要的次数。}

在 @${Df(r) > 1} 时，无论再怎么做平均阻尼，都无济于事。这一点其实可以从图象上直观看出来。

（图继续欠着）

@; TODO: 补图

在 @${r} 可以变成吸引不动点，即 @${Df(r) < 1} 时，我们还希望 @${1 + \dfrac{Df(r) - 1}{2^k}} 尽可能接近 @${0} ，因为这样会让收敛速度最快。观察发现这个式子随 @${k} 增大而严格单调递减，所以我们直接令它等于 @${0} （假定 @${k} 可以是实数），解出 @${k = \log_2(1 - Df(r))} 。 @bold{因此，对它向上和向下取整，其中就有使迭代速度最快的平均阻尼次数。}

综上所述，我们有了如下一些结论。

@itemlist[
  #:style 'ordered
  @item{若 @${f} 是一个可导函数， @${r} 是它的一个不动点，那么当且仅当 @${Df(r) < 1} 时，才能够在对 @${f} 进行 @${k} 次 @${(k \ge 0)} 平均阻尼之后，令 @${r} 变成吸引不动点。}
  @item{当且仅当 @${k > \log_2(1 - Df(r)) - 1} 时， @${r} 会变成吸引不动点。}
  @item{对 @${\log_2(1 - Df(r))} 分别向上、向下取整，其中一个或两个对 @${k} 的取值，会让不动点迭代最快地逼近 @${r} 。}
]

终于，我们可以来考虑求 @${n} 次方根的情况了。对于一个确定的 @${x > 0} ，寻找它的（正的） @${n} 次方根 @${r = \sqrt[n]{x} \, (n \ge 2)} ，题里指出是对函数 @${f(y) = \dfrac{x}{y^{n-1}}} 求不动点。对 @${y} 求导，得到 @${Df(y) = (1-n) \dfrac{x}{y^{n}}} 。可以看到，后者必然小于 @${0} ，由刚才的结论知，做平均阻尼是一定可以让根变成吸引不动点的。平均阻尼的次数要满足：

@$${
  \begin{align*}
    k &> \log_2(1 - Df(r)) - 1  \\
      &= \log_2 \left( 1 - (1-n) \dfrac{x}{r^{n}} \right) - 1  \\
      &= \log_2 \left( 1 - (1-n) \dfrac{x}{(\sqrt[n]{x})^{n}} \right) - 1  \\
      &= \log_2(1 - (1-n)) - 1  \\
      &= \log_2 n - 1
  \end{align*}
}

此外，计算 @${\log_2(1 - Df(r)) = \log_2 n} ，对它向上、向下取整得到 @${\lfloor \log_2 n \rfloor} 和 @${\lceil \log_2 n \rceil} ，其中一个或两个对 @${k} 的取值，会让不动点迭代最快地逼近 @${r} 。

做一些实验。这里直接取 @${k = \lfloor \log_2 n \rfloor} 。这里使用了 Racket 中的过程 @racket[expt] 求幂，还有 @racket[exact-floor] 向下取整。

@ss-interaction[
(define (find-root-of-minimal-damp n x)
  (let ([k (exact-floor (log n 2))])
    (fixed-point-of-transform (lambda (y)
                                (/ x (expt y (- n 1))))
                              (repeated average-damp k)
                              1.0)))
(find-root-of-minimal-damp 2 2)
(find-root-of-minimal-damp 3 2)
(find-root-of-minimal-damp 12 2)
(/ (+ 1 (find-root-of-minimal-damp 2 5)) 2)
]

作为对比，用 Racket 标准库计算上方一些根式：

@ss-interaction[
(expt 2 (/ 1 2))
(expt 2 (/ 1 3))
(expt 2 (/ 1 12))
(/ (+ 1 (expt 5 (/ 1 2))) 2)
]

效果很好。

说点题外话。用牛顿法求 @${f} 的零点，其实是求 @${x \mapsto x - \dfrac{f(x)}{Df(x)}} 的不动点，这一点原书正文里也有提到。那我们拿刚才有关吸引不动点的结论来分析一下它会如何呢？我们设经过“牛顿变换”的 @${f} 为 @${g} ，即 @${g(x) = x - \dfrac{f(x)}{Df(x)}} 。设 @${f} 的根为 @${r} ，它将是 @${g} 的不动点。我们对 @${g} 求导，得到 @${Dg(x) = \dfrac{g(x) D^{2}g(x)}{(Dg(x))^{2}}} 。这里 @${D^{2}g} 表示 @${g} 的二阶导函数。将 @${r} 代入直接得到 @${0} 了！所以按照刚才过程中所说的，迭代一次之后，和答案的距离就直接变成 @${0} 了吗？事实当然并非如此。刚才过程中所分析的情况中，我们说过，放大很多倍之后，函数图象会是一条直线。准确地说，其实应该是一条“斜线”。函数的行为就像一个一次函数一样，其中斜率不为 @${0} 。而当斜率为 @${0} 时，不能直接认为函数的行为就像一个斜率为 @${0} 的一次函数（常数函数）一样。相反，在牛顿迭代的这个情况下，它的行为会像二次函数一样。当一次项消失时，二次项会成为主导。先前针对一次函数的分析将不再适用，不动点迭代会有不同的行为，比如说：每迭代一次，正确的位数往往会翻倍（这一现象在原书 1.3.4 节的一个脚注中也有提及）；而对于一次函数，每迭代一次，正确的位数只会增加一个常数。

就像下面的演示中，对于一次函数，0 的位数每次只增加 1，而对于二次函数，0 的位数每次基本是翻倍的：

@ss-interaction[
((repeated (lambda (x) (/ x 10)) 1) 1.0)
((repeated (lambda (x) (/ x 10)) 2) 1.0)
((repeated (lambda (x) (/ x 10)) 3) 1.0)
((repeated (lambda (x) (/ x 10)) 4) 1.0)
((repeated (lambda (x) (/ x 10)) 5) 1.0)
((repeated (lambda (x) (/ (square x) 10)) 1) 1.0)
((repeated (lambda (x) (/ (square x) 10)) 2) 1.0)
((repeated (lambda (x) (/ (square x) 10)) 3) 1.0)
((repeated (lambda (x) (/ (square x) 10)) 4) 1.0)
((repeated (lambda (x) (/ (square x) 10)) 5) 1.0)
]

也可以用蛛网图来直观感受。

（图依旧欠着）

@; TODO: 补图

牛顿法是二次收敛的，在数学上称为“Q 平方收敛”。而还有一个迭代求根算法称为哈雷迭代法：

@$${x_{n+1} = x_n - \dfrac{f(x_n) \cdot Df(x_n)}{(Df(x_n))^{2} - \dfrac{1}{2} f(x_n) \cdot D^{2}f(x_n)}}

它是三次收敛的。它一般会让根的正确位数每次翻 3 倍。

这甚至可以推广到任意次收敛。通用的算法称为 Householder 法（Householder's method）：

@$${x_{n+1} = x_n + d \dfrac{D^{d-1}(1/f)(x_n)} {D^{d}(1/f)(x_n)}}

其中 @${(1/f)} 表示函数 @${x \mapsto 1/f(x)} 。收敛速度是 @${d+1} 次。牛顿迭代法就是 @${d=1} 时的特殊情况，哈雷迭代法就是 @${d=2} 时的特殊情况。

@; ----------------------------------------------------------------------

@section{练习 1.46 | @racket[iterative-improve] ：迭代式改进}

@racket[iterativa-improve] 过程本身实现起来倒是没什么难度。这里不直接写一个 @tt{lambda} 表达式来作为返回值而是使用了内部定义，是因为它需要递归。（不过，练习 4.21 中还真就讲解了如何只用 @tt{lambda} 实现递归，不过这里就先不搞了。）

@ss-interaction[
(define (iterative-improve good-enough improve)
  (define (iter guess)
    (if (good-enough guess)
        guess
        (iter (improve guess))))
  iter)
(define (fixed-point-altered f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2))
       tolerance))
  (let ([go (iterative-improve (lambda (guess)
                                 (let ([next (f guess)])
                                   (close-enough? guess next)))
                               f)])
    (f (go first-guess))))
(define (sqrt-altered x)
  (let ([go (iterative-improve (lambda (guess)
                                 (< (abs (- (square guess) x)) 0.001))
                               (lambda (guess)
                                 (average guess (/ x guess))))])
    (go 1.0)))

(fixed-point-altered cos 1.0)
(sqrt-altered 9)
(/ (+ 1 (sqrt-altered 5)) 2)
(square (sqrt-altered 1000))
]

实现 @racket[fixed-point] 的时候其实很不优雅。在判断一个数是否足够好时，我们临时计算出了下一个值，只是用它做一下比较，然后立即丢弃掉。 @racket[f] 本身已经作为第二个参数传进去了，却要在和一个参数中再次现身，重复了。而且，这个临时算出的值不能让 @racket[iterative-improve] 过程用来更新状态，它只会自己浑然不觉地再算一次。相当于多做了整整一倍的重复计算。

我们重新审视一下 @racket[fixed-point] 在做什么。我们可以反过来看：在判断最新的一个猜测值够不够好时，需要将它与前一个猜测值做比较。如果我们在迭代中能够同时保存两个数值的状态。一个存储上一个值，一个存储最新的值，就好了。然而， @racket[iterative-improve] 中只维护一个变量 @racket[guess] 。我们需要一种技术，用一个变量保存两个数值的状态。这真的可以做到吗？纵观整个第一章，我们处理的数据只分为数值和过程这两类。我们可以将过程作为突破口，做出一个“二元组”，它能够保存两个对象：

@ss-interaction[
(define (make-pair a b)
  (define (dispatch index)
    (if (= index 0)
        a
        b))
  dispatch)
(define (get-first pair)
  (pair 0))
(define (get-second pair)
  (pair 1))
]

@racket[(make-pair a b)] 过程制造出一个对象，它表示着二元组 (@racket[a], @racket[b])，同时承载着 @racket[a] 和 @racket[b] 的信息。这个二元组可以保存成一个对象。 @racket[get-first] 和 @racket[get-second] 过程能分别从一个二元组中取出 @racket[a] 和 @racket[b] 。可以忽略这个二元组其实是一个过程的事实，因为反正它能保存成一个对象，能够 @racket[get-first] 和 @racket[get-second] ，那它就可以当作二元组。我们甚至可以定义一个过程 @racket[display-pair] 来直接打印一个二元组，显得它更像一个“二元组”了。

@ss-interaction[
(define (display-pair pair)
  (newline)
  (display "(")
  (display (get-first pair))
  (display ", ")
  (display (get-second pair))
  (display ")"))
]

我们来测试一下：

@ss-interaction[
(define p (make-pair 42 3.14))
(get-first p)
(get-second p)
(display-pair p)
]

有了二元组，我们就可以用 @racket[iterative-improve] 把 @racket[fixed-point] 再重写一次了。

@ss-interaction[
(define (fixed-point-altered-2 f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2))
       tolerance))
  (define (pair-close-enough? pair)
    (close-enough? (get-first pair)
                   (get-second pair)))
  (define (pair-transform pair)
    (let ([old (get-first pair)]
          [new (get-second pair)])
      (make-pair new (f new))))
  (let ([go (iterative-improve pair-close-enough?
                               pair-transform)])
    (get-second (go (make-pair (+ first-guess 100.0)
                               first-guess)))))
(fixed-point-altered-2 cos 1.0)
]

在这里，我们一开始使用 @racket[(+ first-guess 100)] 来当作“上一次计算出的值”，只是为了和 @racket[first-guess] 值相差足够大，以便启动计算。

在第二章，我们一开始就会学到“序对”，获得将两个对象组合成一个对象的能力，并开始用序对来表示一切数据结构。从二章开始会经常见到的 @racket[cons] 、 @racket[car] 和 @racket[cdr] 就对应着这里的 @racket[make-pair] 、 @racket[get-first] 和 @racket[get-second] 。原书 2.1.3 节也会讲到如何用过程来实现序对，方法就和上方一样。针对第一章的最后一题，这个优化可以视为从“构造过程抽象”到“构造数据抽象”的一个转折。
