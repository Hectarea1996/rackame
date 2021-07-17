#lang scribble/manual
@(require (for-label racket
                     rackame
                     vulkan/unsafe))


@title{Dispositivo}



@defstruct[rkm-device ([vk-device VkDevice])]{
    Representa un dispositivo del computador.
}


@defproc[(rkm-create-device [physical-device rkm-physical-device?] [device-features rkm-physical-device-features?]
                            [queue-families (listof rkm-queue-family?)])
         rkm-device?]{
    Crea un dispositivo lógico a partir del dispositivo físico @racket[physical-device] que contendrá las colas 
    indicadas por cada familia de colas en @racket[queue-families].
    Además, se activarán las extensiones indicadas por @racket[device-features].
}