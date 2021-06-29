#lang racket/base


(require "surface.rkt"
         glfw3/vulkan
         ffi/unsafe/alloc)


(provide rkm-create-window
         (struct-out rkm-window))


; Window struct
(struct rkm-window
  (glfw-window))


; Crea una ventana
(define (create-window name width height)
  (glfwWindowHint GLFW_CLIENT_API GLFW_NO_API)
  (glfwWindowHint GLFW_RESIZABLE GLFW_FALSE)
  (define glfw-window (glfwCreateWindow width height name #f #f))
  
  (rkm-window glfw-window))



; Destruye una ventana
(define (destroy-window window)
  (glfwDestroyWindow (rkm-window-glfw-window window)))



; Allocator y destructor de una ventana
(define rkm-create-window ((allocator destroy-window) create-window))