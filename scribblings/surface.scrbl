#lang scribble/manual
@(require (for-label racket
                     rackame
                     (except-in ffi/unsafe ->)))


@title{Surface}


@defproc[(rkm-create-surface [instance rkm-instance?] [window cpointer?])
         rkm-surface?]{
        Crea una surface.
}

@defproc[(rkm-surface? [v any])
         boolean?]{
        Devuelve #t si @racket[v] es una surface. Retorna #f en otro caso.
}

@defproc[(rkm-surface-vk-surface [surface rkm-surface?])
         VkSurfaceKHR]{
        Devuelve la surface de vulkan.
}

@defproc[(rkm-destroy-surface [surface rkm-surface?])
         void?]{
        Destruye una surface.
}