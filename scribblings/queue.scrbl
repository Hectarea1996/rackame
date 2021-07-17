#lang scribble/manual
@(require (for-label racket
                     rackame
                     vulkan/unsafe))


@title{Colas}


@defstruct[rkm-queue ([vk-queue VkQueue])]{
    Representa una cola de buffers de comandos.
}


@defproc[(rkm-get-device-queues [device rkm-device?] [queue-family rkm-queue-family?])
         (listof rkm-queue?)]{
    Devuelve las colas de un dispositivo pertenecientes a una familia de colas.
}


@defproc[(rkm-queue-submit [queue rkm-queue?] [submit-infos (listof VkSubmitInfo)]
                           [fence rkm-fence?])
         void?]{
    Entrega a la cola un conjunto de semáforos y comandos situados en @racket[submit-infos].
    El parámetro @racket[fence] debe estar en el estado unsignaled. Cuando todos los comandos 
    terminan, el estado de @racket[fence] pasa a signaled.
}