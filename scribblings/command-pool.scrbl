#lang scribble/manual
@(require (for-label racket
                     rackame))


@title{Command pool}


@defstruct[rkm-command-pool ([vk-command-pool VkCommandPool] [vk-device VkDevice])]{
    Estructura que representa un objeto de tipo VkCommandPool.
}


@defproc[(rkm-create-command-pool [device rkm-device?] [family-queue rkm-queue-family?] [reset-buffers boolean #t])
         rkm-command-pool?]{

    Crea un command pool a partir de un dispositivo y una familia de colas. Si @racket[reset-buffers] vale #t, los
    command buffers que se creen a partir de este command pool tendrán permitido resetearse.
}