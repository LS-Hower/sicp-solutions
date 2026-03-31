#lang scribble/manual

@title{SICP 解题集 —— 2.1 数据抽象导引}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble-math
          "interaction.rkt")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section[#:tag "exercise 2.1"]{练习 2.1 | 有理数的正规化}

@ss-interaction[
(define (make-rat n d)
  (let ([g (gcd (abs n) (abs d))])
    (let ([n1 (/ n g)]
          [d1 (/ d g)])
      (if (< d1 0)
          (cons (- n1) (- d1))
          (cons n1 d1)))))
(print-rat (add-rat one-third one-third))
(print-rat (make-rat 6 (- 8)))
]

这里使用了 Racket 自带的 @racket[gcd] 过程。它其实能够正确处理负数，调用 @racket[(gcd x y)] 就和调用 @racket[(gcd (abs x) (abs y))] 一样。但我们这里还是显式地调用了两次 @racket[abs] 。

@; ----------------------------------------------------------------------

@section{练习 2.2 | 线段的表示}

我们将始点和终点放入一个序对来表示一条线段。

@ss-interaction[
(define (make-point x y) (cons x y))
(define (x-point p) (car p))
(define (y-point p) (cdr p))
(define (make-segment start end) (cons start end))
(define (start-segment s) (car s))
(define (end-segment s) (cdr s))
(define (print-point p)
  (newline)
  (display "(")
  (display (x-point p))
  (display ",")
  (display (y-point p))
  (display ")"))
(define (midpoint-segment s)
  (let ([start (start-segment s)]
        [end (end-segment s)])
    (let ([x0 (x-point start)]
          [y0 (y-point start)]
          [x1 (x-point end)]
          [y1 (y-point end)])
      (make-point (average x0 x1)
                  (average y0 y1)))))
(define source (make-point 3 6))
(define destination (make-point 5 10))
(print-point source)
(print-point destination)
(print-point (midpoint-segment (make-segment source destination)))
]

@; ----------------------------------------------------------------------

@section{练习 2.3 | 平面矩形的表示}

这道题需要我们设计两种不同的表示方式。

@itemlist[
  #:style 'ordered
  @item{底高表示法：用一条有向线段 @${\overrightarrow{AB}} 以及一个长度 @${h} 表示。解释方式：若过点 @${A} 作直线 @${l} 垂直于 @${\overrightarrow{AB}} ，且在 @${l} 上、 @${\overrightarrow{AB}} 的左侧作点 @${C} 使得 @${AC} 长度为 @${h} ，则这个点 @${C} 就是矩形的第三个点。如果 @${h} 是负数，则点 @${C} 要作在右侧，使 @${AC} 长度为 @${-h} 。（“点 @${C} 在 @${\overrightarrow{AB}} 的左侧”的意思是，若将点 @${B} 绕点 @${A} 顺时针旋转 @${90^\circ} 得到 @${B'} ，则点 @${A} 将位于点 @${C} 和点 @${B'} 之间。）}
  @item{长宽表示法：用一个点 @${B} 、两个长度 @${x, \, y} 以及一个角度 @${\alpha} 表示。解释方式：相对于点 @${B} ，若将横坐标增加了 @${x} 的点设为点 @${A} ，纵坐标增加了 @${y} 的点设为点 @${C} ，横、纵坐标分别增加了 @${x} 和 @${y} 的点设为点 @${D} ，则将矩形 @${ABCD} 绕点 @${B} 逆时针旋转 @${\alpha} 弧度后即可得到该平面矩形。}
]

示意图先欠着。

@; TODO

这道题还要求我们设计出通用的操作过程。我们需要一种手段来识别不同版本的表示方式。一种简单的方法是添加一个“版本号”数据。如果 @racket[data] 使用“底高表示法”表示矩形，那么我们将其存储成 @racket[(cons 1 data)] ；对于“长宽表示法”，则是 @racket[(cons 2 data)] 。

定义一下各自的构造函数和选择函数。

@ss-interaction[
(define (make-rect-1 base-segment height)
  (cons 1 (cons base-segment height)))
(define (base-segment-rect-1 r)
  (car (cdr r)))
(define (height-rect-1 r)
  (cdr (cdr r)))

(define (make-rect-2 origin base height alpha)
  (cons 2 (cons origin
                (cons (cons base height)
                      alpha))))
(define (origin-rect-2 r)
  (car (cdr r)))
(define (base-rect-2 r)
  (car (car (cdr (cdr r)))))
(define (height-rect-2 r)
  (cdr (car (cdr (cdr r)))))
(define (alpha-rect-2 r)
  (cdr (cdr (cdr r))))
]

现在为两种表示分别设计出计算周长和面积的函数。为此还需要先写出一个函数计算线段长度。

@ss-interaction[
(define (length-segment s)
  (let ([start (start-segment s)]
        [end (end-segment s)])
    (let ([x0 (x-point start)]
          [y0 (y-point start)]
          [x1 (x-point end)]
          [y1 (y-point end)])
      (sqrt (+ (square (- x0 x1)) (square (- y0 y1)))))))

(define (rect-perimeter-calculator get-edge1 get-edge2)
  (lambda (rect)
    (* 2 (+ (get-edge1 rect)
            (get-edge2 rect)))))

(define (rect-area-calculator get-edge1 get-edge2)
  (lambda (rect)
    (* (get-edge1 rect)
       (get-edge2 rect))))

(define (base-length-rect-1 r)
  (length-segment (base-segment-rect-1 r)))

(define perimeter-rect-1
  (rect-perimeter-calculator base-length-rect-1
                             height-rect-1))
(define perimeter-rect-2
  (rect-perimeter-calculator base-rect-2
                             height-rect-2))
(define area-rect-1
  (rect-area-calculator base-length-rect-1
                        height-rect-1))
(define area-rect-2
  (rect-area-calculator base-rect-2
                        height-rect-2))
]

现在再设计通用的求周长、面积操作。

@ss-interaction[
(define (representation-version-rect r)
  (car r))
(define (perimeter-rect r)
  (let ([version (representation-version-rect r)])
    (cond [(= 1 version) (perimeter-rect-1 r)]
          [(= 2 version) (perimeter-rect-2 r)]
          [else (error "Representation version not 1 or 2 -- PERIMETER-RECT" version)])))
(define (area-rect r)
  (let ([version (representation-version-rect r)])
    (cond [(= 1 version) (area-rect-1 r)]
          [(= 2 version) (area-rect-2 r)]
          [else (error "Representation version not 1 or 2 -- AREA-RECT" version)])))
]

测试一下。

@ss-interaction[
(define r1 (make-rect-1 (make-segment (make-point 1.0 0.0)
                                      (make-point 4.0 4.0))
                        2.0))
(perimeter-rect r1)
(area-rect r1)
(define r2 (make-rect-2 (make-point 1.0 0.0)
                        5.0
                        2.0
                        (atan (/ 4 3))))
(perimeter-rect r2)
(area-rect r2)
]

在这里， @racket[r1] 和 @racket[r2] 表示着同一个矩形，虽然反三角函数 @racket[atan] 的计算结果必然会和数学上的精确值有微量的误差。

示意图也先欠着。

@; TODO

计算几何学这方面的实际代码中，往往要处理大量边界情况，例如高为 0 或者线段始点和终点重合，比较烦人。这里为了清晰体现代码逻辑，没有处理这样的边界情况。

@; ----------------------------------------------------------------------

@section{练习 2.4 | 序对的另一种过程性表示方式}

我们还是不要把 @racket[cons] 、 @racket[car] 和 @racket[cdr] 这三个名字污染了为好。

@ss-interaction[
(define (cons-alt x y)
  (lambda (m) (m x y)))
(define (car-alt z)
  (z (lambda (p q) p)))
(define (cdr-alt z)
  (z (lambda (p q) q)))
(car-alt (cons-alt 1 2))
(cdr-alt (cons-alt 1 2))
]

我们使用代换模型看一看 @racket[(cdr-alt (cons-alt 1 2))] 为什么可以得到 @racket[2] 。

@verbatim{
(cdr-alt (cons-alt 1 2))
((cons-alt 1 2) (lambda (p q) q))
((lambda (m) (m 1 2)) (lambda (p q) q))
((lambda (p q) q) 1 2)
2
}

@; ----------------------------------------------------------------------

@section{练习 2.5 | 非负整数数对用一个正整数就能表示}

题中给出的是一个映射 @${f: \, \mathbb{N} \times \mathbb{N} \to S} ，其中 @${S = \{ 2^a 3^b | a, b \in \mathbb{N} \}} 。映射规则为 @${f(a, b) = 2^a 3^b} 。

首先证明 @${f} 是单射。假设有 @${(a_1, b_1)} 和 @${(a_2, b_2)} 是两个不同的数对，却对应相同的正整数 @${n} ，即 @${n = 2^{a_1}3^{b_1} = 2^{a_2}3^{b_2}} 。但由算术基本定理（正整数唯一分解定理）， @${n} 的质因数分解是唯一的，因此必须有 @${a_1 = a_2} 且 @${b_1 = b_2} ，这与“两个数对不同”的假设矛盾。所以不同的数对一定对应着不同的正整数。

然后证明 @${f} 是满射。对于任何属于集合 @${S} 的整数 @${n} ，我们可以通过质因数分解得到 @${n = 2^a 3^b} ，从而得到 @${a} 和 @${b} ，得到对应的数对。

因此 @${f} 是一个双射。形如 @${2^a 3^b} 的正整数和数对 @${(a, b)} 是一一对应的。

题中还指出，只需要用算术运算来实现这种序对。只使用算术运算的具体算法可以在下方代码中看到。

@ss-interaction[
(define (cons-nonnegative-integer a b)
  (* (expt 2 a) (expt 3 b)))
(define (integer-exponent n b)
  (if (= (remainder n b) 0)
      (+ 1 (integer-exponent (/ n b) b))
      0))
(define (car-nonnegative-integer p)
  (integer-exponent p 2))
(define (cdr-nonnegative-integer p)
  (integer-exponent p 3))
(car-nonnegative-integer (cons-nonnegative-integer 7 8))
(cdr-nonnegative-integer (cons-nonnegative-integer 7 8))
]

@racket[integer-exponent] 的起名参考了 Wolfram 的 @hyperlink["https://reference.wolfram.com/language/ref/IntegerExponent.html"]{IntegerExponent} 。这一函数的扩展在 OEIS 数列 @hyperlink["https://oeis.org/A286561"]{A286561} 中亦有记载。

@; ----------------------------------------------------------------------

@section{练习 2.6 | 丘奇数}

我们按照书上说的做，利用代换求值一下 @racket[(add-1 zero)] ：

@verbatim{
(add-1 zero)
(lambda (f) (lambda (x) (f ((zero f) x))))
(lambda (f) (lambda (x) (f (((lambda (f) (lambda (x) x)) f) x))))
(lambda (f) (lambda (x) (f ((lambda (x) x) x))))
(lambda (f) (lambda (x) (f x)))
}
这就是 @racket[one] 。

事实上，非负整数 @racket[n] 所对应的丘奇数，作为过程的能力是：接收一个过程 @racket[f] ，返回一个过程 @racket[g] 。这个 @racket[g] 作用于一个参数上所得到的结果，和将 @racket[f] 应用于该参数 @racket[n] 次所得到的结果相同。

因此，我们可以直接写出 @racket[zeno] 、 @racket[one] 和 @racket[two] 的定义。

@ss-interaction[
(define zero (lambda (f) (lambda (x) x)))
(define one  (lambda (f) (lambda (x) (f x))))
(define two  (lambda (f) (lambda (x) (f (f x)))))
]

现在定义一下丘奇数的加法。

@ss-interaction[
(define (church-add a b)
  (lambda (f)
    (let ([g (a f)]
          [h (b f)])
      (compose g h))))
]

@itemlist[@item{@racket[a] 能够将 @racket[f] 变为 @racket[g] ， @racket[g] 对参数的效果和应用 @racket[a] 次 @racket[f] 一样；}
          @item{@racket[b] 能够将 @racket[f] 变为 @racket[h] ， @racket[h] 对参数的效果和应用 @racket[b] 次 @racket[f] 一样。}]

因此，将 @racket[g] 和 @racket[h] 复合，得到的函数对参数的效果就和应用 a+b 次 @racket[f] 一样了。这就是丘奇数加法的写法。

测试一下：

@ss-interaction[
(define three (church-add one two))
(define plus-3 (three inc))
(plus-3 7)
]

在 λ 演算中，这是定义非负整数最常见的方式。

事实上，Lisp 语言的设计某种程度上和 λ 演算长得很像（这句没谈本质，谈的是表象）。

@; ----------------------------------------------------------------------

@section{练习 2.7 | 区间算术 —— 实现选择函数}

这里其实有一个小问题。 @racket[make-interval] 过程的参数 @racket[a] 和 @racket[b] ，如果前者大于后者，该如何处理呢？可以有几种做法：

@itemlist[
  #:style 'ordered
  @item{宽进严出：照常返回 @racket[(cons a b)] ，并在选择函数中使用 @racket[min] 和 @racket[max] ，做到将 @racket[a] 视为上界，将 @racket[b] 视为下界；}
  @item{宽进宽出：照常返回 @racket[(cons a b)] ，但在选择函数中仍然机械地将 @racket[a] 视为下界，将 @racket[b] 视为上界，至于用户那边会出什么问题直接放任不管，等于说假定了用户在调用 @racket[make-interval] 时一定会自觉保证 @racket[a] 小于等于 @racket[b]；}
  @item{严进严出：直接报错，从而禁止任何区间对象里 @racket[car] 大于 @racket[cdr] 这种现象存在。}
]

书本前面章节对有理数对象的处理是就“宽进宽出”的。构造函数 @racket[make-rat] 从来没有考虑过分母 @racket[d] 为 @racket[0] 的情况，连我在 @secref["exercise 2.1"] 中改进这个 @racket[make-rat] 时我也没考虑过。用户可以畅通无阻地构造出分母为 @racket[0] 的有理数。分母没被传成 @racket[0] 过真就全靠用户自觉。

@ss-interaction[
(print-rat (make-rat 6 0))
(print-rat (make-rat (- 5) 0))
]

书上写出的 @racket[make-interval] 过程是“宽进”的，没有检查参数。但是书上所有使用了 @racket[make-interval] 的代码其实都有着“保证第一个参数小于等于第二个参数”，有着一个“严进”的意图。我们应该选择哪种做法呢？

宽进严出法看起来最为“用户友好”，但其实与严进严出相比，它让用户发现潜在 bug 的可能性更小了。为什么说严进严出更有可能让用户发现 bug 呢？

想象一个场景，某个用户编写了大量算法代码，能够算出了某个物理量的理论下界和理论上界，他分别起名为 @racket[low] 和 @racket[high] 。他随后调用 @racket[(make-interval low high)] 构造出了一个区间对象并返回它。但如果前边大量计算代码隐藏着一个 bug 使得 @racket[low] 比本应算出的正确值不正常地高了不少，那么宽进严出的设计就会使这个 bug 被偷偷隐藏了。代码继续运行下去，随后对这个区间取 @racket[lower-bound] 只会得到上界，取 @racket[upper-bound] 只会得到一个无意义的值。而这些错误完全没有被察觉，直到十万八千里之外某个地方的 @racket[sqrt] 平方根函数接收了一个负值从而报错，或者各种别的更诡异的位置报出更玄幻的错误信息。程序员并不知道 bug 最初的起因到底在哪里，只能硬着头皮一点一点寻找。几个小时乃至几天的进度停滞、抓耳挠腮，最终找到罪魁祸首 @racket[make-interval] 以及选择函数，一切都是因为这个宽进严出的“小巧思”。

而 @racket[make-interval] 如果做了检查，就可以将错误报告在更准确的地方了，而不是十万八千里外。上面的问题都可以避免了。

这种“严进”做法推而广之就是现在（2026 年 3 月 31 日）流行的“快速出错”（fail-fast）思想的雏形：有异常情况就尽早报告出来，不要藏着掖着、让程序带病执行，以免严重影响寻找 bug 的进度。

这个例子或许太过理想不会遇到，但这样的思想是完全可以推广到一切编程活动，甚至编程以外的事务的。

说回软件，从更高的视角看，“宽进严出”也是有其他问题的。著名开源音视频处理软件 @hyperlink["https://www.ffmpeg.org/"]{FFmpeg} 对待数据就是宽进严出的，而 FFmpeg 的维护者之一就写过文章讨论这种设计引发的问题。文章链接： @hyperlink["https://zhuanlan.zhihu.com/p/1974620533321656280"]{FFmpeg和非洲二哥 - quink的文章 - 知乎}

简单地说，FFmpeg 是这样宽进严出的：

@itemlist[@item{对于输入的音视频数据，放宽限制，兼容各种规范的不规范的数据，给犯错的人擦屁股}
          @item{对于生成的音视频数据，恪守标准规范，避免给人制造麻烦}]

这导致了有人可能写出这样的描述：“这个视频，FFmpeg 能处理，FFplay 能播放，而某某播放器播放不了。”而事实上，这个视频其实已经很可能已经数据很不规范不合法了。 @bold{FFmpeg 不该这样用作“视频数据足够规范”的判定标准。} 文章作者最后一句话就是：“话说回来，FFmpeg无底线的兼容，也是乱七八糟码流横行的原因之一。大家把非洲二哥吃了没事，当成食品合格的唯一标准了。”这自然不是健康的“码流生态”。

不过快速出错的做法也并非总是合适，尤其是在一些不能随便停运的基础设施中。至少要做好分级隔离。2025 年 11 月，Cloudflare 出现宕机事故，持续了约 4 小时，期间全球互联网几乎瘫痪了一半。究其原因，报错地点是代码中采用了快速出错的部分逻辑处。代码及时暴露出了问题，但缺乏 @bold{分级隔离} ，导致整个系统一触就倒。

为什么要讲这些东西？因为这本书的最初的目的之一就是教授一些组织和构造大型程序的技术，控制它们的复杂度，还能让我们更好地理解其他大型程序，或许还能推而广之，将这些思想应用于其他领域。这些是 SICP 的前言（序）里讲到的。

言归正传，我们这里只是写点小算法玩玩，严进严出设计就很好。我们在构造函数中就做检查，并把该报告的错误报告出来：

@ss-interaction[
(define (make-interval a b)
  (if (<= a b)
      (cons a b)
      (error "First argument is greater than the second -- MAKE-INTERVAL"
             a
             b)))
]

刚好也方便了选择函数的实现：

@ss-interaction[
(define (lower-bound interval)
  (car interval))
(define (upper-bound interval)
  (cdr interval))
]

测试一下：

@ss-interaction[
(define length (make-interval 0.9 1.1))
(lower-bound length)
(lower-bound length)
(define mistake (make-interval 9.0 1.1))
]

@; ----------------------------------------------------------------------

@section{练习 2.8 | 区间算术 —— 实现减法}

除以一个数就等于乘上这个数的倒数。与之类似，减去一个数就等于加上这个数的相反数。当然，也要注意，取负之后，大小关系会反转。因此可以写出代码：

@ss-interaction[
(define (sub-interval x y)
  (add-interval x
                (make-interval (- (upper-bound y))
                               (- (lower-bound y)))))
]

为了测试，我们定义一个过程 @racket[print-interval] 用来打印区间：

@ss-interaction[
(define (print-interval interval)
  (newline)
  (display "[")
  (display (lower-bound interval))
  (display ", ")
  (display (upper-bound interval))
  (display "]"))
]

测试一下减法：

@ss-interaction[
(print-interval (sub-interval (make-interval 5.0 6.0)
                              (make-interval 2.0 3.0)))
]

@; ----------------------------------------------------------------------

@section{练习 2.9 | 区间算术 —— 区间宽度的变化}

对于区间 @${x = [a, b]} 和 @${y = [c, d]} ，它们的宽度分别为 @${w_x = \dfrac{b-a}{2}} 和 @${w_y = \dfrac{d-c}{2}} 。

@itemlist[@item{对于加法， @${x+y = [a+c, b+d]} ，宽度为 @${w_{x+y} = \dfrac{b+d-a-c}{2} = \dfrac{b-a}{2} + \dfrac{d-c}{2} = w_x + w_y} 。}
          @item{对于减法， @${x-y = [a-d, b-c]} ，宽度为 @${w_{x-y} = \dfrac{b-c-a+d}{2} = \dfrac{b-a}{2} + \dfrac{d-c}{2} = w_x + w_y} 。}]

所以两个区间之和（或差）的宽度就是两个区间宽度之和，是这两个区间宽度的函数。

@itemlist[@item{对于乘法，区间 @${[0, 1]} 乘以 @${[1, 2]} 得到 @${[0, 2]} ，而区间 @${[0, 1]} 乘以 @${[2, 3]} 得到 @${[0, 3]} 。两次乘法中都是两个区间的宽度均为 @${\dfrac{1}{2}} ，但结果区间的宽度一个是 @${1} ，一个是 @${\dfrac{3}{2}} ，不唯一。}
          @item{对于除法，区间 @${[0, 1]} 除以 @${[1, 2]} 得到 @${[0, 1]} ，而区间 @${[0, 1]} 除以 @${[2, 3]} 得到 @${\left[ 0, \dfrac{1}{2} \right]} 。两次除法中都是两个区间的宽度均为是 @${\dfrac{1}{2}} ，但结果区间的宽度一个是 @${\dfrac{1}{2}} ，一个是 @${\dfrac{1}{4}} ，不唯一。}]
          
所以两个区间之积（或商）的宽度不是这两个区间宽度的函数。


@; ----------------------------------------------------------------------

@section{练习 2.10 | 区间算术 —— 禁止除以横跨 0 的区间}

把原本的 @racket[div-interval] 重命名成 @racket[div-interval-raw] ，然后使用偷天换日大法。

@ss-interaction[
(define (raw-div-interval x y)
  (mul-interval x
                (make-interval (/ 1.0 (upper-bound y))
                               (/ 1.0 (lower-bound y)))))

(define (div-interval x y)
  (display "okay")
  (if (and (<= (lower-bound y) 0.0)
           (<= 0.0 (upper-bound y)))
      (error "Divisor interval spans zero -- DIV-INTERVAL"
             (lower-bound y)
             (upper-bound y))
      (raw-div-interval x y)))
]

测试一下：

@ss-interaction[
(print-interval (div-interval (make-interval 0.0 1.0)
                              (make-interval 2.0 3.0)))
(print-interval (div-interval (make-interval 0.0 1.0)
                              (make-interval 0.0 3.0)))
]

