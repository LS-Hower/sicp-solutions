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

@section{练习 2.1 | 有理数的正规化}

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
