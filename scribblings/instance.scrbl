#lang scribble/manual
@(require (for-label racket
                     rackame
                     vulkan/unsafe))

        
@title{Instancia}


@defproc[(rkm-create-instance [validation boolean?])
         rkm-instance?]{
    Crea una instancia de vulkan.

    Si @racket[validation] no es @racket[#f] se activará la capa de validación de
    vulkan.
}

@defproc[(rkm-instance? [v any])
         boolean?]{
    Comprueba si el valor @racket[v] es una instancia. En ese caso se devuelve #t. En otro
    caso se retorna #f.
}

@defproc[(rkm-instance-layers [instance rkm-instance?])
         (listof bytes?)]{
    Devuelve las capas activadas por la instancia.
}

@defproc[(rkm-instance-extensions [instance rkm-instance?])
         (listof bytes?)]{
    Devuelve las extensiones activadas por la instancia.
}

@defproc[(rkm-instance-vk-instance [instance rkm-instance?])
         VkInstance]{
    Devuelve la instancia de vulkan.
}

@defproc[(rkm-destroy-instance [instance rkm-instance?])
         void?]{
    Destruye una instancia de vulkan.
}