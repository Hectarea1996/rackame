#lang racket/base


(require vulkan/unsafe)
(require ffi/unsafe)


(provide get-device-queue)


; Devuelve una cola del dispositivo
(define (get-device-queue device index-family)

  (define queue-ptr (malloc _VkQueue))
  (vkGetDeviceQueue device index-family 0 queue-ptr)

  (ptr-ref queue-ptr _VkQueue))