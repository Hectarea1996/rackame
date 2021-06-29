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
(define device (rkm-create-device instance window))
(define swapchain (rkm-create-swapchain device window))


;(rkm-destroy-swapchain swapchain)
;(rkm-destroy-device device)
;(rkm-destroy-window window)
;(rkm-destroy-instance instance)

(glfw-terminate)


