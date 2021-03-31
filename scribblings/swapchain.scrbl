#lang scribble/manual
@(require (for-label racket
                     rackame
                     (except-in ffi/unsafe ->)))


@title{Swapchain}


@defstruct[rkm-swapchain ([device rkm-device?] [vk-swapchain VkSwapchainKHR] [format VkFormat]
                      [extent VkExtent2D] [image-count integer?] [images (listof VkImage)]
                      [image-views (listof VkImageView)])]{
    Respresenta un swapchain.
}


@defproc[(rkm-create-swapchain [device rkm-device?] [window rkm-window?])
         rkm-swapchain?]{
    Crea un swapchain.
}


@defproc[(rkm-destroy-swapchain [swapchain rkm-swapchain?])
         void?]{
    Destruye un swapchain.
}