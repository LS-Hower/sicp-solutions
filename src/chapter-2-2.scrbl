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

@section{练习 2.17 | @racket[last-pair] ：表中的最后一个序对}

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

@section[#:tag "exercise 2.18"]{练习 2.18 | @racket[reverse] ：反转一个表}

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

@; ----------------------------------------------------------------------

@section{练习 2.19 | 让兑换零钱的程序更灵活}

书上的新版 @racket[cc] 过程如下：

@ss-interaction[
(define (cc amount coin-values)
  (cond ((= amount 0) 1)
        ((or (< amount 0) (no-more? coin-values)) 0)
        (else
         (+ (cc amount
                (except-first-denomination coin-values))
            (cc (- amount
                   (first-denomination coin-values))
                coin-values)))))
]

可以看到， @racket[no-more?] 其实就是判断货币类型表是否为空， @racket[first-denomination] 其实就是“选取表的第一项”，而 @racket[except-first-denomination] 就是“选取表中除去第一项之后剩下的所有项形成的子表”，三个操作分别对应 @racket[null?] 、 @racket[car] 和 @racket[cdr] 。

@ss-interaction[
(define (no-more? coin-values)
  (null? coin-values))
(define (first-denomination coin-values)
  (car coin-values))
(define (except-first-denomination coin-values)
  (cdr coin-values))
]

测试一下：

@ss-interaction[
(cc 100 (list 50 25 10 5 1))
]

对比一下 1.2.2 节时写的 @racket[cc] 过程。当时没有表这种数据结构，就只能将五种货币面值硬编码在 @racket[first-denomination] 过程里的 @tt{cond} 中，用一个整数变量 @racket[kinds-of-coins] 来表示考虑的硬币类型数，还要自己数出种类数的初始值 @racket[5] ，还要硬编码在 @racket[count-change] 过程的实现中。有了表，这个程序实现起来更自然、更优美了，代码可读性增强了，灵活性也大大增强了。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 2.20"]{练习 2.20 | 用带点尾部记法接收任意多个参数，以及 @racket[same-parity]}

@ss-interaction[
(define (boolean-equal? a b)
  (or (and a b)
      (and (not a) (not b))))

(define (filter take ls)
  (define (filtered sublist)
    (cond [(null? sublist) nil]
          [(take (car sublist))
           (cons (car sublist) (filtered (cdr sublist)))]
          [else (filtered (cdr sublist))]))
  (filtered ls))

(define (same-parity . ls)
  (let ([head-odd (odd? (car ls))])
    (filter (lambda (x)
              (boolean-equal? head-odd (odd? x)))
            ls)))

(same-parity 1 2 3 4 5 6 7)
(same-parity 2 3 4 5 6 7)
]

这里定义了 @racket[boolean-equal?] 过程判断两个布尔值是否相等，它利用了如下事实：两个布尔值相等，当且仅当两者都是真或者两者都是假。原书后面的章节会介绍足够通用的 @racket[equal?] 过程，它对于布尔值也能正确工作。Racket 还自带 @racket[boolean=?] 谓词，专门用于布尔值。

这里还定义了 @racket[filter] 过程，它取一个谓词 @racket[take] 和一个表 @racket[ls] ，返回一个表，包含的是 @racket[ls] 中所有满足谓词 @racket[take] 的项。不难感觉到，这个过程比较通用。它在原书正文中的稍后章节就会遇到，之后还会多次用到。

@; ----------------------------------------------------------------------

@section{练习 2.21 | 定义 @racket[square-list] 的两种方式}

@ss-interaction[
(define (square-list items)
  (if (null? items)
      nil
      (cons (square (car items))
            (square-list (cdr items)))))
(square-list (list 1 2 3 4 5))
(define (square-list items)
  (map square items))
(square-list (list 1 2 3 4 5))
]

正如正文中所说，使用 @racket[map] ，可以“将实现表变换的过程的实现，与如何提取表的元素以及组合结果的细节隔离开”。而在第一种实现中，“程序的递归结构将人的注意力吸引到对于表中逐个元素的处理上。”

@; ----------------------------------------------------------------------

@section{练习 2.22 | 尝试使用迭代计算过程产生表时遇到的问题}

如果要使用只需要常数额外空间的迭代计算过程，那么就一直只能去处理表的开头部分。

想象一下，在桌面上，面前有几百张纸叠放起来，形成纸堆。你需要将它们全都签上名，但是一次只准搬运一张纸（所以总是只能处理纸堆上最上面的部分），那么只能这样做：

@itemlist[@item{取出最靠上的那张纸；}
          @item{给这张纸签上名;}
          @item{将这张纸放在旁边（如果旁边已经有纸了，就叠放在它上方）；}
          @item{重复上述操作，直至面前没有纸了。}]

可以想到，原本位置靠上的纸，先被签上名，先被放在旁边，结果就位置靠下了。这就是为什么结果反转了。想要让结果重新正起来也很简单，那就是再完整搬运一次。这其实就对应了 @secref["exercise 2.18"] 中产生迭代计算过程的 @racket[reverse] 。

与之类似，在 @racket[items] 内容为 @racket[(1 2 3 4 5)] 的情况下， @racket[iter] 的各次调用中， @racket[things] 和 @racket[answer] 分别是：

@itemlist[@item{@racket[(1 2 3 4 5)] 和 @racket[()] ；}
          @item{@racket[(2 3 4 5)] 和 @racket[(1)] ；}
          @item{@racket[(3 4 5)] 和 @racket[(4 1)] ；}
          @item{@racket[(4 5)] 和 @racket[(9 4 1)] ；}
          @item{@racket[(5)] 和 @racket[(16 9 4 1)] ；}
          @item{@racket[()] 和 @racket[(25 16 9 4 1)] ；}]

我们知道，表 @racket[(25 16 9 4 1)] 是通过 @racket[(cons 25 (cons 16 (cons 9 (cons 4 (cons 1 nil)))))] 构造出来的。只把调用 @racket[cons] 时的两个参数交换位置，我们只能得到一个 @racket[(cons (cons (cons (cons (cons nil 1) 4) 9) 16) 25)] 。这甚至不是一个表。而且 @racket[25] 其实也是仍然在最外层。

解决起来其实也不难，刚才就已经说到了：用 @racket[reverse] 过程将结果表反转一下即可。 @racket[reverse] 的迭代计算过程版本在 @secref["exercise 2.18"] 实现了。由于“处理”和“反转”都是迭代计算过程版本，所需步数都是 @${\Theta (n)} （其中 @${n} 是表中项的个数），只需要常数额外空间，所以组合起来之后所需步数和额外空间还是这样的。

@; ----------------------------------------------------------------------

@section{练习 2.23 | @racket[for-each] ：对表中每个项应用一个过程}

实际上可以偷懒，用 @racket[map] 逃课，如下：

@ss-interaction[
(define (for-each proc ls)
  (map proc ls)
  true)
(for-each (lambda (x) (newline) (display x))
          (list 57 321 88))
]

用 @racket[map] 把过程应用于所有项，然后把整个结果表丢弃掉。

但注意：根据 IEEE Scheme 标准， @bold{内置的 @racket[map] 过程对表中各项应用 @racket[proc] 时，顺序是未指定的} ，而 @racket[for-each] 则一定是先对首项应用 @racket[proc] ，再对第二项应用 @racket[proc] ，以此类推。标准里甚至特意强调了它们在这方面的不同。

不过刚才的 @racket[for-each] 还是不会出什么问题，因为 @hyperlink["https://docs.racket-lang.org/reference/pairs.html#%28def._%28%28lib._racket%2Fprivate%2Fmap..rkt%29._map%29%29"]{Racket 内置的 @racket[map]} 还是保证了会顺序应用 @racket[proc] 。此外，书中自己就用递归造了一个一元 @racket[map] 出来，那样一个 @racket[map] 实现也能够保证顺序应用，所以上方的写法仍然可以接受。

不过，我们还是自己写一个使用（尾）递归的版本吧：

@ss-interaction[
(define (for-each proc ls)
  (cond [(null? ls) true]
        [else
         (proc (car ls))
         (for-each proc (cdr ls))]))

(for-each (lambda (x) (newline) (display x))
          (list 57 321 88))
]

这个版本还能产生迭代计算过程，而书中的 @racket[map] 实现并没有。

@; ----------------------------------------------------------------------

@section{练习 2.24 | 熟悉层次性结构}

@ss-interaction[(list 1 (list 2 (list 3 4)))]

始终记住：解释器打印一个表的方式是先打印一个左括号，再将各个元素逐个打印出来，再打印右括号。

盒子指针和树的图先欠着。

@; TODO

@; ----------------------------------------------------------------------

@section{练习 2.25 | 从嵌套列表中取元素}

以题中第一个表 @racket[(1 3 (5 7) 9)] 为例：

@itemlist[
  #:style 'ordered
  @item{应用 @racket[cdr] ，得到 @racket[(3 (5 7) 9)] ；}
  @item{应用 @racket[cdr] ，得到 @racket[((5 7) 9)] ；}
  @item{应用 @racket[car] ，得到 @racket[(5 7)] ；}
  @item{应用 @racket[cdr] ，得到 @racket[(7)] ；}
  @item{应用 @racket[car] ，得到 @racket[7] 。}
]

以下是对三个表的解答：

@ss-interaction[
(define ls1 (list 1 3 (list 5 7) 9))
(define ls2 (list (list 7)))
(define ls3 (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))
(cadr (caddr ls1))
(car (car ls2))
(cadr (cadr (cadr (cadr (cadr (cadr ls3))))))
]

注意，对 @racket[(1 (2 3))] 取 @racket[cdr] 之后只能得到 @racket[((2 3))] ，还需要再取一次 @racket[car] 才能得到 @racket[(2 3)] 。

@; ----------------------------------------------------------------------

@section{练习 2.26 | @racket[append] 、 @racket[cons] 和 @racket[list] 的不同}

逐个分析。

@itemlist[@item{@racket[append] 取两个表作为参数，将这两个表拼接后得到的新表返回出来。所以对于 @racket[(1 2 3)] 和 @racket[(4 5 6)] ，得到的将是表 @racket[(1 2 3 4 5 6)] 。}
          @item{@racket[cons] 如果后面那个参数是表，那么会返回一个表，其首项是前一个参数，而后面的项都是从原来那个表中得到的。也就是说，若 @racket[x] 会被打印成 @italic{<s>} ，而 @racket[y] 的内容是 @racket[(4 5 6)] ，那么 @racket[(cons x y)] 的结果将会打印成 @tt{(}@italic{<s>}@tt{ 4 5 6)} 。而我们知道 @italic{<s>} 就是 @racket[(1 2 3)] ，所以最终打印出来的就是 @racket[((1 2 3) 4 5 6)] 。}
          @item{@racket[list] 取了这两个参数，会返回一个新的表，这个表有两个项，一个会被打印成 @racket[(1 2 3)] ，一个会被打印成 @racket[(4 5 6)] 。回想一下，解释器如何打印一个表：先打印一个左括号“@tt{(}”，再将各个项逐个打印出来，再打印右括号“@tt{)}”。所以打印结果将是 @racket[((1 2 3) (4 5 6))] 。}]

用解释器来验证一下：

@ss-interaction[
(define x (list 1 2 3))
(define y (list 4 5 6))
(append x y)
(cons x y)
(list x y)
]

@; ----------------------------------------------------------------------

@section{练习 2.27 | @racket[deep-reverse] ：深反转}

与 @racket[reverse] 的不同之处是，在处理表中元素时，要看一眼元素本身是不是表（是不是序对）。如果是的话，要递归调用 @racket[deep-reverse] 变换一下。

@ss-interaction[
(define (deep-reverse ls)
  (define (iter source dest)
    (if (null? source)
        dest
        (let ([head (car source)]
              [tail (cdr source)])
          (let ([new-head
                 (if (pair? head)
                     (deep-reverse head)
                     head)])
            (iter tail (cons new-head dest))))))
  (iter ls nil))
(define x (list (list 1 2) (list 3 4)))
x
(reverse x)
(deep-reverse x)
]

也可以在 @racket[deep-reverse] 的入口处检查参数是否为表，不是的话直接返回。这样，在迭代过程中我们就能随意对每一个表项都调用 @racket[deep-reverse] 了。

@ss-interaction[
(define (deep-reverse x)
  (define (iter source dest)
    (if (null? source)
        dest
        (let ([head (car source)]
              [tail (cdr source)])
          (iter tail (cons (deep-reverse head) dest)))))
  (if (pair? x)
      (iter x nil)
      x))
(deep-reverse x)
]

但这样会使类似于 @racket[(deep-reverse 1)] 这样的调用也能不声不响地返回一个值 @racket[1] ，而我们没有把这样的参数拦下的机会。至于这是不是想要的行为，这就不好说了。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 2.28"]{练习 2.28 | @racket[fringe] ：取出树的全部叶子}

@ss-interaction[
(define (fold-right f default ls)
  (if (null? ls)
      default
      (f (car ls)
         (fold-right f default (cdr ls)))))
(define (fringe x)
  (cond [(null? x) nil]
        [(pair? x)
         (let ([fringes-of-subtrees (map fringe x)])
           (fold-right append nil fringes-of-subtrees))]
        [else (list x)]))
(define x (list (list 1 2) (list 3 nil (list 4 5 6))))
x
(fringe x)
]

@; 在有 2.38 之后，链接指向它

@racket[fringe] 的设计思路如下：

@itemlist[@item{若参数 @racket[x] 是一个空表，则直接返回空表。}
          @item{若参数 @racket[x] 是一个叶子而不是树，则直接返回一个表，它只有一项，就是 @racket[x] 本身。（虽然题上说 @racket[fringe] 接收的是表，但考虑这种情况之后会更加自然。）}
          @item{若参数 @racket[x] 是树，我们就先递归求出它所有子树的 @racket[fringe] ，把这些 @racket[fringe] 的结果表又装在一个表里，起名叫 @racket[fringes-of-subtrees] 。然后要将它们全都拼接起来。比如说， @racket[fringes-of-subtrees] 可能是 @racket[((1 2 3) (4 5 6) (7 8 9 10))] 。拼接之后就能得到 @racket[(1 2 3 4 5 6 7 8 9 10)] 。}]

那么，如何拼接呢？

这里定义了一个过程 @racket[fold-right] 。以 @racket[(fold-right f x (list a b c))] 为例，它的结果等同于 @racket[(f a (f b (f c x)))] 的结果。它也是相当通用的函数，随后在练习 2.38 附近也会出现。

有了 @racket[fold-right] 函数，我们用一个 @racket[(fold-right append nil fringes-of-subtrees)] ，就可以把多个 @racket[fringe] 的结果拼接起来了。

@; ----------------------------------------------------------------------

@section{练习 2.29 | 二叉活动体}

分为 (a) (b) (c) (d) 四小题。

这里先将书上的 @racket[make-mobile] 和 @racket[make-branch] 定义出来。

@ss-interaction[
(define (make-mobile left right)
  (list left right))
(define (make-branch length structure)
  (list length structure))
]

@subsection{小题 2.29 (a)}

从一个表中取出首项需要 @racket[car] ，第二项则是 @racket[cadr] 。注意这与用 @racket[cons] 时的不同。

@ss-interaction[
(define (left-branch m) (car m))
(define (right-branch m) (cadr m))
(define (branch-length b) (car b))
(define (branch-structure b) (cadr b))
]

@subsection{小题 2.29 (b)}

我们设计函数，它们能分别求出活动体、分支和结构的总重量。

@ss-interaction[
(define (simple-weight? x)
  (not (pair? x)))

(define (total-weight-mobile m)
  (+ (total-weight-branch (left-branch m))
     (total-weight-branch (right-branch m))))

(define (total-weight-branch b)
  (total-weight-structure (branch-structure b)))

(define (total-weight-structure s)
  (if (simple-weight? s)
      s
      (total-weight-mobile s)))
]

@itemlist[@item{求活动体的重量，依赖于求分支的重量。}
          @item{求分支的重量，依赖于求结构的重量。}
          @item{求结构的重量，依赖于求活动体的重量。}]

这并不会造成无限递归，因为我们目前并不会造出循环的数据结构。总会碰到基底情况：结构是一个简单重量。

题上要求求活动体重量的函数要叫 @racket[total-weight] ，我们就照做一下：

@ss-interaction[
(define (total-weight m)
  (total-weight-mobile m))
]

测试一下：

@ss-interaction[
(define m1 (make-mobile (make-branch 4 6)
                        (make-branch 3 8)))
(define m2 (make-mobile (make-branch 7 4)
                        (make-branch 2 m1)))
(define m3 (make-mobile (make-branch 7 5)
                        (make-branch 2 m1)))
(total-weight m1)
(total-weight m2)
(total-weight m3)
]

@; TODO 添加一个示意图

@subsection{小题 2.29 (c)}

一种直接的做法是按部就班地定义好各个函数：

@ss-interaction[
(define (torque-branch b)
  (* (total-weight-branch b)
     (branch-length b)))

(define (balanced-mobile? m)
  (and (balanced-branch? (left-branch m))
       (balanced-branch? (right-branch m))
       (= (torque-branch (left-branch m))
          (torque-branch (right-branch m)))))

(define (balanced-branch? b)
  (balanced-structure? (branch-structure b)))

(define (balanced-structure? s)
  (if (simple-weight? s)
      true
      (balanced-mobile? s)))

(map balanced-mobile? (list m1 m2 m3))
]

但这样其实导致了一些重复计算。在 @racket[balanced-mobile?] 过程中，我们先判断了两个分支上的结构是否平衡，而这作出的计算其实已经足以得到两个结构的总重量了（只差两个加法操作）。但我们没能使用这些计算结果，而是又调用了一遍 @racket[torque-branch] ，这需要重新对两个分支上的结构计算总重量。

要定量地分析这会怎样拖慢速度的话，我们考虑一个“满二叉活动体”（类比“满二叉树”） ，深度为 @${d} ，有 @${n} 个简单重量，则有 @${n \approx 2^d} 。设上述的算法处理深度为 @${\Theta(d)} 的满二叉活动体时所需时间为 @${T(d)} ，则有递归式 @${T(d) = 4T(d-1) + \Theta(1)} ，解得 @${T(d) = \Theta(4^d) = \Theta((2^d)^2) = \Theta(n^2)} 。而如果能够使用中间计算结果，则有 @${T'(d) = 2T(d-1) + \Theta(1)} ，解得 @${T'(d) = \Theta(n)} 。

也就是说，如果有 @${n} 个简单重量，那么优化前所需步数是 @${\Theta(n^2)} ，优化后只需 @${\Theta(n)} 步数。

我们来做一下这个优化：

@ss-interaction[

(define (torque-branch-with-weight b weight)
  (* weight
     (branch-length b)))

(define (make-stat weight balance)
  (list weight balance))

(define (weight-stat stat)
  (car stat))

(define (balance-stat stat)
  (cadr stat))

(define (stat-mobile m)
  (let ([lbranch (left-branch m)]
        [rbranch (right-branch m)])
    (let ([lstat (stat-branch lbranch)]
          [rstat (stat-branch rbranch)])
      (let ([lweight (weight-stat lstat)]
            [rweight (weight-stat rstat)]
            [lbalance (balance-stat lstat)]
            [rbalance (balance-stat rstat)])
        (make-stat (+ lweight rweight)
                   (and lbalance
                        rbalance
                        (= (torque-branch-with-weight lbranch lweight)
                           (torque-branch-with-weight rbranch rweight))))))))

(define (stat-branch b)
  (stat-structure (branch-structure b)))

(define (stat-structure s)
  (if (simple-weight? s)
      (make-stat s true)
      (stat-mobile s)))

(define (fast-balanced-mobile? m)
  (balance-stat (stat-mobile m)))

(map fast-balanced-mobile? (list m1 m2 m3))
]

我们将先前对活动体、分支和结构计算总重量的函数 @racket[total-weight-mobile] 、 @racket[total-weight-branch] 和 @racket[total-weight-structure] 作出改造，使它们不止返回总重量，还返回“这个东西是否平衡”。这两个信息打包在一起，称为“状态”对象，在代码中称为 @tt{stat} 。它有构造函数 @racket[make-stat] ，以及选择函数 @racket[weight-stat] 和 @racket[balance-stat] 。改造出来的函数称为 @racket[stat-mobile] 、 @racket[stat-branch] 和 @racket[stat-structure] 。有了 @racket[stat-mobile] ，我们对结果做一个 @racket[balance-stat] ，就能轻松解决问题了。

@subsection{小题 2.29 (d)}

得益于抽象屏障，有关活动体和分支如何的实现细节可以和程序中其他程序完全隔离开来，正如原书 2.1.2 节所说的那样。我们只需要更改它们的选择函数即可。获取活动体左分支和分支长度的选择函数刚好一个字都不用改；获取活动体右分支和分支上结构的选择函数则刚好只需要改一个字。将后者实现里的 @racket[cadr] 改成 @racket[cdr] 即可。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 2.30"]{练习 2.30 | @racket[square-tree] ：对树的平方映射}

依葫芦画瓢，模仿正文里的 @racket[scale-tree] 即可。

@ss-interaction[
(define tree-for-test (list 1
                            (list 2 (list 3 4) 5)
                            (list 6 7)))
(define (square-tree tree)
  (cond [(null? tree) nil]
        [(not (pair? tree)) (square tree)]
        [else (cons (square-tree (car tree))
                    (square-tree (cdr tree)))]))
(square-tree tree-for-test)
(define (square-tree tree)
  (map (lambda (sub-tree)
         (if (pair? sub-tree)
             (square-tree sub-tree)
             (square sub-tree)))
       tree))
(square-tree tree-for-test)
]

@; ----------------------------------------------------------------------

@section{练习 2.31 | @racket[tree-map] ：对树的一般映射}

甚至只是将 @secref["exercise 2.30"] 代码中的 @racket[square] 改成一般的 @racket[proc] 就可以了。

@ss-interaction[
(define (tree-map proc tree)
  (define (mapped tree)
    (map (lambda (sub-tree)
           (if (pair? sub-tree)
               (mapped sub-tree)
               (proc sub-tree)))
         tree))
  (mapped tree))
(define (square-tree tree) (tree-map square tree))
(square-tree tree-for-test)
]

@; ----------------------------------------------------------------------

@section{练习 2.32 | @racket[subsets] ：求集合的全部子集}

分为多个小节。

@subsection{@racket[subsets] 的代码}

@ss-interaction[
(define (subsets s)
  (if (null? s)
      (list nil)
      (let ((rest (subsets (cdr s))))
        (append rest (map (lambda (subset) (cons (car s) subset))
                          rest)))))
(subsets (list 1 2 3))
]

以 @racket[s] 为 @racket[(1 2 3)] 时为例，上述算法会先求出其 @racket[cdr] ，即 @racket[(2 3)] ，的全部子集，即 @racket[(() (3) (2) (2 3))] 。然后用 @racket[map] 给这 4 个表都添上 @racket[1]（它是刚才被遗弃的 @racket[(car s)] ），又得到了 4 个表 @racket[((1) (1 3) (1 2) (1 2 3))] 。用 @racket[append] 把前面那 4 个表和现在这个 4 表放在一个表里，就得到了 @racket[(() (3) (2) (2 3) (1) (1 3) (1 2) (1 2 3))] 。

@subsection{证明}

为了证明这个算法为什么正确，我们要先明白这个算法求的到底是什么。我们引入数学概念“幂集”（power set）。集合 @${S} 的幂集就是它的所有子集所组成的集合，记为 @${\mathcal{P}(S)} 。更正式的定义就是 @${\mathcal{P}(S) = \{ T \, | \, T \subseteq S \}} 。例如当 @${S = \{ 1, 2, 3 \}} 时，其幂集 @${\mathcal{P}(S) = \{ \{\}, \{3\}, \{2\}, \{2, 3\}, \{1\}, \{1, 3\}, \{1, 2\}, \{1, 2, 3\} \} } 。所以刚才这个算法就是一个求集合幂集的算法。

刚才构造性地求集合 @${S} 的幂集 @${\mathcal{P}(S)} 的算法，是做了分情况讨论：

@itemlist[@item{若 @${S = \varnothing} 是空集，则幂集 @${\mathcal{P}(S)} 显然是 @${\{\{\}\}} 。}
          @item{若 @${S} 不是空集，则我们随意找出它的一个成员 @${e} （在代码里选择了列表的首个元素，使用 @racket[car] ）。我们记 @${S'} 为 @${S} 除去 @${e} 这个元素所得到的集合，即 @${S' = S \setminus \{ e \} } ，然后递归一下算出它的幂集 @${\mathcal{P}(S')} 。这个算法断言：我们要求的幂集 @${\mathcal{P}(S) = \mathcal{P}(S') \cup \{ T' \cup \{ e \} \, | \, T' \in \mathcal{P}(S') \} } ，且其中出现的两个 @${\cup} 操作，它们都满足：左右两个集合不重叠（所以才用了 @racket[cons] 和 @racket[append] 来合并。）}]

两个 @${\cup} 左右不重叠是比较显然的，我们只证明一下为什么这个断言中的等式：

@$${\mathcal{P}(S) = \mathcal{P}(S') \cup \{ T' \cup \{ e \} \, | \, T' \in \mathcal{P}(S') \} }

是对的。我们将等式左侧称为 @${\text{LHS}} ，右边称为 @${\text{RHS}} 。我们要通过证明 @${\text{LHS} \subseteq \text{RHS}} 及 @${\text{LHS} \supseteq \text{RHS}} 来证明 @${\text{LHS} = \text{RHS}} 。

@itemlist[
  @item{
    先证 @${\text{LHS} \subseteq \text{RHS}} 。取任意 @${A \in \mathcal{P}(S)} ，即 @${A \subseteq S} ，有两种情况：
    @itemlist[
      @item{若 @${e \notin A} ，则 @${A \subseteq S'} ，则 @${A \in \mathcal{P}(S')} ，它属于 @${\text{RHS}} 中的 @${\cup} 的左边。}
      @item{若 @${e \in A} ，则我们定义 @${A' = A \setminus \{ e \} } ，则 @${A' \subseteq S'} ，即 @${A' \in \mathcal{P}(S')} 。而 @${A = A' \cup \{ e \} } ，故它属于 @${\text{RHS}} 中的 @${\cup} 的右边。}
    ]
  }
  @item{
    再证 @${\text{LHS} \supseteq \text{RHS}} 。这个 @${\text{RHS}} 可以以 @${\cup} 分隔，分为左边 @${\mathcal{P}(S')} 和右边 @${ \{ T' \cup \{ e \} \, | \, T' \in \mathcal{P}(S') \} } 。
    @itemlist[
      @item{对于左边，取任意 @${A \in \mathcal{P}(S')} ，则 @${A \subseteq S'} ，则 @${A \subseteq S} ，则 @${A \in \mathcal{P}(S)} 。}
      @item{对于右边，由于 @${T' \in \mathcal{P}(S')} ，故 @${T' \subseteq S'} ，则 @${T' \subseteq S} ，则 @${T' \cup \{ e \} \subseteq S} ，即 @${T' \cup \{ e \} \in \mathcal{P}(S)} 。}
    ]
  }
]

据此，我们证明了，对于非空集合，这个分治构造的定义确实和幂集的定义等价，这个等式是成立的。

@subsection{一个求全部组合的算法}

给定一个整数 @${k} ，和一个集合 @${S} ，它有 @${n} 个元素。从 @${S} 中取出 @${k} 个元素形成一个集合（所以这 @${k} 个元素的顺序是不重要的），我们在这里将其称为一个组合。例如，当 @${S = \{ 1, 2, 3, 4, 5 \} } 且 @${k = 3} 时， @${ \{ 1, 3, 4 \} } 就是一个组合。选出组合的总方法数称为组合数，记为 @${C_n^k} ，也记为 @${\dbinom{n}{k}} 。

我们可以实现一个 @racket[combinations] 函数，将 @${\dbinom{n}{k}} 个组合全部列出。代码如下：

@ss-interaction[
(define (combinations s k)
  (cond [(= k 0) (list nil)]
        [(= k (length s)) (list s)]
        [else
         (append (map (lambda (l)
                        (cons (car s) l))
                      (combinations (cdr s) (- k 1)))
                 (combinations (cdr s) k))]))
(combinations (list 1 2 3 4 5) 3)
]

这里的思想仍然是递归和分治。我们想要得到 @${S} 的所有 @${\dbinom{n}{k}} 种组合，只需分三种情况：

@itemlist[@item{若 @${k = 0} ，则只有一种选择方法，就是什么都不选，结果显然是 @${\{\{\}\}} 。}
          @item{若 @${k = n} ，则还是只有一种选择方法，就是把 @${S} 的所有元素全都选上，结果显然是 @${\{ S \}} 。}
          @item{否则，我们随意找出 @${S} 的一个成员 @${e} （在代码里选择了列表的首个元素，使用 @racket[car] ）。我们记 @${S'} 为 @${S} 除去 @${e} 这个元素所得到的集合，即 @${S' = S \setminus \{ e \} } 。我们先求出在 @${S'} 中取 @${k-1} 个元素形成组合的所有方式，然后给它们都添上 @${e} 。我们还求出在 @${S'} 中取 @${k} 个元素形成组合的所有方式。把它们放在一起，就是结果。}]

直观上，我们如果关注着集合 @${S} 中的一个元素 @${e} ，现在又要从这个集合中取 @${k} 个元素作为一个组合，那么这个 @${e} 要么在组合里，要么不在组合里。如果在的话，我们就只用考虑在剩下的 @${n-1} 的元素里怎么选出 @${k-1} 个，最后只需把这个 @${e} 加回来即可；如果不在的话，我们就只用考虑在剩下的 @${n-1} 个元素里怎么选出 @${k} 个，最后甚至也不用添回来。

@subsection{一个只求组合数的算法：对组合数递推公式的证明}

如果我们不关注具体的方法，而只关注方法数，那么代码可以简化。我们可以得到 @racket[combination-count] 过程，它只给出在有 @${n} 个元素的集合中取出 @${k} 个元素形成组合的方法总数，也就是 @${\dbinom{n}{k}} ：

@ss-interaction[
(define (combination-count n k)
  (cond [(= k 0) 1]
        [(= k n) 1]
        [else
         (+ (combination-count (- n 1) (- k 1))
            (combination-count (- n 1) k))]))
(combination-count 5 3)
]

我们无需再将 @racket[s] 的具体内容传进去，只需要传入元素个数 @racket[n] ；在 @racket[k] 等于 @racket[0] 或者 @racket[n] 时，原本的“列出这一个方法”改成了“给出 @racket[1] ”；原本的 @racket[(cdr s)] 变成了 @racket[(- n 1)] ；原本对具体方法的列表的 @racket[append] 变成了对方法数量的 @racket[+] 。

可以发现，代码里其实出现了组合数著名的递推公式：

@$${\dbinom{n}{k} = \dbinom{n-1}{k-1} + \dbinom{n-1}{k}}

而事实上，刚才的思路确实构成对这个公式的证明。

@subsection{一个只求子集个数的算法：对子集个数公式的证明}

如果将类似的想法套在求幂集的算法上，我们能得到什么呢？

@ss-interaction[
(define (subset-count n)
  (if (= n 0)
      1
      (* 2 (subset-count (- n 1)))))
(subset-count 5)
]

空集只有 @${1} 个子集。而有 @${n} 个元素的集合，它的子集个数，是有 @${n-1} 个元素的集合的子集个数的 @${2} 倍。从上述的前提出发，用数学归纳法，就能轻松证明： @bold{有 @${n} 个元素的集合，其子集个数为 @${2^n} 。}

@subsection{为什么生成的结果顺序很“自然”}

我们观察 @racket[(subsets (list 1 2 3))] 的结果，它是一个表，8 个元素分别是：

@verbatim{
(     )
(    3)
(  2  )
(  2 3)
(1    )
(1   3)
(1 2  )
(1 2 3)
}

可以发现，这和 3 位二进制数计数时的样子是一样的：

@verbatim{
0 0 0
0 0 1
0 1 0
0 1 1
1 0 0
1 0 1
1 1 0
1 1 1
}

这是因为，对于首个元素 @racket[(car s)] ，我们先让它不出现在各个结果的开头，再让它出现在各个结果的开头，前者比后者先在最终的答案里出现。这是代码中的逻辑。所以，如果对于有 n-1 个元素的列表， @racket[subsets] 生成的结果是有着二进制计数的样子的，那么对于有 n 个元素的列表， @racket[subsets] 生成的结果也将是有着二进制计数的样子的。而对于 1 个元素的列表，结果显然也是如此。（0 个元素时的情况也符合。）由数学归纳法，我们就知道， @racket[subsets] 生成的结果，确实一定有着二进制计数的样子。

而对于 @racket[combinations] 函数，我们看到它的结果：

@ss-interaction[(combinations (list 1 2 3 4 5) 3)]

刚好是按照字典序排列的，只要原本的列表已经有序了。证明方法和刚才差不多，对于首个元素 @racket[(car s)] ，我们先让它出现在某些结果的开头，再让它不出现在其他一些结果中，前者比后者先在最终的答案里出现。

@racket[combinations] 函数并不基于比较，而是基于位置。即使传入的列表不是有序的，结果列表中的结果在映射到它们在原列表中的位置之后，结果列表也构成从小到大的字典序。

@; ----------------------------------------------------------------------

@section{练习 2.33 | 基本的表操作也可以用 @racket[accumulate] 表达}

我们需要更清晰地了解一下这个 @racket[accumulate] 。比如 @racket[(accumulate f init (list 1 2 3 4))] 计算的是 @racket[(f 1 (f 2 (f 3 (f 4 init))))] ，以此类推。所以，当 @racket[f] 是 @racket[cons] 且 @racket[init] 是 @racket[nil] 时，它就会返回表，而且内容仍是 @racket[(1 2 3 4)] 。

对于 @racket[map] ，我们让 @racket[cons] 仍然能生成序对，但是会把第一操作数修改一下，用 @racket[p] 修改，这样结果的表的每一项就都是用 @racket[p] 映射过的了。

@ss-interaction[
(define (map p sequence)
  (accumulate (lambda (x y) (cons (p x) y)) nil sequence))
(map square (list 1 2 3 4 5))
]

对于 @racket[append] ，我们把 @racket[nil] 换成 @racket[seq2] ，这样就把 @racket[seq2] 接到 @racket[seq1] 的后面了。

@ss-interaction[
(define (append seq1 seq2)
  (accumulate cons seq2 seq1))
(append (list 1 2 3 4 5) (list 6 7 8 9 10))
]

对于 @racket[length] ，我们只需利用一个如下事实： @racket[p] 被调用的次数刚好和列表长度相等。我们也并不需要读取列表中各项的内容。

@ss-interaction[
(define (length sequence)
  (accumulate (lambda (x y) (+ 1 y)) 0 sequence))
(length (list 6 7 8 9 10))
]

@; ----------------------------------------------------------------------

@section{练习 2.34 | @racket[horner-eval] ：线性步数求多项式值}

@ss-interaction[
(define (horner-eval x coefficient-sequence)
  (accumulate (lambda (this-coeff higher-terms) (+ this-coeff (* x higher-terms)))
              0
              coefficient-sequence))
(horner-eval 2 (list 1 3 0 5 0 1))
]

其实不用 @racket[accumulate] 而是手写递归也比较有意思：

@ss-interaction[
(define (horner-eval x coefficient-sequence)
  (if (null? coefficient-sequence)
      0
      (+ (car coefficient-sequence)
         (* x (horner-eval x (cdr coefficient-sequence))))))
(horner-eval 2 (list 1 3 0 5 0 1))
]

意思是：

@$${
  \begin{align*}
  a_0 + a_1 x + a_2 x^2 + \cdots + a_n x^n &= a_0 + x (a_1 + a_2 x + \cdots + a_n x^{n-1})  \\
                                           &= a_0 + x (b_0 + b_1 x + \cdots + b_{n-1} x^{n-1})
  \end{align*}
}

上边的都产生递归计算过程，下面写一个迭代计算过程的：

@ss-interaction[
(define (horner-eval x coefficient-sequence)
  (define (iter result rest-coefficient)
    (if (null? rest-coefficient)
        result
        (iter (+ (* x result) (car rest-coefficient))
              (cdr rest-coefficient))))
  (iter 0 (reverse coefficient-sequence)))
(horner-eval 2 (list 1 3 0 5 0 1))
]

不变量是：每次调用 @racket[(iter result ls)] 时，都满足

@itemlist[@item{@racket[ls] 所表示的多项式（这里和题中的相反，首项是最高次系数，最后一项是 0 次系数）在 @racket[x] 处的值，以及}
          @item{@racket[result] 与 @${x^n} 之积（其中 @racket[n] 是 @racket[ls] 中项的数量）}]

之和不变，而且等于最终要计算出的值。这样一来，原本的系数列表中， @${n} 次项系数刚好会与 @racket[x] 相乘 @${n} 次。

上边的版本使用了 @racket[reverse] 。 @racket[reverse] 可以实现成产生迭代过程的版本，所以上述算法只需常数额外空间。

再写一个不需要 @racket[reverse] 的版本：

@ss-interaction[
(define (horner-eval x coefficient-sequence)
  (define (iter result i x-power rest-coefficient)
    (if (null? rest-coefficient)
        result
        (iter (+ result (* x-power (car rest-coefficient)))
              (+ i 1)
              (* x x-power)
              (cdr rest-coefficient))))
  (iter 0 0 1 coefficient-sequence))
(horner-eval 2 (list 1 3 0 5 0 1))
]

不变量是：每次调用 @racket[(iter result x-power ls)] 时，都满足 @racket[x-power] 等于 @${x^i} ，以及

@itemlist[@item{@racket[ls] 所表示的多项式（这里和题中的不一样，首项是 @${i} 次系数，最后一项是最高次系数）在 @racket[x] 处的值，以及}
          @item{@racket[result]}]

之和不变，而且等于最终要计算出的值。

这里显式地将 @racket[i] 作为参数，只是为了方便描述不变量。这个参数其实是多余的，可以去掉。

上述算法也只需常数额外空间。

书中也提到：“这一规则是 W@._ G@._ Horner 在 19 世纪早期提出的，但这一方法在 100 多年前就已经被牛顿实际使用了。”但这个算法的历史远不止于此。它还有一个名字叫秦九韶算法。

中文维基百科上的 @hyperlink["https://zh.wikipedia.org/wiki/%E7%A7%A6%E4%B9%9D%E9%9F%B6%E7%AE%97%E6%B3%95#%E5%8E%86%E5%8F%B2"]{秦九韶算法#历史} 列出了一些比 Horner 更早的发现者：

@itemlist[@item{1809年，保罗·鲁菲尼}
          @item{1669年，艾萨克·牛顿（但缺乏详细引文）}
          @item{14世纪，中国数学家朱世杰}
          @item{13世纪，中国数学家秦九韶在《数书九章》中}
          @item{12世纪，波斯的伊斯兰数学家萨拉夫·丁·图西}
          @item{11世纪（宋朝），中国数学家贾宪}
          @item{汉朝（公元前202到公元220年），刘徽所注的《九章算术》中}]

（其中最后一条所引用的参考资料可能不可靠。）

（复制时间：2026-04-23）

@; ----------------------------------------------------------------------

@section{练习 2.35 | 用 @racket[accumulate] 重新定义 @racket[count-leaves]}

和 @secref["exercise 2.28"] 相似。其实在那里，我们定义的 @racket[fold-right] 和 @racket[accumulate] 就是同一个东西。练习 2.38 也有提到。

@; 在有 2.38 之后，链接指向它

与之不同的是，我们将使用 @racket[+] 和 @racket[0] 而非 @racket[cons] 和 @racket[nil] ，因为在这里我们不需要用表把叶子们的实际内容记下来，而是只需要记长度。

@ss-interaction[
(define (count-leaves x)
  (cond [(null? x) 0]
        [(pair? x)
         (let ([leaf-counts-of-subtrees (map count-leaves x)])
           (accumulate + 0 leaf-counts-of-subtrees))]
        [else 1]))
(define x (list (list 1 2) (list 3 nil (list 4 5 6))))
x
(count-leaves x)
]

@; ----------------------------------------------------------------------

@section{练习 2.36 | @racket[accumulate-n] ：差不多是个可变参数版本 @racket[accumulate]}

分为多个小节。

@subsection{@racket[accumulate-n] 的代码}

@ss-interaction[
(define (accumulate-n op init seqs)
  (if (null? (car seqs))
      nil
      (cons (accumulate op init (map car seqs))
            (accumulate-n op init (map cdr seqs)))))
(define data (list (list 1 2 3) (list 4 5 6) (list 7 8 9) (list 10 11 12)))
(accumulate-n + 0 data)
(accumulate-n cons nil data)
]

注意到 @racket[(accumulate-n cons nil data)] 会让 @racket[data] 的行变成列、列变成行，就像矩阵转置一样。紧接着的 @secref["exercise 2.37"] 就要我们实现矩阵转置操作 @racket[transpose] ，方法其实就是这样。在那里也有更详细的讲解。

@subsection{为什么并非真正的变参 @racket[accumulate]}

需要注意的是，例如生成 @racket[22] ， @racket[accumulate-n] 并不是通过计算 @racket[(+ 1 4 7 10)] 生成的，而是做了相当于 @racket[(accumulate + 0 (list 1 4 7 10))] ，也就是 @racket[(+ 1 (+ 4 (+ 7 (+ 10 0))))] 的计算。要想拿着 @racket[(list 1 4 7 10)] 计算 @racket[(+ 1 4 7 10)] ，需要使用后面章节所使用的 @racket[apply] 函数（见 2.4.3 节中的脚注）。简单地说， @racket[apply] 接收两个参数 @racket[f] 和 @racket[ls] ，它将 @racket[ls] 的内容作为参数，来应用 @racket[f] 这个过程：

@ss-interaction[
(apply + (list 1 4 7 10))
(define (average-3 a b c)
  (/ (+ a b c) 3))
(average-3 2 5 5)
(apply average-3 (list 2 5 5))
]

因此，即使使用 @secref["exercise 2.20"] 这道练习题所提到的带点尾部记法让传入的多个序列能够直接写出而不需要手动包装进一个 @racket[list] 里，我们仍然不能说 @racket[accumulate-n] 就是 @racket[accumulate] 的一种变参版本，至少不能说它相对于 @racket[accumulate] 就像 Scheme 标准中的通用 @racket[map] 相对于书中使用的一元 @racket[map] 那样（见原书 2.2.1 节的脚注）。

@subsection{@racket[variadic-accumulate] ：真正的变参 @racket[accumulate]}

如果可以使用 @racket[apply] ，我们就能定义出真正的变参版本 @racket[accumulate] 了。

这里需要补充一点， @racket[apply] 还有扩展，这是书上没有提到的。在 @racket[f] 和 @racket[ls] 两个参数之间还可以插入任意多个参数，它们将成为 @racket[ls] 的开头。例如：

@ss-interaction[
(apply + (list 1 4 7 10))
(apply + 1 4 (list 7 10))
]

这两个调用的效果相同。这个扩展也是 IEEE Scheme 标准中就有的。

这个扩展主要是让我们实现起来更容易一些。

@ss-interaction[
(define (variadic-accumulate f init . seqs)
  (if (null? (car seqs))
      init
      (apply f (append (map car seqs)
                       (list (apply variadic-accumulate
                                    f init (map cdr seqs)))))))

(variadic-accumulate
 (lambda (a b result)
   (* result (- a b)))
 1
 (list 1 2 3)
 (list 4 5 6))
]

事实上，这个 @racket[variadic-accumulate] 的用法，就和 Racket 自带的 @hyperlink["https://docs.racket-lang.org/reference/pairs.html#%28def._%28%28lib._racket%2Fprivate%2Flist..rkt%29._foldr%29%29"]{@racket[foldr]} 一样了。

@subsection{随手写个变参 @racket[map]}

变参 @racket[map] 使用了一个 @racket[map1] ，后者就是书中使用的一元 @racket[map] 。当然，它在变参 @racket[map] 的实现中并不是必要的。

@ss-interaction[
(define (map1 f ls)
  (if (null? ls)
      nil
      (cons (f (car ls))
            (map1 f (cdr ls)))))
(define (map f . seqs)
  (if (null? (car seqs))
      nil
      (cons (apply f (map1 car seqs))
            (apply map f (map1 cdr seqs)))))
(map + (list 1 2 3) (list 40 50 60) (list 700 800 900))
]

此外，这也方便了下一题 @secref["exercise 2.37"] 中 @racket[dot-product] 的实现。

@; ----------------------------------------------------------------------

@section[#:tag "exercise 2.37"]{练习 2.37 | 矩阵与向量操作}

先定义一些测试数据：

@ss-interaction[
(define v (list 1 2 3))
(define w (list 4 5 6))
(define A
  (list (list 1 2 3 4)
        (list 5 6 7 8)))
(define B
  (list (list 1 2 3)
        (list 4 5 6)
        (list 7 8 9)
        (list 10 11 12)))
]

@${n} 维向量 @${v} 与 @${n} 维向量 @${w} 做点积，会得到一个数。计算方法其实就是：将两个向量中位置相同的数相乘，再将得到的 @${n} 个积相加。也就是说，

@$${
  \begin{bmatrix}
    v_1 \\ v_2 \\ \vdots \\ v_n
  \end{bmatrix}
  \cdot
  \begin{bmatrix}
    w_1 \\ w_2 \\ \vdots \\ w_n
  \end{bmatrix}
  =
  v_1 w_1 + v_2 w_2 + \cdots + v_n w_n
}

下文中的向量点乘可能会接收到行向量，此时将其转置变成列向量即可。

因此可以用变参版本 @racket[map] 和 @racket[accumulate] 实现点积操作：

@ss-interaction[
(define (dot-product v w)
  (accumulate + 0 (map * v w)))
v
w
(dot-product v w)
]

@${m \times n} 矩阵 @${A} 与一个 @${n} 维列向量 @${v} 相乘，会得到一个 @${m} 维向量。计算方法其实就是：将矩阵的 @${m} 个行都作为向量看待，并让它们各自和 @${v} 做点积，得到的 @${m} 个数组成 @${m} 维向量，这就是结果。也就是说，

@$${
  \begin{bmatrix}
    A_{1*} \\ A_{2*} \\ \vdots \\ A_{m*}
  \end{bmatrix}
  \cdot v =
  \begin{bmatrix}
    A_{1*} \cdot v  \\
    A_{2*} \cdot v  \\
    \vdots          \\
    A_{m*} \cdot v
  \end{bmatrix}
}

在这里， @${A} 的第 @${i} 行记为 @${A_{i*}} 。

因此可以用 @racket[map] 配合 @racket[dot-product] 实现矩阵与向量的乘法：

@ss-interaction[
(define (matrix-*-vector m v)
  (map (lambda (row) (dot-product row v)) m))
B
v
(matrix-*-vector B v)
]

矩阵转置将矩阵的行变成列，列变成行。 @racket[accumulate-n] 会先对各个行的首个元素做 @racket[accumulate] ，再对各个行的第二个元素做 @racket[accumulate] ……最后将结果做成一个表返回。如果将“各个行的首个元素”组合成表，这个表的内容就是原矩阵的第一列了，以此类推。因此可以用 @racket[accumulate-n] ，传入 @racket[cons] 和 @racket[nil] ，实现矩阵转置操作。

@ss-interaction[
(define (transpose mat)
  (accumulate-n cons nil mat))
B
(transpose B)
]

@${m \times n} 矩阵 @${A} 与一个 @${n \times k} 矩阵 @${B} 相乘，会得到一个 @${m \times k} 矩阵。计算方法其实就是：将 @${A} 的 @${m} 个行与 @${B} 的 @${k} 个列分别做点积，第 @${i} 个行与第 @${j} 个列的点积就是结果矩阵中第 @${i} 行第 @${j} 列的数。也就是说，

@$${
  \begin{bmatrix}
    A_{1*} \\ A_{2*} \\ \vdots \\ A_{m*}
  \end{bmatrix}
  \cdot
  \begin{bmatrix}
    B_{*1} & B_{*2} & \cdots & B_{*k}
  \end{bmatrix}
  =
  \begin{bmatrix}
    A_{1*} \cdot B_{*1} & A_{1*} \cdot B_{*2} & \cdots & A_{1*} \cdot B_{*k}  \\
    A_{2*} \cdot B_{*1} & A_{2*} \cdot B_{*2} & \cdots & A_{2*} \cdot B_{*k}  \\
           \vdots       &        \vdots       & \ddots &        \vdots        \\
    A_{m*} \cdot B_{*1} & A_{m*} \cdot B_{*2} & \cdots & A_{m*} \cdot B_{*k}
  \end{bmatrix}
}

我们发现，结果矩阵的第 @${i} 行其实可以表示成 @${B} 的转置 @${B^{\mathrm{T}}} 与 @${A} 的第 @${i} 行做点积：

@$${
  B^{\mathrm{T}} \cdot A_{i*}
  =
  \begin{bmatrix}
    {B_{*1}}^{\mathrm{T}} \\ {B_{*2}}^{\mathrm{T}} \\ \vdots \\ {B_{*k}}^{\mathrm{T}}
  \end{bmatrix}
  \cdot
  A_{i*}
  =
  \begin{bmatrix}
    A_{i*} \cdot B_{*1} & A_{i*} \cdot B_{*2} & \cdots & A_{i*} \cdot B_{*k}
  \end{bmatrix}
}

所以矩阵乘法的结果可以重写一下：

@$${
  \begin{bmatrix}
    A_{1*} \cdot B_{*1} & A_{1*} \cdot B_{*2} & \cdots & A_{1*} \cdot B_{*k}  \\
    A_{2*} \cdot B_{*1} & A_{2*} \cdot B_{*2} & \cdots & A_{2*} \cdot B_{*k}  \\
           \vdots       &        \vdots       & \ddots &        \vdots        \\
    A_{m*} \cdot B_{*1} & A_{m*} \cdot B_{*2} & \cdots & A_{m*} \cdot B_{*k}
  \end{bmatrix}
  =
  \begin{bmatrix}
    B^{\mathrm{T}} \cdot A_{1*}  \\
    B^{\mathrm{T}} \cdot A_{2*}  \\
                   \vdots        \\
    B^{\mathrm{T}} \cdot A_{k*}  \\
  \end{bmatrix}
}

因此可以用 @racket[transpose] 、 @racket[map] 和 @racket[matrix-*-vector] 实现矩阵相乘操作：

@ss-interaction[
(define (matrix-*-matrix m n)
  (let ((cols (transpose n)))
    (map (lambda (row) (matrix-*-vector cols row)) m)))
A
B
(matrix-*-matrix A B)
]
