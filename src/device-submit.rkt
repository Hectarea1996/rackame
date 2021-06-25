#lang racket/base

(require (for-syntax racket/base)
         (for-syntax macro-help)
         "device.rkt"
         "submit-info.rkt")

(provide rkm-do-submit)

; Inserta los argumentos tras el identificador #'rkm-do-submit-info.
(define-for-syntax (rkm-change-submit-info args stx)
    (syntax-case stx (rkm-do-submit-info)
        [(rkm-do-submit-info rest ...) #`(rkm-do-submit-info #,args rest ...)]))

; Dada una lista de expresiones rkm-submit-expr?, se insertan los argumentos tras cada #'rkm-do-submit-info,
; y se devuelve el codigo que generara un lambda para realizar el submit de todos los commnad buffers que
; se indiquen.
(define-syntax (rkm-do-submit-aux stx)
    (syntax-case stx (rkm-do-submit-info)
        [(_ (args ...) type-queue bodies ...) 
            #`(let* ([pair-submit-infos (rkm-unzip-submit-infos (list #,@(stx-map (lambda (s) 
                                                                                      (rkm-change-submit-info #'(args ...) s)) #'(bodies ...))))]
                     [vk-submit-infos (car pair-submit-infos)]
                     [procs (cdr pair-submit-infos)]
                     [submit-count (cvector-length cv-submit-infos)])
                  (lambda (args ... fence)
                      (for ([proc procs])
                          (proc args ...))
                      (rkm-device-submit type-queue vk-submit-infos fence)))]))



; Comprueba que una expresion contenga el identificador #'rkm-do-submit-info
(define-for-syntax (rkm-submit-expr? stx)
    (syntax-case stx (rkm-do-submit-info)
        [(rkm-do-submit-info rest ...) #t]
        [_ #f]))
    ;(stx-rec-findf #'rkm-do-submit-info stx))

; Para cada expresion de stx, se comprueba si es o no una rkm-submit-expr?
; En caso afirmativo, se inserta la macro #'rkm-do-submit-aux.
; En otro caso, se inserta un #'lambda. 
(define-for-syntax (rkm-list-submit args type-queue stx)
    (cond
        [(stx-null? stx) stx-null]
        [(rkm-submit-expr? (stx-car stx)) (let-values ([(tk dp) (stx-splitf-at stx rkm-submit-expr?)])
                                              (stx-cons (stx-list* #'rkm-do-submit-aux args type-queue tk) (rkm-list-submit args dp)))]
        [else (stx-cons (stx-list #'lambda args (stx-car stx)) (rkm-list-submit))]))

; Macro que devuelve un lambda que ejecuta cada pieza de codigo y realiza un submit de todos
; los submit infos que se indiquen.
(define-syntax (rkm-do-submit stx)
    (syntax-case stx ()
        [(_ (args ...) type-queue bodies ...) #`(let ([procs (list #,@(rkm-list-submit #'(args ...) #'type-queue #'(bodies ...)))])
                                         (lambda (args ...)
                                             (for ([proc procs])
                                                 (proc args ...))))]))