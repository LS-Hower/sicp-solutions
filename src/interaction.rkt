#lang racket/base
(require scribble/eval)

(define ss-eval (make-base-eval))
(void (interaction-eval #:eval ss-eval (require "sicp-text.rkt")))

(define-syntax-rule (ss-interaction e ...)
  (interaction #:eval ss-eval e ...))

(provide ss-interaction)
