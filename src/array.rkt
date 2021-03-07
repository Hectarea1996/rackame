#lang racket/base

(require "unsafe.rkt"
         racket/stream
         ffi/unsafe)


(provide (all-from-out "unsafe.rkt")
         array->bytes
         (rename-out [cvector-aux cvector]))


;Convierte un array de caracteres en un string de bytes
(define (array->bytes arr)
  (cast (array-ptr arr) _pointer _bytes))



