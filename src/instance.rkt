#lang racket/base

(require "array.rkt"
         "cvar.rkt"
         vulkan/unsafe
         glfw3/vulkan
         ffi/unsafe
         ffi/cvector)


(provide create-instance
         destroy-instance
         (rename-out [rkm-instance-layers get-instance-layers]
                     [rkm-instance-extensions get-instance-extensions]
                     [rkm-instance? instance?]))


; Instance struct
(struct rkm-instance
  (instance
   layers
   extensions))


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
  (map (λ (extension-name)
         (cast extension-name _string/utf-8 _bytes/nul-terminated)) (glfwGetRequiredInstanceExtensions)))



; Comprueba si estan disponibles las extensiones deseadas
(define (check-required-extensions required-extensions)

  ; Obtenemos las extensiones disponibles
  (define count (make-cvar _uint32))
  (vkEnumerateInstanceExtensionProperties #f (cvar-ptr count) #f)
  (define properties (make-cvector _VkExtensionProperties (cvar-ref count)))
  (vkEnumerateInstanceExtensionProperties #f (cvar-ptr count) (cvector-ptr properties))

  ; Comprobamos que las extensiones requeridas esten disponibles
  (for/and ([required-extension required-extensions])
    (for/or ([property (cvector->list properties)])
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
    (error 'create-instance "Required extensions not supported"))

  ;Instance
  (define instance-info (make-VkInstanceCreateInfo VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
                                                   #f
                                                   0
                                                   app-info
                                                   required-layers-count
                                                   (if (null? required-layers)
                                                       #f
                                                       (cvector-ptr (list->cvector required-layers _bytes/nul-terminated)))
                                                   required-extensions-count
                                                   (if (null? required-extensions)
                                                       #f
                                                       (cvector-ptr (list->cvector required-extensions _bytes/nul-terminated)))))

  (define instance (make-cvar _VkInstance))
  (define result (vkCreateInstance instance-info #f (cvar-ptr instance)))
  (check-vkResult result 'create-instance)
  (rkm-instance (cvar-ref instance)
                required-layers
                required-extensions))



; Destruye la instancia
(define (destroy-instance s-instance)
  (vkDestroyInstance (rkm-instance-instance s-instance) #f))
