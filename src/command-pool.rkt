#lang racket/base


(require "cvar.rkt"
         "device.rkt"
         "queue-family.rkt"
         ffi/unsafe/alloc
         vulkan/unsafe)


(provide (struct-out rkm-command-pool)
         rkm-create-command-pool)


; ----------------------------------------------------
; ------------------- Estructuras --------------------
; ----------------------------------------------------

; Estructura de un command-pool
(struct rkm-command-pool
  (vk-command-pool
   vk-device))

; ----------------------------------------------------
; ---------------- Funciones privadas ----------------
; ----------------------------------------------------

; Crea un command pool
(define (create-command-pool-aux vk-device index-family reset-buffers)

  (define command-pool-info (make-VkCommandPoolCreateInfo VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
                                                          #f
                                                          (if reset-buffers VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT 0)
                                                          index-family))

  (define command-pool (make-cvar _VkCommandPool))
  (define command-pool-result (vkCreateCommandPool vk-device command-pool-info #f (cvar-ptr command-pool)))
  (check-vkResult command-pool-result 'create-command-pool)

  (cvar-ref command-pool))


; Wrapper de create-command-pool-aux
(define (create-command-pool device family-queue [reset-buffers #t])
  
  (define vk-device (rkm-device-vk-device device))
  (define family-index (rkm-queue-family-index family-queue))
  
  (rkm-command-pool (create-command-pool-aux vk-device family-index reset-buffers) vk-device))


; Destruye un command pool
(define (destroy-command-pool command-pool)

  (define vk-command-pool (rkm-command-pool-vk-command-pool command-pool))
  (define vk-device (rkm-command-pool-vk-device command-pool))

  (vkDestroyCommandPool vk-device vk-command-pool #f))


; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; Constructor de un command-pool
(define rkm-create-command-pool ((allocator destroy-command-pool) create-command-pool))