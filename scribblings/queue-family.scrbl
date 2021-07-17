#lang scribble/manual

@(require (for-label racket
                     rackame))


@title{Familia de colas}


@defstruct[rkm-queue-family ([index nonnegative-exact-integer?])]{
    Representa a una familia de colas.
}


@defproc[(rkm-get-family-queue [physical-device rkm-physical-device?] 
                               [#:queue-flags queue-flags VkQueueFlags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                                                                    VK_QUEUE_TRANSFER_BIT
                                                                                    VK_QUEUE_COMPUTE_BIT)]
                               [#:surface surface VkSurfaceKHR #f]
                               [#:exclusive-flags exclusive-flags boolean #f]
                               [#:families-out families-out (listof rkm-queue-family?) '()])
                               rkm-queue-family?]{

    Devuelve la primera familia de colas que cumplen ciertos requisitos. Los requisitos se establecen mediante
    @racket[queue-flags] y @racket[surface]:
    @itemlist[
        @item{ @racket[queue-flags]: Sirve para indicar el tipo de familia de colas que deseamos. Si este valor es @racket[0],
               cualquier tipo de familia será válido. }
        @item{ @racket[surface]: Sirve para indicar que la familia tiene soporte de presentación sobre @racket[surface].
               Si este valor es @racket[#f], esta comprobación no se realiza. }
    ]
    Además, pasando @racket[#t] al parámetro @racket[exclusive-flags] indicaremos que la familia tiene que tener únicamente capacidad
    para realizar las operaciones indicadas en @racket[queue-flags] y el @racket[surface].
    Por último, @racket[families-out] permite descartar las @racket[rkm-queue-family?] que contiene.
    En particular, si @racket[queue-flags] vale @racket[0], @racket[surface] vale @racket[#f] y @racket[families-out] es @racket['()] 
    se retornará la primera familia de colas que se encuentre.
}


@defproc[(rkm-get-family-queues [physical-device rkm-physical-device?] 
                                [#:queue-flags queue-flags VkQueueFlags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                                                                     VK_QUEUE_TRANSFER_BIT
                                                                                     VK_QUEUE_COMPUTE_BIT)]
                                [#:surface surface VkSurfaceKHR #f]
                                [#:exclusive-flags exclusive-flags boolean #f]
                                [#:families-out families-out (listof rkm-queue-family?) '()])
                                (listof rkm-queue-family?)]{

    Devuelve las familias de colas que cumplen ciertos requisitos. Los requisitos se establecen mediante
    @racket[queue-flags] y @racket[surface]:
    @itemlist[
        @item{ @racket[queue-flags]: Sirve para indicar el tipo de familias de colas que deseamos. Si este valor es @racket[0],
               cualquier tipo de familia será válido. }
        @item{ @racket[surface]: Sirve para indicar que una familia tiene soporte de presentación sobre @racket[surface].
               Si este valor es @racket[#f], esta comprobación no se realiza. }
    ]
    Además, pasando @racket[#t] al parámetro @racket[exclusive-flags] indicaremos que cada familia tiene que tener únicamente capacidad
    para realizar las operaciones indicadas en @racket[queue-flags] y el @racket[surface].
    Por último, @racket[families-out] permite descartar las @racket[rkm-queue-family?] que contiene.
    En particular, si @racket[queue-flags] vale @racket[0], @racket[surface] vale @racket[#f] y @racket[families-out] es @racket['()], se retornará una lista
    con todas las familias de colas.
}


