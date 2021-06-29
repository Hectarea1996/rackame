#lang scribble/manual
@(require (for-label racket
                     rackame))


@title{Dispositivo físico}


@defstruct[rkm-physical-device-features ([vk-physical-device-features VkPhysicalDeviceFeatures])]{
    Representa un objeto de tipo VkPhysicalDeviceFeatures.
}


@defproc[(rkm-create-physical-device-features [#:robustBufferAccess robustBufferAccess VkBool32 #f]
                                              [#:fullDrawIndexUint32 fullDrawIndexUint32 VkBool32 #f]
                                              [#:imageCubeArray imageCubeArray VkBool32 #f]
                                              [#:independentBlend independentBlend VkBool32 #f]
                                              [#:geometryShader geometryShader VkBool32 #f]
                                              [#:tessellationShader tessellationShader VkBool32 #f]
                                              [#:sampleRateShading sampleRateShading VkBool32 #f]
                                              [#:dualSrcBlend dualSrcBlend VkBool32 #f]
                                              [#:logicOp logicOp VkBool32 #f]
                                              [#:multiDrawIndirect multiDrawIndirect VkBool32 #f]
                                              [#:drawIndirectFirstInstance drawIndirectFirstInstance VkBool32 #f]
                                              [#:depthClamp depthClamp VkBool32 #f]
                                              [#:depthBiasClamp depthBiasClamp VkBool32 #f]
                                              [#:fillModeNonSolid fillModeNonSolid VkBool32 #f]
                                              [#:depthBounds depthBounds VkBool32 #f]
                                              [#:wideLines wideLines VkBool32 #f]
                                              [#:largePoints largePoints VkBool32 #f]
                                              [#:alphaToOne alphaToOne VkBool32 #f]
                                              [#:multiViewport multiViewport VkBool32 #f]
                                              [#:samplerAnisotropy samplerAnisotropy VkBool32 #f]
                                              [#:textureCompressionETC2 textureCompressionETC2 VkBool32 #f]
                                              [#:textureCompressionASTC_LDR textureCompressionASTC_LDR VkBool32 #f]
                                              [#:textureCompressionBC textureCompressionBC VkBool32 #f]
                                              [#:occlusionQueryPrecise occlusionQueryPrecise VkBool32 #f]
                                              [#:pipelineStatisticsQuery pipelineStatisticsQuery VkBool32 #f]
                                              [#:vertexPipelineStoresAndAtomics vertexPipelineStoresAndAtomics VkBool32 #f]
                                              [#:fragmentStoresAndAtomics fragmentStoresAndAtomics VkBool32 #f]
                                              [#:shaderTessellationAndGeometryPointSize shaderTessellationAndGeometryPointSize VkBool32 #f]
                                              [#:shaderImageGatherExtended shaderImageGatherExtended VkBool32 #f]
                                              [#:shaderStorageImageExtendedFormats shaderStorageImageExtendedFormats VkBool32 #f]
                                              [#:shaderStorageImageMultisample shaderStorageImageMultisample VkBool32 #f]
                                              [#:shaderStorageImageReadWithoutFormat shaderStorageImageReadWithoutFormat VkBool32 #f]
                                              [#:shaderStorageImageWriteWithoutFormat shaderStorageImageWriteWithoutFormat VkBool32 #f]
                                              [#:shaderUniformBufferArrayDynamicIndexing shaderUniformBufferArrayDynamicIndexing VkBool32 #f]
                                              [#:shaderSampledImageArrayDynamicIndexing shaderSampledImageArrayDynamicIndexing VkBool32 #f]
                                              [#:shaderStorageBufferArrayDynamicIndexing shaderStorageBufferArrayDynamicIndexing VkBool32 #f]
                                              [#:shaderStorageImageArrayDynamicIndexing shaderStorageImageArrayDynamicIndexing VkBool32 #f]
                                              [#:shaderClipDistance shaderClipDistance VkBool32 #f]
                                              [#:shaderCullDistance shaderCullDistance VkBool32 #f]
                                              [#:shaderFloat64 shaderFloat64 VkBool32 #f]
                                              [#:shaderInt64 shaderInt64 VkBool32 #f]
                                              [#:shaderInt16 shaderInt16 VkBool32 #f]
                                              [#:shaderResourceResidency shaderResourceResidency VkBool32 #f]
                                              [#:shaderResourceMinLod shaderResourceMinLod VkBool32 #f]
                                              [#:sparseBinding sparseBinding VkBool32 #f]
                                              [#:sparseResidencyBuffer sparseResidencyBuffer VkBool32 #f]
                                              [#:sparseResidencyImage2D sparseResidencyImage2D VkBool32 #f]
                                              [#:sparseResidencyImage3D sparseResidencyImage3D VkBool32 #f]
                                              [#:sparseResidency2Samples sparseResidency2Samples VkBool32 #f]
                                              [#:sparseResidency4Samples sparseResidency4Samples VkBool32 #f]
                                              [#:sparseResidency8Samples sparseResidency8Samples VkBool32 #f]
                                              [#:sparseResidency16Samples sparseResidency16Samples VkBool32 #f]
                                              [#:sparseResidencyAliased sparseResidencyAliased VkBool32 #f]
                                              [#:variableMultisampleRate variableMultisampleRate VkBool32 #f]
                                              [#:inheritedQueries inheritedQueries VkBool32 #f])]{
    Función que facilita la creación de un objeto de tipo @racket[rkm-physical-device-features].
}


@defproc[(rkm-get-physical-device [instance VkInstance] [#:surface surface VkSurface #f] 
                                  [#:type type VkPhysicalDeviceType VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU]
                                  [#:extensions extensions (listof _bytes/nul-terminated) (list VK_KHR_SWAPCHAIN_EXTENSION_NAME)]
                                  [#:queue-flags queue-flags VkQueueFlags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                                                                       VK_QUEUE_TRANSFER_BIT
                                                                                       VK_QUEUE_COMPUTE_BIT)]
                                  [#:features wanted-features rkm-physical-device-features #f])]{
    Obtiene el primer dispositivo físico que cumpla con las siguientes propiedades:
    @itemlist[@item{@racket[surface]: Se comprueba si el dispositivo soporta el @racket[surface] y si soporta
                                      la operación de presentación sobre dicho @racket[surface].}
              @item{@racket[type]: Se comprueba que el dispositivo sea del tipo indicado.}
              @item{@racket[extensions]: Se comprueba que el dispositivo soporte las extensiones indicadas.}
              @item{@racket[queue-flags]: Se comprueba que el dispositivo contenga familias de colas
                                          con el tipo de colas indicadas.}
              @item{@racket[features]: Se comprueba que el dispositivo soporte las características indicadas.}] 
    En el caso de pasar el valor @racket[#f] en cada uno de los anteriores parámetros, se ignorará
    la comprobación correspondiente.
}