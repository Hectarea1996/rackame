#lang racket/base

(require "../lib/vulkan.rkt"
         "../lib/glfw3.rkt"
         "array.rkt"
         "cvector.rkt"
         ffi/unsafe)


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
      (equal? required-layer (VkLayerProperties-layerName layer-property)))))



; Retorna las extensiones deseadas
(define (get-required-extensions)

  (glfwGetRequiredInstanceExtensions))



; Comprueba si estan disponibles las extensiones deseadas
(define (check-required-extensions required-extensions)

  ; Obtenemos las extensiones disponibles
  (define available-extensions (vkEnumerateInstanceExtensionProperties))

  ; Comprobamos que las extensiones requeridas esten disponibles
  (for/and ([required-extension required-extensions])
    (for/or ([available-extension available-extensions])
      (equal? required-extension (VkExtensionProperties-extensionName available-extension)))))



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
    (error 'create-instance "Required layers not present"))

  ; Extensions
  (define required-extensions (get-required-extensions))
  (define required-extensions-count (length required-extensions))
  (when (not (check-required-extensions required-extensions))
    (error "Required extensions not supported"))

  ; Instance
  (define instance-info (make-VkInstanceCreateInfo VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
                                                   #f
                                                   0
                                                   app-info-ptr
                                                   required-layers-count
                                                   required-layers
                                                   required-extensions-count
                                                   required-extensions))
  
  (vkCreateInstance instance-info #f))



; Destruye la instancia
(define (destroy-instance instance)
  (vkDestroyInstance instance #f))
