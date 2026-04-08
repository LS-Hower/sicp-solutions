#lang scribble/manual

@title{SICP 解题集 —— 1.2 过程及其产生的计算}

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

@section{练习 1.9 | 是递归还是迭代}

@verbatim{
(+ 4 5)
(inc (+ 3 5))
(inc (inc (+ 2 5)))
(inc (inc (inc (+ 1 5))))
(inc (inc (inc (inc (+ 0 5)))))
(inc (inc (inc (inc 5))))
(inc (inc (inc 6)))
(inc (inc 7))
(inc 8)
9
}

上面是一个递归计算过程。

@verbatim{
(+ 4 5)
(+ 3 6)
(+ 2 7)
(+ 1 8)
(+ 0 9)
9
}

上面是一个迭代计算过程。

@; ----------------------------------------------------------------------

@section{练习 1.10 | （伪）阿克曼函数}

分为多个小节。

@subsection{对三个式子的计算}

从 @racket[A] 的过程体能直接看出，@racket[(A 0 n)] 等同于 @racket[(* 2 n)]，所以计算的是 @${2n} 。

计算 @racket[(A 1 10)] 过程如下：

@verbatim{
(A 1 10)
(A 0 (A 1 9))
(* 2 (A 1 9))
(* 2 (A 0 (A 1 8)))
(* 2 (* 2 (A 1 8)))
...
(* 2 (* 2 (* 2 (* 2 (* 2 (* 2 (* 2 (* 2 (* 2 (A 1 1))))))))))
(* 2 (* 2 (* 2 (* 2 (* 2 (* 2 (* 2 (* 2 (* 2 2)))))))))
1024  ; 即 2^10
}

可以看到， @racket[(A 1 10)] 展开成了 10 个 2 相乘（准确地说，是一个 2 经过 9 次“乘以 2”操作）。一般地，有 @${\texttt{(A 1 n)} = 2^n} 。然而，当 @${n = 0} 时，结果是 @${0} 而不是 @${2^0 = 1} 。

计算 @racket[(A 2 4)] 过程如下：

@verbatim{
(A 2 4)
(A 1 (A 2 3))
(A 1 (A 1 (A 2 2)))
(A 1 (A 1 (A 1 (A 2 1))))
(A 1 (A 1 (A 1 2)))
(A 1 (A 1 (A 0 (A 1 1))))
(A 1 (A 1 (A 0 2)))
(A 1 (A 1 4))
(A 1 16)
65536     ; 即 2^16
}

@margin-note{指数塔，是从右上往左下计算的，例如 @${2^{2^{2^2}} = 2^{(2^{(2^2)})}} 。否则，就跟 @${ ((2^2)^2)^2 = 2^{2 \times 2 \times 2} } 一样了。}

注意 @racket[(A 2 4)] 展开成了 @racket[(A 1 (A 1 (A 1 2)))] ，计算结果将是 @${2^{2^{2^2}}} 。一般地，有 @${\texttt{(A 2 n)} = \underbrace{2^{2^{\cdot^{\cdot^{2}}}}}_n} ，这个指数塔里有 @${n} 个 @${2} 。然而，当 @${n = 0} 时，结果是 @${0} 而不是更自然的 @${1} 。下文将讲述为什么 @${1} 更自然。

计算 @racket[(A 3 3)] 过程如下：

@verbatim{
(A 3 3)
(A 2 (A 3 2))
(A 2 (A 2 (A 3 1)))
(A 2 (A 2 2))
(A 2 (A 1 (A 2 1)))
(A 2 (A 1 2))
(A 2 4)  ; 注意和上一题相同
65536
}

用解释器验证一下：

@ss-interaction[
(define (A x y)
  (cond ((= y 0) 0)
        ((= x 0) (* 2 y))
        ((= y 1) 2)
        (else (A (- x 1)
                 (A x (- y 1))))))
(A 1 10) (A 2 4) (A 3 3)
]

@subsection{对 f、g、h 函数（过程）的表示}

上一部分的计算过程中已经讲出了这些结论，在这里汇总一下：

@$${
  \begin{align*}
    \texttt{(f n)} = \texttt{(A 0 n)} &= 2n    \\
    \texttt{(g n)} = \texttt{(A 1 n)} &=
      \begin{cases}
        0, & \text{if } n = 0 \\
        2^n, & \text{if } n > 0
      \end{cases}             \\
    \texttt{(h n)} = \texttt{(A 2 n)} &=
      \begin{cases}
        0, & \text{if } n = 0 \\
        \underbrace{2^{2^{\cdot^{\cdot^{2}}}}}_n, & \text{if } n > 0
      \end{cases}
  \end{align*}
}

也用解释器验证一下：

@margin-note{@racket[(list 0 1 2 3 4)] 创建一个列表，包含 @racket[0] 、 @racket[1] 、 @racket[2] 、 @racket[3] 、 @racket[4] 这 5 个元素。 @racket[(map f (list 0 1 2 3 4))] 能够将 @racket[f] 函数（过程）应用于列表中的每个元素，相当于 @racket[(list (f 0) (f 1) (f 2) (f 3) (f 4))] ，从而能够将所有结果一次性全部打印出来。这样可以避免交互次数太多，影响阅读体验。}

@ss-interaction[
(define (f n) (A 0 n))
(define (g n) (A 1 n))
(define (h n) (A 2 n))
(map f (list 0 1 2 3 4))
(map g (list 0 1 2 3 4))
(map h (list 0 1 2 3 4))
]

