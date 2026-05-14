#lang scribble/manual

@title{补充的 Lisp 知识}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble-math
          "interaction.rkt")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{说明}

SICP 原书刻意避开了一些在实际使用 Lisp 时需要了解的知识。

此外，经过了几十年，人们使用 Lisp 时的习惯也在演化。

同时，本项目使用的 Racket 编程语言和 Scheme 有一些差异。

本页面会补充这些知识。

@; ----------------------------------------------------------------------

@section{数值精度问题}

Racket 和 Chez Scheme 都支持大整数类型，所以不必担心整数溢出等问题。例如，可以轻易计算出 @${2^{256}} 的值：

@ss-interaction[(expt 2 256)]

在 Racket 中，整数除法 @racket[(/ a b)] 的结果类型为有理数（或整数，如果分母为 1），不会进行浮点除法或整除。

@ss-interaction[(/ 6 10) (/ 6 2)]

根据 Scheme 标准 @hyperlink["https://ieeexplore.ieee.org/document/8960950"]{IEEE 1178-1990} ，符合标准的 Scheme 实现并不一定要支持大整数和有理数类型。Racket 和 Chez Scheme 对它们的支持，都属于扩展。

@; ----------------------------------------------------------------------

@section{方括号}

IEEE Scheme 标准是比较早的文献，没有规定方括号和花括号的用途，只说了将它们“保留，用于未来可能的语言扩展”（reserved for possible future extensions to the language），标准全文都只用圆括号写代码。同时代的 SICP，也是全书都使用圆括号写代码。

但现在在 Scheme 和 Racket 编程中，人们有时会使用方括号，例如：

