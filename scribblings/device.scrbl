#lang scribble/manual
@(require (for-label racket
                     rackame
                     vulkan/unsafe))


@title{Dispositivo}


@defproc[(rkm-create-device [instance rkm-instance?] [surface rkm-surface?])
         rkm-device?]{
    Selecciona un dispositivo gpu del computador.
}

@defproc[(rkm-destroy-device [device rkm-device?])
         void?]{
    Selecciona un dispositivo gpu del computador.
}