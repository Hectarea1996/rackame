#lang racket/base

(require "glfw.rkt"
         "instance.rkt"
         "window.rkt"
         "surface.rkt"
         "device.rkt"
         "queue.rkt"
         "command-pool.rkt"
         "swapchain.rkt"
         "device-submit.rkt")


(glfw-init)

(define instance (rkm-create-instance #t))
(define window (rkm-create-window "Hola" 640 480))
(define surface (rkm-create-surface instance window))
(define physical-device (rkm-get-physical-device instance #:surface surface))
(define graphic-family (let* ([queue-family (rkm-get-family-queue physical-device #:queue-flags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                                                                                              VK_QUEUE_TRANSFER_BIT)
                                                                                   #:surface surface
                                                                                   #:queue-count 2)])
                          queue-family))
(when (not graphic-family)
    (error 'main "No hay familias de colas soportadas"))
(define device (rkm-create-device instance (rkm-create-physical-device-features) (list graphic-family)))
(define graphic-queues (rkm-get-device-queues device graphic-family))
(define swapchain (rkm-create-swapchain device window))


;(rkm-destroy-swapchain swapchain)
;(rkm-destroy-device device)
;(rkm-destroy-window window)
;(rkm-destroy-instance instance)

(glfw-terminate)