@subsection[#:tag "hyperoperation"]{超运算入门}

这里更进一步，探讨更一般的 @racket[(A x y)] 。但在此之前，我们需要先了解一下“超运算”的知识。

@itemlist[@item{我们称 1 级运算为加法，写作 @${[1]} ，如 @${3[1]4 = 3+4 = 7} 。}
          @item{我们称 2 级运算为乘法，写作 @${[2]} ，如 @${3[2]4 = 3 \times 4 = 12} 。}
          @item{我们称 3 级运算为幂运算，写作 @${[3]} ，如 @${3[3]4 = 3^4 = 81} 。}
          @item{我们称 4 级运算为迭代幂次，写作 @${[4]} ，如 @${3[4]4 = 3^{3^{3^3}} = 3^{7625597484987}} 。这已经是一个相当大的数了，至少相对于日常生活而言。}
          @item{一般地， @${n} 级运算 @${a[n]b} 要这样计算：@${a[n]b = a[n-1]a[n-1]a[n-1] \cdots [n-1]a} ，其中一共有 @${b} 个 @${a} 。这个运算符是右结合的，从右往左算。也就是说， @${a[n]b[n]c} 等价于 @${a[n](b[n]c)} 。}]

熟悉高德纳箭号表示法的读者可以发现， @${a \uparrow^{n} b} 其实与 @${a[n+2]b} 是等价的。

@subsection{对 A 函数（过程）的完整表示}

现在我们可以用超运算的记法重写一下刚刚的结论了：

@$${
  \begin{align*}
    \texttt{(A 0 n)} &= 2[2]n \\
    \texttt{(A 1 n)} &=
      \begin{cases}
        0, & \text{if } n = 0 \\
        2[3]n, & \text{if } n > 0
      \end{cases}             \\
    \texttt{(A 2 n)} &=
      \begin{cases}
        0, & \text{if } n = 0 \\
        2[4]n, & \text{if } n > 0
      \end{cases}
  \end{align*}
}

可以发现明显的规律性。事实上，可以证明， @racket[(A x y)] 可以表示如下：

@$${
  \texttt{(A x y)} =
    \begin{cases}
      0,  & \text{if } y = 0 \\
      2[x+2]y, & \text{if } y > 0
    \end{cases}
}

画出 @racket[(A x y)] 的表格：

@tabular[#:column-properties '(border)
         (list (list "x\\y" "0" "1" "2" "3" "4" "5")
               (list "0"    "0" "2" "4" "6" "8" "10")
               (list "1"    "0" "2" "4" "8" "16" "32")
               (list "2"    "0" "2" "4" "16" "65536" "2[3]65536")
               (list "3"    "0" "2" "4" "65536" "2[4]65536" "2[4]2[4]65536")
               (list "4"    "0" "2" "4" "2[5]4" "2[5]2[5]4" "2[5]2[5]2[5]4"))]

@subsection{更自然的修改和扩展}

应当指出，对于 @racket[A] 函数（过程），如果一些返回值做一些修改会更自然一些。我们称修改过后的函数（过程）叫 @racket[A-alt] 。

表格是有规律的：

@margin-note{事实上，这个规律对应着原代码中 @tt{(else (A (- x 1) (A x (- y 1))))} 这个分支。}

@$${
  2 [x+1] \texttt{(A-alt x y)} = \texttt{(A-alt x (+ y 1))}
}

直观地说，就是表格的每个格子中的值 @${m} ，与 @${2} 经过 @${x+1} 级运算后，得到的值 @${2[x+1]m} 是右边那个格子的值。 @${y=1} 列和 @${y=2} 列之间遵循这个关系，@${y=2} 列和 @${y=3} 列之间也遵循这个关系……唯独 @${y=0} 列和 @${y=1} 列之间不遵循这个关系。这也是刚才好几次不得不为 @${y=0} 分情况讨论的原因。我们希望改写 @${y=0} 列，让表格处处都遵循这个关系，更加自然。

推算之后可以发现， @${y=0} 列应该填入 @${0, 1, 1, 1, \ldots} 。表格如下：

@tabular[#:column-properties '(border)
         (list (list "x\\y" "0" "1" "2" "3" "4" "5")
               (list "0"    "0" "2" "4" "6" "8" "10")
               (list "1"    "1" "2" "4" "8" "16" "32")
               (list "2"    "1" "2" "4" "16" "65536" "2[3]65536")
               (list "3"    "1" "2" "4" "65536" "2[4]65536" "2[4]2[4]65536")
               (list "4"    "1" "2" "4" "2[5]4" "2[5]2[5]4" "2[5]2[5]2[5]4"))]

事实上，这也正是超运算 @${a[n]b} 中对 @${b = 0} 情况的标准处理方式：若 @${n = 2} ，则结果为 @${0} ；若 @${n > 2} ，则结果为 @${1} 。

这样一来，我们还有了一个简洁的结论：

@$${
  \texttt{(A-alt x y)} = 2[x+2]y
}

在超运算中还有 @${a[0]b = b + 1} 的规定，因此在知道 @${a[0]b} 和 @${a[1]b} 是怎么算的之后，我们甚至可以根据上式将表格再度扩展：

@tabular[#:column-properties '(border)
         (list (list "x\\y" "0" "1" "2" "3" "4" "5")
               (list "-2"   "1" "2" "3" "4" "5" "6")
               (list "-1"   "2" "3" "4" "5" "6" "7")
               (list "0"    "0" "2" "4" "6" "8" "10")
               (list "1"    "1" "2" "4" "8" "16" "32")
               (list "2"    "1" "2" "4" "16" "65536" "2[3]65536")
               (list "3"    "1" "2" "4" "65536" "2[4]65536" "2[4]2[4]65536")
               (list "4"    "1" "2" "4" "2[5]4" "2[5]2[5]4" "2[5]2[5]2[5]4"))]

此表格在 OEIS 数列 @oeis-sequence{A143797} 中亦有记载。

@subsection{补充说明}

最后，通常所说的阿克曼函数 @${A(m, n)} 和这里的 @racket[A] 以及 @racket[A-alt] 函数（过程）其实也有一些小区别。具体地， @${A(m, n) = 2[m](n+3) - 3} 。可以自行查阅相关资料。

@; TODO 用代码自动生成上方的表格（稍微有点难度）

@; ----------------------------------------------------------------------

@section{练习 1.11 | 又一个递推定义的函数}

直接将定义翻译成 Scheme，就是采用递归计算过程的版本：

@ss-interaction[
(define (f n)
  (if (< n 3)
      n
      (+ (* 1 (f (- n 1)))
         (* 2 (f (- n 2)))
         (* 3 (f (- n 3))))))
(map f (list 0 1 2 3 4 5 6 7 8 9 10))
]

采用迭代计算过程的版本：

@ss-interaction[
(define (f n)
  (define (iter a b c i)
    (if (= i n)
        c
        (iter b
              c
              (+ (* 3 a) (* 2 b) (* 1 c))
              (+ i 1))))
  (if (< n 3)
      n
      (iter 0 1 2 2)))
(map f (list 0 1 2 3 4 5 6 7 8 9 10))
]

@racket[iter] 过程的参数总是满足： @racket[a] 、 @racket[b] 、 @racket[c] 分别等于 @${f(i-3)} 、 @${f(i-2)} 、 @${f(i-1)} 。


@; ----------------------------------------------------------------------

@section{练习 1.12 | 杨辉三角}

如下， @racket[binomial] 过程计算杨辉三角（帕斯卡三角形）第 n 行第 k 个数（从 0 开始计数）。

@margin-note{这里第二个交互只是为了较为完整地展示计算结果，不需要理解。如果读者已经在后面的章节学习了 @racket[map] 过程，那么只需要知道：在 Racket 中， @racket[(inclusive-range 0 n)] 返回一个列表，元素从 @racket[0] 到 @racket[n] ，步长为 @racket[1] 。}

@ss-interaction[
(define (binomial n k)
  (if (or (= k 0) (= k n))
      1
      (+ (binomial (- n 1) (- k 1))
         (binomial (- n 1) k))))
(map (lambda (n)
       (map (lambda (k)
              (binomial n k))
            (inclusive-range 0 n)))
     (list 0 1 2 3 4))
]

这是一个递归计算过程，而且有不少冗余计算。这个过程计算出来的是二项式系数 @${\dbinom{n}{k} = C_n^k} （原书此题里的脚注也有提及），而所需步数（不严谨地说，就是时间复杂度）也是 @${\Theta \left( \dbinom{n}{k} \right)} 。

@; ----------------------------------------------------------------------

@section{练习 1.13 | 斐波那契数其实还是四舍五入的结果}

这里先使用数学归纳法证明

@$${
  \mathrm{Fib}(n)
  = \dfrac{1}{\sqrt{5}}(\varphi^n - \psi^n)
  = \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1 + \sqrt{5}}{2} \right)^n - \left(\dfrac{1 - \sqrt{5}}{2} \right)^n \right)
}

