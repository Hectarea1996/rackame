#lang racket/base


(require "cvar.rkt"
         "array.rkt"
         "instance.rkt"
         "surface.rkt"
         vulkan/unsafe
         racket/bool
         ffi/cvector
         ffi/unsafe)

(provide (struct-out rkm-physical-device)
         (struct-out rkm-physical-device-features)
         rkm-get-physical-device
         rkm-create-physical-device-features
         rkm-get-family-queues-properties
         
         get-surface-formats
         get-surface-present-modes
         get-surface-capabilities)

; ----------------------------------------------------
; ------------------- Estructuras --------------------
; ----------------------------------------------------

; Estructura de un dispositivo fisico
(struct rkm-physical-device
  (vk-physical-device))


; Estructura de las caracteristicas de un dispositivo fisico
(struct rkm-physical-device-features
  (vk-physical-device-features))


; ----------------------------------------------------
; ---------------- Funciones privadas ----------------
; ----------------------------------------------------

; --- Dispositivos disponibles ---

; Retorna una lista con todos los dispositivos
(define (enumerate-physical-devices vk-instance)

  (define physical-device-count (make-cvar _uint32))
  (define count-result (vkEnumeratePhysicalDevices vk-instance (cvar-ptr physical-device-count) #f))
  (check-vkResult count-result 'enumerate-physical-devices)
  (when (not (> (cvar-ref physical-device-count) 0))
    (error 'enumerate-physical-devices "No physical devices found"))
  (define physical-devices (make-cvector _VkPhysicalDevice (cvar-ref physical-device-count)))
  (vkEnumeratePhysicalDevices vk-instance (cvar-ptr physical-device-count) (cvector-ptr physical-devices))
  (cvector->list physical-devices))


; --- Tipo de dispositivo ---

; Comprueba que un dispositivo es de cierto tipo
(define (check-type vk-physical-device type)

  (define properties (make-cvar _VkPhysicalDeviceProperties))
  (vkGetPhysicalDeviceProperties vk-physical-device (cvar-ptr properties))

  (equal? (VkPhysicalDeviceProperties-deviceType (cvar-ref properties)) type))


; --- Extensiones del dispositivo ---

; Devuelve las extensiones disponibles en el dispositivo
(define (get-available-extensions vk-physical-device)

  (define extension-count (make-cvar _uint32))
  (vkEnumerateDeviceExtensionProperties vk-physical-device #f (cvar-ptr extension-count) #f)
  (define available-extensions (make-cvector _VkExtensionProperties (cvar-ref extension-count)))
  (vkEnumerateDeviceExtensionProperties vk-physical-device #f (cvar-ptr extension-count) (cvector-ptr available-extensions))
  
  (cvector->list available-extensions))


; Comprueba la disponibilidad de las extensiones en el dispositivo
(define (check-extension-support vk-physical-device required-extensions)

  (define available-extensions (get-available-extensions vk-physical-device))

  (for/and ([required-extension required-extensions])
    (for/or ([available-extension available-extensions])
      (equal? required-extension (array->bytes (VkExtensionProperties-extensionName available-extension))))))


; --- Familias de colas ---

; Devuelve las propiedades de las familias de colas de un dispositivo
(define (get-family-queues-properties vk-physical-device)

  (define family-queues-count (make-cvar _uint32))
  (vkGetPhysicalDeviceQueueFamilyProperties vk-physical-device (cvar-ptr family-queues-count) #f)
  (define family-queues-properties (make-cvector _VkQueueFamilyProperties (cvar-ref family-queues-count)))
  (vkGetPhysicalDeviceQueueFamilyProperties vk-physical-device (cvar-ptr family-queues-count) (cvector-ptr family-queues-properties))
  
  (cvector->list family-queues-properties))


; Comprueba la validez de las familias de colas de un dispositivo
(define (check-queue-family-support vk-physical-device required-flags vk-surface)

  (define family-queues-properties (get-family-queues-properties vk-physical-device))

  (for/fold ([saved-flags 0] [saved-present-queue #f] [result #f] #:result result)
            ([i (build-list (length family-queues-properties) values)] [family-property family-queues-properties] #:break result)
    (define current-flags (bitwise-and (VkQueueFamilyProperties-queueFlags family-property) required-flags))
    (define present-queue (make-cvar _VkBool32))
    (vkGetPhysicalDeviceSurfaceSupportKHR vk-physical-device i vk-surface (cvar-ptr present-queue))
    (define current-present-queue (or saved-present-queue (equal? (cvar-ref present-queue) VK_TRUE)))
    (values current-flags current-present-queue (and (equal? current-flags required-flags) current-present-queue))))


; --- Caracteristicas del dispositivo ---

; Comprueba la disponibilidad de las caracteristicas de un dispositivo
(define (check-available-features vk-physical-device vk-wanted-features)

  (define (vk-implies vk-bool1 vk-bool2)
    (implies (equal? vk-bool1 VK_TRUE) (equal? vk-bool2 VK_TRUE)))

  (define cv-supported-features (make-cvar _VkPhysicalDeviceFeatures))
  (vkGetPhysicalDeviceFeatures vk-physical-device (cvar-ptr cv-supported-features))
  (define vk-supported-features (cvar-ref cv-supported-features))

  (and (vk-implies (VkPhysicalDeviceFeatures-robustBufferAccess vk-wanted-features) (VkPhysicalDeviceFeatures-robustBufferAccess vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-fullDrawIndexUint32 vk-wanted-features) (VkPhysicalDeviceFeatures-fullDrawIndexUint32 vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-imageCubeArray vk-wanted-features) (VkPhysicalDeviceFeatures-imageCubeArray vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-independentBlend vk-wanted-features) (VkPhysicalDeviceFeatures-independentBlend vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-geometryShader vk-wanted-features) (VkPhysicalDeviceFeatures-geometryShader vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-tessellationShader vk-wanted-features) (VkPhysicalDeviceFeatures-tessellationShader vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sampleRateShading vk-wanted-features) (VkPhysicalDeviceFeatures-sampleRateShading vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-dualSrcBlend vk-wanted-features) (VkPhysicalDeviceFeatures-dualSrcBlend vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-logicOp vk-wanted-features) (VkPhysicalDeviceFeatures-logicOp vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-multiDrawIndirect vk-wanted-features) (VkPhysicalDeviceFeatures-multiDrawIndirect vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-drawIndirectFirstInstance vk-wanted-features) (VkPhysicalDeviceFeatures-drawIndirectFirstInstance vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-depthClamp vk-wanted-features) (VkPhysicalDeviceFeatures-depthClamp vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-depthBiasClamp vk-wanted-features) (VkPhysicalDeviceFeatures-depthBiasClamp vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-fillModeNonSolid vk-wanted-features) (VkPhysicalDeviceFeatures-fillModeNonSolid vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-depthBounds vk-wanted-features) (VkPhysicalDeviceFeatures-depthBounds vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-wideLines vk-wanted-features) (VkPhysicalDeviceFeatures-wideLines vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-largePoints vk-wanted-features) (VkPhysicalDeviceFeatures-largePoints vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-alphaToOne vk-wanted-features) (VkPhysicalDeviceFeatures-alphaToOne vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-multiViewport vk-wanted-features) (VkPhysicalDeviceFeatures-multiViewport vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-samplerAnisotropy vk-wanted-features) (VkPhysicalDeviceFeatures-samplerAnisotropy vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-textureCompressionETC2 vk-wanted-features) (VkPhysicalDeviceFeatures-textureCompressionETC2 vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-textureCompressionASTC_LDR vk-wanted-features) (VkPhysicalDeviceFeatures-textureCompressionASTC_LDR vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-textureCompressionBC vk-wanted-features) (VkPhysicalDeviceFeatures-textureCompressionBC vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-occlusionQueryPrecise vk-wanted-features) (VkPhysicalDeviceFeatures-occlusionQueryPrecise vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-pipelineStatisticsQuery vk-wanted-features) (VkPhysicalDeviceFeatures-pipelineStatisticsQuery vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-vertexPipelineStoresAndAtomics vk-wanted-features) (VkPhysicalDeviceFeatures-vertexPipelineStoresAndAtomics vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-fragmentStoresAndAtomics vk-wanted-features) (VkPhysicalDeviceFeatures-fragmentStoresAndAtomics vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderTessellationAndGeometryPointSize vk-wanted-features) (VkPhysicalDeviceFeatures-shaderTessellationAndGeometryPointSize vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderImageGatherExtended vk-wanted-features) (VkPhysicalDeviceFeatures-shaderImageGatherExtended vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderStorageImageExtendedFormats vk-wanted-features) (VkPhysicalDeviceFeatures-shaderStorageImageExtendedFormats vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderStorageImageMultisample vk-wanted-features) (VkPhysicalDeviceFeatures-shaderStorageImageMultisample vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderStorageImageReadWithoutFormat vk-wanted-features) (VkPhysicalDeviceFeatures-shaderStorageImageReadWithoutFormat vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderStorageImageWriteWithoutFormat vk-wanted-features) (VkPhysicalDeviceFeatures-shaderStorageImageWriteWithoutFormat vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderUniformBufferArrayDynamicIndexing vk-wanted-features) (VkPhysicalDeviceFeatures-shaderUniformBufferArrayDynamicIndexing vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderSampledImageArrayDynamicIndexing vk-wanted-features) (VkPhysicalDeviceFeatures-shaderSampledImageArrayDynamicIndexing vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderStorageBufferArrayDynamicIndexing vk-wanted-features) (VkPhysicalDeviceFeatures-shaderStorageBufferArrayDynamicIndexing vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderStorageImageArrayDynamicIndexing vk-wanted-features) (VkPhysicalDeviceFeatures-shaderStorageImageArrayDynamicIndexing vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderClipDistance vk-wanted-features) (VkPhysicalDeviceFeatures-shaderClipDistance vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderCullDistance vk-wanted-features) (VkPhysicalDeviceFeatures-shaderCullDistance vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderFloat64 vk-wanted-features) (VkPhysicalDeviceFeatures-shaderFloat64 vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderInt64 vk-wanted-features) (VkPhysicalDeviceFeatures-shaderInt64 vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderInt16 vk-wanted-features) (VkPhysicalDeviceFeatures-shaderInt16 vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderResourceResidency vk-wanted-features) (VkPhysicalDeviceFeatures-shaderResourceResidency vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-shaderResourceMinLod vk-wanted-features) (VkPhysicalDeviceFeatures-shaderResourceMinLod vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseBinding vk-wanted-features) (VkPhysicalDeviceFeatures-sparseBinding vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidencyBuffer vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidencyBuffer vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidencyImage2D vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidencyImage2D vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidencyImage3D vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidencyImage3D vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidency2Samples vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidency2Samples vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidency4Samples vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidency4Samples vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidency8Samples vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidency8Samples vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidency16Samples vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidency16Samples vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-sparseResidencyAliased vk-wanted-features) (VkPhysicalDeviceFeatures-sparseResidencyAliased vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-variableMultisampleRate vk-wanted-features) (VkPhysicalDeviceFeatures-variableMultisampleRate vk-supported-features))
       (vk-implies (VkPhysicalDeviceFeatures-inheritedQueries vk-wanted-features) (VkPhysicalDeviceFeatures-inheritedQueries vk-supported-features))))


; --- Presentacion de una surface ---

; Devuelve las prestaciones de una surface
(define (get-surface-capabilities vk-physical-device vk-surface)

  (define capabilities (make-cvar _VkSurfaceCapabilitiesKHR))
  (vkGetPhysicalDeviceSurfaceCapabilitiesKHR vk-physical-device vk-surface (cvar-ptr capabilities))

  (cvar-ref capabilities))


; Devuelve los formatos disponibles de un surface en el dispositivo
(define (get-surface-formats vk-physical-device vk-surface)

  (define format-count (make-cvar _uint32))
  (vkGetPhysicalDeviceSurfaceFormatsKHR vk-physical-device vk-surface (cvar-ptr format-count) #f)
  (define formats (make-cvector _VkSurfaceFormatKHR (cvar-ref format-count)))
  (vkGetPhysicalDeviceSurfaceFormatsKHR vk-physical-device vk-surface (cvar-ptr format-count) (cvector-ptr formats))

  (cvector->list formats))


; Devuelve los modos de presentacion de un surface en el dispositivo
(define (get-surface-present-modes vk-physical-device vk-surface)

  (define mode-count (make-cvar _uint32))
  (vkGetPhysicalDeviceSurfacePresentModesKHR vk-physical-device vk-surface (cvar-ptr mode-count) #f)
  (define present-modes (make-cvector _VkPresentModeKHR (cvar-ref mode-count)))
  (vkGetPhysicalDeviceSurfacePresentModesKHR vk-physical-device vk-surface (cvar-ptr mode-count) (cvector-ptr present-modes))

  (cvector->list present-modes))


; Comprueba la validez de un surface
(define (check-surface-presentation-support vk-physical-device vk-surface)

  (define surface-formats (get-surface-formats vk-physical-device vk-surface))
  (define surface-present-modes (get-surface-present-modes vk-physical-device vk-surface))

  (and (not (null? surface-formats)) (not (null? surface-present-modes))))


; --- Tipo de memoria ---

; Devuelve el tipo de memoria que cumple unos requisitos
(define (get-memory-type vk-physical-device type-filter property-flags)

  (define mem-properties (make-cvar _VkPhysicalDeviceMemoryProperties))
  (vkGetPhysicalDeviceMemoryProperties vk-physical-device (cvar-ptr mem-properties))

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
(define (get-format vk-physical-device possible-formats tiling features)

  (define the-format
    (for/or ([format possible-formats])
      (define format-properties (make-cvar _VkFormatProperties))
      (vkGetPhysicalDeviceFormatProperties vk-physical-device format (cvar-ptr format-properties))

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


; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; --- Caracteristicas del dispositivo ---

; Crea una estructura de caracteristicas de un dispositivo
(define (rkm-create-physical-device-features #:robustBufferAccess [robustBufferAccess VK_FALSE]
                                             #:fullDrawIndexUint32 [fullDrawIndexUint32 VK_FALSE]
                                             #:imageCubeArray [imageCubeArray VK_FALSE]
                                             #:independentBlend [independentBlend VK_FALSE]
                                             #:geometryShader [geometryShader VK_FALSE]
                                             #:tessellationShader [tessellationShader VK_FALSE]
                                             #:sampleRateShading [sampleRateShading VK_FALSE]
                                             #:dualSrcBlend [dualSrcBlend VK_FALSE]
                                             #:logicOp [logicOp VK_FALSE]
                                             #:multiDrawIndirect [multiDrawIndirect VK_FALSE]
                                             #:drawIndirectFirstInstance [drawIndirectFirstInstance VK_FALSE]
                                             #:depthClamp [depthClamp VK_FALSE]
                                             #:depthBiasClamp [depthBiasClamp VK_FALSE]
                                             #:fillModeNonSolid [fillModeNonSolid VK_FALSE]
                                             #:depthBounds [depthBounds VK_FALSE]
                                             #:wideLines [wideLines VK_FALSE]
                                             #:largePoints [largePoints VK_FALSE]
                                             #:alphaToOne [alphaToOne VK_FALSE]
                                             #:multiViewport [multiViewport VK_FALSE]
                                             #:samplerAnisotropy [samplerAnisotropy VK_FALSE]
                                             #:textureCompressionETC2 [textureCompressionETC2 VK_FALSE]
                                             #:textureCompressionASTC_LDR [textureCompressionASTC_LDR VK_FALSE]
                                             #:textureCompressionBC [textureCompressionBC VK_FALSE]
                                             #:occlusionQueryPrecise [occlusionQueryPrecise VK_FALSE]
                                             #:pipelineStatisticsQuery [pipelineStatisticsQuery VK_FALSE]
                                             #:vertexPipelineStoresAndAtomics [vertexPipelineStoresAndAtomics VK_FALSE]
                                             #:fragmentStoresAndAtomics [fragmentStoresAndAtomics VK_FALSE]
                                             #:shaderTessellationAndGeometryPointSize [shaderTessellationAndGeometryPointSize VK_FALSE]
                                             #:shaderImageGatherExtended [shaderImageGatherExtended VK_FALSE]
                                             #:shaderStorageImageExtendedFormats [shaderStorageImageExtendedFormats VK_FALSE]
                                             #:shaderStorageImageMultisample [shaderStorageImageMultisample VK_FALSE]
                                             #:shaderStorageImageReadWithoutFormat [shaderStorageImageReadWithoutFormat VK_FALSE]
                                             #:shaderStorageImageWriteWithoutFormat [shaderStorageImageWriteWithoutFormat VK_FALSE]
                                             #:shaderUniformBufferArrayDynamicIndexing [shaderUniformBufferArrayDynamicIndexing VK_FALSE]
                                             #:shaderSampledImageArrayDynamicIndexing [shaderSampledImageArrayDynamicIndexing VK_FALSE]
                                             #:shaderStorageBufferArrayDynamicIndexing [shaderStorageBufferArrayDynamicIndexing VK_FALSE]
                                             #:shaderStorageImageArrayDynamicIndexing [shaderStorageImageArrayDynamicIndexing VK_FALSE]
                                             #:shaderClipDistance [shaderClipDistance VK_FALSE]
                                             #:shaderCullDistance [shaderCullDistance VK_FALSE]
                                             #:shaderFloat64 [shaderFloat64 VK_FALSE]
                                             #:shaderInt64 [shaderInt64 VK_FALSE]
                                             #:shaderInt16 [shaderInt16 VK_FALSE]
                                             #:shaderResourceResidency [shaderResourceResidency VK_FALSE]
                                             #:shaderResourceMinLod [shaderResourceMinLod VK_FALSE]
                                             #:sparseBinding [sparseBinding VK_FALSE]
                                             #:sparseResidencyBuffer [sparseResidencyBuffer VK_FALSE]
                                             #:sparseResidencyImage2D [sparseResidencyImage2D VK_FALSE]
                                             #:sparseResidencyImage3D [sparseResidencyImage3D VK_FALSE]
                                             #:sparseResidency2Samples [sparseResidency2Samples VK_FALSE]
                                             #:sparseResidency4Samples [sparseResidency4Samples VK_FALSE]
                                             #:sparseResidency8Samples [sparseResidency8Samples VK_FALSE]
                                             #:sparseResidency16Samples [sparseResidency16Samples VK_FALSE]
                                             #:sparseResidencyAliased [sparseResidencyAliased VK_FALSE]
                                             #:variableMultisampleRate [variableMultisampleRate VK_FALSE]
                                             #:inheritedQueries [inheritedQueries VK_FALSE])
                                    
  (rkm-physical-device-features (make-VkPhysicalDeviceFeatures robustBufferAccess
                                                               fullDrawIndexUint32
                                                               imageCubeArray
                                                               independentBlend
                                                               geometryShader
                                                               tessellationShader
                                                               sampleRateShading
                                                               dualSrcBlend
                                                               logicOp
                                                               multiDrawIndirect
                                                               drawIndirectFirstInstance
                                                               depthClamp
                                                               depthBiasClamp
                                                               fillModeNonSolid
                                                               depthBounds
                                                               wideLines
                                                               largePoints
                                                               alphaToOne
                                                               multiViewport
                                                               samplerAnisotropy
                                                               textureCompressionETC2
                                                               textureCompressionASTC_LDR
                                                               textureCompressionBC
                                                               occlusionQueryPrecise
                                                               pipelineStatisticsQuery
                                                               vertexPipelineStoresAndAtomics
                                                               fragmentStoresAndAtomics
                                                               shaderTessellationAndGeometryPointSize
                                                               shaderImageGatherExtended
                                                               shaderStorageImageExtendedFormats
                                                               shaderStorageImageMultisample
                                                               shaderStorageImageReadWithoutFormat
                                                               shaderStorageImageWriteWithoutFormat
                                                               shaderUniformBufferArrayDynamicIndexing
                                                               shaderSampledImageArrayDynamicIndexing
                                                               shaderStorageBufferArrayDynamicIndexing
                                                               shaderStorageImageArrayDynamicIndexing
                                                               shaderClipDistance
                                                               shaderCullDistance
                                                               shaderFloat64
                                                               shaderInt64
                                                               shaderInt16
                                                               shaderResourceResidency
                                                               shaderResourceMinLod
                                                               sparseBinding
                                                               sparseResidencyBuffer
                                                               sparseResidencyImage2D
                                                               sparseResidencyImage3D
                                                               sparseResidency2Samples
                                                               sparseResidency4Samples
                                                               sparseResidency8Samples
                                                               sparseResidency16Samples
                                                               sparseResidencyAliased
                                                               variableMultisampleRate
                                                               inheritedQueries)))


; --- Dispositivo fisico ---

; Devuelve un dispositivo que cumpla con los requerimientos
(define (rkm-get-physical-device instance #:surface [surface #f] #:type [type VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU] 
                                 #:extensions [extensions (list VK_KHR_SWAPCHAIN_EXTENSION_NAME)] 
                                 #:queue-flags [queue-flags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                                                         VK_QUEUE_TRANSFER_BIT
                                                                         VK_QUEUE_COMPUTE_BIT)] 
                                 #:features [wanted-features #f])

  (define vk-instance (rkm-instance-vk-instance instance))
  (define vk-surface (and surface (rkm-surface-vk-surface surface)))
  (define vk-wanted-features (and wanted-features (rkm-physical-device-features-vk-physical-device-features wanted-features)))

  (define physical-devices (enumerate-physical-devices vk-instance))

  (define the-physical-device
    (for/or ([vk-physical-device physical-devices])
      (if (and (implies type (check-type vk-physical-device type))
               (implies extensions (check-extension-support vk-physical-device extensions))
               (implies vk-surface (check-queue-family-support vk-physical-device queue-flags vk-surface))
               (implies vk-wanted-features (check-available-features vk-physical-device vk-wanted-features))
               (implies vk-surface (check-surface-presentation-support vk-physical-device vk-surface)))
          vk-physical-device
          #f)))

  (when (not the-physical-device)
    (error 'get-physical-device "No valid physical device found"))
  (rkm-physical-device the-physical-device))


; --- Familias de colas ---

; Devuelve las propiedades de las familias de colas de un dispositivo
(define (rkm-get-family-queues-properties physical-device)
  
  (define vk-physical-device (rkm-physical-device-vk-physical-device))
  (get-family-queues-properties vk-physical-device))