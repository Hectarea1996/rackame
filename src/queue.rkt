#lang racket/base


(require "cvar.rkt"
         "device.rkt"
         "queue-family.rkt"
         vulkan/unsafe
         (for-syntax macro-help)
         ffi/cvector
         (for-syntax racket/base))

(provide rkm-get-device-queues
         rkm-lambda-submit)


; ----------------------------------------------------
; ------------------- Estructuras --------------------
; ----------------------------------------------------

; Estructura de una cola
(struct rkm-queue
  (vk-queue))


; ----------------------------------------------------
; ---------------- Funciones privadas ----------------
; ----------------------------------------------------

; Devuelve una cola del dispositivo
(define (get-device-queue vk-device index-family index-queue)

  (define queue (make-cvar _VkQueue))
  (vkGetDeviceQueue vk-device index-family index-queue (cvar-ptr queue))

  (rkm-queue (cvar-ref queue)))


; Devuelve las colas de una familia
(define (get-device-queues vk-device index-family queue-count)

  (for/list ([i (build-list queue-count values)])
    (get-device-queue vk-device index-family i)))


; Realiza un submit sobre una queue
(define (queue-submit vk-queue vk-submit-infos vk-fence)

  ;(define vk-queue (rkm-queue-vk-queue queue))
  (define cv-submit-infos (list->cvector vk-submit-infos _VkSubmitInfo))
  (define submit-info-count (cvector-length cv-submit-infos))
  ;(define vk-fence (rkm-fence-vk-fence fence))
  
  (define submit-result (vkQueueSubmit vk-queue submit-info-count (cvector-ptr cv-submit-infos) vk-fence))
  (check-vkResult submit-result 'rkm-queue-submit))


; --- submit info ---

; Crea un vk-submit-info
(define (create-vk-submit-info vk-wait-sems wait-stages vk-signal-sems vk-command-buffers)

  (define wait-semaphore-count     (length vk-wait-sems))
  (define vk-wait-semaphores-ptr   (cvector-ptr (list->cvector vk-wait-sems _VkSemaphore)))
  (define vk-wait-stages-ptr       (cvector-ptr (list->cvector wait-stages _VkPipelineStageFlags)))
  (define signal-semaphore-count   (length vk-signal-sems))
  (define vk-signal-semaphores-ptr (cvector-ptr (list->cvector vk-signal-sems _VkSemaphore)))
  (define command-buffers-count    (length vk-command-buffers))
  (define vk-command-buffers-ptr   (cvector-ptr (list->cvector vk-command-buffers _VkSubmitInfo)))

  (make-VkSubmitInfo VK_STRUCTURE_TYPE_SUBMIT_INFO
                                            #f
                                            wait-semaphore-count
                                            vk-wait-semaphores-ptr
                                            vk-wait-stages-ptr
                                            command-buffers-count
                                            vk-command-buffers-ptr
                                            signal-semaphore-count
                                            vk-signal-semaphores-ptr))


; Macro auxiliar para crear un submit info junto con las funciones que actualizan los command-buffers
(define-syntax (do-vk-submit-info-aux stx)

  (define (dynamic? args-stx stx)
    (ormap values (syntax->datum (stx-map (lambda (s)
                                            (stx-rec-findb s stx)) args-stx))))

  (define (transform-body device-stx args-stx pool-stx reset-pool-stx stx)
    (syntax-case stx (rkm-do-command-buffer)
      [(rkm-do-command-buffer rest ...) (if (dynamic? args-stx #'(rest ...))
                                            #`(rkm-do-command-buffer/proc #,args-stx #,device-stx #,reset-pool-stx rest ...)
                                            #`(values (rkm-do-command-buffer #,device-stx #,pool-stx rest ...) #f))]))
  
  (syntax-case stx ()
    [(do-vk-submit-info-aux (args ...) device pool reset-pool) #'(values '() '())]
    [(do-vk-submit-info-aux (args ...) device pool reset-pool body bodies ...)
        (let ([new-body (transform-body #'device #'(args ...) #'pool #'reset-pool #'body)])
          #`(let-values ([(command-buffers procs) (do-vk-submit-info-aux (args ...) device pool reset-pool bodies ...)]
                         [(command-buffer proc) #,new-body])
              (values (cons command-buffer command-buffers) (if proc 
                                                                (cons proc procs)
                                                                procs))))]))


; Macro para crear un submit info junto con las funciones que actualizan los command-buffers
(define-syntax (do-vk-submit-info stx)
  
  (syntax-case stx ()
    [(do-vk-submit-info (args ...) device wait-sems wait-stages signal-sems pool reset-pool bodies ...)
        #'(let-values ([(command-buffers procs) 
                        (do-vk-submit-info-aux (args ...) device pool reset-pool bodies ...)])
            (let ([vk-command-buffers (map (lambda (cb)
                                             (cvar-ref (rkm-command-buffer-cv-command-buffer cb))) command-buffers)]
                  [vk-wait-sems (map rkm-semaphore-vk-semaphore wait-sems)]
                  [vk-signal-sems (map rkm-semaphore-vk-semaphore signal-sems)])
              (values (create-vk-submit-info vk-wait-sems wait-stages vk-signal-sems vk-command-buffers) procs)))]))


; Macro auxiliar para crear un submit info junto con las funciones que actualizan los command-buffers
(define-syntax (do-queue-submit-aux stx)

  (define (transform-body device-stx args-stx stx)
    (syntax-case stx (rkm-do-submit-info)
      [(rkm-do-submit-info rest ...) #`(do-vk-submit-info #,args-stx #,device-stx rest ...)]))
  
  (syntax-case stx ()
    [(do-queue-submit-aux (args ...) device queue fence) #'(values '() '())]
    [(do-queue-submit-aux (args ...) device queue fence body bodies ...)
        (let ([new-body (transform-body #'device #'(args ...) #'body)])
          #`(let-values ([(vk-submit-infos procs) (do-queue-submit-aux (args ...) device queue fence bodies ...)]
                         [(vk-submit-info new-procs) #,new-body])
              (values (cons vk-submit-info vk-submit-infos) (append new-procs procs))))]))


; Macro que crea una funcion que regraba los command buffers
; y tambien envia los submit infos a una cola (submit). 
(define-syntax (do-queue-submit stx)
  
  (syntax-case stx ()
    [(do-queue-submit (args ...) device queue fence bodies ...)
        #'(let-values ([(vk-submit-infos procs) (do-queue-submit-aux (args ...) device queue fence bodies ...)])
            (let ([vk-queue (rkm-queue-vk-queue queue)]
                  [vk-fence (rkm-fence-vk-fence fence)])
              (lambda (args ...)
                (for ([proc procs])
                  (proc args ...))
                (queue-submit vk-queue vk-submit-infos vk-fence))))]))


; Devuelve todas las funciones que hay que ejecutar dentro de un rkm-lambda-submit
(define-syntax (lambda-submit-aux stx)

  (define (transform-body device-stx args-stx stx)
    (syntax-case stx (rkm-queue-submit)
      [(rkm-queue-submit rest ...) #`(do-queue-submit #,args-stx #,device-stx rest ...)]
      [expression #`(lambda #,args-stx expression)]))
  
  (syntax-case stx ()
    [(lambda-submit-aux (args ...) device) #'(values '())]
    [(lambda-submit-aux (args ...) device body bodies ...)
        (let ([new-body (transform-body #'device #'(args ...) #'body)])
          #`(let ([procs (lambda-submit-aux (args ...) device bodies ...)]
                  [proc #,new-body])
              (cons proc procs)))]))

; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; Devuelve las colas de una familia de colas
(define (rkm-get-device-queues device queue-family)
  
  (define vk-device (rkm-device-vk-device device))
  (define index-family (rkm-queue-family-index queue-family))
  (define queue-count (rkm-queue-family-queue-count queue-family))
  
  (get-device-queues vk-device index-family queue-count))


; Macro que crea una funcion que ejecuta cada una de las expresiones
; que contenga, y realiza los correspondientes queue submits.
(define-syntax (rkm-lambda-submit stx)

  (syntax-case stx ()
    [(rkm-lambda-submit (args ...) device bodies ...)
        #'(let ([procs (lambda-submit-aux (args ...) device bodies ...)])
            (lambda (args ...)
              (for ([proc procs])
                (proc args ...))))]))