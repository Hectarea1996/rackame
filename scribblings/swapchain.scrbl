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


@defproc[(rkm-create-swapchain [physical-device rkm-physical-device?] [device rkm-device?] [surface rkm-surface?]
                               [present-families (listof rkm-queue-families?)] [width nonnegative-integer?] [height nonnegative-integer?])
         rkm-swapchain?]{
    Crea un swapchain que podrá trabajar sobre las familias de colas indicadas en @racket[present-families]. Las imágenes tendrán
    un tamaño de @racket[width]x@racket[height].
}


@defproc[(rkm-acquire-next-image [device rkm-device?] [swapchain rkm-swapchain?] [#:semaphore semaphore rkm-semaphore? #f]
                                 [#:fence fence rkm-fence? #f])
         exact-nonnegative-integer?]{
    Devuelve la siguiente imagen disponible del swapchain. En caso de que no haya ninguna disponible la función
    se bloquea hasta que haya alguna. Los parámetros @racket[semaphore] y @racket[fence] pasarán al estado signal
    cuando la función finalice.
}


@defproc[(rkm-present-swapchain [queue rkm-queue?] [swapchain rkm-swapchain?] [image-index nonnegative-integer?] 
                                [#:semaphore semaphore rkm-semaphore? #f])
         void?]{
    Presenta una imagen del swapchain por pantalla. El semáforo realiza una operación wait para asegurar que la operación
    se realiza después que otras operaciones. La imagen a usar es la que cuyo índice dentro del swapchain es @racket[image-index].
}