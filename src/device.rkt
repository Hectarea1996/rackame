#lang racket/base


(require "physical-device.rkt"
         "instance.rkt"
         "surface.rkt"
         "command-pool.rkt"
         "window.rkt"
         "cvar.rkt"
         vulkan/unsafe
         ffi/unsafe
         ffi/unsafe/alloc
         ffi/cvector
         racket/list)


(provide rkm-create-device
         rkm-get-device-queues)


; ----------------------------------------------------
; ------------------- Estructuras --------------------
; ----------------------------------------------------

; struct device
(struct rkm-device
  (vk-device))


; ----------------------------------------------------
; ---------------- Funciones privadas ----------------
; ----------------------------------------------------

; Devuelve una cola del dispositivo
(define (get-device-queue vk-device index-family index-queue)

  (define queue (make-cvar _VkQueue))
  (vkGetDeviceQueue vk-device index-family index-queue (cvar-ptr queue))

  (cvar-ref queue))


; Devuelve las colas de una familia
(define (get-device-queues vk-device index-family queue-count)

  (for/list ([i (build-list queue-count values)])
    (get-device-queue vk-device index-family i)))


; Obtiene un dispositivo y devuelve la estructura device.
(define (create-device physical-device device-features queue-families)

  (define vk-physical-device (rkm-physical-device-vk-physical-device physical-device))
  (define vk-device-features (rkm-physical-device-features-vk-physical-device-features device-features))
  (define device-extensions (list VK_KHR_SWAPCHAIN_EXTENSION_NAME))

  (define priority (cvar _float 1.0))
  (define queue-create-infos
    (for/list ([family queue-families])
      (make-VkDeviceQueueCreateInfo VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
                                    #f
                                    0
                                    (rkm-queue-family-index family)
                                    (rkm-queue-family-queue-count family)
                                    (cvar-ptr priority))))

  (define device-create-info (make-VkDeviceCreateInfo VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
                                                      #f
                                                      0
                                                      (length queue-create-infos)
                                                      (cast (list->cblock queue-create-infos _VkDeviceQueueCreateInfo)
                                                            _pointer
                                                            _VkDeviceQueueCreateInfo-pointer)
                                                      0
                                                      #f
                                                      (length device-extensions)
                                                      (list->cblock device-extensions _bytes/nul-terminated)
                                                      vk-device-features))

  (define device (make-cvar _VkDevice))
  (define device-result (vkCreateDevice physical-device device-create-info #f (cvar-ptr device)))
  (check-vkResult device-result 'create-device)
  (define vk-device (cvar-ref device))

  (rkm-device vk-device))


; Destruye un dispositivo
(define (destroy-device device)

  (define vk-device (rkm-device-vk-device device))

  (vkDestroyDevice vk-device #f))


; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; Allocator y destructor de un dispositivo
(define rkm-create-device ((allocator destroy-device) create-device))


; Devuelve las colas de una familia de colas
(define (rkm-get-device-queues device queue-family)
  
  (define vk-device (rkm-device-vk-device device))
  (define index-family (rkm-queue-family-index queue-family))
  (define queue-count (rkm-queue-family-queue-count queue-family))
  
  (get-device-queues vk-device index-family queue-count))