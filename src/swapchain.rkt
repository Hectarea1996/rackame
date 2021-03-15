#lang racket/base


(require "physical-device.rkt"
         "cvar.rkt"
         ffi/unsafe
         ffi/cvector
         vulkan/unsafe
         glfw3)


(provide create-swapchain
         destroy-swapchain)


; El maximo valor de un entero de 32 bits
(define UINT32_MAX (- (expt 2 64) 1))



; Devuelve un formato para el swapchain
(define (choose-format physical-device surface)

  (define formats (get-surface-formats physical-device surface))

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
(define (choose-present-mode physical-device surface)

  (define present-modes (get-surface-present-modes physical-device surface))

  (define the-mode
    (for/or ([mode present-modes])
      (if (equal? mode VK_PRESENT_MODE_MAILBOX_KHR)
          mode
          #f)))

  (if the-mode
      the-mode
      VK_PRESENT_MODE_FIFO_KHR))



; Devuelve unas dimensiones para el swapchain
(define (choose-extent physical-device surface window)

  (define surface-capabilities (get-surface-capabilities physical-device surface))

  (if (not (equal? (VkExtent2D-width (VkSurfaceCapabilitiesKHR-currentExtent surface-capabilities)) UINT32_MAX))
      (VkSurfaceCapabilitiesKHR-currentExtent surface-capabilities)
      (let ([win-width (make-cvar _int)] [win-height (make-cvar _int)])
        (glfwGetWindowSize (cvar-ptr win-width) (cvar-ptr win-height))
        (make-VkExtent2D (max (VkExtent2D-width (VkSurfaceCapabilitiesKHR-minImageExtent surface-capabilities))
                              (min (VkExtent2D-width (VkSurfaceCapabilitiesKHR-maxImageExtent surface-capabilities))
                                   (cast (cvar-ref win-width) _int _uint32)))
                         (max (VkExtent2D-height (VkSurfaceCapabilitiesKHR-minImageExtent surface-capabilities))
                              (min (VkExtent2D-height (VkSurfaceCapabilitiesKHR-maxImageExtent surface-capabilities))
                                   (cast (cvar-ref win-height) _int _uint32)))))))



; Devuelve un pre transform para el swapchain
(define (choose-pre-transform physical-device surface)

  (define surface-capabilities (get-surface-capabilities physical-device surface))

  (VkSurfaceCapabilitiesKHR-currentTransform surface-capabilities))



; Devuelve un numero de imagenes para el swapchain
(define (choose-image-count physical-device surface)

  (define surface-capabilities (get-surface-capabilities physical-device surface))

  (if (and (> (VkSurfaceCapabilitiesKHR-maxImageCount surface-capabilities) 0)
           (>= (VkSurfaceCapabilitiesKHR-minImageCount surface-capabilities) (VkSurfaceCapabilitiesKHR-maxImageCount surface-capabilities)))
      (VkSurfaceCapabilitiesKHR-maxImageCount surface-capabilities)
      (add1 (VkSurfaceCapabilitiesKHR-minImageCount surface-capabilities))))


(require racket/trace)
; Crea un swapchain
(define (create-swapchain physical-device device surface window graphics-index present-index)

  (define format (choose-format physical-device surface))
  (define present-mode (choose-present-mode physical-device surface))
  (define extent (choose-extent physical-device surface window))
  (define pre-transform (choose-pre-transform physical-device surface))
  (define image-count (choose-image-count physical-device surface))
  

  (define-values (sharing-mode index-count indices)
    (if (not (equal? graphics-index present-index))
        (values VK_SHARING_MODE_CONCURRENT 2 (list->cblock `(,graphics-index ,present-index) _uint32))
        (values VK_SHARING_MODE_EXCLUSIVE 0 #f)))

  (define swapchain-info (make-VkSwapchainCreateInfoKHR VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
                                                        #f
                                                        0
                                                        surface
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
  (define swapchain-result (vkCreateSwapchainKHR device swapchain-info #f (cvar-ptr swapchain)))
  (check-vkResult swapchain-result 'create-swapchain)

  ;Obtenemos las imagenes
  (define true-image-count (make-cvar _uint32))
  (vkGetSwapchainImagesKHR device (cvar-ref swapchain) (cvar-ptr true-image-count) #f)
  (define images (make-cvector _VkImage (cvar-ref true-image-count)))
  (vkGetSwapchainImagesKHR device (cvar-ref swapchain) (cvar-ptr true-image-count) (cvector-ptr images))

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
                        (define view-result (vkCreateImageView device image-view-info #f (cvar-ptr image-view)))
                        (check-vkResult view-result 'create-swapchain)
                        (cvar-ref image-view)))

  ;Retornamos todo
  (values (cvar-ref swapchain) (cvector->list images) image-views))



; Destruye un swapchain y las imageviews
(define (destroy-swapchain device swapchain image-views)

  (for ([image-view image-views])
    (vkDestroyImageView device image-view #f))

  (vkDestroySwapchainKHR device swapchain #f))

