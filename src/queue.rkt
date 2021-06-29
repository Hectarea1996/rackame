#lang racket/base


(require "cvar.rkt"
         vulkan/unsafe)

(provide get-device-queue)



(struct rkm-queue
  (vk-command-pool
   vk-queue))


; Devuelve una cola del dispositivo
(define (create-queue device index-family index-queue)

  ; Obtenemos la cola
  (define vk-device (rkm-device-vk-device device))
  (define cv-queue (make-cvar _VkQueue))
  (vkGetDeviceQueue vk-device index-family 0 (cvar-ptr cv-queue))

  ; Creamos el command pool
  (define vk-command-pool (create-command-pool vk-device graphics-index))

  (cvar-ref queue))



; Realiza un submit sobre una queue
(define (rkm-queue-submit queue submits fence)

  (define vk-queue (rkm-queue-vk-queue queue))
  (define cv-submits-info (list->cvector submits _VkSubmitInfo))
  (define submit-info-count (cvector-length cv-submits-info))
  (define vk-fence (rkm-fence-vk-fence fence))
  
  (vkQueueSubmit vk-queue submit-info-count (cvector-ptr cv-submits-info) vk-fence))