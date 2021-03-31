#lang racket/base


(require "physical-device.rkt"
         "cvar.rkt"
         vulkan/unsafe
         ffi/unsafe
         racket/list)


(provide (except-out (all-defined-out)
                     get-family-indices
                     features-checker
                     get-device-queue))


; struct device
(struct rkm-device
  (vk-phisical-device
   vk-device
   graphics-index transfer-index compute-index present-index
   graphics-queue transfer-queue compute-queue present-queue))


; Devuelve cuatro valores que se corresponden con los indices donde existen respectivamente
; colas graphic, transfer, compute y present
(define (get-family-indices physical-device surface)

  (define family-properties (get-family-queues-properties physical-device))

  (for/fold ([graphics #f] [transfer #f] [compute #f] [present #f])
            ([i (length family-properties)]
             [family-property family-properties]
             #:unless (and graphics transfer compute present))
    (define actual-graphics (if (> (bitwise-and (VkQueueFamilyProperties-queueFlags family-property) VK_QUEUE_GRAPHICS_BIT) 0)
                                i
                                #f))
    (define actual-transfer (if (> (bitwise-and (VkQueueFamilyProperties-queueFlags family-property) VK_QUEUE_TRANSFER_BIT) 0)
                                i
                                #f))
    (define actual-compute (if (> (bitwise-and (VkQueueFamilyProperties-queueFlags family-property) VK_QUEUE_COMPUTE_BIT) 0)
                                i
                                #f))
    (define actual-present (let ([present-queue (make-cvar _VkBool32)])
                             (vkGetPhysicalDeviceSurfaceSupportKHR physical-device i surface (cvar-ptr present-queue))
                             (if (equal? (cvar-ref present-queue) VK_TRUE)
                                 i
                                 #f)))
    
    (values (or graphics actual-graphics)
            (or transfer actual-transfer)
            (or compute actual-compute)
            (or present actual-present))))



; Metodo para comprobar las caracteristics existentes en un dispositivo
(define (features-checker features)
  (and (equal? (VkPhysicalDeviceFeatures-geometryShader features) VK_TRUE)
       (equal? (VkPhysicalDeviceFeatures-samplerAnisotropy features) VK_TRUE)))



; Devuelve una cola del dispositivo
(define (get-device-queue vk-device index-family)

  (define queue (make-cvar _VkQueue))
  (vkGetDeviceQueue vk-device index-family 0 (cvar-ptr queue))

  (cvar-ref queue))



; Obtiene un dispositivo y devuelve la estructura device.
(define (rkm-create-device instance surface)

  ; Requisitos
  (define device-extensions (list VK_KHR_SWAPCHAIN_EXTENSION_NAME))
  (define family-queue-flags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                          VK_QUEUE_TRANSFER_BIT
                                          VK_QUEUE_COMPUTE_BIT))
  (define physical-device-type VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU)

  ; Obtenemos un dispositivo fisico que cumpla los requisitos
  (define physical-device (get-physical-device instance
                                               surface
                                               physical-device-type
                                               device-extensions
                                               family-queue-flags
                                               features-checker))

  ; Obtenemos los indices de las familias de colas
  (define-values (graphics-index transfer-index compute-index present-index) (get-family-indices physical-device surface))
  (define family-indices (remove-duplicates (list graphics-index transfer-index compute-index present-index)))

  ; Generamos los create-info de cada familia de colas
  (define priority (cvar _float 1.0))
  (define queue-create-infos
    (for/list ([family-index family-indices])
      (make-VkDeviceQueueCreateInfo VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
                                    #f
                                    0
                                    family-index
                                    1
                                    (cvar-ptr priority))))

  ; Indicamos las caracteristicas deseadas
  (define device-features-ptr (make-VkPhysicalDeviceFeatures VK_FALSE      ;robustBufferAccess
                                                             VK_FALSE      ;fullDrawIndexUint32
                                                             VK_FALSE      ;imageCubeArray
                                                             VK_FALSE      ;independentBlend
                                                             VK_TRUE       ;geometryShader
                                                             VK_FALSE      ;tessellationShader
                                                             VK_FALSE      ;sampleRateShading
                                                             VK_FALSE      ;dualSrcBlend
                                                             VK_FALSE      ;logicOp
                                                             VK_FALSE      ;multiDrawIndirect
                                                             VK_FALSE      ;drawIndirectFirstInstance
                                                             VK_FALSE      ;depthClamp
                                                             VK_FALSE      ;depthBiasClamp
                                                             VK_FALSE      ;fillModeNonSolid
                                                             VK_FALSE      ;depthBounds
                                                             VK_FALSE      ;wideLines
                                                             VK_FALSE      ;largePoints
                                                             VK_FALSE      ;alphaToOne
                                                             VK_FALSE      ;multiViewport
                                                             VK_TRUE       ;samplerAnisotropy
                                                             VK_FALSE      ;textureCompressionETC2
                                                             VK_FALSE      ;textureCompressionASTC_LDR
                                                             VK_FALSE      ;textureCompressionBC
                                                             VK_FALSE      ;occlusionQueryPrecise
                                                             VK_FALSE      ;pipelineStatisticsQuery
                                                             VK_FALSE      ;vertexPipelineStoresAndAtomics
                                                             VK_FALSE      ;fragmentStoresAndAtomics
                                                             VK_FALSE      ;shaderTessellationAndGeometryPointSize
                                                             VK_FALSE      ;shaderImageGatherExtended
                                                             VK_FALSE      ;shaderStorageImageExtendedFormats
                                                             VK_FALSE      ;shaderStorageImageMultisample
                                                             VK_FALSE      ;shaderStorageImageReadWithoutFormat
                                                             VK_FALSE      ;shaderStorageImageWriteWithoutFormat
                                                             VK_FALSE      ;shaderUniformBufferArrayDynamicIndexing
                                                             VK_FALSE      ;shaderSampledImageArrayDynamicIndexing
                                                             VK_FALSE      ;shaderStorageBufferArrayDynamicIndexing
                                                             VK_FALSE      ;shaderStorageImageArrayDynamicIndexing
                                                             VK_FALSE      ;shaderClipDistance
                                                             VK_FALSE      ;shaderCullDistance
                                                             VK_FALSE      ;shaderFloat64
                                                             VK_FALSE      ;shaderInt64
                                                             VK_FALSE      ;shaderInt16
                                                             VK_FALSE      ;shaderResourceResidency
                                                             VK_FALSE      ;shaderResourceMinLod
                                                             VK_FALSE      ;sparseBinding
                                                             VK_FALSE      ;sparseResidencyBuffer
                                                             VK_FALSE      ;sparseResidencyImage2D
                                                             VK_FALSE      ;sparseResidencyImage3D
                                                             VK_FALSE      ;sparseResidency2Samples
                                                             VK_FALSE      ;sparseResidency4Samples
                                                             VK_FALSE      ;sparseResidency8Samples
                                                             VK_FALSE      ;sparseResidency16Samples
                                                             VK_FALSE      ;sparseResidencyAliased
                                                             VK_FALSE      ;variableMultisampleRate
                                                             VK_FALSE      ;inheritedQueries
                                                             ))

  ; Creamos el dispositivo logico
  (define device-create-info (make-VkDeviceCreateInfo VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
                                                      #f
                                                      0
                                                      (length queue-create-infos)
                                                      (cast (list->cblock queue-create-infos _VkDeviceQueueCreateInfo)
                                                            _pointer
                                                            _VkDeviceQueueCreateInfo-pointer)
                                                      0
                                                      #f
                                                      (length device-extensions)
                                                      (list->cblock device-extensions _bytes/nul-terminated)
                                                      device-features-ptr))

  (define device (make-cvar _VkDevice))
  (define device-result (vkCreateDevice physical-device device-create-info #f (cvar-ptr device)))
  (check-vkResult device-result 'create-device)

  ;Obtenemos las colas
  (define-values (graphics-queue transfer-queue compute-queue present-queue)
    (values (get-device-queue graphics-index)
            (get-device-queue transfer-index)
            (get-device-queue compute-index)
            (get-device-queue present-index)))

  ;Retornamos el dispositivo
  (rkm-device physical-device
              (cvar-ref device)
              graphics-index transfer-index compute-index present-index
              graphics-queue transfer-queue compute-queue present-queue))



; Destruye un dispositivo
(define (rkm-destroy-device device)

  (vkDestroyDevice (rkm-device-vk-device device) #f))