@itemlist[
  #:style 'ordered
  @item{基础：当 @${n=0} 或 @${n=1} 时，代入验证即可得到该公式成立。}
  @item{递推：假设当 @${n=k} 以及 @${n=k-1} 时公式成立，现在要证明当 @${n=k+1} 时公式也成立。过程见下方：}
]

@$${
  \begin{align*}
    \mathrm{Fib}(k+1)
      &= \mathrm{Fib}(k) + \mathrm{Fib}(k-1) \\
      &= \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1 + \sqrt{5}}{2} \right)^k - \left(\dfrac{1 - \sqrt{5}}{2} \right)^k \right) + \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1 + \sqrt{5}}{2} \right)^{k-1} - \left(\dfrac{1 - \sqrt{5}}{2} \right)^{k-1} \right) \\
      &= \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1 + \sqrt{5}}{2} \right)^k - \left(\dfrac{1 - \sqrt{5}}{2} \right)^k + \left(\dfrac{1 + \sqrt{5}}{2} \right)^{k-1} - \left(\dfrac{1 - \sqrt{5}}{2} \right)^{k-1} \right) \\
      &= \dfrac{1}{\sqrt{5}} \left( \left(1 + \dfrac{1 + \sqrt{5}}{2} \right) \left(\dfrac{1 + \sqrt{5}}{2} \right)^{k-1} - \left(1 + \dfrac{1 - \sqrt{5}}{2} \right) \left(\dfrac{1 - \sqrt{5}}{2} \right)^{k-1} \right) \\
      &= \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{3 + \sqrt{5}}{2} \right) \left(\dfrac{1 + \sqrt{5}}{2} \right)^{k-1} - \left(\dfrac{3 - \sqrt{5}}{2} \right) \left(\dfrac{1 - \sqrt{5}}{2} \right)^{k-1} \right) \\
      &= \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1 + \sqrt{5}}{2} \right)^2 \left(\dfrac{1 + \sqrt{5}}{2} \right)^{k-1} - \left(\dfrac{1 - \sqrt{5}}{2} \right)^2 \left(\dfrac{1 - \sqrt{5}}{2} \right)^{k-1} \right) \\
      &= \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1 + \sqrt{5}}{2} \right)^{k+1} - \left(\dfrac{1 - \sqrt{5}}{2} \right)^{k+1} \right)
  \end{align*}
}

确实与 @${n=k+1} 时的公式相同。因此，

@$${
  \mathrm{Fib}(n)
  = \dfrac{1}{\sqrt{5}}(\varphi^n - \psi^n)
  = \dfrac{1}{\sqrt{5}} \left( \left(\dfrac{1 + \sqrt{5}}{2} \right)^n - \left(\dfrac{1 - \sqrt{5}}{2} \right)^n \right)
}

得证。

现在来解答问题。

我们设 @${\mathrm{Fib}(n)} 与 @${\dfrac{\varphi^n}{\sqrt{5}}} 的距离（差值的绝对值）为 @${\mathrm{dist}(n)}：

