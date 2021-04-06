#lang racket/base

(require "device.rkt" 
         "cvar.rkt"
         vulkan/unsafe)

(provide (struct-out rkm-semaphore)
         rkm-create-semaphore
         rkm-destroy-semaphore)


; struct semaforo
(struct rkm-semaphore
   (vk-device
    vk-semaphore))


; Crea un semaforo
(define (rkm-create-semaphore device)

  (define vk-device (rkm-device-vk-device device))

  (define vk-semaphore-info (make-VkSemaphoreCreateInfo VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO
                                                        #f
                                                        0))

  (define cv-semaphore (make-cvar _VkSemaphore))
  (define semaphore-result (vkCreateSemaphore vk-device vk-semaphore-info #f (cvar-ptr cv-semaphore)))
  (check-vkResult semaphore-result)
  
  (rkm-semaphore vk-device (cvar-ref cv-semaphore)))



; Destruye un semaforo
(define (rkm-destroy-semaphore semaphore)

  (define vk-device (rkm-semaphore-vk-device semaphore))
  (define vk-semaphore (rkm-semaphore-vk-semaphore semaphore))

  (vkDestroySemaphore vk-device vk-semaphore #f))