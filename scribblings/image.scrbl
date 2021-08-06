#lang scribble/manual
@(require (for-label racket
                     rackame))


@title{Images}


@defstruct[rkm-image ([vk-device VkDevice] [vk-image VkImage] [vk-memory VkDeviceMemory])]{
    Representa una imagen 2D.
}


@defproc[(rkm-create-image [physical-device rkm-physical-device?] [device rkm-device?] 
                           [width exact-nonnegative-integer?] [height exact-nonnegative-integer?]
                           [format VkFormat] [usage VkImageUsageFlags])
         rkm-image?]{
    Crea una imagen 2D con optimal tiling y con la memoria reservada en el dispositivo. Los valores
    @racket[width] y @racket[height] indican las dimensiones de la imagen. El formato de la imagen se 
    especifica con @racket[format]. Por último, indicmos para qué usaremos la imagen con el valor @racket[usage].
}