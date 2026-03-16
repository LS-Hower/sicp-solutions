#lang scribble/manual

@title{SICP 解题集 —— 第 1 章 构造过程抽象}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble/manual
          scribble-math
          "interaction.ss")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

更新日期：2026-03-16

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{练习 1.1}

只是按顺序执行一些 Scheme 代码。结果如下：

@ss-interaction[
10
(+ 5 3 4)
(- 9 1)
(/ 6 2)
(+ (* 2 4) (- 4 6))
(define a 3)
(define b (+ a 1))
(+ a b (* a b))
(= a b)
(if (and (> b a) (< b (* a b)))
    b
    a)
(cond ((= a 4) 6)
      ((= b 4) (+ 6 7 a))
      (else 25))
(+ 2 (if (> b a) b a))
(* (cond ((> a b) a)
         ((< a b) b)
         (else -1))
   (+ a 1))
]

注意：正文中说过，特殊形式 @tt{define} 返回的值是不确定的。解释器可以不打印任何值。

@; ----------------------------------------------------------------------

@section{练习 1.2}

如下：

@ss-interaction[
(/ (+ 5
      4
      (- 2
         (- 3
            (+ 6 (/ 4 5)))))
   (* 3
      (- 6 2)
      (- 2 7)))
]

@; ----------------------------------------------------------------------

@section{练习 1.3}

如下：

@margin-note{在 Scheme 中，分号表示代码中的注释，从分号开始到该行行尾的内容都会被解释器忽略。}

@margin-note{关于代码中的方括号，见主页面里的说明。}

@ss-interaction[
(code:line
(define (sum-of-bigger-two a b c)
  (cond [(and (< a b) (< a c)) (+ b c)]
        [(and (< b a) (< b c)) (+ a c)]
        [else (+ a b)]))
(code:comment "三个情况分别对应 a、b 和 c 是最小值时的情况"))

(sum-of-bigger-two (- 5) (- 2) 4)
(sum-of-bigger-two (- 5) 4 (- 2))
(sum-of-bigger-two (- 2) 4 (- 5))
]

@; ----------------------------------------------------------------------

@section{练习 1.4}

根据正文里的表述，在求值一个组合式时，第一步是求值该组合式的各个子表达式。

我们考察过程体中这个表达式 @racket[((if (> b 0) + -) a b)] ，它由三个子表达式组成：

@itemlist[@item{@racket[(if (> b 0) + -)]}
          @item{@racket[a]}
          @item{@racket[b]}]

其中第一个子表达式是要被调用的过程，而第二和第三个都是参数。

这确实与书中之前见过的所有代码都不同。之前的代码中，要被调用的过程，即第一个子表达式，都被表示成一个普通的名字，如 @racket[square] 或 @racket[+] 。但在这里，要被调用的过程，不再是一个简单名字，而是一个组合式。“求值各个子表达式”，意味着这三个子表达式都要被求值，包括第一个子表达式——这个组合式。虽然在逻辑上，第一个和后面两个不同，但它们都将被一视同仁地求值。于是，第一个子表达式也被（递归地）求值。若 @racket[b] 大于 @racket[0] ，则它的结果是 @racket[+] ，这相当于对 @racket[(+ a b)] 求值。否则，相当于对 @racket[(- a b)] 求值。这样，便计算出了 @racket[b] 的绝对值与 @racket[a] 的和。

@; ----------------------------------------------------------------------

@section{练习 1.5}

解释器采用应用序求值时：

在执行 @racket[test] 过程之前，解释器必须先去求值第二个参数 @racket[(p)] ，为了得到它的结果。但不幸地， @racket[p] ，这个没有参数的过程，它只会调用自己，形成无限递归。由于是尾递归，所以计算过程会被优化成常数空间的迭代，也就是通常所说的死循环（这部分内容正文后续部分即将会讲到）。因此，解释器陷入死循环，永远不能结束计算，除非强行停止。

解释器采用正则序求值时：

