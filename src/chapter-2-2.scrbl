#lang scribble/manual

@title{SICP 解题集 —— 2.2 层次性数据和闭包性质}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble-math
          "interaction.rkt")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{练习 2.17 | 表中的最后一个序对}

一个表只有一个元素，当且仅当它是一个序对，且其 @racket[cdr] 是 @racket[nil] 。此时 @racket[car] 就是这个元素。仿照书上的做法，我们写出如下递归步骤：

@itemlist[@item{对于只有一个元素的表，它本身就是结果。}
          @item{否则，返回这个表的 @racket[cdr] 的“最后一个序对”。}]

代码如下：

@ss-interaction[
(define (last-pair ls)
  (define (iter ls)
    (let ([rest (cdr ls)])
      (if (null? rest)
          ls
          (iter rest))))
  (if (null? ls)
      (error "Argument is empty list -- LAST-PAIR")
      (iter ls)))
(last-pair (list 23 72 149 34))
(last-pair (list 34))
(last-pair nil)
]

（原书 3.3.1 节也使用了这个 @racket[last-pair] 过程。）

@; ----------------------------------------------------------------------

@section{练习 2.18 | 反转一个表}

@ss-interaction[
(define (reverse ls)
  (define (iter source dest)
    (if (null? source)
        dest
        (iter (cdr source)
              (cons (car source) dest))))
  (iter ls nil))
(reverse (list 1 4 9 16 25))
(reverse (list 25))
(reverse nil)
]

不变量是： @racket[(append (reverse dest) source)] 总是和原列表 @racket[ls] 内容相同。

直观上， @racket[iter] 的每一步，都 @racket[source] 的首个元素取出，置于 @racket[dest] 的开头。以 @racket[ls] 内容为 @racket[(1 4 9 16 25)] 为例，每次调用 @racket[iter] 时， @racket[source] 和 @racket[dest] 的内容分别是：

@itemlist[@item{@racket[(1 4 9 16 25)] 和 @racket[()]；}
          @item{@racket[(4 9 16 25)] 和 @racket[(1)]；}
          @item{@racket[(9 16 25)] 和 @racket[(4 1)]；}
          @item{@racket[(16 25)] 和 @racket[(9 4 1)]；}
          @item{@racket[(25)] 和 @racket[(16 9 4 1)]；}
          @item{@racket[()] 和 @racket[(25 16 9 4 1)]；}]

最后返回了 @racket[dest] ，完成计算。
