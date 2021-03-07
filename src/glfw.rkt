#lang racket/base


(require "../lib/glfw3.rkt")


(provide glfw-init
         glfw-terminate)


(define (error-callback code description)
  (eprintf "GLFW Error with code ~a: ~a~n" code description))


(define (glfw-init)
  (glfwInit)
  (glfwSetErrorCallback error-callback)
  (void))


(define (glfw-terminate)
  (glfwTerminate))