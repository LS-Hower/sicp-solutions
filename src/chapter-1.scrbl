#lang scribble/doc

@title{SICP 解题集 —— 第 1 章 构造过程抽象}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble/manual
          "interaction.ss")

@; ----------------------------------------------------------------------

更新日期：2026-03-10

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

