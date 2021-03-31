#lang scribble/manual
@(require (for-label racket
                     rackame
                     vulkan/unsafe))


@title{Dispositivo}



@defstruct[rkm-device ([vk-physical-device VkPhysicalDevice] [vk-device VkDevice] [graphics-index integer?]
                       [transfer-index integer?] [compute-index integer?] [present-index integer?]
                       [graphics-queue VkQueue] [transfer-queue VkQueue] [compute-queue VkQueue]
                       [present-queue VkQueue] [graphics-pool VkCommandPool] [transfer-pool VkCommandPool]
                       [compute-pool VkCommandPool] [present-pool VkCommandPool])]{
    Representa un dispositivo del computador.
}


@defproc[(rkm-create-device [instance rkm-instance?] [surface rkm-surface?])
         rkm-device?]{
    Selecciona un dispositivo gpu del computador y crea una interfaz para su manejo.
}

@defproc[(rkm-destroy-device [device rkm-device?])
         void?]{
    Elimina la interfaz de un dispositivo.
}