#lang racket/base

(require (for-syntax racket/base)
         "device.rkt"
         "submit-info.rkt")



(define-syntax (rkm-define-submit stx)
    (syntax-case stx (rkm-do-submit-info)
        [(_ (name args ...) type-queue (rkm-do-submit-info rest ...) ...) 
            #'(define name (let* ([pair-submit-infos (rkm-unzip-submit-infos (list (rkm-do-submit-info (args ...) rest ...) ...))]
                                  [vk-submit-infos (car pair-submit-infos)]
                                  [procs (cdr pair-submit-infos)]
                                  [submit-count (cvector-length cv-submit-infos)])
                              (lambda (args ... fence)
                                (for ([proc procs])
                                    (proc args ...))
                                (rkm-device-submit type-queue vk-submit-infos fence))))]))