#lang scribble/manual
@(require (for-label racket
                     rackame))


@title{Fence}



@defstruct[rkm-fence ([vk-device VkDevice] [vk-fence VkFence])]{
    Representa objeto de tipo VkFence.
}


@defproc[(rkm-create-fence [device rkm-device?])
         rkm-fence?]{
    Crea un objeto de tipo VkFence.
}

@defproc[(rkm-reset-fence [fence VkFence])
         void?]{
    Resetea un fence al estado unsignaled.
}

@defproc[(rkm-reset-fences [fences (listof VkFence)])
         void?]{
    Resetea una lista de fences al estado unsignaled.
}

@defproc[(rkm-wait-for-fence [fence VkFence] [#:timeout timeout exact-nonnegative-integer? UINT64_MAX])
         void?]{
    Realiza una operación de espera hasta que el estado del fence pase a ser signaled.
    La espera también acaba cuando @racket[timeout] expira (medido en nanosegundos).
}

@defproc[(rkm-wait-for-fences [fences (listof VkFence)] [#:waitAll waitAll boolean? #t] [#:timeout timeout exact-nonnegative-integer? UINT64_MAX])
         void?]{
    Realiza una operación de espera.
    Si @racket[waitAll] vale @racket[#t], la espera finaliza cuando todos los fence pasen
    al estado signaled.
    Si @racket[waitAll] vale @racket[#f], la espera finaliza cuando uno de los fences pase al
    estado signaled.
    La espera también acaba cuando @racket[timeout] expira (medido en nanosegundos).
}