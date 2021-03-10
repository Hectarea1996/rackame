#lang racket/base

(require "../lib/vulkan.rkt"
         "../lib/glfw3.rkt"
         "array.rkt"
         "cvar.rkt"
         ffi/unsafe
         ffi/unsafe/alloc)


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
  (define count (make-cvar _uint32))
  (vkEnumerateInstanceLayerProperties (cvar-ptr count) #f)
  (define properties (make-cvector _VkLayerProperties (cvar-ref count)))
  (vkEnumerateInstanceLayerProperties (cvar-ptr count) (cvector-ptr properties))
  
  ; Comprobamos que los layers requeridos estan disponibles
  (for/and ([required-layer required-layers])
    (for/or ([property (cvector->list properties)])
      (equal? required-layer (array->bytes (VkLayerProperties-layerName property))))))



; Retorna las extensiones deseadas
(define (get-required-extensions)
  (glfwGetRequiredInstanceExtensions))



; Comprueba si estan disponibles las extensiones deseadas
(define (check-required-extensions required-extensions)

  ; Obtenemos las extensiones disponibles
  (define count (make-cvar _uint32))
  (vkEnumerateInstanceExtensionProperties #f (cvar-ptr count) #f)
  (define properties (make-cvector _VkExtensionProperties (cvar-ref count)))
  (vkEnumerateInstanceExtensionProperties #f (cvar-ptr count) (cvector-ptr properties))

  ; Comprobamos que las extensiones requeridas esten disponibles
  (for/and ([required-extension required-extensions])
    (for/or ([property properties])
      (equal? required-extension (array->bytes (VkExtensionProperties-extensionName property))))))



; Crea la instancia de vulkan y retorna el destructor
(define (create-instance validation)

  ; Application info
  (define app-info (make-VkApplicationInfo VK_STRUCTURE_TYPE_APPLICATION_INFO
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

  ;Instance
  (define instance-info (make-VkInstanceCreateInfo VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
                                                   #f
                                                   0
                                                   app-info
                                                   required-layers-count
                                                   (cvector-ptr (list->cvector required-layers _bytes))
                                                   required-extensions-count
                                                   (cvector-ptr (list->cvector required-extensions _bytes))))

  (define instance (make-cvar _VkInstance))
  (define result (((allocator destroy-instance) (λ ()
                                                  (vkCreateInstance instance-info #f (cvar-ptr instance))))))
  (check-vkResult result 'create-instance)
  instance)



; Destruye la instancia
(define (destroy-instance instance)
  (vkDestroyInstance instance #f))
