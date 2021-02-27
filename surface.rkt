#lang racket/base

(require glfw3)
(require vulkan/unsafe)
(require ffi/unsafe)


(provide create-surface
         destroy-surface)



; Crea la surface
(define (create-surface instance window-ptr)

  ; Holder de la surface
  (define surface-ptr (malloc _VkSurfaceKHR))

  (define surface-result (glfwCreateWindowSurface instance window-ptr #f surface-ptr))
  (when (not (equal? surface-result VK_SUCCESS))
    (error 'create-surface "Error al crear VkSurfaceKHR"))

  (ptr-ref surface-ptr _VkSurfaceKHR))



; Destruye la surface
(define (destroy-surface instance surface)
  (vkDestroySurfaceKHR instance surface #f))