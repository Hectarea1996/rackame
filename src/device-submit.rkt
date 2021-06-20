#lang racket/base

(require (for-syntax racket/base)
         "device.rkt"
         "submit-info.rkt")



(define-syntax (rkm-do-submit-aux stx)
    (syntax-case stx (rkm-do-submit-info)
        [(_ (args ...) type-queue (rkm-do-submit-info rest ...) ...) 
            #'(let* ([pair-submit-infos (rkm-unzip-submit-infos (list (rkm-do-submit-info (args ...) rest ...) ...))]
                     [vk-submit-infos (car pair-submit-infos)]
                     [procs (cdr pair-submit-infos)]
                     [submit-count (cvector-length cv-submit-infos)])
                  (lambda (args ... fence)
                      (for ([proc procs])
                          (proc args ...))
                      (rkm-device-submit type-queue vk-submit-infos fence)))]))



(define-for-syntax (rkm-submit-expr? stx)
    (stx-rec-findf #'rkm-do-submit-info stx))

(define-for-syntax (rkm-list-submit args stx)
    (cond
        [(stx-null? stx) stx-null]
        [(stx-submit-expr? (stx-car stx)) (let-values ([(tk dp) (stx-splitf-at stx stx-submit-expr?)])
                                              (stx-cons (stx-list* #'rkm-do-submit-aux args tk) (rkm-list-submit args dp)))]
        [else (stx-cons (stx-list #'lambda args (stx-car stx)) (rkm-list-submit)))]))

(define-syntax (rkm-do-submit stx)
    (syntax-case stx ()
        [(_ (args ...) bodies ...) #`(let ([procs (list #,@(rkm-list-submit #'(args ...) #'(bodies ...)))])
                                         (lambda (args ...)
                                             (for ([proc procs])
                                                 (proc args ...))))]))