@$${
  \begin{align*}
    \mathrm{dist}(n)
      &= \left| \mathrm{Fib}(n) - \dfrac{\varphi^n}{\sqrt{5}} \right|  \\
      &= \left| \dfrac{1}{\sqrt{5}}(\varphi^n - \psi^n) - \dfrac{\varphi^n}{\sqrt{5}} \right| \\
      &= \dfrac{|\psi^n|}{\sqrt{5}} \\
      &= \dfrac{|\psi|^n}{\sqrt{5}}
  \end{align*}
}

@${\mathrm{dist}(n)} 其实随着 @${n} 的变大会越来越小，因为分子的底 @${|\psi| = \left| \dfrac{1 - \sqrt{5}}{2} \right| = 0.618 \ldots < 1} 。总之当 @${n \ge 0} 时 @${|\psi|^n \le 1} 。而分母上的 @${\sqrt{5} = 2.236 \ldots > 2} 又足够大，所以 @${\mathrm{dist}(n) = \dfrac{|\psi|^n}{\sqrt{5}} < 0.5} 。既然实数 @${\dfrac{\varphi^n}{\sqrt{5}}} 与整数 @${\mathrm{Fib}(n)} 的距离永远小于 @${0.5} ，那么 @${\dfrac{\varphi^n}{\sqrt{5}}} 的值四舍五入到整数之后一定是 @${\mathrm{Fib}(n)} ，这个 @${\mathrm{Fib}(n)} 就是最接近 @${\dfrac{\varphi^n}{\sqrt{5}}} 的整数。

此事在《算法导论》（第 3 版）第 3 章最后几段正文以及最后几道练习中亦有记载。

@; ----------------------------------------------------------------------

@section{练习 1.14 | 找钱时的树形递归计算过程}

TODO

@; ----------------------------------------------------------------------

@section{练习 1.15 | 三倍角公式算正弦函数}

分为 (a) (b) 两小题。

@subsection{小题 1.15 (a)}

@itemlist[
  #:style 'ordered
  @item{在调用 @racket[(sine 12.15)] 时，最后一步是调用一次 @racket[p] 过程；}
  @item{在调用 @racket[(sine 4.05)] 时，最后一步是调用一次 @racket[p] 过程；}
  @item{在调用 @racket[(sine 1.35)] 时，最后一步是调用一次 @racket[p] 过程；}
  @item{在调用 @racket[(sine 0.45)] 时，最后一步是调用一次 @racket[p] 过程；}
  @item{在调用 @racket[(sine 0.15)] 时，最后一步是调用一次 @racket[p] 过程；}
  @item{在调用 @racket[(sine 0.05)] 时，不调用 @racket[p] 过程了。}
]

因此一共调用 @racket[p] 过程 5 次。

@subsection{小题 1.15 (b)}

可以采用解递归式的方式来计算，但这里我们直接精确算出过程调用的次数。

从 (a) 小题中可以看出，在计算 @racket[(sine a)] 时，调用 @racket[p] 过程的次数，就等于在如下数列中大于 @${0.1} 的项的总个数：

@$${
  |a|, \dfrac{|a|}{3}, \dfrac{|a|}{3^2}, \dfrac{|a|}{3^3}, \ldots
}

因此只需找出所有满足 @${\dfrac{|a|}{3^n} \le 0.1} 的整数 @${n} 中最小的那个，记为 @${k} ，然后 @${k+1} 就是 @racket[p] 被调用的总次数。

由 @${\dfrac{|a|}{3^n} \le 0.1} 得 @${10 |a| \le 3^n} ，取对数得 @${\log_{3} (10 |a|) \le n} ，故 @${k = \lceil \log_{3} (10 |a|) \rceil} （这里 @${\lceil a \rceil} 表示向上取整函数，定义为最小的不小于 @${a} 的整数），因此 @racket[p] 被调用的次数为 @${k + 1 = \lceil \log_{3} (10 |a|) \rceil + 1} 。而 @racket[sine] 被调用的次数为 @${k+2} 。此外， @racket[not] 、 @racket[>] 、@racket[*] 、@racket[cube] 等过程被调用的次数也和前两者的调用次数成正比，而它们本身，都可以认为只使用常数空间和时间（步数）。

@margin-note{这里的对数底 @${3} 是可以省略掉的，稍后的章节会解释为什么可以这样。}

据此，由于 @${k = \lceil \log_{3} (10 |a|) \rceil = \Theta(log_{3} |a|)} ，所以计算占用的空间和时间（步数）资源增长阶都是 @${\Theta(log_{3} |a|)} 。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.16"]{练习 1.16 | 快速幂，而且迭代}

@ss-interaction[
(define (fast-expt-iter b n)
  (define (iter a b n)
    (cond [(= n 0) a]
          [(even? n) (iter a (* b b) (/ n 2))]
          [else (iter (* b a) b (- n 1))]))
  (iter 1 b n))
(fast-expt-iter 2 5)
(fast-expt-iter 3 4)
]

正如题目中所提示的那样，每次调用 @racket[(iter a b n)] 时，参数都必定满足一个条件： @bold{ @${ab^n} 是恒定不变的，而且等于我们最终应当计算出来的结果。} 要维持好这个不变量，只要第一次调用 @racket[iter] 时保证这个条件成立，之后在做递归调用时也一定保证这个条件成立。然后只需去保证 @racket[n] 能够快速下降到 @racket[0] 即可。而从代码中也可以看出，每一步中，如果 @racket[n] 是偶数，就会除以 @racket[2] ；如果是奇数，就会减去 @racket[1] 。所以 @racket[n] 一定会下降到 @racket[0] ，而且很快。算法的正确性和效率由此得到保证。

@; ----------------------------------------------------------------------

@section{练习 1.17 | “快速乘”}

如法炮制。

@ss-interaction[
(define (doubling-* a b)
  (cond [(= b 0) 0]
        [(even? b) (double (doubling-* a (halve b)))]
        [else (+ a (doubling-* a (- b 1)))]))
(doubling-* 2 3)
(doubling-* 4 7)
]

