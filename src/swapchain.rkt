#lang racket/base


(require "physical-device.rkt"
         "device.rkt"
         "window.rkt"
         "surface.rkt"
         "cvar.rkt"
         ffi/unsafe
         ffi/cvector
         vulkan/unsafe
         glfw3)


(provide rkm-create-swapchain
         (struct-out rkm-swapchain)
         rkm-destroy-swapchain)



; struct de un swapchain
(struct rkm-swapchain
  (device
   vk-swapchain
   format
   extent
   image-count
   images
   image-views))


; El maximo valor de un entero de 32 bits
(define UINT32_MAX (- (expt 2 64) 1))



; Devuelve un formato para el swapchain
(define (choose-format vk-physical-device vk-surface)

  (define formats (get-surface-formats vk-physical-device vk-surface))

  (define the-format
    (for/or ([format formats])
      (if (and (equal? (VkSurfaceFormatKHR-format format) VK_FORMAT_B8G8R8A8_SRGB)
               (equal? (VkSurfaceFormatKHR-colorSpace format) VK_COLOR_SPACE_SRGB_NONLINEAR_KHR))
          format
          #f)))

  (if the-format
      the-format
      (car formats)))



; Devuelve un modo de presentacion para el swapchain
(define (choose-present-mode vk-physical-device vk-surface)

  (define present-modes (get-surface-present-modes vk-physical-device vk-surface))

  (define the-mode
    (for/or ([mode present-modes])
      (if (equal? mode VK_PRESENT_MODE_MAILBOX_KHR)
          mode
          #f)))

  (if the-mode
      the-mode
      VK_PRESENT_MODE_FIFO_KHR))



; Devuelve unas dimensiones para el swapchain
(define (choose-extent vk-physical-device vk-surface glfw-window)

  (define surface-capabilities (get-surface-capabilities vk-physical-device vk-surface))

  (if (not (equal? (VkExtent2D-width (VkSurfaceCapabilitiesKHR-currentExtent surface-capabilities)) UINT32_MAX))
      (VkSurfaceCapabilitiesKHR-currentExtent surface-capabilities)
      (let ([win-width (make-cvar _int)] [win-height (make-cvar _int)])
        (glfwGetWindowSize glfw-window (cvar-ptr win-width) (cvar-ptr win-height))
        (make-VkExtent2D (max (VkExtent2D-width (VkSurfaceCapabilitiesKHR-minImageExtent surface-capabilities))
                              (min (VkExtent2D-width (VkSurfaceCapabilitiesKHR-maxImageExtent surface-capabilities))
                                   (cast (cvar-ref win-width) _int _uint32)))
                         (max (VkExtent2D-height (VkSurfaceCapabilitiesKHR-minImageExtent surface-capabilities))
                              (min (VkExtent2D-height (VkSurfaceCapabilitiesKHR-maxImageExtent surface-capabilities))
                                   (cast (cvar-ref win-height) _int _uint32)))))))



; Devuelve un pre transform para el swapchain
(define (choose-pre-transform vk-physical-device vk-surface)

  (define surface-capabilities (get-surface-capabilities vk-physical-device vk-surface))

  (VkSurfaceCapabilitiesKHR-currentTransform surface-capabilities))



; Devuelve un numero de imagenes para el swapchain
(define (choose-image-count vk-physical-device vk-surface)

  (define surface-capabilities (get-surface-capabilities vk-physical-device vk-surface))

  (if (and (> (VkSurfaceCapabilitiesKHR-maxImageCount surface-capabilities) 0)
           (>= (VkSurfaceCapabilitiesKHR-minImageCount surface-capabilities) (VkSurfaceCapabilitiesKHR-maxImageCount surface-capabilities)))
      (VkSurfaceCapabilitiesKHR-maxImageCount surface-capabilities)
      (add1 (VkSurfaceCapabilitiesKHR-minImageCount surface-capabilities))))



; Crea un swapchain
(define (rkm-create-swapchain device window)

  ;Obtenemos informacion preliminar
  (define vk-physical-device (rkm-device-vk-physical-device device))
  (define vk-surface (rkm-surface-vk-surface (rkm-window-surface window)))
  (define vk-device (rkm-device-vk-device device))
  (define glfw-window (rkm-window-glfw-window window))
  (define graphics-index (rkm-device-graphics-index device))
  (define present-index (rkm-device-present-index device))

  (define format (choose-format vk-physical-device vk-surface))
  (define present-mode (choose-present-mode vk-physical-device vk-surface))
  (define extent (choose-extent vk-physical-device vk-surface glfw-window))
  (define pre-transform (choose-pre-transform vk-physical-device vk-surface))
  (define image-count (choose-image-count vk-physical-device vk-surface))

  (define-values (sharing-mode index-count indices)
    (if (not (equal? graphics-index present-index))
        (values VK_SHARING_MODE_CONCURRENT 2 (list->cblock `(,graphics-index ,present-index) _uint32))
        (values VK_SHARING_MODE_EXCLUSIVE 0 #f)))

  ;Creamos el swapchain
  (define swapchain-info (make-VkSwapchainCreateInfoKHR VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
                                                        #f
                                                        0
                                                        vk-surface
                                                        image-count
                                                        (VkSurfaceFormatKHR-format format)
                                                        (VkSurfaceFormatKHR-colorSpace format)
                                                        extent
                                                        1
                                                        VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT
                                                        sharing-mode
                                                        index-count
                                                        indices
                                                        pre-transform
                                                        VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
                                                        present-mode
                                                        VK_TRUE
                                                        #f))  ;Esto deberia ser VK_NULL_HANDLE

  (define swapchain (make-cvar _VkSwapchainKHR))
  (define swapchain-result (vkCreateSwapchainKHR vk-device swapchain-info #f (cvar-ptr swapchain)))
  (check-vkResult swapchain-result 'create-swapchain)
  (define vk-swapchain (cvar-ref swapchain))

  ;Obtenemos las imagenes
  (define true-image-count (make-cvar _uint32))
  (vkGetSwapchainImagesKHR vk-device vk-swapchain (cvar-ptr true-image-count) #f)
  (define images (make-cvector _VkImage (cvar-ref true-image-count)))
  (vkGetSwapchainImagesKHR vk-device vk-swapchain (cvar-ptr true-image-count) (cvector-ptr images))

  ;Creamos las imageviews
  (define image-views (for/list ([i (build-list image-count values)])
                        (define image-view-info (make-VkImageViewCreateInfo VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
                                                                            #f
                                                                            0
                                                                            (cvector-ref images 0)
                                                                            VK_IMAGE_VIEW_TYPE_2D
                                                                            (VkSurfaceFormatKHR-format format)
                                                                            (make-VkComponentMapping VK_COMPONENT_SWIZZLE_IDENTITY
                                                                                                     VK_COMPONENT_SWIZZLE_IDENTITY
                                                                                                     VK_COMPONENT_SWIZZLE_IDENTITY
                                                                                                     VK_COMPONENT_SWIZZLE_IDENTITY)
                                                                            (make-VkImageSubresourceRange VK_IMAGE_ASPECT_COLOR_BIT
                                                                                                          0
                                                                                                          1
                                                                                                          0
                                                                                                          1)))
                        (define image-view (make-cvar _VkImageView))
                        (define view-result (vkCreateImageView vk-device image-view-info #f (cvar-ptr image-view)))
                        (check-vkResult view-result 'create-swapchain)
                        (cvar-ref image-view)))

  ;Devolvemos el swapchain
  (rkm-swapchain device vk-swapchain
                 format extent
                 (cvar-ref true-image-count)
                 (cvector->list images) image-views))



; Destruye un swapchain y las imageviews
(define (rkm-destroy-swapchain swapchain)

  (define vk-device (rkm-device-vk-device (rkm-swapchain-device swapchain)))
  (define image-views (rkm-swapchain-image-views swapchain))
  (define vk-swapchain (rkm-swapchain-vk-swapchain swapchain))

  (for ([image-view image-views])
    (vkDestroyImageView vk-device image-view #f))

  (vkDestroySwapchainKHR vk-device vk-swapchain #f))

