#lang scribble/manual
@(require (for-label racket
                     rackame))


@title{Command buffer}


@defstruct[rkm-command-buffer ([vk-device VkDevice] [vk-command-pool VkCommandPool] [cv-command-buffer cvar?])]{
    Representa un command buffer.
}


@defproc[(rkm-create-command-buffer [device rkm-device?] [family-symbol symbol?])
          rkm-command-buffer?]{
    Crea un command buffer para la familia de colas representada por @racket[family-symbol].

    El valor @racket[family-symbol] puede ser:
    @itemlist[
        @item{ @racket['graphics] : Colas de tipo graphic. }
        @item{ @racket['transfer] : Colas de tipo transfer. }
        @item{ @racket['compute] : Colas de tipo compute. }
        @item{ @racket['present] : Colas de tipo present. }
    ]
}

@defproc[(rkm-begin-command-buffer [command-buffer rkm-command-buffer?] [usage-flags VkCommandBufferUsageFlags])
         void?]{
    Inicia la grabacion de comandos en un command buffer.            
}

@defproc[(rkm-end-command-buffer [command-buffer rkm-command-buffer?])
         void?]{
    Termina la grabacion de comandos en un command buffer.   
}

@defform[(rkm-do-command-buffer device family-symbol bodies ...)
         #:contracts ([device rkm-device?] [family-symbol symbol?])]{
    Crea un command buffer y graba los comandos situados en @racket[bodies ...].
}

@defform[(rkm-do-command-buffer/proc (args ...) device family-symbol bodies ...)
         #:contracts ([device rkm-device?] [family-symbol symbol?])]{
    Crea un command buffer y una función que graba los comandos situados en @racket[bodies ...].
    La función puede usarse varias veces.
}