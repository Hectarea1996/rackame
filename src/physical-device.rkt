#lang racket/base


(require "cvar.rkt"
         "array.rkt"
         vulkan/unsafe
         ffi/cvector
         ffi/unsafe)

(provide get-physical-device
         get-family-queues-properties
         get-surface-formats
         get-surface-present-modes
         get-surface-capabilities)


; --- physical devices ---


; Retorna una lista con todos los dispositivos
(define (enumerate-physical-devices instance)

  (define physical-device-count (make-cvar _uint32))
  (define count-result (vkEnumeratePhysicalDevices instance (cvar-ptr physical-device-count) #f))
  (check-vkResult count-result 'enumerate-physical-devices)
  (when (not (> (cvar-ref physical-device-count) 0))
    (error 'enumerate-physical-devices "No physical devices found"))
  (define physical-devices (make-cvector _VkPhysicalDevice (cvar-ref physical-device-count)))
  (vkEnumeratePhysicalDevices instance (cvar-ptr physical-device-count) (cvector-ptr physical-devices))
  (cvector->list physical-devices))


; --- device type ---


; Comprueba que un dispositivo es de cierto tipo
(define (check-type physical-device type)

  (define properties (make-cvar _VkPhysicalDeviceProperties))
  (vkGetPhysicalDeviceProperties physical-device (cvar-ptr properties))

  (equal? (VkPhysicalDeviceProperties-deviceType (cvar-ref properties)) type))


; --- device extensions ---


; Devuelve las extensiones disponibles en el dispositivo
(define (get-available-extensions physical-device)

  (define extension-count (make-cvar _uint32))
  (vkEnumerateDeviceExtensionProperties physical-device #f (cvar-ptr extension-count) #f)
  (define available-extensions (make-cvector _VkExtensionProperties (cvar-ref extension-count)))
  (vkEnumerateDeviceExtensionProperties physical-device #f (cvar-ptr extension-count) (cvector-ptr available-extensions))
  
  (cvector->list available-extensions))


; Comprueba la disponibilidad de las extensiones en el dispositivo
(define (check-extension-support physical-device required-extensions)

  (define available-extensions (get-available-extensions physical-device))

  (for/and ([required-extension required-extensions])
    (for/or ([available-extension available-extensions])
      (equal? required-extension (array->bytes (VkExtensionProperties-extensionName available-extension))))))


; --- family queues ---


; Devuelve las propiedades de las familias de colas de un dispositivo
(define (get-family-queues-properties physical-device)

  (define family-queues-count (make-cvar _uint32))
  (vkGetPhysicalDeviceQueueFamilyProperties physical-device (cvar-ptr family-queues-count) #f)
  (define family-queues-properties (make-cvector _VkQueueFamilyProperties (cvar-ref family-queues-count)))
  (vkGetPhysicalDeviceQueueFamilyProperties physical-device (cvar-ptr family-queues-count) (cvector-ptr family-queues-properties))
  
  (cvector->list family-queues-properties))


; Comprueba la validez de las familias de colas de un dispositivo
(define (check-queue-family-support physical-device required-flags surface)

  (define family-queues-properties (get-family-queues-properties physical-device))

  (for/fold ([saved-flags 0] [saved-present-queue #f] [result #f] #:result result)
            ([i (build-list (length family-queues-properties) values)] [family-property family-queues-properties] #:break result)
    (define current-flags (bitwise-and (VkQueueFamilyProperties-queueFlags family-property) required-flags))
    (define present-queue (make-cvar _VkBool32))
    (vkGetPhysicalDeviceSurfaceSupportKHR physical-device i surface (cvar-ptr present-queue))
    (define current-present-queue (or saved-present-queue (equal? (cvar-ref present-queue) VK_TRUE)))
    (values current-flags current-present-queue (and (equal? current-flags required-flags) current-present-queue))))


; --- device features ---


; Comprueba la disponibilidad de las caracteristicas del dispositivo
(define (check-features physical-device checker)

  (define features (make-cvar _VkPhysicalDeviceFeatures))
  (vkGetPhysicalDeviceFeatures physical-device (cvar-ptr features))

  (checker (cvar-ref features)))


; --- surface presentation ---


; Devuelve las prestaciones de una surface
(define (get-surface-capabilities physical-device surface)

  (define capabilities (make-cvar _VkSurfaceCapabilitiesKHR))
  (vkGetPhysicalDeviceSurfaceCapabilitiesKHR physical-device surface (cvar-ptr capabilities))

  (cvar-ptr capabilities))



; Devuelve los formatos de surface disponibles en el dispositivo
(define (get-surface-formats physical-device surface)

  (define format-count (make-cvar _uint32))
  (vkGetPhysicalDeviceSurfaceFormatsKHR physical-device surface (cvar-ptr format-count) #f)
  (define formats (make-cvector _VkSurfaceFormatKHR (cvar-ref format-count)))
  (vkGetPhysicalDeviceSurfaceFormatsKHR physical-device surface (cvar-ptr format-count) (cvector-ptr formats))

  (cvector->list formats))



; Devuelve los modos de presentacion de un surface en el dispositivo
(define (get-surface-present-modes physical-device surface)

  (define mode-count (make-cvar _uint32))
  (vkGetPhysicalDeviceSurfacePresentModesKHR physical-device surface (cvar-ptr mode-count) #f)
  (define present-modes (make-cvector _VkPresentModeKHR (cvar-ref mode-count)))
  (vkGetPhysicalDeviceSurfacePresentModesKHR physical-device surface (cvar-ptr mode-count) (cvector-ptr present-modes))

  (cvector->list present-modes))


; Comprueba la validez de un surface
(define (check-surface-presentation-support physical-device surface)

  (define surface-formats (get-surface-formats physical-device surface))
  (define surface-present-modes (get-surface-present-modes physical-device surface))

  (and (not (null? surface-formats)) (not (null? surface-present-modes))))


; --- physical device ---


; Devuelve un dispositivo que cumpla con los requerimientos
(define (get-physical-device instance surface type extensions queue-flags features-checker)

  (define physical-devices (enumerate-physical-devices instance))

  (define the-physical-device
    (for/or ([physical-device physical-devices])
      (if (and (check-type physical-device type)
               (check-extension-support physical-device extensions)
               (check-queue-family-support physical-device queue-flags surface)
               (check-features physical-device features-checker)
               (check-surface-presentation-support physical-device surface))
          physical-device
          #f)))

  (when (not the-physical-device)
    (error 'get-physical-device "No valid physical device found"))
  the-physical-device)


; --- memory type ---


; Devuelve el tipo de memoria que cumple unos requisitos
(define (get-memory-type physical-device type-filter property-flags)

  (define mem-properties (make-cvar _VkPhysicalDeviceMemoryProperties))
  (vkGetPhysicalDeviceMemoryProperties physical-device (cvar-ptr mem-properties))

  (define mem-type
    (for/or ([i (build-list (VkPhysicalDeviceMemoryProperties-memoryTypeCount (cvar-ref mem-properties)) values)])
      (if (and (not (zero? (bitwise-and type-filter (arithmetic-shift 1 i))))
               (bitwise-and (VkMemoryType-propertyFlags
                             (array-ref (VkPhysicalDeviceMemoryProperties-memoryTypes (cvar-ref mem-properties)) i)
                             property-flags)))
          i
          #f)))

  (when (not mem-type)
    (error 'get-memory-type "No existe un tipo de memoria con los requisitos necesarios."))
  mem-type)


; --- format ---


; Devuelve un formato que verifique unos requisitos.
(define (get-format physical-device possible-formats tiling features)

  (define the-format
    (for/or ([format possible-formats])
      (define format-properties (make-cvar _VkFormatProperties))
      (vkGetPhysicalDeviceFormatProperties physical-device format (cvar-ptr format-properties))

      (cond
        [(and (equal? tiling VK_IMAGE_TILING_LINEAR)
              (equal? (bitwise-and (VkFormatProperties-linearTilingFeatures (cvar-ref format-properties)) features) features))
         format]
        [(and (equal? tiling VK_IMAGE_TILING_OPTIMAL)
              (equal? (bitwise-and (VkFormatProperties-optimalTilingFeatures (cvar-ref format-properties)) features) features))
         format]
        [else #f])))

  (when (not the-format)
    (error 'get-format "No se encuentra ningun formato con los requisitos necesarios."))
  the-format)