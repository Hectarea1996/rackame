#lang racket/base


(require "util/util.rkt")
(require vulkan/unsafe)
(require ffi/unsafe)

(provide get-physical-device
         get-family-queues-properties
         get-surface-formats
         get-surface-present-modes
         get-surface-capabilities)


; --- physical devices ---


; Retorna una lista con todos los dispositivos
(define (enumerate-physical-devices instance)

  (define physical-device-count-ptr (malloc _uint32))
  (define count-result (vkEnumeratePhysicalDevices instance physical-device-count-ptr #f))
  (when (not (equal? count-result VK_SUCCESS))
    (error 'enumerate-physical-devices "Error al enumerar los dispositivos."))
  (define physical-device-count (ptr-ref physical-device-count-ptr _uint32))
  (when (not (> physical-device-count 0))
    (error 'enumerate-physical-devices "El numero de dispositivos no es positivo."))
  (define physical-devices-ptr (malloc _VkPhysicalDevice physical-device-count))
  (vkEnumeratePhysicalDevices instance physical-device-count-ptr physical-devices-ptr)
  (for/list ([i (build-list physical-device-count values)])
    (ptr-ref physical-devices-ptr _VkPhysicalDevice)))


; --- device type ---


; Comprueba que un dispositivo es de cierto tipo
(define (check-type physical-device type)

  (define properties-ptr (cast (malloc _VkPhysicalDeviceProperties) _pointer _VkPhysicalDeviceProperties-pointer))
  (vkGetPhysicalDeviceProperties physical-device properties-ptr)

  (equal? (VkPhysicalDeviceProperties-deviceType properties-ptr) type))


; --- device extensions ---


; Devuelve las extensiones disponibles en el dispositivo
(define (get-available-extensions physical-device)

  (define extension-count-ptr (malloc _uint32))
  (vkEnumerateDeviceExtensionProperties physical-device #f extension-count-ptr #f)
  (define extension-count (ptr-ref extension-count-ptr _uint32))
  (define available-extensions-ptr (malloc _VkExtensionProperties extension-count))
  (vkEnumerateDeviceExtensionProperties physical-device #f extension-count-ptr available-extensions-ptr)
  
  (for/list ([i (build-list extension-count values)])
    (ptr-ref available-extensions-ptr _VkExtensionProperties i)))


; Comprueba la disponibilidad de las extensiones en el dispositivo
(define (check-extension-support physical-device required-extensions)

  (define available-extensions (get-available-extensions physical-device))

  (for/and ([required-extension required-extensions])
    (for/or ([available-extension available-extensions])
      (zero? (strcmp required-extension (array-ptr (VkExtensionProperties-extensionName available-extension)))))))


; --- family queues ---


; Devuelve las propiedades de las familias de colas de un dispositivo
(define (get-family-queues-properties physical-device)

  (define family-queues-count-ptr (malloc _uint32))
  (vkGetPhysicalDeviceQueueFamilyProperties physical-device family-queues-count-ptr #f)
  (define family-queues-count (ptr-ref family-queues-count-ptr _uint32))
  (define family-queues-properties-ptr (malloc _VkQueueFamilyProperties family-queues-count))
  (vkGetPhysicalDeviceQueueFamilyProperties physical-device family-queues-count-ptr family-queues-properties-ptr)
  
  (for/list ([i (build-list family-queues-count values)])
    (ptr-ref family-queues-properties-ptr _VkQueueFamilyProperties i)))


; Comprueba la validez de las familias de colas de un dispositivo
(define (check-queue-family-support physical-device required-flags surface)

  (define family-queues-properties (get-family-queues-properties physical-device))

  (for/fold ([saved-flags 0] [saved-present-queue #f] [result #f] #:result result)
            ([i (build-list (length family-queues-properties) values)] [family-property family-queues-properties] #:break (equal? result #t))
    (define current-flags (bitwise-and (VkQueueFamilyProperties-queueFlags family-property) required-flags))
    (define present-queue-ptr (malloc _VkBool32))
    (vkGetPhysicalDeviceSurfaceSupportKHR physical-device i surface present-queue-ptr)
    (define current-present-queue (or saved-present-queue (ptr-ref present-queue-ptr _VkBool32)))
    (values current-flags current-present-queue (and (equal? current-flags required-flags) (equal? current-present-queue VK_TRUE)))))


; --- device features ---


; Comprueba la disponibilidad de las caracteristicas del dispositivo
(define (check-features physical-device checker)

  (define features-ptr (cast (malloc _VkPhysicalDeviceFeatures) _pointer _VkPhysicalDeviceFeatures-pointer))
  (vkGetPhysicalDeviceFeatures physical-device features-ptr)

  (checker features-ptr))


; --- surface presentation ---


; Devuelve las prestaciones de una surface
(define (get-surface-capabilities physical-device surface)

  (define capabilities-ptr (malloc _VkSurfaceCapabilitiesKHR))
  (vkGetPhysicalDeviceSurfaceCapabilitiesKHR physical-device surface capabilities-ptr)

  (cast capabilities-ptr _pointer _VkSurfaceCapabilitiesKHR-pointer))



; Devuelve los formatos de surface disponibles en el dispositivo
(define (get-surface-formats physical-device surface)

  (define format-count-ptr (malloc _uint32))
  (vkGetPhysicalDeviceSurfaceFormatsKHR physical-device surface format-count-ptr #f)
  (define format-count (ptr-ref format-count-ptr _uint32))
  (define formats-ptr (malloc _VkSurfaceFormatKHR format-count))
  (vkGetPhysicalDeviceSurfaceFormatsKHR physical-device surface format-count-ptr formats-ptr)

  (for/list ([i (build-list format-count values)])
    (ptr-ref formats-ptr _VkSurfaceFormatKHR i)))



; Devuelve los modos de presentacion de un surface en el dispositivo
(define (get-surface-present-modes physical-device surface)

  (define mode-count-ptr (malloc _uint32))
  (vkGetPhysicalDeviceSurfacePresentModesKHR physical-device surface mode-count-ptr #f)
  (define mode-count (ptr-ref mode-count-ptr _uint32))
  (define present-modes-ptr (malloc _VkPresentModeKHR mode-count))
  (vkGetPhysicalDeviceSurfacePresentModesKHR physical-device surface mode-count-ptr present-modes-ptr)

  (for/list ([i (build-list mode-count values)])
    (ptr-ref present-modes-ptr _VkPresentModeKHR i)))


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

  (if (not the-physical-device)
      (error 'get-physical-device "No se ha encontrado un dispositivo valido.")
      the-physical-device))


; --- memory type ---


; Devuelve el tipo de memoria que cumple unos requisitos
(define (get-memory-type physical-device type-filter property-flags)

  (define mem-properties-ptr (malloc _VkPhysicalDeviceMemoryProperties))
  (vkGetPhysicalDeviceMemoryProperties physical-device mem-properties-ptr)

  (define mem-type
    (for/or ([i (build-list (VkPhysicalDeviceMemoryProperties-memoryTypeCount mem-properties-ptr) values)])
      (if (and (not (zero? (bitwise-and type-filter (arithmetic-shift 1 i))))
               (bitwise-and (VkMemoryType-propertyFlags
                             (ptr-add (array-ptr (VkPhysicalDeviceMemoryProperties-memoryTypes mem-properties-ptr)) i _VkMemoryType))
                            property-flags))
          i
          #f)))

  (if (not mem-type)
      (error 'get-memory-type "No existe un tipo de memoria con los requisitos necesarios.")
      mem-type))


; --- format ---


; Devuelve un formato que verifique unos requisitos.
(define (get-format physical-device possible-formats tiling features)

  (define the-format
    (for/or ([format possible-formats])
      (define format-properties-ptr (malloc _VkFormatProperties))
      (vkGetPhysicalDeviceFormatProperties physical-device format format-properties-ptr)

      (cond
        [(and (equal? tiling VK_IMAGE_TILING_LINEAR)
              (equal? (bitwise-and (VkFormatProperties-linearTilingFeatures format-properties-ptr) features) features))
         format]
        [(and (equal? tiling VK_IMAGE_TILING_OPTIMAL)
              (equal? (bitwise-and (VkFormatProperties-optimalTilingFeatures format-properties-ptr) features) features))
         format]
        [else #f])))

  (if (not the-format)
      (error 'get-format "No se encuentra ningun formato con los requisitos necesarios.")
      the-format))