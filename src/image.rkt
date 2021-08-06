#lang racket/base

;(require racket/draw)
; read-bitmap   save-file (method)   get-data-from-file (method)

(require vulkan/unsafe
         ffi/unsafe)



; ----------------------------------------------------
; ------------------- Estructuras --------------------
; ----------------------------------------------------

(struct rkm-image
    (vk-device
     vk-image
     vk-memory))

    
; ----------------------------------------------------
; ---------------- Funciones privadas ----------------
; ----------------------------------------------------

; Devuelve el tipo de memoria que cumple unos requisitos
(define (get-memory-type-index vk-physical-device type-filter property-flags)

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


; Devuelve los requisitos de memoria de una imagen
(define (get-image-memory-requirements vk-device vk-image)

    (define cv-mem-requirements (make-cvar _VkMemoryRequirements))
    (vkGetImageMemoryRequirements vk-device vk-image (cvar-ptr cv-mem-requirements))
    
    (cvar-ref cv-mem-requirements))


; Crea una imagen y su correspondiente memoria
(define (create-image/memory vk-physical-device vk-device width height format tiling usage properties queue-family-indices)

    (define sharing-mode (if (> (length queue-family-indices) 1) VK_SHARING_MODE_CONCURRENT VK_SHARING_MODE_EXCLUSIVE))
    (define queue-family-index-count (length queue-family-indices))
    (define cv-family-indices (list->cvector queue-family-indices _uint32))


    (define image-create-info (make-VkImageCreateInfo VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO
                                                      #f
                                                      0
                                                      VK_IMAGE_TYPE_2D
                                                      format
                                                      (make-VkExtent3D width
                                                                       height
                                                                       1)
                                                      1
                                                      1
                                                      VK_SAMPLE_COUNT_1_BIT
                                                      tiling
                                                      usage
                                                      sharing-mode
                                                      queue-family-index-count
                                                      (cvector-ptr cv-family-indices)
                                                      VK_IMAGE_LAYOUT_UNDEFINED))
                                                      
    (define cv-image (make-cvar _VkImage))
    (define image-result (vkCreateImage vk-device image-create-info #f (cvar-ptr cv-image)))
    (check-vkResult image-result)
    (define vk-image (cvar-ref cv-image))
    
    (define vk-memory-requirements (get-image-memory-requirements device vk-image))

    (define allocation-size (VkMemoryAllocateInfo-size vk-memory-requirements))
    (define memory-type-index (get-memory-type-index vk-physical-device 
                                                     (VkMemoryAllocateInfo-memoryTypeBits vk-memory-requirements)
                                                     properties))
    
    (define alloc-info (make-VkMemoryAllocateInfo VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
                                                  #f
                                                  allocation-size
                                                  memory-type-index))

    (define cv-memory (make-cvar _VkDeviceMemory))                                             
    (define alloc-result (vkAllocateMemory device alloc-info #f (cvar-ptr cv-memory)))
    (check-vkResult alloc-result)
    (define vk-memory (cvar-ref cv-memory))
    
    (vkBindImageMemory device vk-image vk-memory 0)
    
    (values vk-image vk-memory))


; Crea una estructura que representa una imagen
(define (create-image physical-device device width height format usage)

    (define vk-physical-device (rkm-physical-device-vk-physical-device physical-device))
    (define vk-device (rkm-device-vk-device device))
    
    (define-values (vk-image vk-memory) (create-image/memory vk-physical-device vk-device width height
                                                             format VK_IMAGE_TILING_OPTIMAL usage
                                                             VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT))
                                                             
    (rkm-image vk-device vk-image vk-memory))


; Destruye una imagen
(define (destroy-image image)

    (define vk-device (rkm-image-vk-device image))
    (define vk-image (rkm-image-vk-image image))
    (define vk-memory (rkm-image-vk-memory image))
    
    (vkFreeMemory vk-device vk-memory #f)
    (vkDestroyImage vk-device vk-image #f))


; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; Constructor de una imagen
(define rkm-create-image ((allocator destroy-image) create-image))