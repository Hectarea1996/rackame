#lang racket/base

(require "unsafe.rkt"
         ffi/unsafe)


(provide (except-out (all-from-out "unsafe.rkt")
                     vkEnumerateInstanceLayerProperties)
         (rename-out [vkEnumerateInstanceLayerProperties-aux vkEnumerateInstanceLayerProperties]))




(define (vkEnumerateInstanceLayerProperties-aux)
  
  (define available-layers-count-ptr (malloc _uint32))
  (define result (vkEnumerateInstanceLayerProperties available-layers-count-ptr #f))
  (check-vkResult result 'vkEnumerateInstanceLayerProperties)
  
  (define available-layers-count (ptr-ref available-layers-count-ptr _uint32))
  (define available-layers (malloc _VkLayerProperties available-layers-count))
  (define result2 (vkEnumerateInstanceLayerProperties available-layers-count-ptr available-layers))
  (check-vkResult result2 'vkEnumerateInstanceLayerProperties)
  
  (cblock->list available-layers _VkLayerProperties available-layers-count))