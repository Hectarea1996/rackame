#lang racket/base

(require "../lib/vulkan.rkt")
(require "../lib/glfw3.rkt")
(require ffi/unsafe)


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
(define (check-required-layers required-layers)

  ; Cogemos los layers disponibles
  (define available-layer-properties (vkEnumerateInstanceLayerProperties))
  
  ; Comprobamos que los layers requeridos estan disponibles
  (for/and ([required-layer required-layers])
    (for/or ([layer-property available-layer-properties])
      (define available-layer (cast (array-ptr (VkLayerProperties-layerName layer-property)) _pointer _bytes))
      (equal? required-layer available-layer))))



; Retorna las extensiones deseadas
(define (get-required-extensions)

  (glfwGetRequiredInstanceExtensions))



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


