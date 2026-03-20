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

SICP 书中刻意避开了一些在实际使用 Lisp 时需要了解的知识，这里进行补充。

@section{数值精度问题}

Racket 和 Chez Scheme 都支持大整数类型，所以不必担心整数溢出等问题。例如，可以轻易计算出 @${2^{256}} 的值：

@ss-interaction[(expt 2 256)]

在 Racket 中，整数除法 @racket[(/ a b)] 的结果类型为有理数（或整数，如果分母为 1），不会进行浮点除法或整除。

@ss-interaction[(/ 6 10) (/ 6 2)]

（根据 Scheme 标准 IEEE 1178-1990，符合标准的 Scheme 实现并不一定要支持大整数和有理数类型。）

@section{不适当表}

在书中，我们知道解释器会将 @racket[(cons 1 (cons 2 (cons 3 '())))] 打印成 @tt{(1 2 3)} ，如下：

@ss-interaction[(cons 1 (cons 2 (cons 3 '())))]

但书中没有提到， @racket[(cons 1 (cons 2 3))] 会打印成什么样。事实上，会像这样打印：

@ss-interaction[(cons 1 (cons 2 3))]

像这样，对于一个序对，如果递归应用 @racket[cdr] ，最后得到的却不是空表 @racket['()] ，这样的结构称为“不适当表”（improper list）。注意到普通的序对也是不适当表，所以我们可以知道解释器是怎样打印一个普通序对了。

@ss-interaction[(cons 1 2)]

（SICP 竟然在全书都避免了打印不适当表。）

@section{方括号}

SICP 全书都使用圆括号写代码，但 Lisp 代码中有时会使用方括号，例如：

@ss-interaction[
(define (fib n)
  (cond [(= n 0) 0]
        [(= n 1) 1]
        [else (+ (fib (- n 1))
                 (fib (- n 2)))]))
(map fib '(0 1 2 3 4 5 6))
]

事实上，方括号和圆括号是等价的，可以随意互换。（但至于 @tt{([)]} 这种诡异的结构还是算了吧。）

方括号标记着 @tt{cond} 和 @tt{let} 中，根据语法规定必须成对出现的东西。例如， @tt{cond} 中的每一个子句（条件-结果），或者 @tt{let} 中的每一对绑定（名字-值），就用方括号来标记：形如 @racket[(a b)] 的代码将会写成 @racket[[a b]] 。

在其他一些地方也会用，例如 @hyperlink["https://docs.racket-lang.org/guide/pattern-macros.html"]{基于模式匹配的宏} 中的每一个子句（模式-模板）。

@hyperlink["https://docs.racket-lang.org/guide/syntax-overview.html#(part._.Conditionals_with_if__and__or__and_cond)"]{Racket 官方文档对 @racket[cond] 的讲解} 中提到，这是一种惯例写法，这样做有助于提高可读性。

@section{宏}

SICP 中没有涉及 Lisp 宏，只在脚注 217（位于 4.1.2 节）里提了一句。

应当指出，Lisp 最精髓的地方不是发明了 REPL，甚至也不是发明了 GC（垃圾回收），而是成为了一个“手写语法树”的语言，让代码和数据共享同一个表示方式。这样一来，就能够轻易编写出宏，使用代码对代码作出变换。这是其他语言绝不可能做到的，除非其他语言也将自己变成手写语法树的样子。

自然，学习 SICP 并不需要理解宏，因为全书都没有使用过它。但在学习之余，也可以试着了解一下有关 Lisp 宏的知识。

第三章中，延迟求值的语法就可以使用宏实现。
