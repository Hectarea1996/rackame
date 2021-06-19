#lang racket/base

(require "semaphore.rkt"
         macro-helper)


; struct submit-info
(struct rkm-submit-info
  (vk-command-buffers
   vk-wait-semaphores/stage
   vk-signal-semaphores
   pre-submit-procs))


#|
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
|#

        

; crea un submit info a partir de unos command buffers y unos semaforos
(define (rkm-create-submit-info #:wait-sems/stage [w-sems/stage '()] #:signal-sems [s-sems '()] . command-buffers)
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



; Genera un par de valores, una lista de command buffers y una lista de procedimientos. 
; Primero hay que especificar los argumentos de los procedimientos (como un lambda), luego los semaforos con 
; los keywords #:wait-sems/stage y #:signal-sems, y por ultimo el comportamiento de cada command buffer. Cada
; linea debe grabar un command buffer, si se utilizan los argumentos se usara rkm-do-command-buffer/proc, si no, 
; se usara rkm-do-command-buffer.
(define-syntax (rkm-do-submit-info stx)

  (define (rkm-change-body args stx)
    (define dynamic? (apply or (syntax->datum (stx-map (lambda (s)
                                                         (stx-rec-findb s stx)) args))))      
    (if dynamic?
      #`(rkm-do-command-buffer/proc #,args #,stx)
      #`(rkm-do-command-buffer #,stx))))

  (define (rkm-transform-bodies args stx)
    (syntax-case stx ()
      [() stx-null]
      [(kw val rest ...) (stx-keyword? kw) (stx-list* #'kw #'val (rkm-transorm-bodies #'(rest ...)))]
      [(b bs ...) (stx-cons (rkm-change-body args #'b) (rkm-transform-bodies args #'(bs ...)))]))

  (syntax-case stx ()
    [(_ (args ...) bodies ...) #`(rkm-create-submit-info #,@(rkm-transform-bodies #'(bodies ...)))]))

            

; Crea los vkSubmitInfo y devuelve la lista que los contiene y la lista de procs
(define (rkm-unzip-submit-infos submit-infos)

   (for/foldr ([vk-submit-infos '()] [proc-lst '()]) ([submit-info submit-infos])

      (define submit-procs (rkm-submit-info-procs submit-info))

      (define wait-semaphore-count   (length (rkm-submit-info-w-sems/stage submit-info)))
      (define vk-wait-semaphores     (cvector-ptr (list->cvector (map car (rkm-submit-info-w-sems/stage submit-info)) VkSemaphore)))
      (define vk-wait-stages         (cvector-ptr (list->cvector (map cdr (rkm-submit-info-w-sems/stage submit-info)) VkPipelineStageFlags)))
      (define signal-semaphore-count (length s-sems))
      (define vk-signal-semaphores   (cvector-ptr (list->cvector s-sems VkSemaphore)))
      (define command-buffers-count  (length (rkm-submit-info-vk-command-buffers submit-info)))
      (define vk-command-buffers        (cvector-ptr (list->cvector (rkm-submit-info-vk-command-buffers submit-info) VkSubmitInfo)))

      (define vk-submit-info (make-VkSubmitInfo VK_STRUCTURE_TYPE_SUBMIT_INFO
                                                #f
                                                wait-semaphore-count
                                                vk-wait-semaphores
                                                vk-wait-stages
                                                command-buffers-count
                                                vk-command-buffers
                                                signal-semaphore-count
                                                vk-signal-semaphores))))
                                              
      (values (cons vk-submit-info vk-submit-infos) (append submit-procs proc-lst))

                   