如果读过练习 1.10 的解答里 @secref["hyperoperation"] 这一部分，可以注意到，幂运算比乘法运算高一级，乘法运算比加法运算高一级，似乎这就是能用对数次乘法计算幂以及用对数次加法计算乘法的原因。然而，我们无法将这个思想扩展到更高一级的运算，比如用对数次幂运算计算迭代幂次。原因是，幂运算和更高级的运算不再满足结合律。

反过来，其实任何具有结合律的运算都可以使用“反复平方法”的思想。具体地，对于任何满足结合律的二元运算符 @${\circ} ，我们都可以只进行对数次 @${\circ} 运算，计算出

@$${
  \underbrace{a \circ a \circ \cdots \circ a \circ a}_{n}
}

（其中一共有 @${n} 个 @${a} ，且 @${n > 0} ）。刚刚在正文中用对数次乘法计算幂以及本习题中用对数次加法计算乘法，都是特例：对于前者， @${\circ} 就是乘法运算 @${\times} ，对于后者， @${\circ} 就是加法运算 @${+} 。

如果读者已经了解后面章节有关高阶函数的内容，则可以阅读下方的代码，它能够计算 @${n} 个 @${a} 的 @${\circ} 运算结果，前提是 @${\circ} 运算满足结合律：

@ss-interaction[
(define (double-and-add op n a)
  (cond [(= n 1) a]
        [(even? n)
          (let ([half (double-and-add op (/ n 2) a)])
            (op half half))]
        [else (op a (double-and-add op (- n 1) a))]))
(double-and-add + 7 2)
(double-and-add * 7 2)
]

若 @racket[op] 是满足结合律的二元运算符 @${\circ} ， @racket[n] 是正整数，则上述过程会计算出 @${\underbrace{a \circ a \circ \cdots \circ a \circ a}_{n}} 。

@; ----------------------------------------------------------------------

@section{练习 1.18 | “快速乘”，甚至迭代}

依旧维持不变量。就像 @secref["exercise 1.16"] 中维持 @racket[(iter a b n)] 每次被调用时有 @${ab^n} 恒定且等于我们应当计算出来的最终结果一样，我们这次维持 @${a+bn} 恒定且等于我们应当计算出来的最终结果。

@ss-interaction[
(define (doubling-*-iter a b)
  (define (iter a b n)
    (cond [(= n 0) a]
          [(even? n) (iter a (double b) (halve n))]
          [else (iter (+ b a) b (- n 1))]))
  (iter 0 a b))
(doubling-*-iter 2 5)
(doubling-*-iter 3 4)
]

@; ----------------------------------------------------------------------

@section{练习 1.19 | 斐波那契数也能对数步数算出来}

记住变换 @${T_{p, q}((a, \, b)) = (bq+aq+ap, \, bp+aq)} ，它接收一个数对，给出一个数对。现在我们计算 @${T_{p, q}(T_{p, q}((a, \, b)))} 。

@$${
  \begin{align*}
    T_{p, q}(T_{p, q}((a, \, b)))
      &= T_{p, q}((bq+aq+ap, \, bp+aq))  \\
      &= ((bp+aq)q+(bq+aq+ap)q+(bq+aq+ap)p, \, (bp+aq)p+(bq+aq+ap)q)  \\
      &= (bpq + aq^2 + bq^2 + aq^2 + apq + bpq + apq + ap^2, \, bp^2 + apq + bq^2 + aq^2 + apq)  \\
      &= (a (2q^2 + 2pq + p^2) + b (q^2 + 2pq), \, a (q^2 + 2pq) + b (q^2 + p^2))  \\
      &= (b (q^2 + 2pq) + a (q^2 + 2pq) + a (q^2 + p^2), \, b (q^2 + p^2) + a (q^2 + 2pq))
  \end{align*}
}

我们发现如果令 @${p' = q^2 + p^2} ，令 @${q' = q^2 + 2pq} ，那么上式结果可以写成 @${(bq' + aq' + ap', \, bp' + aq')} ，这正是 @${T_{p', q'}} 这一变换应用于 @${(a, b)} 的结果。也就是说，正如题面中所说，如果应用变换 @${T_{p, q}} 两次，效果就等同于应用变换 @${T_{p', q'}} 一次。然后通过 @${p} 和 @${q} 算出其中 @${p'} 和 @${q'} 的计算方式刚刚已经给出了：

@$${
  \begin{align*}
    p' &= p^2 + q^2  \\
    q' &= q^2 + 2pq
  \end{align*}
}

于是，我们可以填空了：

@ss-interaction[
(define (fib n)
  (fib-iter 1 0 0 1 n))
(define (fib-iter a b p q count)
  (cond ((= count 0) b)
        ((even? count)
         (fib-iter a
                   b
                   (+ (* p p) (* q q))
                   (+ (* q q) (* 2 p q))
                   (/ count 2)))
        (else (fib-iter (+ (* b q) (* a q) (* a p))
                        (+ (* b p) (* a q))
                        p
                        q
                        (- count 1)))))
(map fib (list 0 1 2 3 4 5 6 7))
]

主播主播，你的 @${T_{p,q}} 变换还是太吃操作了，有没有简单一点的理解方法？

有的有的，我们可以用 @${2 \times 2} 矩阵来理解。我们把重新看斐波那契数列的递推规律：

@$${
  \begin{align*}
    F_{n+2} = 1 \cdot F_{n+1} + 1 \cdot F_{n}  \\
    F_{n+1} = 1 \cdot F_{n+1} + 0 \cdot F_{n}
  \end{align*}
}

我们把它写成矩阵形式：

@$${
  \begin{bmatrix}F_{n+2} \\ F_{n+1} \end{bmatrix}
  =
  \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}
  \begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}
}

