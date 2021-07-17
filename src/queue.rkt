#lang racket/base


(require "cvar.rkt"
         vulkan/unsafe)

(provide get-device-queue)


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


; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; Devuelve las colas de una familia de colas
(define (rkm-get-device-queues device queue-family)
  
  (define vk-device (rkm-device-vk-device device))
  (define index-family (rkm-queue-family-index queue-family))
  (define queue-count (rkm-queue-family-queue-count queue-family))
  
  (get-device-queues vk-device index-family queue-count))


; Realiza un submit sobre una queue
(define (rkm-queue-submit queue submit-infos fence)

  (define vk-queue (rkm-queue-vk-queue queue))
  (define cv-submit-infos (list->cvector submit-infos _VkSubmitInfo))
  (define submit-info-count (cvector-length cv-submit-infos))
  (define vk-fence (rkm-fence-vk-fence fence))
  
  (define submit-result (vkQueueSubmit vk-queue submit-info-count (cvector-ptr cv-submit-infos) vk-fence))
  (check-vkResult submit-result 'rkm-queue-submit))