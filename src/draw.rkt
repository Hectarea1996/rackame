#lang racket


(define-syntax (draw stx)
  (syntax-case stx ()
    [(draw ) #'(begin)]))
