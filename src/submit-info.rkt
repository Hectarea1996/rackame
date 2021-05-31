#lang racket/base

(require "semaphore.rkt")


; struct submit-info
(struct rkm-submit-info
  (vk-command-buffers
   vk-wait-semaphores/stage
   vk-signal-semaphores
   pre-submit-procs))


; inserta un nuevo semaforo de tipo signal
(define (rkm-add-signal-semaphore submit-info signal-sem)
  (rkm-submit-info (rkm-submit-info-vk-command-buffers submit-info)
                   (rkm-submit-info-vk-wait-semaphores/stage submit-info)
                   (cons signal-sem (rkm-submit-info-vk-signal-semaphores submit-info))
                   (rkm-submit-info-pre-submit-procs submit-info)))
        

; inserta un nuevo semaforo de tipo wait
(define (rkm-add-wait-semaphore/stage submit-info wait-sem/stage)
  (rkm-submit-info (rkm-submit-info-vk-command-buffers submit-info)
                   (cons wait-sem/stage (rkm-submit-info-vk-wait-semaphores/stage submit-info))
                   (rkm-submit-info-vk-signal-semaphores submit-info)
                   (rkm-submit-info-pre-submit-procs submit-info)))


; combina unos submit info para que sean secuenciales
(define (rkm-make-sequential-submit-infos device submit-infos)
  
  (if (null? submit-infos)
    (values '() '())
    (let ([submit1 (car submit-infos)])
      (if (null? (cdr submit-infos))
        (values submit1 '())
        (let-values ([(submit2) (cadr submit-infos)] [(new-sem) (rkm-create-semaphore device)]
                     [(new-submit-infos new-sems) 
                        (rkm-make-sequential-infos device (cons (rkm-add-wait-semaphore/stage submit2 (rkm-semaphore/stages new-sem 
                                                                                                                            VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT )) 
                                                                (cddr submit-infos)))])
          (values (cons (rkm-add-signal-semaphore submit1 new-sem)
                        new-submit-infos)
                  (cons new-sem new-sems)))))))

        

; crea un submit info a partir de unos command buffers y unos semaforos
(define (rkm-create-submit-info #:wait-sems/stage w-sems/stage #:signal-sems s-sems . command-buffers)
  (define-values (vk-command-buffers procs) (for/fold ([command-buffer command-buffers] [vk-command-buffers '()] [procs '()] 
                                                       #:result (values vk-command-buffers procs))
                                              (if (rkm-command-buffer? command-buffer)
                                                (values (cdr command-buffers) 
                                                        (cons (cvar-ref (rkm-command-buffer-cv-command-buffer command-buffer)) 
                                                              vk-command-buffers)
                                                        procs)
                                                (values (cdr command-buffers)
                                                        (cons (cvar-ref (rkm-command-buffer-cv-command-buffer (car command-buffer))) 
                                                              vk-command-buffers)
                                                        (cons (cdr command-buffer) procs)))))
  (rkm-submit-info vk-command-buffers
                   w-sems/stage
                   s-sems
                   procs))

                   