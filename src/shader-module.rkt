#lang racket/base

(require racket/port)
(require vulkan/unsafe)
(require ffi/unsafe)


(provide create-shader-module
         destroy-shader-module)


; Crea un modulo shader
(define (create-shader-module device spv-file)

  (define code (port->bytes (open-input-file spv-file)))

  (define shader-module-info (make-VkShaderModuleCreateInfo VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
                                                            #f
                                                            0
                                                            (bytes-length code)
                                                            code))

  (define shader-module-ptr (malloc _VkShaderModule))
  (define module-result (vkCreateShaderModule device shader-module-info #f shader-module-ptr))

  (when (not (equal? module-result VK_SUCCESS))
    (error 'create-shader-module "Error al crea el modulo shader."))

  (ptr-ref shader-module-ptr _VkShaderModule))



; Destruye un modulo shader
(define (destroy-shader-module device shader-module)

  (vkDestroyShaderModule device shader-module #f))