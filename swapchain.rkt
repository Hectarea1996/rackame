#lang racket/base


(require "physical-device.rkt")
(require vulkan/unsafe)
(require ffi/unsafe)
(require glfw3)


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
      (let ([win-width-ptr (malloc _int)] [win-height-ptr (malloc _int)])
        (glfwGetWindowSize win-width win-height)
        (define-values (win-width win-height) (values (ptr-ref win-width-ptr _int) (ptr-ref win-height-ptr _int)))
        (make-VkExtent2D (max (VkExtent2D-width (VkSurfaceCapabilitiesKHR-minImageExtent surface-capabilities))
                              (min (VkExtent2D-width (VkSurfaceCapabilitiesKHR-maxImageExtent surface-capabilities))
                                   (cast win-width _int _uint32)))
                         (max (VkExtent2D-height (VkSurfaceCapabilitiesKHR-minImageExtent surface-capabilities))
                              (min (VkExtent2D-height (VkSurfaceCapabilitiesKHR-maxImageExtent surface-capabilities))
                                   (cast win-height _int _uint32)))))))



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



; Crea un swapchain
(define (create-swapchain physical-device device surface window graphics-index present-index)

  (define format (choose-format physical-device surface))
  (define present-mode (choose-present-mode physical-device surface))
  (define extent (choose-extent physical-device surface))
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
                                                        VK_NULL_HANDLE))

  (define swapchain-ptr (malloc _VkSwapchainKHR))
  (define swapchain-result (vkCreateSwapchainKHR device swapchain-info #f swapchain-ptr))
  (when (not (equal? swapchain-result VK_SUCCESS))
    (error 'create-swapchain "Error al crear el swapchain."))

  (ptr-ref swapchain-ptr _VkSwapchainKHR))



; Destruye un swapchain
(define (destroy-swapchain device swapchain)

  (vkDestroySwapchainKHR device swapchain #f))



; Devuelve las imagenes de un swapchain
(define (get-swapchain-images device swapchain)

  (define image-count-ptr (malloc _uint32))
  (vkGetSwapchainImagesKHR device swapchain image-count-ptr #f)
  (define image-count (ptr-ref image-count-ptr _uint32))
  (define images-ptr (malloc _VkImage image-count))
  (vkGetSwapchainImagesKHR device swapchain image-count-ptr images-ptr)

  (cblock->list images-ptr _VkImage image-count))