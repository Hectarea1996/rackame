#lang scribble/manual
@(require (for-label racket
                     rackame))


@title{Command buffer}


@defstruct[rkm-command-buffer ([vk-device VkDevice] [vk-command-pool VkCommandPool] [cv-command-buffer cvar?])]{
    Representa un command buffer.
}


@defproc[(rkm-create-command-buffer [device rkm-device?] [command-pool rkm-command-pool?]
                                    [secondary-buffer boolean #f])
          rkm-command-buffer?]{
    Crea un command buffer a partir de un command pool.
    Si @racket[secondary-buffer] vale @racket[#t], el buffer será secundario. En otro caso será primario.
}

@defproc[(rkm-reset-command-buffer [command-buffer rkm-command-buffer?])
         void?]{
    Resetea un command buffer.          
}

@defproc[(rkm-begin-command-buffer [command-buffer rkm-command-buffer?] [usage-flags VkCommandBufferUsageFlags])
         void?]{
    Inicia la grabacion de comandos en un command buffer.            
}

@defproc[(rkm-end-command-buffer [command-buffer rkm-command-buffer?])
         void?]{
    Termina la grabacion de comandos en un command buffer.   
}

@defform[(rkm-do-command-buffer device command-pool bodies ...)
         #:contracts ([device rkm-device?] [command-pool rkm-command-pool?])]{
    Crea un @racket[rkm-command-buffer?] y graba los comandos situados en @racket[bodies ...].
}

@defform[(rkm-do-command-buffer/proc (args ...) device command-pool bodies ...)
         #:contracts ([device rkm-device?] [command-pool rkm-command-pool?])]{
    Crea un @racket[pair?] con un @racket[rkm-command-buffer?] y una función.
    La función resetea el command buffer y graba todos los comandos situados en @racket[bodies ...].
}