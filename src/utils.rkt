#lang racket

(require scribble/core
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

; --------------------------------

(provide oeis-sequence)
