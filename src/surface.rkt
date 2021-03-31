#lang racket/base

(require "instance.rkt"
         glfw3/vulkan
         vulkan/unsafe
         ffi/unsafe)


(provide rkm-create-surface
         (struct-out rkm-surface)
         rkm-destroy-surface)


; struct surface
(struct rkm-surface
  (vk-instance
   vk-surface))


; Crea la surface
(define (rkm-create-surface instance glfw-window)

  (define vk-instance (rkm-instance-vk-instance instance))
  (define-values (surface-result vk-surface) (glfwCreateWindowSurface vk-instance glfw-window #f))
  (check-vkResult surface-result 'create-surface)

  (rkm-surface vk-instance
               vk-surface))



; Destruye la surface
(define (rkm-destroy-surface surface)
  (vkDestroySurfaceKHR (rkm-surface-vk-instance surface) (rkm-surface-vk-surface surface) #f))