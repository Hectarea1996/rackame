#lang racket/base


(require "cvar.rkt"
         vulkan/unsafe)


(provide get-device-queue)


; Devuelve una cola del dispositivo
(define (get-device-queue device index-family)

  (define queue (make-cvar _VkQueue))
  (vkGetDeviceQueue device index-family 0 (cvar-ptr queue))

  (cvar-ref queue))