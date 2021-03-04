#lang racket/base


(require vulkan/unsafe)
(require ffi/unsafe)


(provide create-command-pool
         destroy-command-pool)



; Crea un command pool
(define (create-command-pool device index-family)

  (define command-pool-info (make-VkCommandPoolCreateInfo VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
                                                          #f
                                                          0
                                                          index-family))

  (define command-pool-ptr (malloc _VkCommandPool))
  (define command-pool-result (vkCreateCommandPool device command-pool-info #f command-pool-ptr))
  (when (not (equal? command-pool-result VK_SUCCESS))
      (error 'create-command-pool "Error al crear el command pool."))

  (ptr-ref command-pool-ptr _VkCommandPool))



; Destruye un command pool
(define (destroy-command-pool device command-pool)

  (vkDestroyCommandPool device command-pool #f))