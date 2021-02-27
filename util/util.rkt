#lang racket

(require ffi/unsafe)
(require ffi/cvector)
(require (for-syntax syntax/parse))


(provide (all-defined-out))



; Para definir una funcion en el standard de C
(define-syntax (define-stdc stx)
  (syntax-parse stx
    [(_ name:id type:expr) #`(define name
                               (get-ffi-obj #,(symbol->string (syntax->datum #'name)) #f type))]))


; strlen
(define-stdc strlen (_fun _pointer -> _size))


; strcmp
(define-stdc strcmp (_fun _pointer _pointer -> _int))

