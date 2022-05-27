#lang racket


(require "device.rkt"
         "cvar.rkt"
         "command-pool.rkt"
         vulkan/unsafe
         ffi/unsafe
         ffi/unsafe/alloc
         ffi/cvector)


(provide (struct-out rkm-command-buffer)
         rkm-create-command-buffer
         rkm-do-command-buffer
         rkm-do-command-buffer/proc)


; ----------------------------------------------------
; ------------------- Estructuras --------------------
; ----------------------------------------------------

; struct de un command buffer
(struct rkm-command-buffer
  (vk-device
   vk-command-pool
   cv-command-buffer))


; ----------------------------------------------------
; ---------------- Funciones privadas ----------------
; ----------------------------------------------------

; Crea un command buffer
(define (create-command-buffer device command-pool [secondary-buffer #f])

  (define vk-command-pool (rkm-command-pool-vk-command-pool command-pool))
  (define vk-device (rkm-device-vk-device device))

  (define vk-allocate-info (make-VkCommandBufferAllocateInfo VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
                                                             #f
                                                             vk-command-pool
                                                             (if secondary-buffer VK_COMMAND_BUFFER_LEVEL_SECONDARY
                                                                                  VK_COMMAND_BUFFER_LEVEL_PRIMARY)
                                                             1))

  (define cv-command-buffer (make-cvar _VkCommandBuffer))
  (define allocate-result (vkAllocateCommandBuffers vk-device vk-allocate-info (cvar-ptr cv-command-buffer)))
  (check-vkResult allocate-result)

  (rkm-command-buffer vk-device vk-command-pool cv-command-buffer))


; Destruye un command buffer
(define (destroy-command-buffer command-buffer)

  (vkFreeCommandBuffers (rkm-command-buffer-vk-device command-buffer)
                        (rkm-command-buffer-vk-command-pool)
                        1
                        (cvar-ptr (rkm-command-buffer-cv-command-buffer command-buffer))))


; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; Allocator y destructor de un command buffer
(define rkm-create-command-buffer ((allocator destroy-command-buffer) create-command-buffer))


; Resetea un command buffer
(define (rkm-reset-command-buffer command-buffer)

  (define vk-command-buffer (cvar-ref (rkm-command-buffer-cv-command-buffer command-buffer)))

  (vkResetCommandBuffer vk-command-buffer 0))


; Inicia la grabacion de comandos en un buffer de comandos
(define (rkm-begin-command-buffer command-buffer usage-flags)

  (define begin-info (make-VkCommandBufferBeginInfo VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
                                                    #f
                                                    usage-flags
                                                    #f))

  (vkBeginCommandBuffer (cvar-ref (rkm-command-buffer-cv-command-buffer command-buffer)) begin-info))


; Termina la grabacion de comandos en un buffer de comandos
(define (rkm-end-command-buffer command-buffer)

  (vkEndCommandBuffer (cvar-ref (rkm-command-buffer-cv-command-buffer command-buffer))))


; Macro para generar un command buffer listo para submit.
(define-syntax (rkm-do-command-buffer stx)
  (syntax-case stx ()
    [(_ device command-pool buffer-name bodies ...) #'(let ([buffer-name (rkm-create-command-buffer device command-pool)])
                                                       (rkm-begin-command-buffer buffer-name VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT)
                                                       bodies ...
                                                       (rkm-end-command-buffer buffer-name)
                                                       buffer-name)]))


; Macro para generar un command buffer que debe ser preparado para el submit usando la
; funcion que retorna.
(define-syntax (rkm-do-command-buffer/proc stx)
  (syntax-case stx ()
    [(_ (args ...) device command-pool buffer-name bodies ...) #'(let ([buffer-name (rkm-create-command-buffer device command-pool)])
                                                                  (values command-buffer
                                                                          (lambda (args ...)
                                                                            (rkm-reset-command-buffer buffer-name)
                                                                            (rkm-begin-command-buffer buffer-name VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT)
                                                                            bodies ...
                                                                            (rkm-end-command-buffer buffer-name))))]))
