#lang racket/base

(require "glfw.rkt"
         "instance.rkt"
         "window.rkt"
         "surface.rkt"
         "device.rkt"
         "queue.rkt"
         "command-pool.rkt"
         "swapchain.rkt")


(glfw-init)

(define instance (create-instance #t))
(define window (create-window "Hola" 640 480))
(define surface (create-surface instance window))
(define-values (physical-device device graphics-index transfer-index compute-index present-index)
  (create-device instance surface))

(define-values (graphics-queue transfer-queue compute-queue present-queue)
  (values (get-device-queue device graphics-index)
          (get-device-queue device transfer-index)
          (get-device-queue device compute-index)
          (get-device-queue device present-index)))
(define-values (graphics-pool transfer-pool compute-pool present-pool)
  (values (create-command-pool device graphics-index)
          (create-command-pool device transfer-index)
          (create-command-pool device compute-index)
          (create-command-pool device present-index)))

(define-values (swapchain swapchain-imges swapchain-image-views) (create-swapchain physical-device device surface window graphics-index present-index))

(sleep 3)

(destroy-swapchain device swapchain swapchain-image-views)
(destroy-command-pool device graphics-pool)
(destroy-command-pool device transfer-pool)
(destroy-command-pool device compute-pool)
(destroy-command-pool device present-pool)
(destroy-device device)
(destroy-surface instance surface)
(destroy-window window)
(destroy-instance instance)

(glfw-terminate)


