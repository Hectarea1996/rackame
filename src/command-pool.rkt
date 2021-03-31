#lang racket/base


(require "cvar.rkt"
         vulkan/unsafe)


(provide create-command-pool
         destroy-command-pool)



; Crea un command pool
(define (create-command-pool vk-device index-family)

  (define command-pool-info (make-VkCommandPoolCreateInfo VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
                                                          #f
                                                          0
                                                          index-family))

  (define command-pool (make-cvar _VkCommandPool))
  (define command-pool-result (vkCreateCommandPool vk-device command-pool-info #f (cvar-ptr command-pool)))
  (check-vkResult command-pool-result 'create-command-pool)

  (cvar-ref command-pool))



; Destruye un command pool
(define (destroy-command-pool vk-device command-pool)

  (vkDestroyCommandPool vk-device command-pool #f))