#lang racket/base

(require racket/stream
         ffi/unsafe)


(provide array->bytes)


;Convierte un array de caracteres en un string de bytes
(define (array->bytes arr)
  (cast (array-ptr arr) _pointer _bytes))