也就是说，二维向量 @${\begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}} 左乘一下这个矩阵就得到 @${\begin{bmatrix} F_{n+2} \\ F_{n+1} \end{bmatrix}} 了。那么从 @${\begin{bmatrix} F_{1} \\ F_{0} \end{bmatrix}} 出发，左乘这个矩阵 @${n} 次，就可以得到 @${\begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}} 了。又考虑到矩阵乘法满足结合律，所以我们可以提前算出 @${n} 个矩阵相乘的结果，然后让它左乘 @${\begin{bmatrix} F_{1} \\ F_{0} \end{bmatrix}} ，就可以得到 @${\begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}} 了。用数学语言表达这个思路，就是：

@$${
  \begin{align*}

    \begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}
    &=
    \underbrace{
      \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}
      \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}
      \cdots
      \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}
    }_{n}
    \begin{bmatrix} F_{1} \\ F_{0} \end{bmatrix}

    \\

    \begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}
    &=
    {\begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}}^{n}
    \begin{bmatrix} F_{1} \\ F_{0} \end{bmatrix}

    \\

    \begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}
    &=
    {\begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}}^{n}
    \begin{bmatrix} 1 \\ 0 \end{bmatrix}

  \end{align*}
}

至于 @${\begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}^{n}} 又如何计算呢？仍然可以利用本节中提到的平方求幂思想，因为矩阵乘法是满足结合律的。算出这个矩阵幂后，只需和 @${\begin{bmatrix} 1 \\ 0 \end{bmatrix}} 相乘，我们就能得到 @${\begin{bmatrix} F_{n+1} \\ F_{n} \end{bmatrix}} 了。

事实上， @${T_{p,q}} 方法就是矩阵平方求幂方法的另一种表达方式罢了。

@; ----------------------------------------------------------------------

@section{练习 1.20 | 不同求值规则中的欧几里得算法}

使用正则序+替换模型，看一下过程：

@verbatim{
(gcd 206 40)

(if (= 40 0)
    206
    (gcd 40
         (remainder 206 40)))

(gcd 40 (remainder 206 40))

(if (= (remainder 206 40) 0) ; 将会求值 1 次 remainder
    40
    (gcd (remainder 206 40)
         (remainder 40 (remainder 206 40))))

(gcd (remainder 206 40)
     (remainder 40 (remainder 206 40)))

(if (= (remainder 40 (remainder 206 40)) 0)  ; 将会求值 2 次 remainder
    (remainder 206 40)
    (gcd (remainder 40 (remainder 206 40))
         (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))))

(gcd (remainder 40 (remainder 206 40))
     (remainder (remainder 206 40) (remainder 40 (remainder 206 40))))

(if (= (remainder (remainder 206 40) (remainder 40 (remainder 206 40))) 0) ; 将会求值 4 次 remainder
    (remainder 40 (remainder 206 40))
    (gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
         (remainder (remainder 40 (remainder 206 40))
                    (remainder (remainder 206 40) (remainder 40 (remainder 206 40))))))

(gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
     (remainder (remainder 40 (remainder 206 40))
                (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))))

(if (= (remainder (remainder 40 (remainder 206 40))
                (remainder (remainder 206 40) (remainder 40 (remainder 206 40))))
       0)  ; 将会求值 7 次 remainder
    (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
    (gcd (remainder (remainder 40 (remainder 206 40))
                    (remainder (remainder 206 40) (remainder 40 (remainder 206 40))))
         (remainder (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
                    (remainder (remainder 40 (remainder 206 40))
                               (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))))))

; 这里 if 的条件终于为真了

(remainder (remainder 206 40) (remainder 40 (remainder 206 40)))  ; 将会求值 4 次 remainder

2
}

结束。

对 @racket[remainder] 共计求值 1+2+4+7+4 = 18 次。

这里出现的数列 @${1, 2, 4, 7, 12, 20, \ldots} 满足前两项之和再加 1 等于后一项。实际上它就是斐波那契数列减去 1。

使用应用序：

@verbatim{
(gcd 206 40)
(if (= 40 0) 206 (gcd 40 (remainder 206 40)))  ; 将会求值 1 次 remainder
(gcd 40 6)
(if (= 6 0) 40 (gcd 6 (remainder 40 6)))  ; 将会求值 1 次 remainder
(gcd 6 4)
(if (= 4 0) 6 (gcd 4 (remainder 6 4)))  ; 将会求值 1 次 remainder
(gcd 4 2)
(if (= 2 0) 4 (gcd 2 (remainder 4 2)))  ; 将会求值 1 次 remainder
(gcd 2 0)
(if (= 0 0) 2 (gcd 0 (remainder 2 0)))  ; 这次不再求值 remainder
2
}

结束。

对 @racket[remainder] 共计求值 4 次。

@; ----------------------------------------------------------------------

@section{练习 1.21 | 找几个最小因子}

依旧交给计算机处理：

@ss-interaction[(smallest-divisor 199) (smallest-divisor 1999) (smallest-divisor 19999)]

事实上，199 和 1999 都是质数，而 19999 的质因数分解为 7 × 2857 。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 1.22"]{练习 1.22 | 朴素素数算法是根号时间的吗}

注：Racket 没有 @racket[runtime] 过程，但有 @racket[current-process-milliseconds] 和 @racket[current-inexact-milliseconds] 等过程，测量单位是毫秒，但测量的是 UNIX 时间（从 1970 年 1 月 1 日 00:00:00 开始的毫秒数）。由于下方的程序只使用了 @racket[runtime] 返回结果之间的差值，所以直接用 @racket[current-process-milliseconds] 来实现 @racket[runtime] 也可以，但这种做法不能用在所有场合。

代码如下：

@racketblock[
(define (search-for-primes n)
  (define (iter needed n)
    (cond [(= needed 0)
            (newline)
            (display "done.")]
          [(even? n)
            (iter needed (+ n 1))]
          [(prime? n)
            (timed-prime-test n)
            (iter (- needed 1) (+ n 1))]
          [else
            (iter needed (+ n 1))]))
  (iter 3 n))
]

