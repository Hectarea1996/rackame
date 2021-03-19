#lang racket/base


(require vulkan/unsafe
         ffi/unsafe
         ffi/cvector)


; Devuelve una lista con un numero count de buffers de comandos primarios.
(define (allocate-primary-command-buffer device command-pool count)

  (define allocate-info (make-VkCommandBufferAllocateInfo VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
                                                          #f
                                                          command-pool
                                                          VK_COMMAND_BUFFER_LEVEL_PRIMARY
                                                          count))

  (define command-buffers (make-cvector _VkCommandBuffer count))
  (define allocate-result (vkAllocateCommandBuffers device allocate-info (cvector-ptr command-buffers)))
  (cvector->list command-buffers))



;REVISAR, free-command-buffer deberia recibir el mismo puntero que devuelve allocate-primary-command-buffer

; Libera la memoria de los buffers de comandos 
(define (free-command-buffer device command-pool command-buffers)

  (vkFreeCommandBuffers device command-pool (length command-buffers) (cvector-ptr (list->cvector command-buffers _VkCommandBuffer))))



; Inicia la grabacion de comandos en un buffer de comandos
(define (begin-command-buffer command-buffer usage-flags)

  (define begin-info (make-VkCommandBufferBeginInfo VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
                                                    #f
                                                    usage-flags
                                                    #f))

  (vkBeginCommandBuffer command-buffer begin-info))



; Termina la grabacion de comandos en un buffer de comandos
(define (end-command-buffer command-buffer)

  (vkEndCommandBuffer command-buffer))