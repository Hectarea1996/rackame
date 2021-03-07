#lang racket/base


(require ffi/unsafe/cvector
         racket/stream)

(provide (rename-out [make-cvector-aux make-cvector]
                     [cvector-aux-aux cvector]
                     [cvector-length-aux cvector-length]
                     [cvector-type-aux cvector-type]
                     [cvector-ptr-aux cvector-ptr]
                     [cvector-ref-aux cvector-ref]
                     [cvector-set-aux! cvector-set!]
                     [cvector->list-aux cvector->list]
                     [list->cvector-aux list->cvector]
                     [make-cvector-aux* make-cvector*]))


;Iterador para un cvector
(struct cvector-iterator
  (index cvec)

  #:methods gen:stream
  [(define (stream-empty? iter)
     (>= (cvector-iterator-index iter)
         (cvector-length (cvector-iterator-cvec iter))))
   
   (define (stream-first iter)
     (cvector-ref (cvector-iterator-cvec iter) (cvector-iterator-index iter)))
   
   (define (stream-rest iter)
     (cvector-iterator (add1 (cvector-iterator-index iter)) (cvector-iterator-cvec iter)))])


;Funcion que genera un iterador de un cvector
(define (make-cvector-iterator cvec)
  (cvector-iterator 0 cvec))


;cvector adornado para ser una secuencia
(struct cvector-aux
  (cvec)

  #:property prop:sequence
  make-cvector-iterator)


;Metodos de cvector
(define (make-cvector-aux type length)
  (cvector-aux (make-cvector type length)))

(define (cvector-aux-aux type . vals)
  (cvector-aux (apply cvector type vals)))

(define (cvector-length-aux cvec)
  (cvector-length (cvector-aux-cvec cvec)))

(define (cvector-type-aux cvec)
  (cvector-type (cvector-aux-cvec cvec)))

(define (cvector-ptr-aux cvec)
  (cvector-ptr (cvector-aux-cvec cvec)))

(define (cvector-ref-aux cvec k)
  (cvector-ref (cvector-aux-cvec cvec) k))

(define (cvector-set-aux! cvec k val)
  (cvector-set! (cvector-aux-cvec cvec) k val))

(define (cvector->list-aux cvec)
  (cvector->list (cvector-aux-cvec cvec)))

(define (list->cvector-aux lst)
  (cvector-aux (list->cvector lst)))

(define (make-cvector-aux* cptr type length)
  (cvector-aux (make-cvector* cptr type length)))