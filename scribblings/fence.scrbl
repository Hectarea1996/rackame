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