由于这本书编写于 30 年前（1996 年修订为第 2 版，而我打出这段话时是 2026 年 3 月 19 日），当时和现在的计算机算力、解释器实现技术不可同日而语，所以用来测试的数据量级也要提高才能看出效果。另外还有一点很重要，就是我们这里测量的是毫秒而不是微秒。用 10,000,000,000,000,000 以及它的 10 倍、100 倍来测试。

在我的电脑上运行测试，某次运行结果如下：

@verbatim{
10000000000000061 *** 266
10000000000000069 *** 265
10000000000000079 *** 250
done.
100000000000000003 *** 813
100000000000000013 *** 812
100000000000000019 *** 812
done.
1000000000000000003 *** 2578
1000000000000000009 *** 2594
1000000000000000031 *** 2593
done.
}

三次调用产生三组测量值，每组取平均数得到 @${260.33, \, 812.33, \, 2588.33} ，后项比前项分别得到 @${3.12, \, 3.18} 。而 @${\sqrt{10} \approx 3.16} ，测量结果符合预期。

@; ----------------------------------------------------------------------

@section{练习 1.23 | 步数少一半，时间就少一半吗}

为了不重名，把很多过程都重新写了一遍：

@racketblock[
(define (next test-divisor)
  (if (= test-divisor 2)
      3
      (+ test-divisor 2)))

(define (smallest-divisor-halved n)
  (find-divisor-halved n 2))

(define (find-divisor-halved n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor-halved n (next test-divisor)))))

(define (halved-prime? n)
  (= n (smallest-divisor-halved n)))

(define (timed-prime-test-halved n)
  (newline)
  (display n)
  (start-prime-test-halved n (runtime)))

