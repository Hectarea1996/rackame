#lang racket/base

(require "glfw.rkt"
         "instance.rkt"
         "window.rkt"
         "surface.rkt"
         "physical-device.rkt"
         "device.rkt"
         "queue.rkt"
         "queue-family.rkt"
         "command-pool.rkt"
         "queue.rkt"
         "swapchain.rkt"
         vulkan/unsafe)


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
(define static-pool (rkm-create-command-pool device graphic-family #f))
(define dynamic-pool (rkm-create-command-pool device graphic-family #t))
(define device (rkm-create-device physical-device (rkm-create-physical-device-features) (list graphic-family)))
(define graphic-queues (rkm-get-device-queues device graphic-family))
(define swapchain (rkm-create-swapchain physical-device device surface (list graphic-family) 640 480))

;vkCmdClearColorImage
#|(define present-color
    (let ([sem1 (rkm-create-semaphore device)]
          [sem2 (rkm-create-semaphore device)])
        (rkm-lambda-submit (r g b) device

            (define next-image (rkm-acquire-next-image device swapchain #:semaphore sem1))
            
            (rkm-queue-submit (car graphic-queues) #f
            
                (rkm-do-submit-info (list sem1) (list VK_PIPELINE_STAGE_TRANSFER_BIT) (list sem2)
                                    static-pool dynamic-pool
                    
                    (rkm-do-command-buffer com-buf
                    
                        (vkCmdClearColorImage )))))))|#

(sleep 3)

(glfw-terminate)