无需对第二个参数 @racket[(p)] 求值，解释器就能直接开始执行 @racket[test] 的过程体。于是对 @racket[(if (= 0 0) 0 (p))] 求值。注意题中明确指出 @tt{if} 的求值规则仍然是原样，于是对谓词 @italic{<predicate>} 先求值。在得到 @racket[#t] ，即真值之后，根据求值规则，解释器只会对 @italic{<consequent>} ，也就是 @racket[0] ，求值，而根本不会对 @italic{<alternative>} ，也就是 @racket[(p)] ，求值。因此，解释器不会陷入无限递归 / 循环，而能够正常求出并打印 @racket[0] 。

@; ----------------------------------------------------------------------

@section{练习 1.6}

@margin-note{原书在 4.2.1 节再次提到了这道练习 1.6。那一节里做出了一个类似的操作，定义了 @racket[unless] 过程，之后也进行了讲解。}

@bold{重点： @tt{if} 是特殊形式，而 @racket[new-if] 只是一个普通的过程。}

我们使用的 Scheme 解释器是采用应用序求值的，所以在对 @racket[(new-if a b c)] 求值时，解释器会先对 @racket[new-if] 、 @racket[a] 、 @racket[b] 和 @racket[c] 这四个表达式全都求值，然后再去执行 @racket[new-if] 的过程体。

而 @tt{if} 作为特殊形式，是有着它独特的求值规则的：对 @racket[(if a b c)] 求值时，解释器会先对 @racket[a] 求值，然后根据结果，选择对 @racket[b] 和 @racket[c] 中的其中一个求值。

在 @racket[sqrt-iter] 里，原本的 @tt{if} 中， @italic{<alternative>} 是一个（尾）递归调用。在谓词 @italic{<predicate>} 为真时，根据上面的规则，这个递归调用便不会被求值，从而使程序能够停止。使用 @racket[new-if] 替换 @tt{if} 之后，这个递归调用无论如何都会被求值，从而造成无限递归。此外，由于 @racket[new-if] 是一个普通的过程，所以这个递归调用不再是尾递归了，计算过程不能被强制优化成常数空间的迭代计算过程，因此解释器会消耗越来越多的内存空间，最终导致错误。

@; ----------------------------------------------------------------------

@section{练习 1.7}

为了获取两次猜测之间的“改变值”，对于一些过程我们要新增一个参数 @tt{previous-guess} ，记录上一次的猜测值。至于初始时的“上次猜测值”，这里设置成 @racket[2.0] 。设置成其他值也可以，只要和 @racket[1.0] 相差足够大，从而能够进入递归（循环）。

在 @racket[ratio-sqrt-iter] 中，进行（尾）递归调用时， @racket[guess] 成为下一轮的 @racket[previous-guess] ，而下一轮的 @racket[guess] 则由 @racket[improve] 过程计算得出。

@margin-note{下一节（1.1.8）指出，定义在全局的过程会占用名字，这个问题其实这里已经能感受到了：为了避免和正文里的过程重名，我们添加了一些“@tt{ratio-}”前缀。}

@ss-interaction[
(define (ratio-good-enough? previous-guess guess)
  (< (abs (/ (- guess previous-guess) guess)) 0.001))

(define (ratio-sqrt-iter previous-guess guess x)
  (if (ratio-good-enough? previous-guess guess)
      guess
      (ratio-sqrt-iter guess
                       (improve guess x)
                       x)))

(define (ratio-sqrt x)
  (ratio-sqrt-iter 2.0 1.0 x))

(ratio-sqrt 9)
(ratio-sqrt (+ 100 37))
(ratio-sqrt (+ (ratio-sqrt 2) (ratio-sqrt 3)))
(square (ratio-sqrt 1000))
]

@; ----------------------------------------------------------------------

@section{练习 1.8}

和正文中几乎一样，只有公式不同。反映在代码中，就是 @racket[cbrt-improve] 的过程体。

@ss-interaction[

(define (cube x)
  (* x x x))

(define (cbrt x)
  (cbrt-iter 1.0 x))

(define (cbrt-iter guess x)
  (if (cbrt-good-enough? guess x)
      guess
      (cbrt-iter (cbrt-improve guess x)
                 x)))

(define (cbrt-improve guess x)
  (/ (+ (/ x (square guess))
        (* 2 guess))
     3))

(define (cbrt-good-enough? guess x)
  (< (abs (- (cube guess) x)) 0.001))

(cbrt 8)
(cbrt 27)
(cbrt 2)
(cube (cbrt 2))
]

@; ----------------------------------------------------------------------

@section{练习 1.9}

TODO

@; ----------------------------------------------------------------------

@section{练习 1.10}

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
\begin{align}
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
\end{align}
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

@subsection{超运算入门}

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
\begin{align}
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
\end{align}
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

此表格在 OEIS 数列 @hyperlink["https://oeis.org/A143797"]{A143797} 中亦有记载。

@subsection{补充说明}

最后，通常所说的阿克曼函数 @${A(m, n)} 和这里的 @racket[A] 以及 @racket[A-alt] 函数（过程）其实也有一些小区别。具体地， @${A(m, n) = 2[m](n+3) - 3} 。可以自行查阅相关资料。

@; TODO 用代码自动生成上方的表格
