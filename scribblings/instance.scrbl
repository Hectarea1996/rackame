#lang scribble/manual
@(require (for-label racket
                     rackame
                     vulkan/unsafe))

        
@title{Instancia}


@defstruct[rkm-instance ([vk-instance VkInstance] [layers (Listof bytes?)] [extensions (Listof bytes?)])]{
    Estructura que representa una instancia de vulkan.

    @racket[layers] es la lista de layers activadas.
    @racket[extensions] es la lista de extensiones activadas.
}


@defproc[(rkm-create-instance [validation boolean?])
         rkm-instance?]{
    Crea una instancia de vulkan.

    Si @racket[validation] no es @racket[#f] se activará la capa de validación de
    vulkan.
}


@defproc[(rkm-destroy-instance [instance rkm-instance?])
         void?]{
    Destruye una instancia de vulkan.
}