(define (start-prime-test-halved n start-time)
  (if (halved-prime? n)
      (report-prime (- (runtime) start-time))
      'placeholder))

(define (search-for-primes-halved n)
  (define (iter needed n)
    (cond [(= needed 0)
            (newline)
            (display "done.")]
          [(even? n)
            (iter needed (+ n 1))]
          [(halved-prime? n)
            (timed-prime-test-halved n)
            (iter (- needed 1) (+ n 1))]
          [else
            (iter needed (+ n 1))]))
  (iter 3 n))
]

这次测量和 @secref["exercise 1.22"] 中的测量发生于同一次 @tt{racket} 进程的运行中。结果如下：

@verbatim{
10000000000000061 *** 140
10000000000000069 *** 125
10000000000000079 *** 140
done.
100000000000000003 *** 438
100000000000000013 *** 454
100000000000000019 *** 438
done.
1000000000000000003 *** 1375
1000000000000000009 *** 1391
1000000000000000031 *** 1406
done.
}

三个平均值分别为 @${135.00, \, 443.33, \, 1390.67} 。拿它们分别去除 @secref["exercise 1.22"] 中对应的测量值 @${260.33, \, 812.33, \, 2588.33} ，分别得到 @${1.93, \, 1.83, \, 1.86} 。这些比率比较接近但略小于 2。理论上，在 @racket[(start-prime-test-halved n (runtime))] 和 @racket[(report-prime (- (runtime) start-time))] 中两次 @racket[(runtime)] 的求值之间出现了除 @racket[prime?] （或 @racket[halved-prime?] ）以外的少量操作，以及调用 @racket[next] 过程并对 @tt{if} 特殊形式求值可能也比单纯的 @racket[(+ test-divisor 1)] 慢一点点，但更重要的因素可能仍然只是普通的测量误差罢了。

@; ----------------------------------------------------------------------

@section{练习 1.24 | 费马检查是对数时间的吗}

@racketblock[
(define (timed-prime-test-fast n)
  (newline)
  (display n)
  (start-prime-test-fast n (runtime)))

(define (start-prime-test-fast n start-time)
  (if (fast-prime? n 50)
      (report-prime (- (runtime) start-time))
      'placeholder))

(define (search-for-primes-fast n)
  (define (iter needed n)
    (cond [(= needed 0)
            (newline)
            (display "done.")]
          [(even? n)
            (iter needed (+ n 1))]
          [(fast-prime? n 50)
            (timed-prime-test-fast n)
            (iter (- needed 1) (+ n 1))]
          [else
            (iter needed (+ n 1))]))
  (iter 3 n))
]

这里将测试次数设为 50。

@racket[fast-prime?] 还是太快了，我们用 @racket[expt] 来生成输入数据。 @racket[(expt a b)] 计算 @${a^b} 的值。

这里测试了如下数据：

@racketblock[
(search-for-primes-fast (expt 10 50))
(search-for-primes-fast (expt 10 100))
(search-for-primes-fast (expt 10 150))
(search-for-primes-fast (expt 10 200))
(search-for-primes-fast (expt 10 250))
(search-for-primes-fast (expt 10 300))
]

得到的结果是：

@verbatim{
(0 0 0)
(16 0 16)
(31 31 15)
(46 47 47)
(94 79 78)
(141 141 157)
}

用时开始时基本是线性增加（一次增加一个常数）的，符合预期，但后期增长变快了，可能的原因是整数本身变得更长了。乘法和模运算的用时不会永远是常数。当然，测量误差也一定会存在。

@; ----------------------------------------------------------------------

@section{练习 1.25 | 先幂再模？}

这样改会严重拖慢程序。

正文中已经说过，我们的 @racket[expmod] 过程的一个优点就在于，计算过程中从来不需要对比 @racket[n] 大很多的数进行操作。具体地，在计算 @racket[(expmod a b n)] 时，可能遇到的最极端的情况只是 @${a = n-1} ，此时需要去先计算 @${a^2 = (n-1)^2} ，再去模以 @${n} ，然后就又比 @${n} 小了。 @${(n-1)^2} 是计算时能遇到的最大的数了。而修改后的 @racket[expmod] ，计算 @racket[(expmod a b n)] 时，会先把 @${a^b} 算出来，这期间所有的 @${a, \, a^2, \, a^3, \, \ldots, \, a^b} 全都有可能遇到。这些数往往几乎都非常非常大，它们哪怕是参与一个乘法计算都极为耗时。

@; ----------------------------------------------------------------------

@section{练习 1.26 | 没写 @racket[square]}

没有使用 @racket[square] 的版本，进行的过程调用次数是随 @racket[exp] 参数线性增长的。我们设 @racket[exp] 参数为 @${n} 时过程次数为 @${f(n)} ，由代码可以直接看出：

@$${
  f(n) =
  \begin{cases}
    1,  & \text{if } n = 0  \\
    1 + 2f \left( \dfrac{n}{2} \right),  & \text{if } n > 0 \text{ and } n \text{ is even} \\
    1 + f(n-1),  & \text{if } n > 0 \text{ and } n \text{ is odd}
  \end{cases}
}

我们也用 Scheme 计算一下，看一下前几项：

@ss-interaction[
(define (call-times n)
  (cond [(= n 0) 1]
        [(even? n)
         (+ 1 (* 2 (call-times (/ n 2))))]
        [else
         (+ 1 (call-times (- n 1)))]))
(map call-times (list 0 1 2 3 4 5 6 7 8 9 10))
]

该数列在 OEIS 上是 @oeis-sequence{A206332} （没有首项 1）。

可以用反证法证明 @${n \le f(n) \le 3n} 。事实上，有通项公式 @${f(n) = n + 2^{1 + \lfloor log_2(n) \rfloor} - 1} 及结论 @${2n \le f(n) \le 3n} ，因此该过程是 @${\Theta(n)} 的。

这里展示一下 @${n \le f(n)} 的证明：

首先，当 @${n < 2} 时，可以直接计算验证该结论。当 @${n \ge 2} 时，假设存在一些 @${n} 使得 @${f(n) < n} ，设 @${k} 是其中最小的那个。则：

@itemlist[@item{@${k} 不能是奇数，否则由 @${f} 的定义，有 @${1 + f(k-1) < k} ，即 @${f(k-1) < k-1} ，有 @${k-1} 比 @${k} 更小却也满足要求，矛盾；}
          @item{@${k} 也不能是偶数，否则由 @${f} 的定义，有 @${1 + 2f\left( \dfrac{k}{2} \right) < k} ，可得 @${f\left( \dfrac{k}{2} \right) < \dfrac{k-1}{2} < \dfrac{k}{2}} ，有 @${\dfrac{k}{2}} 比 @${k} 小却也满足要求，矛盾。}]

这样的 @${k} 不可能存在。因此， @${f(n) \ge n} 对于所有 @${n \ge 0} 都成立。

@; ----------------------------------------------------------------------

@section{练习 1.27 | 骗过检查的 Carmichael 数}

设计了一个过程 @racket[(fermat-test-all n)] ，在 @racket[n] 满足费马小定理那个式子时返回 @racket[true] ，否则返回 @racket[false] 。预计这个过程对于素数和 Carmichael 数会给出 @racket[true] ，对于其他合数会给出 @racket[false] 。

@ss-interaction[
(define (fermat-test-all n)
  (define (iter a)
    (cond [(= a n)
           true]
          [(= (expmod a n n) a)
           (iter (+ a 1))]
          [else
           false]))
  (iter 0))
(map fermat-test-all (list 561 1105 1729 2465 2821 6601))
(map fermat-test-all (list 2 3 5 7 11 13))
(map fermat-test-all (list 4 6 8 9 10 12))
]

@; ----------------------------------------------------------------------

@section{练习 1.28 | Miller-Rabin 素性测试}

@bold{注意：Racket 自带的 @racket[random] 过程有限制，参数不能大于 4294967087。这里使用 Racket 数学库中的 的 @racket[random-natural] 过程，功能相同，但没有这个限制。}

@ss-interaction[
(define (expmod-altered base exp m)
  (cond [(= exp 0) 1]
        [(even? exp)
         (define (handle-root root)
           (define (handle-modded-square result)
             (if (and (= result 1)
                      (not (= root 1))
                      (not (= root (- m 1))))
                 0
                 result))
           (handle-modded-square (remainder (square root) m)))
         (handle-root (expmod base (/ exp 2) m))]
        [else
         (remainder
          (* base (expmod base (- exp 1) m))
          m)]))

(define (miller-rabin-test n)
  (define (try-it a)
    (= (expmod-altered a (- n 1) n) 1))
  (try-it (+ 1 (random-natural (- n 1)))))

(define (miller-rabin-prime? n times)
  (cond [(= times 0) true]
        [(miller-rabin-test n) (miller-rabin-prime? n (- times 1))]
        [else false]))
]

（在 @tt{cond} 中，对于 @racket[(even? exp)] 的情况，临时定义了一些过程来避免重复计算，并给计算出的中间量起名字。稍后章节会介绍 @tt{lambda} 和 @tt{let} 特殊形式，方便我们更清晰地表达这样的意图。）

这里采纳了书中的建议，发出失败信号的方式是返回 @racket[0] 。这样一来， @racket[expmod-altered] 过程一旦发现了 1 的非平凡平方根，最终结果就一定是 @racket[0] ，绝不会和 @racket[1] 相等，因此最终能够返回 @racket[false] 。

做一些测试：

@ss-interaction[
(define (miller-rabin-prime-50? n)
  (miller-rabin-prime? n 50))

(map miller-rabin-prime-50? (list 561 1105 1729 2465 2821 6601))
(map miller-rabin-prime-50? (list 2 3 5 7 11 13))
(map miller-rabin-prime-50? (list 4 6 8 9 10 12))
]

这个 @racket[(miller-rabin-prime? n 50)] 就几乎不可能会误把合数（包括 Carmichael 数）认成素数了。对于一个数测试 50 轮，它将合数错认成素数的概率已经低于 @${\dfrac{1}{2^{50}}} ，比走在路上被陨石砸中的概率还要低得多。
