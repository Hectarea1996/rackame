#lang racket/base

(require "instance.rkt"
         "window.rkt"
         glfw3/vulkan
         vulkan/unsafe
         ffi/unsafe
         ffi/unsafe/alloc)


(provide rkm-create-surface
         (struct-out rkm-surface))


; struct surface
(struct rkm-surface
  (vk-instance
   vk-surface))


; Crea la surface
(define (create-surface instance window)

  (define vk-instance (rkm-instance-vk-instance instance))
  (define glfw-window (rkm-window-glfw-window window))
  (define-values (surface-result vk-surface) (glfwCreateWindowSurface vk-instance glfw-window #f))
  (check-vkResult surface-result 'create-surface)

  (rkm-surface vk-instance
               vk-surface))



; Destruye la surface
(define (destroy-surface surface)
  (vkDestroySurfaceKHR (rkm-surface-vk-instance surface) (rkm-surface-vk-surface surface) #f))



; Allocator y destructor de una surface
(define rkm-create-surface ((allocator destroy-surface) create-surface))