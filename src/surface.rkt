#lang racket/base

(require glfw3/vulkan)
(require vulkan/unsafe)
(require ffi/unsafe)


(provide create-surface
         destroy-surface)



; Crea la surface
(define (create-surface instance window)

  (define-values (surface-result surface) (glfwCreateWindowSurface instance window #f))
  (check-vkResult surface-result 'create-surface)

  surface)



; Destruye la surface
(define (destroy-surface instance surface)
  (vkDestroySurfaceKHR instance surface #f))