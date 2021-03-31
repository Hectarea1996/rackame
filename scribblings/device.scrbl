#lang scribble/manual
@(require (for-label racket
                     rackame
                     vulkan/unsafe))


@title{Dispositivo}



@defstruct[rkm-device ([vk-phisical-device VkPhysicalDevice] [vk-device VkDevice] [graphics-index integer?]
                       [transfer-index integer?] [compute-index integer?] [present-index integer?]
                       [graphics-queue integer?] [transfer-queue integer?] [compute-queue integer?]
                       [present-queue integer?])]{
    Representa un dispositivo del computador.
}


@defproc[(rkm-create-device [instance rkm-instance?] [surface rkm-surface?])
         rkm-device?]{
    Selecciona un dispositivo gpu del computador.
}

@defproc[(rkm-destroy-device [device rkm-device?])
         void?]{
    Selecciona un dispositivo gpu del computador.
}