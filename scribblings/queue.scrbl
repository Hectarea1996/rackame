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


@defform[(rkm-lambda-submit (args ...) [device rkm-device?] expr-or-submit ...)
         #:grammar
         [(expr-or-submit (code:line)
                          expr
                          (rkm-queue-submit [queue rkm-queue?] [fence rkm-fence?] submit-info ...))
          (submit-info    (code:line)
                          (rkm-do-submit-info [wait-sems (listof rkm-semaphore?)] [wait-stages (listof VkPipelineStageFlags)] [signal-sems (listof rkm-semaphore?)] 
                                              [pool rkm-command-pool?] [reset-pool rkm-command-pool?] command-buffer ...))
          (command-buffer (rkm-do-command-buffer expr ...))]]{

    Crea un lambda que ejecuta cada @racket[expr] en @racket[expr-or-submit] y realiza un submit para cada
    @racket[rkm-queue-submit] encontrado. En un @racket[rkm-queue-submit] especificamos primero la @racket[rkm-queue?] sobre
    la que se realiza el submit y un @racket[rkm-fence?]. Luego debemos crear los submit infos usando @racket[rkm-do-submit-info].
    Todas las operaciones que se hagan entre submit infos se realizan de forma asíncrona, por lo que tenemos que usar @racket[wait-sems] 
    y @racket[signal-sems] para controlar el orden de ejecución. Los @racket[wait-stages] permiten controla cuando deberían usarse los
    @racket[wait-sems]. Tras esto debemos especificar dos @racket[rkm-command-pool], donde el segundo debe permitir que los command buffers
    que se creen a partir de él puedan ser reseteados. Tras esto crearemos los command buffer usando @racket[rkm-do-command-buffer]. Dentro
    escribiremos los comandos que se deben grabar en el command buffer.

    El lambda resultante recibe los parámetros especificados por @racket[(args ...)] que pueden ser usados en cualquier momento.

}