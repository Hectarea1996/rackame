#lang racket/base

(require ffi/unsafe)


(provide make-cvar
         cvar
         cvar-ref
         cvar-set!
         (rename-out [cvar-struct? cvar?]
                     [cvar-struct-type cvar-type]
                     [cvar-struct-ptr cvar-ptr]
                     [cvar-struct make-cvar*]))



(struct cvar-struct
  (ptr type))


(define (make-cvar type)
  (cvar-struct (malloc type) type))


(define (cvar type val)
  (let ([ptr (malloc type)])
    (ptr-set! ptr type val)
    (cvar-struct ptr type)))


(define (cvar-ref cv)
  (ptr-ref (cvar-struct-ptr cv) (cvar-struct-type cv)))


(define (cvar-set! cv val)
  (ptr-set! (cvar-struct-ptr cv) (cvar-struct-type cv) val))


