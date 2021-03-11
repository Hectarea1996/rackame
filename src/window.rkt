#lang racket/base


(require glfw3
         ffi/unsafe/alloc)


(provide create-window
         destroy-window)


; Crea una ventana
(define (create-window name width height)
  (glfwWindowHint GLFW_CLIENT_API GLFW_NO_API)
  (glfwWindowHint GLFW_RESIZABLE GLFW_FALSE)
  (glfwCreateWindow width height name #f #f))



; Destruye una ventana
(define (destroy-window window-ptr)
  (glfwDestroyWindow window-ptr))