@ss-interaction[
(define (fib n)
  (cond [(= n 0) 0]
        [(= n 1) 1]
        [else (+ (fib (- n 1))
                 (fib (- n 2)))]))
(map fib '(0 1 2 3 4 5 6))
]

事实上，在 Scheme 和 Racket 中，现在一般都将方括号和圆括号视为等价物，可以随意互换。（但至于 @tt{([)]} 这种诡异的结构还是算了吧。）这在其他 Lisp 方言中不一定成立，例如 Clojure 用方括号表示向量。

所以方括号一般要在什么地方用呢？

方括号一般在一些特殊形式里，标记会在一个表内多次出现的、本身长度固定的列表，它们一般都是子句。

也就是说，如果我们写代码时，一些代码因为语法规定会长成这样：

@verbatim{
((a-1 b-1)
 (a-2 b-2)
 ...
 (a-n b-n))
}

其中所有的 @tt{a-i} 都有着类似的功能，所有的 @tt{b-i} 都有着类似的功能，那么这时候用方括号就很合适了：

@verbatim{
([a-1 b-1]
 [a-2 b-2]
 ...
 [a-n b-n])
}

除了刚才的 @tt{cond} 之外，再举一个 @tt{let} 的例子：

@ss-interaction[
(let ([a 1]
      [b 2]
      [c 3])
  (+ a b c))
]

刚才的例子都是表长固定为 2 的情况。也有表长为 3 的情况，例如 @tt{do} 中描述各个变量更新的代码（下面这段示例代码来自 IEEE Scheme 标准，做了修改）：

@ss-interaction[
(define x '(1 3 5 7 9))
(do ([x x (cdr x)]
     [sum 0 (+ sum (car x))])
  ((null? x) sum))
]

@hyperlink["https://docs.racket-lang.org/guide/syntax-overview.html#(part._.Conditionals_with_if__and__or__and_cond)"]{Racket 官方文档对 @tt{cond} 的讲解} 中提到，这是一种惯例写法，这样做有助于提高可读性。

在 Racket 中，方括号还是比较常见的，会出现在包括但不限于：

@itemlist[@item{@hyperlink["https://docs.racket-lang.org/reference/if.html#(part._if)"]{条件} ： @tt{cond}}
          @item{@hyperlink["https://docs.racket-lang.org/reference/let.html#(part._let)"]{绑定} ： @tt{let} 及其变体}
          @item{@hyperlink["https://docs.racket-lang.org/reference/for.html#(part._.Do_.Loops)"]{循环} ： @tt{for} 和 @tt{do} 及它们的变体}
          @item{@hyperlink["https://docs.racket-lang.org/reference/case.html#(part._case)"]{分派} ： @tt{case} 及其变体}
          @item{@hyperlink["https://docs.racket-lang.org/reference/match.html#(part._match)"]{模式匹配} ： @tt{match} 及其变体}
          @item{@hyperlink["https://docs.racket-lang.org/guide/pattern-macros.html#(part._pattern-macros)"]{宏定义} ： @tt{define-syntax} 及其变体}]

这些特殊形式里。

@; ----------------------------------------------------------------------

@section{宏}

SICP 中没有涉及 Lisp 宏，只在 4.1.2 节中的一个脚注里提了一句。

应当指出，Lisp 最精髓的地方不是发明了 REPL，甚至也不是发明了 GC（垃圾回收），而是成为了一个“手写语法树”的语言，让代码和数据共享同一个表示方式。这样一来，就能够轻易编写出宏，使用代码对代码作出变换。 @bold{对普通数据（表）做处理、变换的代码，可以无缝地对代码做处理、变换。} 这是其他语言极难做到的，除非其他语言也将自己变成手写语法树的样子。Racket 社区的新项目 @hyperlink["https://rhombus-lang.org/"]{Rhombus 语言} 则在尝试另辟蹊径，在避免传统 Lisp 大量括号、使用一套更“正常”的语法的同时，保证语言的可扩展性。

自然，学习 SICP 并不需要理解宏，因为全书都没有使用过它。但在学习之余，也可以试着了解一下有关 Lisp 宏的知识。

第三章中，延迟求值的语法就可以使用宏实现。

@; ----------------------------------------------------------------------

@section{表，不适当表，表结构，空表，序对}

@subsection{不适当表}

在书中，我们知道解释器会将 @racket[(cons 1 (cons 2 (cons 3 '())))] 打印成 @tt{(1 2 3)} ，如下：

@ss-interaction[(cons 1 (cons 2 (cons 3 '())))]

但书中没有提到， @racket[(cons 1 (cons 2 3))] 会打印成什么样。事实上，会像这样打印：

@ss-interaction[(cons 1 (cons 2 3))]

可以看到，对于最后的那个序对，解释器将它的两个元素都打印出来，但中间会加上一个点号，表示“这个序对链没有以 @racket[nil] 结尾”。

像这样，对于一个序对，如果一直对其应用 @racket[cdr] 直至它不是序对，最后得到的结果却不是 @racket[nil] ，那么这样的对象称为“不适当表”（improper list）。原本就不是序对的对象，并不属于不适当表，空表 @racket[nil] 也是如此。

根据上述说法，我们可以写一个过程 @racket[improper-list?] 来检查一个对象是否是“不适当表”：

@ss-interaction[
(define (improper-list? x)
  (define (check p)
    (if (pair? p)
        (check (cdr p))
        (not (null? p))))
  (if (pair? x)
      (check x)
      false))
(map improper-list?
     (list (cons 1 (cons 2 '()))
           (cons 2 '())
           '()
           (cons 1 (cons 2 3))
           (cons 2 3)
           3))
]

利用 @racket[list?] 谓词， @racket[improper-list?] 可以实现得更简单：

@ss-interaction[
(define (improper-list? x)
  (and (pair? x) (not (list? x))))
(map improper-list?
     (list (cons 1 (cons 2 '()))
           (cons 2 '())
           '()
           (cons 1 (cons 2 3))
           (cons 2 3)
           3))
]

（上述代码并没有考虑循环列表。循环列表在原书练习题 3.13、3.18、3.19 中有提及，在本页中的 @secref["mutability of pair"] 部分也有讲解。）

可以发现，普通的序对也是不适当表，所以我们可以知道解释器是怎样打印一个普通序对的了：

@ss-interaction[(cons 1 2)]

对称地，我们也就有了一种不用 @racket[cons] 就表达一个序对或者不适当表的方式：

@ss-interaction['(1 . 2) '(1 2 . 3)]

（SICP 竟然在全书都避免了打印不适当表。）

@subsection{空表是表吗}

书中回避了对“ @racket[nil] 是不是表”的讨论，见原书 2.2.1 节脚注。但还是 2.2.1 节，另一个脚注说：“在这本书里，我们用术语 @italic{表} （@italic{list}）专指那些有表尾结束标记的序对的链。与此相对应，用术语 @italic{表结构} （@italic{list structure}）指所有的由序对构造起来的数据结构，而不仅是表。”

这句话说表是“序对的链”，所以一个对象想要是表的话似乎至少应该存在一个序对？所以 @racket[nil] 或者说 @racket['()] 就应该不是表了？但事实上，Lisp 程序员一般都会认可“空表也是一个表”这种说法，因为这样会有更好的性质。标准 Common Lisp、标准 Scheme 和 Emacs Lisp 等方言都是这样的。脚注里直接描述成了“序对的链”应该只是编者的疏忽，不必咬文嚼字。

在 Racket 里试一下：

@ss-interaction[(list? '())]

所以可以对“表结构”的定义做一个修正：空表 @racket[nil] 也认为是表结构。于是我们可以写一个过程 @racket[list-structure?] 判断一个对象是不是表结构：

@ss-interaction[
(define (list-structure? x)
  (or (null? x) (pair? x)))
(map list-structure?
     (list (cons 2 '())
           '()
           (cons 2 3)
           3))
]

我们还可以发现，这个修正过后的“表结构”其实刚好就是“适当表”和“不适当表”的合称。所以还能改写 @racket[list-structure?] ：

@ss-interaction[
(define (list-structure? x)
  (or (list? x) (improper-list? x)))
(map list-structure?
     (list (cons 2 '())
           '()
           (cons 2 3)
           3))
]

Reddit 上有一个帖子：“@hyperlink["https://www.reddit.com/r/lisp/comments/1gd2hrs/why_does_nil_have_to_be_both_an_atom_and_a_list/"]{Why does nil have to be both an atom and a list?}”上面的讨论值得一读。帖子里的楼主认为，空表是一个表却不是序对，有些奇怪。网友讲解为什么这是合理的。

（注意：这个版面不止会讨论 Scheme，还会讨论 Lisp 的其他方言，注意不同方言的不同之处。例如在 Common Lisp 中， @tt{nil} 是一个特殊符号，正如 2.1.1 节脚注所说。Common Lisp 还用 @tt{nil} 表示假值，它不能通过 @tt{if} 测试，而在 Scheme 中并非如此，诸如此类。）

此外，Racket 其实也用一个内置普通变量表示空表，但它叫 @racket[null] ，而非 @racket[nil] 。

@ss-interaction[null]

@subsection[#:tag "mutability of pair"]{序对的可变性}

TODO：循环表，以及不同实现的解释器如何打印它们；Racket 序对的不可变性以及 @racket[list?] 结果被缓存

TODO：把自己 Scheme 教程中的结论搬过来，重构

@; ----------------------------------------------------------------------

@section{关于 Scheme 语言标准}

IEEE 制定过 Scheme 语言标准 @hyperlink["https://standards.ieee.org/ieee/1178/1787/"]{IEEE 1178-1990} ，ISO 也制定过和 Scheme 有关的标准 @hyperlink["https://www.iso.org/standard/18196.html"]{ISO/IEC 10179:1996} （DSSSL）。但据 @hyperlink["https://standards.scheme.org/"]{Scheme 官方网站对这些正式标准的介绍} 所说，它们都基本只剩历史意义了。

@subsection{RnRS 系列标准}

Scheme 实现一般都倾向于参考 @hyperlink["http://www.scheme-reports.org/"]{RnRS 系列标准} 。这一系列标准还会与时俱进：目前（2026 年 5 月 14 日），最新版本是 @hyperlink["https://r7rs.org/"]{R7RS} ，并且分化成了 small 和 large 两个分支，后者仍在制定中。

1998 年的 R5RS 可以说是最广泛接受的标准。

王永刚对 R5RS 标准做了一个非官方的中文翻译（ @hyperlink["https://math.pku.edu.cn/teachers/qiuzy/progtech/scheme/r5rscn.pdf"]{算法语言 Scheme 修订⁵报告} ），得到了 SICP 译者裘宗燕的支持。

Scheme 官网上有 RnRS 标准各版本 PDF 文档与简单介绍，见本项目的 @hyperlink["./resources.html"]{学习资源} 页面。

@subsection{SRFI 扩展}

语言标准都很小（除了 R7RS 的 large 分支，可能还有 R6RS），所以只用标准 Scheme 编程解决实际问题其实不太方便，这是没法否认的。因此人们提出 @hyperlink["“https://srfi.schemers.org/"]{SRFI 项目} （全称 Scheme Requests for Implementation），以模块化的方式为 Scheme 添加实用扩展功能。

不同的 Scheme 实现对 SRFI 的支持程度也不同，支持较好的有 GNU Guile 和 Racket（其实后者的内置库往往比 SRFI 还强大）。
