#lang racket

(require scribble/core
         scribble/decode
         scribble/manual)

; --------------------------------

; "A000010" "A229037" etc but not "A000000"
(define/contract (oeis-seq-id? v)
  (-> any/c boolean?)
  (and
    (string? v)
    (not (string=? "A000000" v))
    (regexp-match-exact? #px"A\\d{6}" v)))

(define/contract (oeis-sequence seq-id)
  (-> oeis-seq-id? element?)
  (hyperlink (string-append "https://oeis.org/" seq-id)
             seq-id))

; TODO
; 考虑将原书各章名称、x.y 节的名称和练习题题号范围等数据在这里结构化地编码一遍，用于生成契约在下面代码中使用（替换掉所有 `integer?` ），以及用在主页和每个页面的标题，让它们自动获取题号和各章各节名称。

(define/contract (sicp-chapter-number? v)
  (-> integer? boolean?)
  (<= 1 v 5))

; 例如在开始编写 1.2 节的各个练习题解答时：
; @(define section-exercise (section-exercise-generate 1 2)
; 开始写 1.2 节里的 1.16 题时：
; @section-exercise[16]{快速幂，而且迭代}
; 等价于
; @section[#:tag "exercise 1.16"]{练习 1.16 | 快速幂，而且迭代}
(define/contract (section-exercise-generate chapter section)
  (-> sicp-chapter-number? integer? (-> integer? part-start?))
  (define/contract (sec exercise-num name)
    (-> integer? string? part-start?)
    (let ([x.y (format "~a.~a" chapter exercise-num)])
      (section #:tag (string-append "exercise " x.y)
               (format "练习 ~a | ~a" x.y name))))
  sec)

; --------------------------------

(provide oeis-sequence
         section-exercise-generate)
