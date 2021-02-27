#lang racket/base

(require vulkan/unsafe)
(require glfw3)
(require ffi/unsafe)
(require "util/util.rkt")


(provide create-instance
         destroy-instance
         (rename-out [get-required-layers get-enabled-layers]
                     [get-required-extensions get-enabled-extensions]))


; Lista de layers deseados
(define (get-required-layers validation)
  (if validation
      '(#"VK_LAYER_KHRONOS_validation")
      '()))



; Comprueba si estan disponibles los layers deseados
(define (check-required-layers layers)

  ; Cogemos los layers disponibles
  (define available-layers-count-ptr (malloc _uint32))
  (vkEnumerateInstanceLayerProperties available-layers-count-ptr #f)
  (define available-layers-count (ptr-ref available-layers-count-ptr _uint32))
  (define available-layers (malloc _VkLayerProperties available-layers-count))
  (vkEnumerateInstanceLayerProperties available-layers-count-ptr available-layers)
  
  ; Comprobamos que los layers requeridos estan disponibles
  (for/and ([layer layers])
    (for/or ([j (build-list available-layers-count (λ (x) x))])
      (define aval-layer (ptr-ref available-layers _VkLayerProperties j))
      (zero? (strcmp layer (array-ptr (VkLayerProperties-layerName aval-layer)))))))



; Retorna las extensiones deseadas
(define (get-required-extensions)

  ; Obtenemos las extensiones requeridas de glfw
  (define glfw-ext-count-ptr (malloc _uint32))
  (define glfw-extensions (glfwGetRequiredInstanceExtensions glfw-ext-count-ptr))
  (define glfw-ext-count (ptr-ref glfw-ext-count-ptr _uint32))

  ; Devolvemos las extensiones en una lista
  (for/list ([j (build-list glfw-ext-count values)])
    (ptr-ref glfw-extensions _bytes j)))



; Comprueba si estan disponibles las extensiones deseadas
(define (check-required-extensions extensions)

  ; Obtenemos las extensiones disponibles
  (define available-extensions-count-ptr (malloc _uint32))
  (vkEnumerateInstanceExtensionProperties #f available-extensions-count-ptr #f)
  (define available-extensions-count (ptr-ref available-extensions-count-ptr _uint32))
  (define available-extensions (malloc _VkExtensionProperties available-extensions-count))
  (vkEnumerateInstanceExtensionProperties #f available-extensions-count-ptr available-extensions)

  ; Comprobamos que las extensiones requeridas esten disponibles
  (for/and ([extension extensions])
    (for/or ([j (build-list available-extensions-count (λ (x) x))])
      (define available-extension (ptr-ref available-extensions _VkExtensionProperties j))
      (zero? (strcmp extension (array-ptr (VkExtensionProperties-extensionName available-extension)))))))



; Crea la instancia de vulkan y retorna el destructor
(define (create-instance validation)

  ; Application info
  (define app-info-ptr (make-VkApplicationInfo VK_STRUCTURE_TYPE_APPLICATION_INFO
                                           #f
                                           #"HGS_EXAMPLE"
                                           (VK_MAKE_VERSION 0 1 1)
                                           #"HGS"
                                           (VK_MAKE_VERSION 0 1 1)
                                           VK_API_VERSION_1_0))

  ; Layers
  (define required-layers (get-required-layers validation))
  (define required-layers-count (length required-layers))
  (when (not (check-required-layers required-layers))
    (eprintf "Error: Required layers not present~n"))

  ; Extensions
  (define required-extensions (get-required-extensions))
  (define required-extensions-count (length required-extensions))
  (when (not (check-required-extensions required-extensions))
    (eprintf "Error: Required extensions not supported~n"))

  ; Holder de la instancia de vulkan
  (define instance-ptr (malloc _VkInstance))

  ; Instance
  (define instance-info-ptr (make-VkInstanceCreateInfo VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
                                                       #f
                                                       0
                                                       app-info-ptr
                                                       ;layers y extensions
                                                       required-layers-count
                                                       (array-ptr (cast required-layers
                                                                        (_array/list _bytes required-layers-count)
                                                                        (_array _bytes/nul-terminated required-layers-count)))
                                                       required-extensions-count
                                                       (array-ptr (cast required-extensions
                                                                        (_array/list _bytes/nul-terminated required-extensions-count)
                                                                        (_array _bytes/nul-terminated required-extensions-count)))))
  (define instance-result (vkCreateInstance instance-info-ptr #f instance-ptr))
  (when (not (equal? instance-result VK_SUCCESS))
    (error 'create-instance "Error al crear VkInstance"))

  ; Retornamos el destructor
  (ptr-ref instance-ptr _VkInstance))



; Destruye la instancia
(define (destroy-instance instance)
  (vkDestroyInstance instance #f))



; Retorna la instancia
;(define (get-instance)
;  (ptr-ref instance-ptr _VkInstance))


