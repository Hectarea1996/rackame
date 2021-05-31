#lang scribble/manual
@(require (for-label racket
                     rackame))


@title{Semáforo}



@defstruct[rkm-semaphore ([vk-device VkDevice] [vk-semaphore VkSemaphore])]{
    Representa a un semaforo.
}


@defproc[(rkm-create-semaphore [device rkm-device?])
         rkm-semaphore?]{
    Crea un semaforo.
}